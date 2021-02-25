variable "aws_region" {
  description = "AWS region for the infrastructure"
  type = string
  default = "us-east-1"
}
 
data "archive_file" "placeholder" {
  type = "zip"
  output_path = "${path.module}/lambda-function-payload.zip"
  source {
    content = "placeholder"
    filename = "placeholder.txt"
  }
}

provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Define a Lambda function.
#
# The handler is the name of the executable for go1.x runtime.
resource "aws_lambda_function" "resume" {
  filename = data.archive_file.placeholder.output_path
  function_name = "resume"
  handler       = "resume"
  role          = aws_iam_role.resume.arn
  runtime       = "go1.x"
  memory_size   = 128
  timeout       = 1
}

# A Lambda function may access to other AWS resources such as S3 bucket. So an
# IAM role needs to be defined. This example does not access to any resource,
# so the role is empty.
#
# The date 2012-10-17 is just the version of the policy language used here [1].
#
# [1]: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_version.html
resource "aws_iam_role" "resume" {
  name               = "resume"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": {
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "lambda.amazonaws.com"
    },
    "Effect": "Allow"
  }
}
POLICY
}

# Allow API gateway to invoke the resume-api Lambda function.
resource "aws_lambda_permission" "resume" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.resume.arn
  principal     = "apigateway.amazonaws.com"
}

# A Lambda function is not a usual public REST API. We need to use AWS API
# Gateway to map a Lambda function to an HTTP endpoint.
resource "aws_api_gateway_resource" "resume" {
  rest_api_id = aws_api_gateway_rest_api.resume.id
  parent_id   = aws_api_gateway_rest_api.resume.root_resource_id
  path_part   = "resume"
}

resource "aws_api_gateway_rest_api" "resume" {
  name = "resume"
}

#           GET
# Internet -----> API Gateway
resource "aws_api_gateway_method" "resume" {
  rest_api_id   = aws_api_gateway_rest_api.resume.id
  resource_id   = aws_api_gateway_resource.resume.id
  http_method   = "GET"
  authorization = "NONE"
}

#              POST
# API Gateway ------> Lambda
# For Lambda the method is always POST and the type is always AWS_PROXY.
#
# The date 2015-03-31 in the URI is just the version of AWS Lambda.
resource "aws_api_gateway_integration" "resume" {
  rest_api_id             = aws_api_gateway_rest_api.resume.id
  resource_id             = aws_api_gateway_resource.resume.id
  http_method             = aws_api_gateway_method.resume.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.resume.arn}/invocations"
}

# This resource defines the URL of the API Gateway.
resource "aws_api_gateway_deployment" "resume_v1" {
  depends_on = [
    aws_api_gateway_integration.resume
  ]
  rest_api_id = aws_api_gateway_rest_api.resume.id
  stage_name  = "v1"
}

# Set the generated URL as an output. Run `terraform output url` to get this.
output "url" {
  value = "${aws_api_gateway_deployment.resume_v1.invoke_url}${aws_api_gateway_resource.resume.path}"
}