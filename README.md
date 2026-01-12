## Terraform modules

Reusable Terraform modules for AWS infrastructure, built from patterns used in production environments. These templates offer standardized configurations for common AWS services, incorporating security and cost optimization.

## Components

### ECR Repository Management
Manages container registries with retention policies based on environment tagging. Prevents production image loss when development teams push frequent builds while controlling storage costs.

```hcl
module "app_registry" {
  source = "./modules/ecr-lifecycle"
  
  repository_name = "backend-api"
  environment     = var.environment
  
  retention_rules = {
    production  = { preserve = true }
    staging     = { days = 365, count = 12 }
    development = { days = 30, count = 10 }
  }
}
```

### Cognito User Pools
User authentication setup with optional development client for API testing. Provides secure user management without building custom authentication systems.

```hcl
module "auth" {
  source = "./modules/cognito-auth"
  
  pool_name   = "app-users-${var.environment}"
  environment = var.environment
  
  enable_dev_client = var.environment != "production"
}
```

### S3 Storage
Secure bucket configuration with encryption and lifecycle management. Ensures compliant file storage with automatic cost optimization through storage class transitions.

```hcl
module "storage" {
  source = "./modules/secure-s3"
  
  bucket_name = "app-data-${var.environment}"
  
  versioning_enabled    = true
  encryption_enabled    = true
  public_access_blocked = true
  
  lifecycle_rules = {
    ia_transition      = 30
    glacier_transition = 90
  }
}
```

### VPC Security Groups
Network access controls for application tiers. Implements security boundaries between different parts of your infrastructure while maintaining necessary connectivity.

```hcl
module "security_groups" {
  source = "./modules/vpc-security-groups"
  
  vpc_id      = data.aws_vpc.main.id
  name_prefix = "app"
  
  web_tier = {
    internal_access = ["10.0.0.0/8"]
    https_enabled   = true
  }
  
  app_tier = {
    database_access = true
    cache_access    = true
  }
}
```

## Usage

### Setup
```bash
git clone https://github.com/D-Stap/terraform-modules.git
cd terraform-modules/examples/basic
terraform init
terraform plan
```

### Environment Configuration
```hcl
# Development
environment = "dev"
retention_days = 30
backup_enabled = false

# Production  
environment = "prod"
retention_days = 2555
backup_enabled = true
```

## Features

**Cost Management**
- Automatic cleanup of development resources
- Storage lifecycle transitions
- Environment-specific retention policies

**Security**
- Encryption enabled by default
- Network isolation between tiers
- Public access blocked unless required

**Operations**
- Consistent deployments across environments
- Standardized tagging for resource management
- Input validation to prevent misconfigurations

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- AWS CLI configured with appropriate permissions
