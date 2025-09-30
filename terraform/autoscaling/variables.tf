variable "asg_name" {
  description = "The name for the Auto Scaling group."
  type        = string
}

variable "vpc_private_subnet_ids" {
  description = "A list of private subnet IDs for the EC2 instances."
  type        = list(string)
}

variable "lb_target_group_arn" {
  description = "The ARN of the Load Balancer target group to associate with the ASG."
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type to use."
  type        = string
  default     = "t3.micro"
}