Terraform module to create AWS ECS service task .

terrafrom config example:

```
module "ecs_task_security_group" {
  source        = "git::https://github.com/mbelousov7/aws-security-group.git?ref=main"
  vpc_id        = var.vpc_config.vpc_id
  ingress_rules = var.security_group.ingress_rules
  egress_rules  = var.security_group.egress_rules
  labels        = local.labels
}

module "ecs_task_definition" {
  source                      = "git::git::https://github.com/mbelousov7/aws-ecs-task-definition.git?ref=main"
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
  source = "../.."
  task_definition_arn      = module.ecs_task_definition.task_definition_arn
  task_subnet_ids         = var.vpc_config.subnet_ids
  task_security_group_ids = [module.ecs_task_security_group.id]
  labels                   = local.labels
}
```
more info see [examples/test](examples/test)


terraform run example
```
cd examples/test
terraform init
terraform plan
``` 

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.task_stopped_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_ecs_cluster.ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_cluster.ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Assign a public IP address to the ENI (Fargate launch type only). Valid values are `true` or `false`. Default `false` | `bool` | `false` | no |
| <a name="input_aws_ecs_cluster_containerInsights"></a> [aws\_ecs\_cluster\_containerInsights](#input\_aws\_ecs\_cluster\_containerInsights) | option to enabled \| disabled CloudWatch Container Insights for a cluster | `string` | `"enabled"` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Number of instances of the task definition to place and keep running. | `number` | `1` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | optionally define a custom value for the ecs cluster name and tag=Name parameter<br>in aws\_ecs\_cluster. By default, it is defined as a construction from var.labels | `string` | `"default"` | no |
| <a name="input_ecs_cluster_new"></a> [ecs\_cluster\_new](#input\_ecs\_cluster\_new) | optionally set to false, then no new ecs cluster will be created | `bool` | `true` | no |
| <a name="input_ecs_load_balancers"></a> [ecs\_load\_balancers](#input\_ecs\_load\_balancers) | A list of load balancer config objects for the ECS service; see [ecs\_service#load\_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#load_balancer) docs | `any` | `[]` | no |
| <a name="input_ecs_service_name"></a> [ecs\_service\_name](#input\_ecs\_service\_name) | optionally define a custom value for the aws\_ecs\_service.<br>By default, it is defined as a construction from var.labels | `string` | `"default"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Minimum required map of labels(tags) for creating aws resources | <pre>object({<br>    prefix    = string<br>    stack     = string<br>    component = string<br>    env       = string<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags | `map(string)` | `{}` | no |
| <a name="input_task_definition_arn"></a> [task\_definition\_arn](#input\_task\_definition\_arn) | Task definition arn | `string` | n/a | yes |
| <a name="input_task_security_group_ids"></a> [task\_security\_group\_ids](#input\_task\_security\_group\_ids) | Security group IDs to allow in Service `network_configuration` | `list(string)` | `[]` | no |
| <a name="input_task_stopped_rule"></a> [task\_stopped\_rule](#input\_task\_stopped\_rule) | option to create aws\_cloudwatch\_event\_rule which Trigger when the Fargate task has stopped | `bool` | `false` | no |
| <a name="input_task_subnet_ids"></a> [task\_subnet\_ids](#input\_task\_subnet\_ids) | Subnet IDs used in Service `network_configuration` | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_ecs_cluster_arn"></a> [aws\_ecs\_cluster\_arn](#output\_aws\_ecs\_cluster\_arn) | ecs cluster arn |
| <a name="output_aws_ecs_cluster_name"></a> [aws\_ecs\_cluster\_name](#output\_aws\_ecs\_cluster\_name) | ecs cluster name |
| <a name="output_task_stopped_event_rule_name"></a> [task\_stopped\_event\_rule\_name](#output\_task\_stopped\_event\_rule\_name) | service task stopped event rule name |
<!-- END_TF_DOCS -->