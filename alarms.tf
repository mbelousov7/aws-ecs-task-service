locals {

  alarm_count = var.alarm_enable == true ? 1 : 0
  names = {
    cpu_utilization    = "${local.ecs_service_name}-cpu-utilization-${var.labels.env}"
    memory_utilization = "${local.ecs_service_name}-memory-utilization-${var.labels.env}"
    task_count         = "${local.ecs_service_name}-task-count-${var.labels.env}"
  }
  thresholds = {
    cpu_utilization    = min(max(var.cpu_utilization_threshold, 0), 100)
    memory_utilization = min(max(var.memory_utilization_threshold, 0), 100)
    task_count         = max(min(var.task_count_threshold, 0), 1)
  }

}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count               = local.alarm_count
  alarm_name          = local.names["cpu_utilization"]
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  evaluation_periods  = "4"
  treat_missing_data  = "missing"
  statistic           = "Average"
  threshold           = local.thresholds["cpu_utilization"]
  alarm_description   = "( ${upper(var.labels.env)} | ${upper(var.labels.stack)} | CPU ) Average Fargate task CPU utilization over last 20 minutes too high ~>${local.thresholds["cpu_utilization"]}% ${var.alarm_config}"

  alarm_actions = [var.alarm_topic_arn]
  ok_actions    = [var.alarm_topic_arn]
  dimensions = {
    ClusterName = local.ecs_cluster_name
    ServiceName = local.ecs_service_name
  }
  tags = merge(
    var.labels,
    var.tags,
    { Name = local.ecs_service_name }
  )
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  count               = local.alarm_count
  alarm_name          = local.names["memory_utilization"]
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  evaluation_periods  = "4"
  treat_missing_data  = "missing"
  statistic           = "Average"
  threshold           = local.thresholds["memory_utilization"]
  alarm_description   = "( ${upper(var.labels.env)} | ${upper(var.labels.stack)} | Memory ) Average Fargate task Memory utilization over last 20 minutes too high ~>${local.thresholds["memory_utilization"]}% ${var.alarm_config}"

  alarm_actions = [var.alarm_topic_arn]
  ok_actions    = [var.alarm_topic_arn]
  dimensions = {
    ClusterName = local.ecs_cluster_name
    ServiceName = local.ecs_service_name
  }
  tags = merge(
    var.labels,
    var.tags,
    { Name = local.ecs_service_name }
  )
}



resource "aws_cloudwatch_metric_alarm" "task_count" {
  count               = local.alarm_count
  alarm_name          = local.names["task_count"]
  comparison_operator = "LessThanThreshold"
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = "300"
  evaluation_periods  = "4"
  treat_missing_data  = "breaching"
  statistic           = "Average"
  threshold           = local.thresholds["task_count"]
  alarm_description   = "( ${upper(var.labels.env)} | ${upper(var.labels.stack)} | Task ) Average Fargate task count over last 20 minutes too low ~>${local.thresholds["task_count"]}% ${var.alarm_config}"

  alarm_actions = [var.alarm_topic_arn]
  ok_actions    = [var.alarm_topic_arn]
  dimensions = {
    ClusterName = local.ecs_cluster_name
    ServiceName = local.ecs_service_name
  }
  tags = merge(
    var.labels,
    var.tags,
    { Name = local.ecs_service_name }
  )
}


