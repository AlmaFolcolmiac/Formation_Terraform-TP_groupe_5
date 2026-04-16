# Module `data`

Couche persistance : RDS PostgreSQL + 2 buckets S3.

Créé par le **Rôle 4 — Data Engineer** lors du TP05.

## Contenu attendu

- RDS PostgreSQL 16.4 Multi-AZ, chiffré KMS, db.t3.micro
- Bucket S3 `primary` : stockage fichiers Nextcloud (versioning + SSE-KMS)
- Bucket S3 `logs` : access logs ALB (SSE-AES256 — ALB ne supporte pas KMS ici), lifecycle Glacier/expiration

## Interface

Voir `variables.tf` et `outputs.tf`.

Consultez [role-4-data.md](../../../cours/jour5/tp05-team-nextcloud/role-4-data.md) pour le détail.
