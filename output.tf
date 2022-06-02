output "task_stopped_event_rule_name" {
  value       = aws_cloudwatch_event_rule.task_stopped_rule.name
  description = "service task stopped event rule name"
}