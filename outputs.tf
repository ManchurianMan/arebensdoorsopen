output "website_url" {
  description = "Website URL (HTTPS)"
  value       = aws_cloudfront_distribution.distribution.domain_name
}

output "s3_url" {
  description = "S3 hosting URL (HTTP)"
  value       = aws_s3_bucket_website_configuration.hosting.website_endpoint
}

output "api_gateway_url" {
  description = "The URL of the API Gateway"
  value       = "${aws_apigatewayv2_api.are_bens_doors_open.api_endpoint}/${aws_apigatewayv2_stage.example_stage.name}/${var.route}"
}
