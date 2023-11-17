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

    # Add CORS configuration
  cors_configuration {
    allow_headers = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key"]
    allow_methods = ["GET", "POST", "OPTIONS"] # Add other methods as needed
    allow_origins = ["*"] # It's safer to list specific origins in production
    allow_credentials = false # Set to true if credentials are needed
  }


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
  auto_deploy = true
  default_route_settings {
    
  throttling_burst_limit = 20
  throttling_rate_limit = 10
  }
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



#############
# S3 BUCKET #
#############
resource "aws_s3_bucket" "bucket" {
  bucket = "are-bens-doors-open"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "PublicReadGetObject",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"
        }
      ]
    }
  )
}

resource "aws_s3_object" "file" {
  for_each     = fileset(path.module, "content/**/*.{html,css,js}")
  bucket       = aws_s3_bucket.bucket.id
  key          = replace(each.value, "/^content//", "")
  source       = each.value
  content_type = lookup(local.content_types, regex("\\.[^.]+$", each.value), null)
  etag         = filemd5(each.value)
}

resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_cloudfront_distribution" "distribution" {
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket_website_configuration.hosting.website_endpoint
    origin_id   = aws_s3_bucket.bucket.bucket_regional_domain_name

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  default_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.bucket.bucket_regional_domain_name
  }
}
