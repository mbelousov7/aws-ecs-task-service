locals {

  task_log_group_name = "/fargate/${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-log-group-${var.labels.env}"

  task_metric_namespace = "System/${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-log-metrics/${var.labels.env}"

  task_alarm_log_configs = local.alarm_count == 1 ? {
    for k, v in var.alarm_log_configs :
    k => merge(v, { metric_namespace = local.task_metric_namespace },
    )
  } : {}
}

resource "aws_cloudwatch_log_metric_filter" "errors" {
  for_each       = local.task_alarm_log_configs
  name           = each.value.metric_name
  pattern        = each.value.filter_pattern
  log_group_name = local.task_log_group_name

  metric_transformation {
    name          = each.value.metric_name
    namespace     = each.value.metric_namespace
    value         = each.value.metric_value
    default_value = each.value.metric_default_value
  }

  depends_on = [aws_ecs_service.ecs_service]
}

resource "aws_cloudwatch_metric_alarm" "default" {
  for_each            = local.task_alarm_log_configs
  alarm_name          = "${local.ecs_service_name}-${each.value.alarm_name}-${var.labels.env}"
  comparison_operator = each.value.alarm_comparison_operator
  evaluation_periods  = each.value.alarm_evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.metric_namespace
  period              = each.value.alarm_period
  statistic           = each.value.alarm_statistic
  treat_missing_data  = each.value.alarm_treat_missing_data
  threshold           = each.value.alarm_threshold
  alarm_description   = "( ${upper(var.labels.env)} | ${upper(var.labels.stack)} | Logs ) ${each.value.alarm_description} ${var.alarm_config}"
  alarm_actions       = [var.alarm_topic_arn]
  ok_actions          = [var.alarm_topic_arn]
  tags = merge(
    var.labels,
    var.tags,
    { Name = local.ecs_service_name }
  )

}
