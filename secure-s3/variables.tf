variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning on the bucket"
  type        = bool
  default     = true
}

variable "public_access_block" {
  description = "Public access block configuration"
  type = object({
    block_public_acls       = optional(bool, true)
    block_public_policy     = optional(bool, true)
    ignore_public_acls      = optional(bool, true)
    restrict_public_buckets = optional(bool, true)
  })
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

variable "encryption_configuration" {
  description = "Server-side encryption configuration"
  type = object({
    sse_algorithm      = optional(string, "AES256")
    kms_master_key_id  = optional(string)
    bucket_key_enabled = optional(bool, true)
  })
  default = {
    sse_algorithm      = "AES256"
    bucket_key_enabled = true
  }
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for the bucket"
  type = list(object({
    id     = string
    status = string
    expiration = optional(object({
      days = number
    }))
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    noncurrent_version_expiration = optional(object({
      days = number
    }))
    filter = optional(object({
      prefix = string
    }))
  }))
  default = []
}

variable "logging_configuration" {
  description = "Access logging configuration"
  type = object({
    target_bucket = string
    target_prefix = optional(string, "access-logs/")
  })
  default = null
}

variable "notification_configuration" {
  description = "S3 bucket notification configuration"
  type = list(object({
    lambda_function_arn = string
    events              = list(string)
    filter_prefix       = optional(string)
    filter_suffix       = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}