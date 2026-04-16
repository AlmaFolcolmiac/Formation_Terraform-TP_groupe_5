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
#   Filtres : name = al2023-ami-*-x86_64 ; architecture = x86_64 ;
#             state = available ; most_recent = true ; owners = ["amazon"]

# TODO(role-3) : tls_private_key "cert"
#   algorithm = "RSA" ; rsa_bits = 4096

# TODO(role-3) : tls_self_signed_cert "cert"
#   private_key_pem       = tls_private_key.cert.private_key_pem
#   subject { common_name = "nextcloud-${var.environment}.kolab.local" ; organization = "Kolab" }
#   validity_period_hours = 8760  # 1 an
#   allowed_uses          = ["digital_signature", "key_encipherment", "server_auth"]

# TODO(role-3) : aws_acm_certificate "cert"
#   private_key      = tls_private_key.cert.private_key_pem
#   certificate_body = tls_self_signed_cert.cert.cert_pem
