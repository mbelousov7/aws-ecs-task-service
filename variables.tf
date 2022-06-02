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

variable "ecs_service_name" {
  type        = string
  description = <<-EOT
      optionally define a custom value for the aws_ecs_service.
      By default, it is defined as a construction from var.labels
    EOT
  default     = "default"
}

variable "ecs_cluster_name" {
  type        = string
  description = <<-EOT
      optionally define a custom value for the ecs cluster name and tag=Name parameter
      in aws_ecs_cluster. By default, it is defined as a construction from var.labels
    EOT
  default     = "default"
}


########################################  configs #######################################
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

variable "assign_public_ip" {
  type        = bool
  description = "Assign a public IP address to the ENI (Fargate launch type only). Valid values are `true` or `false`. Default `false`"
  default     = false
}

