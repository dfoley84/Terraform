data "archive_file" "zip_the_python_code" {
type        = "zip"
source_dir  = "${path.module}/aws_config_change/"
output_path = "${path.module}/aws_config_change/aws_config_change.zip"
}

# Lambda Function
resource "aws_lambda_function" "aws_config_change_lambda" {
  filename                       = "${path.module}/aws_config_change/aws_config_change.zip"
  function_name                  = "aws_config_change_lambda"
  role                           =  var.lambda_arn_id
  handler                        = "lambda_function.lambda_handler"
  runtime                        = "python3.8"
  depends_on = [var.lambda_policy_arn_id]
}

# Lambda Policy inorder to Add EventBridge to Lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aws_config_change_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.console.arn
}

#Create EventBridge Rule for Config Change
resource "aws_cloudwatch_event_rule" "console" {
  name        = "aws_config_change_compliance_rule"
  description = "Capture Config Chanes within AWS"
  event_pattern = <<EOF
    {
    "source": ["aws.config"],
    "detail-type": ["Config Configuration Item Change"]
    }
EOF
  depends_on = [aws_lambda_function.aws_config_change_lambda]
  is_enabled = true
}

resource "aws_cloudwatch_event_target" "Lambda_event_target" {
  target_id = "aws_config_change_lambda"
  rule = aws_cloudwatch_event_rule.console.name
  arn = aws_lambda_function.aws_config_change_lambda.arn
}

#SNS Topic for Failed Invocation
resource "aws_sns_topic" "user_updates" {
  name = "Lambda_Config_failure"
}
resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "email"
  endpoint  = "david_foley@fundrecs.com"
}

#Configure Lambda to send Failed Invocation to SNS Topic
resource "aws_lambda_function_event_invoke_config" "example" {
  function_name = aws_lambda_function.aws_config_change_lambda.arn
  depends_on = [aws_sns_topic.user_updates]
  destination_config {
    on_failure {
      destination = aws_sns_topic.user_updates.arn
    }
  }
}
