output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.arn
}

output "user_pool_endpoint" {
  description = "Endpoint of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.endpoint
}

output "app_client_id" {
  description = "ID of the app client"
  value       = aws_cognito_user_pool_client.app_client.id
}

output "app_client_secret" {
  description = "Secret of the app client"
  value       = aws_cognito_user_pool_client.app_client.client_secret
  sensitive   = true
}

output "dev_client_id" {
  description = "ID of the development token client"
  value       = var.enable_dev_client ? aws_cognito_user_pool_client.dev_token_client[0].id : null
}

output "domain_name" {
  description = "Domain name for Cognito hosted UI"
  value       = var.domain_name != null ? aws_cognito_user_pool_domain.this[0].domain : null
}