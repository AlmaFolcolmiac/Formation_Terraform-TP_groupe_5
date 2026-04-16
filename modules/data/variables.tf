variable "vpc_id" {
  description = "ID du VPC (output du module networking)."
  type        = string
}

variable "private_db_subnet_ids" {
  description = "Map AZ -> subnet_id prive DB (2 subnets sur 2 AZ pour Multi-AZ)."
  type        = map(string)
}

variable "db_security_group_id" {
  description = "SG attache au RDS (fourni par le module security)."
  type        = string
}

variable "kms_key_arn" {
  description = "ARN de la CMK KMS (fournie par le module security)."
  type        = string
}

variable "db_password_secret_arn" {
  description = "ARN du secret Secrets Manager contenant le mot de passe DB."
  type        = string
}

variable "project_name" {
  description = "Nom de projet pour le tagging."
  type        = string
  default     = "kolab"
}

variable "environment" {
  description = "Nom de l environnement."
  type        = string
  default     = "dev"
}

variable "db_instance_class" {
  description = "Classe d instance RDS. db.t3.micro = plus petit dispo Multi-AZ."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Storage initial RDS en Go."
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Storage max (auto-scaling gp3) pour absorber les uploads Nextcloud."
  type        = number
  default     = 100
}

variable "db_engine_version" {
  description = "Version PostgreSQL."
  type        = string
  default     = "16.4"
}
