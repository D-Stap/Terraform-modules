terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_cognito_user_pool" "this" {
  name = var.pool_name

  # Password policy
  password_policy {
    minimum_length    = var.password_policy.minimum_length
    require_lowercase = var.password_policy.require_lowercase
    require_numbers   = var.password_policy.require_numbers
    require_symbols   = var.password_policy.require_symbols
    require_uppercase = var.password_policy.require_uppercase
  }

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # User attributes
  auto_verified_attributes = var.auto_verified_attributes
  
  dynamic "schema" {
    for_each = var.user_attributes
    content {
      attribute_data_type = schema.value.type
      name               = schema.value.name
      required           = schema.value.required
      mutable           = schema.value.mutable
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = var.pool_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

# Standard app client for production use
resource "aws_cognito_user_pool_client" "app_client" {
  name         = "${var.pool_name}-app-client"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret                      = var.generate_client_secret
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = var.oauth_flows
  allowed_oauth_scopes                 = var.oauth_scopes
  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  # Token validity
  access_token_validity  = var.token_validity.access_token
  id_token_validity     = var.token_validity.id_token
  refresh_token_validity = var.token_validity.refresh_token

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}

# Development token generator client (conditional)
resource "aws_cognito_user_pool_client" "dev_token_client" {
  count = var.enable_dev_client ? 1 : 0

  name         = "${var.pool_name}-dev-token-generator"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  # Shorter token validity for development
  access_token_validity  = 1
  id_token_validity     = 1
  refresh_token_validity = 1

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}

# User pool domain (optional)
resource "aws_cognito_user_pool_domain" "this" {
  count = var.domain_name != null ? 1 : 0

  domain       = var.domain_name
  user_pool_id = aws_cognito_user_pool.this.id
}