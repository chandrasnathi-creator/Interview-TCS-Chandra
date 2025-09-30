output "autoscaling_group_name" {
  description = "The name of the Auto Scaling group"
  value       = aws_autoscaling_group.main.name
}

output "autoscaling_group_arn" {
  description = "The ARN of the Auto Scaling group"
  value       = aws_autoscaling_group.main.arn
}

output "launch_template_id" {
  description = "The ID of the launch template"
  value       = aws_launch_template.main.id
}

output "instance_profile_name" {
  description = "The name of the IAM instance profile"
  value       = aws_iam_instance_profile.instance_profile.name
}
