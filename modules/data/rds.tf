# rds.tf (partie 1 : lecture du secret)

# -----------------------------------------------------------------------------
# Lecture du mot de passe DB genere par le module security
# Le secret arn est passe en variable, Terraform resout le graphe de dependances.
# -----------------------------------------------------------------------------
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = var.db_password_secret_arn
}

# rds.tf (partie 2 : RDS)

# -----------------------------------------------------------------------------
# DB Subnet Group : RDS a besoin d au moins 2 subnets sur 2 AZ
# -----------------------------------------------------------------------------
resource "aws_db_subnet_group" "nextcloud" {
  name       = "${local.name_prefix}-db-subnets"
  subnet_ids = values(var.private_db_subnet_ids)

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-subnets"
  })
}

# -----------------------------------------------------------------------------
# Parameter Group : parametres PostgreSQL personnalises
# On force TLS cote serveur (rds.force_ssl = 1)
# -----------------------------------------------------------------------------
resource "aws_db_parameter_group" "nextcloud" {
  name   = "${local.name_prefix}-pg16"
  family = "postgres16"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  parameter {
    name  = "log_statement"
    value = "ddl" # logue CREATE/ALTER/DROP (audit)
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-pg16-params"
  })
}

# -----------------------------------------------------------------------------
# Instance RDS PostgreSQL 16 Multi-AZ chiffree KMS
# -----------------------------------------------------------------------------
resource "aws_db_instance" "nextcloud" {
  identifier = "${local.name_prefix}-nextcloud"

  # Moteur
  engine         = "postgres"
  engine_version = var.db_engine_version

  # Taille compute + storage
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  # Base, identifiants
  db_name  = "nextcloud"
  username = "nextcloud"
  password = data.aws_secretsmanager_secret_version.db_password.secret_string

  # Reseau (prive uniquement, pas d acces public)
  db_subnet_group_name   = aws_db_subnet_group.nextcloud.name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false
  port                   = 5432

  # Haute dispo
  multi_az                = true
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  # Upgrades
  auto_minor_version_upgrade = true
  apply_immediately          = false # false en prod, ici peu importe

  # Logs vers CloudWatch
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  performance_insights_enabled    = true
  performance_insights_kms_key_id = var.kms_key_arn

  # Destruction (dev only)
  deletion_protection      = false # 🟡 TRUE en prod obligatoire
  skip_final_snapshot      = true  # 🟡 FALSE en prod obligatoire
  delete_automated_backups = true

  # Parametres custom
  parameter_group_name = aws_db_parameter_group.nextcloud.name

  # IAM auth (bonus securite - ne remplace pas le mdp, s ajoute)
  iam_database_authentication_enabled = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nextcloud-rds"
  })

  lifecycle {
    # Le password peut changer si le Role 5 regenere le secret.
    # Ignorer evite un recreate cyclique en cas de rotation.
    ignore_changes = [password]
  }
}
