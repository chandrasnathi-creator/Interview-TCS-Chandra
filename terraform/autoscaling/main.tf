data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

# IAM Role and Policy for SSM and CloudWatch Agent
resource "aws_iam_role" "instance_role" {
  name = "${var.asg_name}-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.asg_name}-instance-profile"
  role = aws_iam_role.instance_role.name
}

locals {
  user_data = templatefile("${path.module}/user_data.sh", {
    asg_name = var.asg_name
  })
}

# Launch Template for the Auto Scaling group
resource "aws_launch_template" "main" {
  name_prefix   = "${var.asg_name}-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.instance_profile.arn
  }

  user_data = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.asg_name
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                      = var.asg_name
  vpc_zone_identifier       = var.vpc_private_subnet_ids
  desired_capacity          = 2
  max_size                  = 5
  min_size                  = 1
  max_instance_lifetime     = 2592000 
  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [var.lb_target_group_arn]

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.asg_name
    propagate_at_launch = true
  }
}
