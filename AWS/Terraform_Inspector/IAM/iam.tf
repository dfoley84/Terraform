resource "aws_iam_role" "lambda_role" {
  name   = "aws_config_change_aws_lambda_role"
  assume_role_policy = file("${path.module}/roles/lambda_assume.json")
  depends_on = [var.lambda_policy_arn_name]
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role        = aws_iam_role.lambda_role.name
  for_each = toset(["arn:aws:iam::aws:policy/AWSCloudFormationReadOnlyAccess",
                    "arn:aws:iam::aws:policy/AmazonInspector2ReadOnlyAccess",
                    "arn:aws:iam::aws:policy/AmazonSNSFullAccess",
                     var.lambda_policy_arn_id])
  policy_arn  = each.key
  depends_on = [var.lambda_policy_arn_name]
}

