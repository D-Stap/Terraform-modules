variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production."
  }
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting"
  type        = string
  default     = "MUTABLE"
  
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for repository"
  type        = string
  default     = "AES256"
  
  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Encryption type must be AES256 or KMS."
  }
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (required if encryption_type is KMS)"
  type        = string
  default     = null
}

variable "retention_rules" {
  description = "Retention rules for different environments"
  type = object({
    production = object({
      preserve = optional(bool, true)
      days     = optional(number)
      count    = optional(number)
    })
    staging = object({
      days  = optional(number, 365)
      count = optional(number, 12)
    })
    dev = object({
      days  = optional(number, 30)
      count = optional(number, 10)
    })
  })
  default = {
    production = { preserve = true }
    staging    = { days = 365, count = 12 }
    dev        = { days = 30, count = 10 }
  }
}

variable "allowed_account_ids" {
  description = "List of AWS account IDs allowed to access this repository"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}