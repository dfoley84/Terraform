module "IAM" {
  source = "./IAM"
   providers = {
    aws = aws.Ireland
    }
}

module "Lambda_Ireland" {
  source = "./Lambda"
  lambda_arn_id = module.IAM.lambda_arn_id
  lambda_policy_arn_id = module.IAM.lambda_policy_arn_id
  providers = {
    aws = aws.Ireland
    }
}

