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


  metrics_querys_cpu = [
    {
      metric_id        = "mm1"
      metric_name      = "CpuUtilized"
      metric_namespace = "ECS/ContainerInsights"
      metric_period    = "60"
      metric_stat      = "Average"
      metric_dimensions = {
        "ClusterName" : "${local.ecs_cluster_name}",
        "TaskDefinitionFamily" : "${local.ecs_service_name}"
      }
    },
    {
      metric_id        = "mm0"
      metric_name      = "CpuReserved"
      metric_namespace = "ECS/ContainerInsights"
      metric_period    = "60"
      metric_stat      = "Average"
      metric_dimensions = {
        "ClusterName" : "${local.ecs_cluster_name}",
        "TaskDefinitionFamily" : "${local.ecs_service_name}"
      }

    }
  ]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {

  count = local.alarm_count

  alarm_name          = local.names["cpu_utilization"]
  comparison_operator = "GreaterThanThreshold"
  alarm_description   = "( ${upper(var.labels.env)} | ${upper(var.labels.stack)} | CPU ) Average EC2 CPU utilization over last 20 minutes too high ~>${local.thresholds["cpu_utilization"]}% ${var.alarm_config}"
  threshold           = local.thresholds["cpu_utilization"]

  metric_query {
    id          = "expr1"
    expression  = "mm1/mm0"
    label       = "% of available memory"
    return_data = "true"
  }

  dynamic "metric_query" {
    for_each = local.metrics_querys_cpu
    content {
      id          = metric_query.value["metric_id"]
      return_data = "false"
      metric {
        metric_name = metric_query.value["metric_name"]
        namespace   = metric_query.value["metric_namespace"]
        period      = metric_query.value["metric_period"]
        stat        = metric_query.value["metric_stat"]
        dimensions  = merge(metric_query.value["metric_dimensions"])
      }
    }
  }

  evaluation_periods = "5"
  treat_missing_data = "missing"
  alarm_actions      = [var.alarm_topic_arn]
  ok_actions         = [var.alarm_topic_arn]

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
  evaluation_periods  = "2"
  treat_missing_data  = "breaching"
  statistic           = "Average"
  threshold           = local.thresholds["task_count"]
  alarm_description   = "( ${upper(var.labels.env)} | ${upper(var.labels.stack)} | Task ) Average Fargate task count over last 20 minutes too low ~>${local.thresholds["task_count"]}% ${var.alarm_config}"

  alarm_actions = [var.alarm_topic_arn]
  ok_actions    = [var.alarm_topic_arn]
  dimensions = {
    ClusterName          = local.ecs_cluster_name
    TaskDefinitionFamily = local.ecs_service_name
  }
  tags = merge(
    var.labels,
    var.tags,
    { Name = local.ecs_service_name }
  )
}