output "prometheus_task_definition" {
  value = aws_ecs_task_definition.prometheus.arn
}
