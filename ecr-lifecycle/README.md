# ECR Lifecycle Management Module

Creates ECR repositories with environment-aware image retention policies. Prevents production image loss when development teams push frequent builds while controlling storage costs.

## Usage

```hcl
module "app_registry" {
  source = "./modules/ecr-lifecycle"
  
  repository_name = "backend-api"
  environment     = "production"
  
  retention_rules = {
    production = { preserve = true }
    staging    = { days = 365, count = 12 }
    dev        = { days = 30, count = 10 }
  }
  
  tags = {
    Team    = "platform"
    Service = "backend"
  }
}
```

## Retention Logic

- **Production images** (`v1.2.3`): Preserved indefinitely
- **Staging images** (`*-stg*`, `*-staging*`): Keep last 12 images or 365 days
- **Development images** (`*-dev*`): Keep last 10 images or 30 days
- **Untagged images**: Deleted after 1 day

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| repository_name | Name of the ECR repository | `string` | n/a | yes |
| environment | Environment name | `string` | n/a | yes |
| image_tag_mutability | Image tag mutability setting | `string` | `"MUTABLE"` | no |
| scan_on_push | Enable image scanning on push | `bool` | `true` | no |
| retention_rules | Retention rules for different environments | `object` | See variables.tf | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| repository_arn | ARN of the ECR repository |
| repository_url | URL of the ECR repository |
| repository_name | Name of the ECR repository |
| registry_id | Registry ID where the repository was created |