output "parameter_names" {
  value = module.ssm_params.parameter_names
}

output "parameter_values" {
  value     = module.ssm_params.parameter_values
  sensitive = true
}

output "data_bucket_name" {
  description = "Name of the application data S3 bucket"
  value       = module.data_bucket.s3_bucket_id
}

output "data_bucket_arn" {
  description = "ARN of the application data S3 bucket"
  value       = module.data_bucket.s3_bucket_arn
}