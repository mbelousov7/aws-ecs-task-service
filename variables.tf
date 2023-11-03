######################################## names, labels, tags ########################################
variable "labels" {
  type = object({
    prefix    = string
    stack     = string
    component = string
    env       = string
  })
  description = "Minimum required map of labels(tags) for creating aws resources"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ecs_service_name" {
  type        = string
  description = <<-EOT
      optionally define a custom value for the aws_ecs_service.
      By default, it is defined as a construction from var.labels
    EOT
  default     = ""
}

variable "ecs_cluster_name" {
  type        = string
  description = <<-EOT
      optionally define a custom value for the ecs cluster name and tag=Name parameter
      in aws_ecs_cluster. By default, it is defined as a construction from var.labels
    EOT
  default     = ""
}

variable "ecs_cluster_new" {
  type        = bool
  description = <<-EOT
      optionally set to false, then no new ecs cluster will be created
    EOT
  default     = true
}

variable "ecs_cluster_arn" {
  type        = string
  description = <<-EOT
      provide value if ecs_cluster_new == false
    EOT
  default     = ""
}


variable "aws_ecs_cluster_containerInsights" {
  type        = string
  description = "option to enabled | disabled CloudWatch Container Insights for a cluster"
  default     = "enabled"
}

########################################  configs #######################################
variable "launch_type" {
  type        = string
  description = "The launch type on which to run your service. Valid values are `EC2` and `FARGATE`"
  default     = "FARGATE"
}


variable "task_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs used in Service `network_configuration`"
  default     = null
}

variable "task_definition_arn" {
  type        = string
  description = "Task definition arn"
}

variable "task_security_group_ids" {
  description = "Security group IDs to allow in Service `network_configuration`"
  type        = list(string)
  default     = []
}

variable "task_desired_count" {
  type        = number
  description = "Number of instances of the task definition to place and keep running."
  default     = 1
}

variable "assign_public_ip" {
  type        = bool
  description = "Assign a public IP address to the ENI (Fargate launch type only). Valid values are `true` or `false`. Default `false`"
  default     = false
}


variable "ecs_load_balancers" {
  /*
  type = list(object({
    container_name   = string
    container_port   = number
    elb_name         = string
    target_group_arn = string
  }))
*/
  type        = any
  description = "A list of load balancer config objects for the ECS service; see [ecs_service#load_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#load_balancer) docs"
  default     = []
}

variable "service_registries" {
  type        = list(any)
  description = <<-EOT
    Zero or one service discovery registries for the service.
    The currently supported service registry is Amazon Route 53 Auto Naming Service - `aws_service_discovery_service`;
    see `service_registries` docs https://www.terraform.io/docs/providers/aws/r/ecs_service.html#service_registries-1"
    Service registry is object with required key `registry_arn = string` and optional keys
      `port           = number`
      `container_name = string`
      `container_port = number`
    EOT

  default = []
}

variable "task_stopped_rule" {
  type        = bool
  description = "option to create aws_cloudwatch_event_rule which Trigger when the Fargate task has stopped"
  default     = false
}

variable "wait_for_steady_state" {
  type        = bool
  description = "Terraform will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing"
  default     = true
}

variable "deployment_maximum_percent" {
  default = 200
}

variable "deployment_minimum_healthy_percent" {
  default = 100
}


######################################## alarm configs #######################################

variable "alarm_enable" {
  type    = bool
  default = true
}

variable "alarm_topic_arn" {
  type    = string
  default = ""
}

variable "alarm_config" {
  type        = string
  default     = ""
  description = "add custom string into alarm descritptioon"
}

variable "cpu_utilization_threshold" {
  description = "The maximum percentage of CPU utilization."
  type        = number
  default     = 80
}

variable "memory_utilization_threshold" {
  description = "The maximum percentage of Memory utilization."
  type        = number
  default     = 80
}

variable "task_count_threshold" {
  description = "The minimum task count threshold"
  type        = number
  default     = 1
}

variable "alarm_log_configs" {
  /*
  type = map(object({
  }))
  */
  default = {
    logs-errors = {
      metric_name               = "ECSLogErrors"
      filter_pattern            = "\"ERROR\""
      metric_value              = "1"
      metric_default_value      = "0"
      alarm_name                = "log-errors"
      alarm_comparison_operator = "GreaterThanThreshold"
      alarm_evaluation_periods  = 1
      alarm_period              = 60
      alarm_statistic           = "Sum"
      alarm_treat_missing_data  = "notBreaching"
      alarm_threshold           = 0
      alarm_description         = "Erros in log files"
    }

  }

  description = "The cloudwatch metrics filters definitions"
}