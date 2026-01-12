# Cognito Authentication Module

Creates Cognito User Pools with optional development client for API testing. Provides secure user management without building custom authentication systems.

## Usage

```hcl
module "auth" {
  source = "./modules/cognito-auth"
  
  pool_name   = "app-users-${var.environment}"
  environment = var.environment
  
  # Enable development token generator for non-prod
  enable_dev_client = var.environment != "production"
  
  callback_urls = ["https://app.example.com/callback"]
  logout_urls   = ["https://app.example.com/logout"]
  
  tags = {
    Team    = "platform"
    Service = "authentication"
  }
}
```

## Features

- **Standard app client** for production OAuth flows
- **Development client** for easy token generation in non-prod environments
- **Configurable password policy** with security defaults
- **Auto-verified email** for user registration
- **Flexible token validity** periods

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| pool_name | Name of the Cognito User Pool | `string` | n/a | yes |
| environment | Environment name | `string` | n/a | yes |
| enable_dev_client | Enable development token generator client | `bool` | `false` | no |
| password_policy | Password policy configuration | `object` | See variables.tf | no |
| oauth_flows | Allowed OAuth flows | `list(string)` | `["code"]` | no |
| callback_urls | Callback URLs for OAuth | `list(string)` | `[]` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| user_pool_id | ID of the Cognito User Pool |
| user_pool_arn | ARN of the Cognito User Pool |
| app_client_id | ID of the app client |
| dev_client_id | ID of the development token client |