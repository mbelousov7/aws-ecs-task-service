#################################################  <ENV>.tfvars  #################################################
# in the examples for modules, variables are defined and set in the same file as the module definition.
# This is done to better understand the meaning of the variables.
# In a real environment, you should define variables in a variables.tf, the values of variables depending on the environment in the <ENV name>.tfvars

variable "ENV" {
  type        = string
  description = "defines the name of the environment(dev, prod, etc). Should be defined as env variable, for example export TF_VAR_ENV=dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

# in example using dev account
variable "account_number" {
  type    = string
  default = "12345678910"
}

variable "labels" {
  default = {
    prefix = "myproject"
    stack  = "stackName"
  }
}

variable "component" {
  default = "componentName"
}

variable "vpc_id" {
  default = "vpc-change-me-123123"
}

variable "subnet_ids" {
  default = ["subnet-1234567890"]
}

variable "security_group" {
  default = {
    ingress_rules = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        description = "Allow SSH access"
        cidr_blocks = ["192.168.0.0/24"]
      },
    ]
    egress_rules = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        description = "Allow All access"
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
}

variable "container_name" {
  default = "nginx"
}

variable "container_image" {
  default = "nginx:1.14.2"
}

variable "task_cpu" {
  default = 256
}

variable "task_memory" {
  default = 512
}

variable "task_role_policy_statements" {
  default = {}
}

variable "cloudteam_policy_names" {
  default = ["cloud-service-policy-global-deny-1", "cloud-service-policy-global-deny-2"]
}

# <ENV>.tfvars end
#################################################################################################################

#################################################  locals vars  #################################################
#if the value of a variable depends on the value of other variables, it should be defined in a locals block

locals {

  labels = merge(
    { env = var.ENV },
    { component = var.component },
    var.labels
  )

  cloudteam_policy_arns = formatlist("arn:aws:iam::${var.account_number}:policy/%s", var.cloudteam_policy_names)

}

#################################################  module config  #################################################
# In module parameters recommend use terraform variables, because:
# - values can be environment dependent
# - this ComponentName.tf file - is more for component logic description, not for values definition
# - it is better to store vars values in one or two places(<ENV>.tfvars file and variables.tf)

module "ecs_task_security_group" {
  source        = "git::https://github.com/mbelousov7/aws-security-group.git?ref=v1.0.0"
  vpc_id        = var.vpc_id
  ingress_rules = var.security_group.ingress_rules
  egress_rules  = var.security_group.egress_rules
  labels        = local.labels
}

module "ecs_task_definition" {
  source                      = "git::https://github.com/mbelousov7/aws-ecs-task-definition.git?ref=v1.0.0"
  aws_region                  = var.region
  container_name              = var.container_name
  container_image             = var.container_image
  task_cpu                    = var.task_cpu
  task_memory                 = var.task_memory
  task_role_policy_arns       = local.cloudteam_policy_arns
  task_role_policy_statements = var.task_role_policy_statements
  labels                      = local.labels
}

module "ecs_task_service" {
  source                  = "../.."
  task_definition_arn     = module.ecs_task_definition.task_definition_arn
  task_subnet_ids         = var.subnet_ids
  task_security_group_ids = [module.ecs_task_security_group.id]
  labels                  = local.labels
}

