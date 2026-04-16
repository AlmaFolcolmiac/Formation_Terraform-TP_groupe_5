# =============================================================================
# modules/security/sg.tf
# 3 Security Groups : alb (public), app (prive), db (prive-DB).
# =============================================================================
# Ressources a declarer :
#
#   - aws_security_group "alb"   (nom alb-sg, vpc_id = var.vpc_id)
#   - aws_security_group "app"   (nom app-sg, vpc_id = var.vpc_id)
#   - aws_security_group "db"    (nom db-sg,  vpc_id = var.vpc_id)
#
#   - aws_vpc_security_group_ingress_rule "alb_https"  : 443 from 0.0.0.0/0
#   - aws_vpc_security_group_ingress_rule "alb_http"   : 80  from 0.0.0.0/0 (redirect)
#   - aws_vpc_security_group_egress_rule  "alb_all"    : -1  to   0.0.0.0/0
#
#   - aws_vpc_security_group_ingress_rule "app_from_alb" : 80 from SG alb
#                                                          (referenced_security_group_id)
#   - aws_vpc_security_group_egress_rule  "app_all"      : -1 to   0.0.0.0/0
#
#   - aws_vpc_security_group_ingress_rule "db_from_app"  : 5432 TCP from SG app
#                                                          (referenced_security_group_id)
#
# 🟡 Rappel syntaxe v5+ : depuis le provider AWS 5.x, on utilise des ressources
#   separees aws_vpc_security_group_ingress_rule / _egress_rule (et non plus les
#   blocs ingress {} / egress {} dans aws_security_group).
#
# Pattern inter-SG : pour autoriser "app" depuis "alb", on utilise :
#   referenced_security_group_id = aws_security_group.alb.id
#   (et PAS cidr_ipv4 — les 2 arguments sont exclusifs)
# =============================================================================

# TODO(role-5) : 3 aws_security_group

# TODO(role-5) : 3 ingress + 2 egress rules


# sg.tf
#############################################
# SG ALB - accepte HTTPS et HTTP depuis Internet
#############################################
resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb"
  description = "SG pour l ALB public Nextcloud"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
  })
}

# Ingress 443 depuis tout Internet (HTTPS)
resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS from Internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Ingress 80 depuis tout Internet (pour redirect 80 -> 443)
resource "aws_vpc_security_group_ingress_rule" "alb_http_redirect" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP from Internet (redirect to HTTPS)"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# Egress ALL (l ALB doit pouvoir atteindre les cibles)
resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow all egress"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#############################################
# SG app - accepte uniquement depuis le SG ALB
#############################################
resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app"
  description = "SG pour les EC2 Nextcloud derriere l ALB"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app"
  })
}

# Ingress 80 depuis le SG ALB UNIQUEMENT (pas de CIDR)
resource "aws_vpc_security_group_ingress_rule" "app_http_from_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "HTTP from ALB only"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

# Egress ALL (dnf update, Docker pull, RDS, S3, Secrets Manager)
resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.app.id
  description       = "Allow all egress for updates Docker pull RDS S3"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#############################################
# SG db - accepte uniquement PostgreSQL depuis SG app
#############################################
resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-db"
  description = "SG pour RDS PostgreSQL Nextcloud"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db"
  })
}

# Ingress 5432 TCP depuis le SG app UNIQUEMENT
resource "aws_vpc_security_group_ingress_rule" "db_pg_from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "PostgreSQL from app only"
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

# Pas d egress par defaut (RDS n a pas besoin d initier de connexion sortante).
# Si tfsec rale : on ajoute un egress minimal vers le VPC CIDR.
resource "aws_vpc_security_group_egress_rule" "db_minimal" {
  security_group_id = aws_security_group.db.id
  description       = "Minimal egress within VPC"
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "-1"
}
