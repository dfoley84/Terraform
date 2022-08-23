resource "aws_iam_policy" "iam_policy" {
  name         = "aws_stackdrift_policy"
  path         = "/"
  description  = "AWS Stack Drift IAM Policy"
  policy = file("${path.module}/policies/cf_stackdrift_policy.json")
}
