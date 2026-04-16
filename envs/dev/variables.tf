variable "aws_region" {
  description = "Region AWS cible. eu-west-1 (Irlande) imposee par le CdC RGPD."
  type        = string
  default     = "eu-west-1"

  validation {
    condition     = var.aws_region == "eu-west-1"
    error_message = "La region doit etre eu-west-1 (exigence T1 du CdC)."
  }
}

variable "allowed_admin_cidr" {
  description = "CIDR IP source autorise pour l acces HTTPS a l ALB (IP formateur)."
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_admin_cidr, 0))
    error_message = "Doit etre un CIDR IPv4 valide (ex: 203.0.113.42/32)."
  }

  validation {
    condition     = var.allowed_admin_cidr != "0.0.0.0/0"
    error_message = "Ouvrir au monde entier (0.0.0.0/0) est interdit en TP."
  }
}

variable "project_name" {
  description = "Nom de projet utilise pour tagger les ressources."
  type        = string
  default     = "kolab"
}

variable "environment" {
  description = "Nom de l environnement (dev, staging, prod)."
  type        = string
  default     = "dev"
}
