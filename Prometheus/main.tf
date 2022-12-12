module "Role"{
  source = "./IAM"
  providers = {
    aws = aws.Ireland
  }
}

module "PrometheusECR"{
  source = "./ECR"
  providers = {
    aws = aws.Ireland
  }
}

module "TaskDefinition"{
  source = "./TaskDefinition"
  arn_prometheus_role = module.Role.arn_prometheus_role
  providers = {
    aws = aws.Ireland
  }
  depends_on = [
    module.Role
  ]
}

module "prometheus_service"{
  source = "./ECS"
  prometheus_task_definition = module.TaskDefinition.prometheus_task_definition
  arn_prometheus_role = module.Role.arn_prometheus_role
  providers = {
    aws = aws.Ireland
  }
  depends_on = [
    module.Role,
    module.TaskDefinition
  ]
}

module "AWSPrometheus"{
  source = "./AWSPrometheus"
  providers = {
    aws = aws.Ireland
  }
  depends_on = [
    module.Role,
    module.TaskDefinition,
    module.prometheus_service
  ]
}
