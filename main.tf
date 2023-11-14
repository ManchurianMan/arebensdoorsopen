provider "aws" {
  region = "us-east-2"
    # skip_requesting_account_id should be disabled to generate valid ARN in apigatewayv2_api_execution_arn
  skip_requesting_account_id = false

}

#############
# VARIABLES #
#############

variable "region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-2"  # Replace with your AWS region
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "route" {
  description = "The route"
  type        = string
  default     = "door"
}

#################
# IAM FOR LAMBDA #
#################

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

###################
# LAMBDA FUNCTION #
###################

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "door_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "door_tester_api"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.7"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_lambda_permission" "api_gw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.door_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The source ARN can be constructed using the API ID and region
  source_arn    = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_apigatewayv2_api.are_bens_doors_open.id}/*/*/*"
}


###############
# API GATEWAY #
###############

resource "aws_apigatewayv2_api" "are_bens_doors_open" {
  name          = "are-bens-doors-open"
  description   = "Are Bens Doors Open?"
  protocol_type = "HTTP"

}
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.are_bens_doors_open.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.door_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "example_route" {
  api_id    = aws_apigatewayv2_api.are_bens_doors_open.id
  route_key = "GET /${var.route}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "example_stage" {
  api_id      = aws_apigatewayv2_api.are_bens_doors_open.id
  name        = "doorsv2"
  deployment_id = aws_apigatewayv2_deployment.example_deployment.id
  auto_deploy = true
}

resource "aws_apigatewayv2_deployment" "example_deployment" {
  api_id = aws_apigatewayv2_api.are_bens_doors_open.id
  # The triggers argument is used to redeploy when there are changes.
  triggers = {
    redeployment = sha1(jsonencode(aws_apigatewayv2_route.example_route))
  }

  lifecycle {
    create_before_destroy = true
  }
}


output "api_gateway_url" {
  description = "The URL of the API Gateway"
  value       = "${aws_apigatewayv2_api.are_bens_doors_open.api_endpoint}/${aws_apigatewayv2_stage.example_stage.name}/${var.route}"
}

