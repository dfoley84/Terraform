resource "aws_iam_policy" "iam_policy_for_lambda" {
  name         = "aws_config_change_aws_lambda_policy"
  path         = "/"
  description  = "AWS IAM Policy for Config Change Alert AWS lambda role"
  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sns:Publish",
                "sns:Subscribe",
                "sns:CreateTopic",
                "sns:GetTopicAttributes",
                "sns:SetTopicAttributes",
                "sns:TagResource",
                "sns:UntagResource",
                "sns:ListTagsForResource",
                "sns:ListSubscriptionsByTopic"
            ],
            "Resource": [
                "arn:aws:sns:*:*:*"
            ]
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role" "lambda_role" {
  name   = "aws_config_changr_aws_lambda_role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role        = aws_iam_role.lambda_role.name
  policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

