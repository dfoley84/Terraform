data "archive_file" "zip_the_python_code" {
type        = "zip"
source_dir  = "${path.module}/aws_inspector/"
output_path = "${path.module}/aws_inspector/aws_inspector.zip"
}

data "archive_file" "zip_the_python_lib" {
type        = "zip"
source_dir  = "${path.module}/python/"
output_path = "${path.module}/python/python.zip"
}

#Createing a Lambda Layer for Required Python Libraries
resource "aws_lambda_layer_version" "python_libs" {
layer_name = "python_lib"
filename   = "${path.module}/python/python.zip"
compatible_runtimes = ["python3.8","python3.7"]
}

# Creating Lambda Function
resource "aws_lambda_function" "aws_inspector_lambda" {
  filename                       = "${path.module}/aws_inspector/aws_inspector.zip"
  function_name                  = "aws_inspector"
  role                           =  var.lambda_arn_id
  handler                        = "lambda_function.lambda_handler"
  runtime                        = "python3.8"
  timeout = 900
  layers = [aws_lambda_layer_version.python_libs.arn]
  depends_on = [var.lambda_policy_arn_id, aws_lambda_layer_version.python_libs]
}

# Lambda Policy inorder to Add EventBridge to Lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aws_inspector_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.console.arn
}

#Create EventBridge Rule for Config Change
resource "aws_cloudwatch_event_rule" "console" {
  name        = "aws_inspector_cron_job"
  description = "Inspector Cron Job"
  schedule_expression  = "cron(32 09 ? * Wed *)"
  depends_on = [aws_lambda_function.aws_inspector_lambda]
  is_enabled = true
}

resource "aws_cloudwatch_event_target" "Lambda_event_target" {
  target_id = "aws_inspector_lambda"
  rule = aws_cloudwatch_event_rule.console.name
  arn = aws_lambda_function.aws_inspector_lambda.arn
}

#SNS Topic for Failed Invocation
resource "aws_sns_topic" "user_updates" {
  name = "Lambda_Inspector_failure"
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "email"
  endpoint  = ""
}

#Configure Lambda to send Failed Invocation to SNS Topic
resource "aws_lambda_function_event_invoke_config" "example" {
  function_name = aws_lambda_function.aws_inspector_lambda.arn
  depends_on = [aws_sns_topic.user_updates]
  destination_config {
    on_failure {
      destination = aws_sns_topic.user_updates.arn
    }
  }
}
