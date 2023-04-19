locals {

  ecs_cluster_name = var.ecs_cluster_name == "default" ? (
    "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-cl-${data.aws_region.current.name}-${var.labels.env}"
  ) : var.ecs_cluster_name

  ecs_service_name = var.ecs_service_name == "default" ? (
    "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-svc-${var.labels.env}"
  ) : var.ecs_service_name

  ecs_cluster_arn = var.ecs_cluster_new == true ? join("", aws_ecs_cluster.ecs_cluster.*.arn) : join("", data.aws_ecs_cluster.ecs_cluster.*.arn)

}

data "aws_region" "current" {}

data "aws_ecs_cluster" "ecs_cluster" {
  count        = var.ecs_cluster_new == true ? 0 : 1
  cluster_name = local.ecs_cluster_name
}

resource "aws_ecs_cluster" "ecs_cluster" {
  count = var.ecs_cluster_new == true ? 1 : 0
  name  = local.ecs_cluster_name
  setting {
    name  = "containerInsights"
    value = var.aws_ecs_cluster_containerInsights
  }
  tags = merge(
    var.labels,
    var.tags,
    { Name = local.ecs_cluster_name }
  )
}


resource "aws_ecs_service" "ecs_service" {
  depends_on = [
    aws_ecs_cluster.ecs_cluster,
  ]
  name            = local.ecs_service_name
  cluster         = local.ecs_cluster_arn
  task_definition = var.task_definition_arn
  desired_count   = var.task_desired_count
  launch_type     = var.launch_type

  network_configuration {
    subnets          = var.task_subnet_ids
    security_groups  = var.task_security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.ecs_load_balancers
    content {
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
      elb_name         = lookup(load_balancer.value, "elb_name", null)
      target_group_arn = lookup(load_balancer.value, "target_group_arn", null)
    }
  }
  propagate_tags = "SERVICE"
}


