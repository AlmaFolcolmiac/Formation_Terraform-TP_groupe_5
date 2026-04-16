output "alb_security_group_id" {
  description = "Security Group ID pour l ALB."
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security Group ID pour les EC2 app."
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "Security Group ID pour RDS."
  value       = aws_security_group.db.id
}

output "kms_key_id" {
  description = "ID de la KMS CMK principale."
  value       = aws_kms_key.main.id
}

output "kms_key_arn" {
  description = "ARN de la KMS CMK principale."
  value       = aws_kms_key.main.arn
}

output "app_instance_profile_name" {
  description = "Nom de l instance profile a attacher a l ASG."
  value       = aws_iam_instance_profile.app.name
}

output "app_iam_role_arn" {
  description = "ARN du role IAM de l application."
  value       = aws_iam_role.app.arn
}

output "app_iam_role_name" {
  description = "Nom du role IAM de l application (utile pour attacher des policies inline depuis envs/dev)."
  value       = aws_iam_role.app.name
}

output "db_password_secret_arn" {
  description = "ARN du secret Secrets Manager contenant le password RDS."
  value       = aws_secretsmanager_secret.db_password.arn
}

output "admin_password_secret_arn" {
  description = "ARN du secret Secrets Manager contenant le password admin Nextcloud."
  value       = aws_secretsmanager_secret.admin_password.arn
}
