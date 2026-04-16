# Module `compute`

Frontal applicatif : ALB + ASG + launch template + user_data Nextcloud.

Créé par le **Rôle 3 — Compute Engineer** lors du TP05.

## Contenu attendu

- Certificat TLS self-signed (provider `tls`) importé dans ACM
- ALB public + target group (health check `/status.php`) + 2 listeners (443 forward, 80 redirect 301)
- Launch template (Amazon Linux 2023, t3.small, IMDSv2, EBS chiffré)
- ASG min=1 / max=2 / desired=1
- user_data templatifié lançant `nextcloud:30-apache` en Docker

## Interface

Voir `variables.tf` et `outputs.tf`.

Consultez [role-3-compute.md](../../../cours/jour5/tp05-team-nextcloud/role-3-compute.md) pour le détail.
