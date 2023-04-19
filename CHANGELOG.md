# Changelog

Make sure to update this file for each merge into *develop*, otherwise the build fails.

The build relies on the latest version in this file.

Latest versions must be at the top!

## [1.1.0] - 2023-04-19

- rename input vars

## [1.0.5] - 2023-03-02

- add task load_balancer dynamic configuration


## [1.0.4] - 2023-02-27

- add aws region in ecs cluster name

## [1.0.3] - 2022-09-08

- add ecs_cluster_arn varible and crating cluster logic

## [1.0.1] - 2022-08-02

- add var task_stopped_rule(default = false) option to create aws_cloudwatch_event_rule which Trigger when the Fargate task has stopped
- add var desired_count(default = 0) Number of instances of the task definition to place and keep running.
- add ecs cluster name as output

## [1.0.0] - 2022-05-25

- add tf module, example, readme, gitlab-ci
