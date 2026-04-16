# main.tf (locals + data sources partages)

data "aws_caller_identity" "current" {}

resource "random_pet" "bucket_suffix" {
  length    = 2
  separator = "-"
}

locals {
  name_prefix = "${var.project_name}-${var.environment}-equipe5"

  # Noms globalement uniques pour S3 (account_id + random_pet)
  primary_bucket_name = "${local.name_prefix}-primary-${data.aws_caller_identity.current.account_id}-${random_pet.bucket_suffix.id}"
  logs_bucket_name    = "${local.name_prefix}-alb-logs-${data.aws_caller_identity.current.account_id}-${random_pet.bucket_suffix.id}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "data"
  }
}
