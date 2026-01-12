# Secure S3 Module

Creates S3 buckets with security and compliance defaults. Ensures compliant file storage with automatic cost optimization through storage class transitions.

## Usage

```hcl
module "storage" {
  source = "./modules/secure-s3"
  
  bucket_name = "app-data-${var.environment}"
  environment = var.environment
  
  versioning_enabled = true
  
  lifecycle_rules = [
    {
      id     = "cost_optimization"
      status = "Enabled"
      
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
      
      noncurrent_version_expiration = {
        days = 90
      }
    }
  ]
  
  tags = {
    Team    = "platform"
    Service = "storage"
  }
}
```

## Security Features

- **Public access blocked** by default
- **Server-side encryption** enabled (AES256 or KMS)
- **Versioning support** for data protection
- **Lifecycle policies** for cost optimization
- **Access logging** support

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of the S3 bucket | `string` | n/a | yes |
| environment | Environment name | `string` | n/a | yes |
| versioning_enabled | Enable versioning on the bucket | `bool` | `true` | no |
| encryption_configuration | Server-side encryption configuration | `object` | AES256 | no |
| lifecycle_rules | Lifecycle rules for the bucket | `list(object)` | `[]` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | ID of the S3 bucket |
| bucket_arn | ARN of the S3 bucket |
| bucket_domain_name | Domain name of the S3 bucket |