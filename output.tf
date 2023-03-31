output "task_stopped_event_rule_name" {
  value       = join("", aws_cloudwatch_event_rule.task_stopped_rule.*.name)
  description = "service task stopped event rule name"
}

output "aws_ecs_cluster_name" {
  value       = local.ecs_cluster_name
  description = "ecs cluster name"
}

output "aws_ecs_cluster_arn" {
  value       = local.ecs_cluster_arn
  description = "ecs cluster arn"
}