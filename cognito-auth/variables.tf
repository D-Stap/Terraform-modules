variable "pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enable_dev_client" {
  description = "Enable development token generator client"
  type        = bool
  default     = false
}

variable "password_policy" {
  description = "Password policy configuration"
  type = object({
    minimum_length    = optional(number, 8)
    require_lowercase = optional(bool, true)
    require_numbers   = optional(bool, true)
    require_symbols   = optional(bool, true)
    require_uppercase = optional(bool, true)
  })
  default = {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
}

variable "auto_verified_attributes" {
  description = "Attributes to be auto-verified"
  type        = list(string)
  default     = ["email"]
}

variable "user_attributes" {
  description = "User pool schema attributes"
  type = list(object({
    name     = string
    type     = string
    required = bool
    mutable  = bool
  }))
  default = [
    {
      name     = "email"
      type     = "String"
      required = true
      mutable  = true
    }
  ]
}

variable "generate_client_secret" {
  description = "Generate client secret for app client"
  type        = bool
  default     = true
}

variable "oauth_flows" {
  description = "Allowed OAuth flows"
  type        = list(string)
  default     = ["code"]
}

variable "oauth_scopes" {
  description = "Allowed OAuth scopes"
  type        = list(string)
  default     = ["openid", "email", "profile"]
}

variable "callback_urls" {
  description = "Callback URLs for OAuth"
  type        = list(string)
  default     = []
}

variable "logout_urls" {
  description = "Logout URLs for OAuth"
  type        = list(string)
  default     = []
}

variable "token_validity" {
  description = "Token validity periods"
  type = object({
    access_token  = optional(number, 1)
    id_token      = optional(number, 1)
    refresh_token = optional(number, 30)
  })
  default = {
    access_token  = 1
    id_token      = 1
    refresh_token = 30
  }
}

variable "domain_name" {
  description = "Domain name for Cognito hosted UI"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}