resource "aws_iam_role" "lambda-role" {
  name = "vm-stop-start"
  managed_policy_arns = [aws_iam_policy.lambda-policy.arn]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    tag-key = "lambda-vm-stop-start"
  }
}

resource "aws_iam_policy" "lambda-policy" {
  name = "lambda-vm-stop-start"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ec2:*"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "cloudwatch:*",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
          ],
        Resource = "*"
      }
    ]
  })
 }

 resource "aws_lambda_function" "stop_start_ec2" {
  filename      = "lambda.zip"
  function_name = "lambda_stop_start_ec2"
  role          = aws_iam_role.lambda-role.arn
  handler       = "lambda.lambda_handler"
  source_code_hash = filebase64sha256("lambda.zip")
  runtime = "python3.9"
  timeout = 10

}

resource "aws_cloudwatch_event_rule" "stop_lambda" {
  name = "stop_lambda"
  description = "define time to trigger ec2 stop_lambda function"
  schedule_expression = var.stop_schedule
  
}

resource "aws_cloudwatch_event_target" "stop_lambda" {
  target_id = "stop_start_lambda_ec2"
  rule = aws_cloudwatch_event_rule.stop_lambda.name
  arn = aws_lambda_function.stop_start_ec2.arn
  
  input = jsonencode({
    action = "stop"
    tag_key = var.tag_key
    tag_value = var.tag_value
  })
}

resource "aws_lambda_permission" "stop_lambda_rights" {
  statement_id = "AllowExecutionFromStopEC2CloudWatchEvent"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_start_ec2.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.stop_lambda.arn
}

resource "aws_cloudwatch_event_rule" "start_lambda" {
  name = "start_lambda"
  description = "define time to trigger ec2 stop_start_lambda function"
  schedule_expression = var.start_schedule
  
}

resource "aws_cloudwatch_event_target" "start_lambda" {
  target_id = "stop_start_lambda_ec2"
  rule = aws_cloudwatch_event_rule.start_lambda.name
  arn = aws_lambda_function.stop_start_ec2.arn
  
  input = jsonencode({
    action = "start" 
    tag_key = var.tag_key
    tag_value = var.tag_value
  })
}

resource "aws_lambda_permission" "start_lambda_rights" {
  statement_id = "AllowExecutionFromsStartEC2CloudWatchEvent"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_start_ec2.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.start_lambda.arn
}

resource "aws_cloudwatch_log_group" "stop_start_lambda_log" {
  name = "/aws/lambda/stop_start_ec2"
  retention_in_days = 30
}