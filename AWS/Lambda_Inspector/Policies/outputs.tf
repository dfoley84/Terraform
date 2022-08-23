output "lambda_policy_arn_name" {
  value = aws_iam_policy.iam_policy.name
}
output "lambda_policy_arn_id" {
  value = aws_iam_policy.iam_policy.arn
}