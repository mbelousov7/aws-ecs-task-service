resource "aws_cloudwatch_event_rule" "task_stopped_rule" {
  count       = var.task_stopped_rule == true ? 1 : 0
  name        = "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-task-stopped-${var.labels.env}"
  description = "Trigger when the Fargate task has stopped"

  event_pattern = jsonencode({
    "source"      = ["aws.ecs"]
    "detail-type" = ["ECS Task State Change"]
    "detail" = {
      "clusterArn"    = [local.ecs_cluster_arn]
      "lastStatus"    = ["STOPPED"]
      "stoppedReason" = ["Essential container in task exited"]
    }
  })
}