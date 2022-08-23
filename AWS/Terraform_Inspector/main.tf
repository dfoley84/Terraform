
module "Policies"{
  source = "./Policies"
  providers = {
    aws = aws.Ireland
  }
}
module "IAM" {
  source = "./IAM"
  lambda_policy_arn_id = module.Policies.lambda_policy_arn_id
  lambda_policy_arn_name = module.Policies.lambda_policy_arn_name
  providers = {
    aws = aws.Ireland
  }
}

module "Inspector" {
  source = "./Lambda_Inspector"
  lambda_arn_id = module.IAM.lambda_arn_id
  lambda_policy_arn_id = module.Policies.lambda_policy_arn_id
  providers = {
    aws = aws.Ireland
  }
}

