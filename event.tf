resource "aws_cloudwatch_event_rule" "task_stopped_rule" {

  name        = "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-task-stopped-${var.labels.env}"
  description = "Trigger when the Fargate task has stopped"

  event_pattern = jsonencode({
    "source"      = ["aws.ecs"]
    "detail-type" = ["ECS Task State Change"]
    "detail" = {
      "clusterArn"    = [aws_ecs_cluster.ecs_cluster.arn]
      "lastStatus"    = ["STOPPED"]
      "stoppedReason" = ["Essential container in task exited"]
    }
  })
}