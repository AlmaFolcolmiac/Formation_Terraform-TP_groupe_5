output "db_endpoint" {
  description = "Hostname RDS (sans port)."
  value       = aws_db_instance.nextcloud.address
}

output "db_port" {
  description = "Port PostgreSQL (5432)."
  value       = aws_db_instance.nextcloud.port
}

output "db_name" {
  description = "Nom de la base logique."
  value       = aws_db_instance.nextcloud.db_name
}

output "db_username" {
  description = "User master PostgreSQL."
  value       = aws_db_instance.nextcloud.username
}

output "s3_primary_bucket_name" {
  description = "Nom du bucket primary storage."
  value       = aws_s3_bucket.primary.bucket
}

output "s3_primary_bucket_arn" {
  description = "ARN du bucket primary (consomme par envs/dev pour scoper la policy IAM app)."
  value       = aws_s3_bucket.primary.arn
}

output "s3_logs_bucket_name" {
  description = "Nom du bucket access logs ALB."
  value       = aws_s3_bucket.logs.bucket
}

output "s3_logs_bucket_arn" {
  description = "ARN du bucket logs."
  value       = aws_s3_bucket.logs.arn
}
