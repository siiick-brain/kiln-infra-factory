output "distribution_id" {
  value       = aws_cloudfront_distribution.site.id
  description = "CloudFront distribution identifier."
}

output "distribution_domain_name" {
  value       = aws_cloudfront_distribution.site.domain_name
  description = "CloudFront distribution domain name."
}

output "origin_bucket_arn" {
  value       = aws_s3_bucket.origin.arn
  description = "Private S3 origin bucket ARN."
}
