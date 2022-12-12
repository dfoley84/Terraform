resource "aws_ecs_service" "prometheus_service" {
    name = "prometheus-service"
    cluster = "fr-ecs-cluster"
    task_definition = var.prometheus_task_definition
    desired_count = 1
    deployment_maximum_percent = 100
    deployment_minimum_healthy_percent = 0
    launch_type = "EC2"
}
