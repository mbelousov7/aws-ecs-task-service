Terraform module to create AWS ECS service task .

terrafrom config example:

```
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
| [aws_cloudwatch_log_metric_filter.errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.cpu_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.task_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ecs_cluster.ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_config"></a> [alarm\_config](#input\_alarm\_config) | add custom string into alarm descritptioon | `string` | `""` | no |
| <a name="input_alarm_enable"></a> [alarm\_enable](#input\_alarm\_enable) | n/a | `bool` | `true` | no |
| <a name="input_alarm_log_configs"></a> [alarm\_log\_configs](#input\_alarm\_log\_configs) | The cloudwatch metrics filters definitions | `map` | <pre>{<br>  "logs-errors": {<br>    "alarm_comparison_operator": "GreaterThanThreshold",<br>    "alarm_description": "Erros in log files",<br>    "alarm_evaluation_periods": 1,<br>    "alarm_name": "log-errors",<br>    "alarm_period": 60,<br>    "alarm_statistic": "Sum",<br>    "alarm_threshold": 0,<br>    "alarm_treat_missing_data": "notBreaching",<br>    "filter_pattern": "\"ERROR\"",<br>    "metric_default_value": "0",<br>    "metric_name": "ECSLogErrors",<br>    "metric_value": "1"<br>  }<br>}</pre> | no |
| <a name="input_alarm_topic_arn"></a> [alarm\_topic\_arn](#input\_alarm\_topic\_arn) | n/a | `string` | `""` | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Assign a public IP address to the ENI (Fargate launch type only). Valid values are `true` or `false`. Default `false` | `bool` | `false` | no |
| <a name="input_aws_ecs_cluster_containerInsights"></a> [aws\_ecs\_cluster\_containerInsights](#input\_aws\_ecs\_cluster\_containerInsights) | option to enabled \| disabled CloudWatch Container Insights for a cluster | `string` | `"enabled"` | no |
| <a name="input_cpu_utilization_threshold"></a> [cpu\_utilization\_threshold](#input\_cpu\_utilization\_threshold) | The maximum percentage of CPU utilization. | `number` | `80` | no |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | n/a | `number` | `200` | no |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | n/a | `number` | `100` | no |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | provide value if ecs\_cluster\_new == false | `string` | `""` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | optionally define a custom value for the ecs cluster name and tag=Name parameter<br>in aws\_ecs\_cluster. By default, it is defined as a construction from var.labels | `string` | `""` | no |
| <a name="input_ecs_cluster_new"></a> [ecs\_cluster\_new](#input\_ecs\_cluster\_new) | optionally set to false, then no new ecs cluster will be created | `bool` | `true` | no |
| <a name="input_ecs_load_balancers"></a> [ecs\_load\_balancers](#input\_ecs\_load\_balancers) | A list of load balancer config objects for the ECS service; see [ecs\_service#load\_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service#load_balancer) docs | `any` | `[]` | no |
| <a name="input_ecs_service_name"></a> [ecs\_service\_name](#input\_ecs\_service\_name) | optionally define a custom value for the aws\_ecs\_service.<br>By default, it is defined as a construction from var.labels | `string` | `""` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Minimum required map of labels(tags) for creating aws resources | <pre>object({<br>    prefix    = string<br>    stack     = string<br>    component = string<br>    env       = string<br>  })</pre> | n/a | yes |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | The launch type on which to run your service. Valid values are `EC2` and `FARGATE` | `string` | `"FARGATE"` | no |
| <a name="input_memory_utilization_threshold"></a> [memory\_utilization\_threshold](#input\_memory\_utilization\_threshold) | The maximum percentage of Memory utilization. | `number` | `80` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-east-1"` | no |
| <a name="input_service_registries"></a> [service\_registries](#input\_service\_registries) | Zero or one service discovery registries for the service.<br>The currently supported service registry is Amazon Route 53 Auto Naming Service - `aws_service_discovery_service`;<br>see `service_registries` docs https://www.terraform.io/docs/providers/aws/r/ecs_service.html#service_registries-1"<br>Service registry is object with required key `registry_arn = string` and optional keys<br>  `port           = number`<br>  `container_name = string`<br>  `container_port = number` | `list(any)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags | `map(string)` | `{}` | no |
| <a name="input_task_count_threshold"></a> [task\_count\_threshold](#input\_task\_count\_threshold) | The minimum task count threshold | `number` | `1` | no |
| <a name="input_task_definition_arn"></a> [task\_definition\_arn](#input\_task\_definition\_arn) | Task definition arn | `string` | n/a | yes |
| <a name="input_task_desired_count"></a> [task\_desired\_count](#input\_task\_desired\_count) | Number of instances of the task definition to place and keep running. | `number` | `1` | no |
| <a name="input_task_security_group_ids"></a> [task\_security\_group\_ids](#input\_task\_security\_group\_ids) | Security group IDs to allow in Service `network_configuration` | `list(string)` | `[]` | no |
| <a name="input_task_stopped_rule"></a> [task\_stopped\_rule](#input\_task\_stopped\_rule) | option to create aws\_cloudwatch\_event\_rule which Trigger when the Fargate task has stopped | `bool` | `false` | no |
| <a name="input_task_subnet_ids"></a> [task\_subnet\_ids](#input\_task\_subnet\_ids) | Subnet IDs used in Service `network_configuration` | `list(string)` | `null` | no |
| <a name="input_wait_for_steady_state"></a> [wait\_for\_steady\_state](#input\_wait\_for\_steady\_state) | Terraform will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_ecs_cluster_arn"></a> [aws\_ecs\_cluster\_arn](#output\_aws\_ecs\_cluster\_arn) | ecs cluster arn |
| <a name="output_aws_ecs_cluster_name"></a> [aws\_ecs\_cluster\_name](#output\_aws\_ecs\_cluster\_name) | ecs cluster name |
| <a name="output_task_stopped_event_rule_name"></a> [task\_stopped\_event\_rule\_name](#output\_task\_stopped\_event\_rule\_name) | service task stopped event rule name |
<!-- END_TF_DOCS -->