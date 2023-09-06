# Define the AWS provider
provider "aws" {
  region = "us-west-2"  # Replace with your desired region
}

# Create an EC2 launch configuration
resource "aws_launch_configuration" "example" {
  name_prefix          = "example-lc"
  image_id             = "ami-0123456789abcdef0"  # Replace with your desired AMI
  instance_type        = "t2.micro"  # Replace with your desired instance type
  security_groups      = ["sg-0123456789abcdef0"]  # Replace with your desired security group(s)

  # Additional configuration options as needed
}

# Create an EC2 Auto Scaling Group
resource "aws_autoscaling_group" "example" {
  name_prefix          = "example-asg"
  launch_configuration = aws_launch_configuration.example.name
  min_size             = 0  # Set the minimum size to 0 to allow for scaling down to no instances
  max_size             = 1  # Set the maximum size to 1 for single instance scaling

  # Additional configuration options as needed
}

# Create a CloudWatch event rule to schedule the start of instances
resource "aws_cloudwatch_event_rule" "start_instances" {
  name        = "start-instances-rule"
  description = "Scheduled rule to start instances"

  schedule_expression = "cron(0 8 * * ? *)"  # Set the desired start time (UTC) using cron expression
}

# Create a CloudWatch event target to start instances
resource "aws_cloudwatch_event_target" "start_instances_target" {
  rule      = aws_cloudwatch_event_rule.start_instances.name
  arn       = aws_autoscaling_group.example.arn
  target_id = "start-instances-target"
}

# Create a CloudWatch event rule to schedule the stop of instances
resource "aws_cloudwatch_event_rule" "stop_instances" {
  name        = "stop-instances-rule"
  description = "Scheduled rule to stop instances"

  schedule_expression = "cron(0 20 * * ? *)"  # Set the desired stop time (UTC) using cron expression
}

# Create a CloudWatch event target to stop instances
resource "aws_cloudwatch_event_target" "stop_instances_target" {
  rule      = aws_cloudwatch_event_rule.stop_instances.name
  arn       = aws_autoscaling_group.example.arn
  target_id = "stop-instances-target"
}