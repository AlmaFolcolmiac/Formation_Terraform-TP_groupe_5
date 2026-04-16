variable "project_name" {
  description = "Nom du projet (prefixe de nommage)."
  type        = string
}

variable "environment" {
  description = "Environnement (dev, staging, prod)."
  type        = string
}

variable "vpc_id" {
  description = "ID du VPC (fourni par le module networking)."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR du VPC (fourni par le module networking)."
  type        = string
}

variable "allowed_admin_cidr" {
  description = "CIDR autorise pour l acces admin (IP formateur). Non utilise pour l instant mais figes au contrat."
  type        = string
  default     = "0.0.0.0/0"
}
