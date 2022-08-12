output "lambda_arn_id" {
  value = aws_iam_role.lambda_role.arn
}
output "lambda_policy_arn_id" {
  value = aws_iam_policy.iam_policy_for_lambda.name
}