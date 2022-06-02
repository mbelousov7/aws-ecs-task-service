locals {

  ecs_cluster_name = var.ecs_cluster_name == "default" ? (
    "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-cl-${var.labels.env}"
  ) : var.ecs_cluster_name

  ecs_service_name = var.ecs_service_name == "default" ? (
    "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-svc-${var.labels.env}"
  ) : var.ecs_service_name

}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.ecs_cluster_name
  tags = merge(
    var.labels,
    var.tags,
    { Name = local.ecs_cluster_name }
  )
}

resource "aws_ecs_service" "ecs_service" {
  name            = local.ecs_service_name
  cluster         = aws_ecs_cluster.ecs_cluster.arn
  task_definition = var.task_definition_arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.task_subnet_ids
    security_groups  = var.task_security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  propagate_tags = "SERVICE"
}


