# =============================================================================
# modules/data/rds.tf
# RDS PostgreSQL Multi-AZ + DB subnet group + parameter group.
# =============================================================================
# Ressources a declarer :
#
#   - aws_db_subnet_group    "main"
#       - name       = "${local.name_prefix}-db-subnet-group"
#       - subnet_ids = values(var.private_db_subnet_ids)
#
#   - aws_db_parameter_group "postgres16"
#       - family = "postgres16"
#       - name   = "${local.name_prefix}-pg16"
#       - parameter { name = "rds.force_ssl"       value = "1" }
#       - parameter { name = "log_connections"      value = "1" }
#       - parameter { name = "log_disconnections"   value = "1" }
#
#   - aws_db_instance        "nextcloud"
#       - engine                  = "postgres"
#       - engine_version          = "16.4"
#       - instance_class          = "db.t3.micro"
#       - allocated_storage       = 20
#       - max_allocated_storage   = 100
#       - storage_type            = "gp3"
#       - storage_encrypted       = true
#       - kms_key_id              = var.kms_key_arn
#       - multi_az                = true
#       - db_name                 = "nextcloud"
#       - username                = "nextcloud"
#       - password                = data.aws_secretsmanager_secret_version.db_password.secret_string
#       - port                    = 5432
#       - db_subnet_group_name    = aws_db_subnet_group.main.name
#       - parameter_group_name    = aws_db_parameter_group.postgres16.name
#       - vpc_security_group_ids  = [var.db_security_group_id]
#       - publicly_accessible     = false
#       - skip_final_snapshot     = true   (dev uniquement)
#       - deletion_protection     = false  (dev uniquement)
#       - backup_retention_period = 7
#       - lifecycle { ignore_changes = [password] }  # pour permettre rotation manuelle sans drift
# =============================================================================

# TODO(role-4) : aws_db_subnet_group

# TODO(role-4) : aws_db_parameter_group

# TODO(role-4) : aws_db_instance
