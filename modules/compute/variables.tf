variable "vpc_id" {
  description = "ID du VPC (output du module networking)."
  type        = string
}

variable "public_subnet_ids" {
  description = "Map AZ -> subnet_id public (pour l ALB)."
  type        = map(string)
}

variable "private_app_subnet_ids" {
  description = "Map AZ -> subnet_id prive (pour l ASG)."
  type        = map(string)
}

variable "alb_security_group_id" {
  description = "SG de l ALB (fourni par le module security)."
  type        = string
}

variable "app_security_group_id" {
  description = "SG des EC2 applicatives (fourni par le module security)."
  type        = string
}

variable "app_instance_profile_name" {
  description = "Instance profile IAM pour l ASG (fourni par security)."
  type        = string
}

variable "db_endpoint" {
  description = "Hostname RDS (output du module data)."
  type        = string
}

variable "db_name" {
  description = "Nom base logique RDS."
  type        = string
}

variable "db_username" {
  description = "User master RDS."
  type        = string
}

variable "db_password_secret_arn" {
  description = "ARN du secret Secrets Manager contenant le password DB."
  type        = string
}

variable "admin_password_secret_arn" {
  description = "ARN du secret du password admin Nextcloud."
  type        = string
}

variable "s3_primary_bucket_name" {
  description = "Nom du bucket S3 primary storage Nextcloud."
  type        = string
}

variable "s3_logs_bucket_name" {
  description = "Nom du bucket S3 pour les access logs ALB."
  type        = string
}

variable "project_name" {
  description = "Nom de projet."
  type        = string
  default     = "kolab"
}

variable "environment" {
  description = "Environnement."
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "t3.small mini pour faire tourner Docker + Nextcloud confortablement."
  type        = string
  default     = "t3.small"
}

variable "aws_region" {
  description = "Region AWS (injectee dans le user_data)."
  type        = string
  default     = "eu-west-1"
}
