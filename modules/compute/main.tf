# =============================================================================
# modules/compute/main.tf
# ROLE 3 (Compute Engineer) — donnees partagees : AMI + cert TLS self-signed.
# =============================================================================
# OBJECTIF : le frontal applicatif complet — ALB + ASG + EC2 Nextcloud en Docker.
#
# Fichiers de ce module (chacun a completer) :
#   - alb.tf   : ALB + target group + 2 listeners (443 forward, 80 redirect)
#   - asg.tf   : launch template + auto scaling group
#   - templates/nextcloud-user-data.sh.tftpl : script user_data
#
# Ce fichier main.tf contient :
#   - data "aws_ami" "al2023"                        -> AMI Amazon Linux 2023
#   - resource "tls_private_key" "cert"              -> cle privee RSA 4096
#   - resource "tls_self_signed_cert" "cert"         -> cert auto-signe
#   - resource "aws_acm_certificate" "cert"          -> import du cert dans ACM
# =============================================================================

# TODO(role-3) : data "aws_ami" "al2023"
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# TODO(role-3) : tls_private_key "cert"
resource "tls_private_key" "cert" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# TODO(role-3) : tls_self_signed_cert "cert"
resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.cert.private_key_pem

  subject {
    common_name  = "${local.name_prefix}.kolab.local"
    organization = "Kolab Cabinet Avocats"
  }

  validity_period_hours = 17520 # 365 jours

  # Usages autorises par le cert
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  # DNS alternatif : on autorise n importe quel domaine ALB AWS
  # (le DNS name de l ALB sera genere apres)
  dns_names = [
    "${local.name_prefix}.kolab.local",
    "*.elb.amazonaws.com",
    "*.eu-west-1.elb.amazonaws.com",
  ]
}


# TODO(role-3) : aws_acm_certificate "cert"
resource "aws_acm_certificate" "cert" {
  private_key      = tls_private_key.cert.private_key_pem
  certificate_body = tls_self_signed_cert.cert.cert_pem

  tags = {
    Name = "cert-nextcloud-${var.environment}"
  }
}
