output "alb_dns_name" {
  description = "DNS public de l ALB, a utiliser pour acceder a Nextcloud."
  value       = module.compute.alb_dns_name
}

output "nextcloud_url" {
  description = "URL complete HTTPS de Nextcloud (self-signed : avertissement navigateur)."
  value       = module.compute.nextcloud_url
}

output "s3_primary_bucket_name" {
  description = "Bucket S3 primary storage Nextcloud."
  value       = module.data.s3_primary_bucket_name
}

output "s3_logs_bucket_name" {
  description = "Bucket S3 access logs ALB."
  value       = module.data.s3_logs_bucket_name
}

output "db_endpoint" {
  description = "Hostname RDS (non public)."
  value       = module.data.db_endpoint
}

output "db_password_secret_arn" {
  description = "ARN Secrets Manager du password DB (lecture via aws secretsmanager)."
  value       = module.security.db_password_secret_arn
}

output "admin_password_secret_arn" {
  description = "ARN Secrets Manager du password admin Nextcloud."
  value       = module.security.admin_password_secret_arn
}

output "vpc_id" {
  description = "ID du VPC (debug)."
  value       = module.networking.vpc_id
}

output "asg_name" {
  description = "Nom de l ASG applicatif."
  value       = module.compute.asg_name
}
