# Module `security`

Centralise la sécurité : KMS CMK, 3 Security Groups, 2 secrets Manager, IAM role + instance profile.

Créé par le **Rôle 5 — Security Engineer** lors du TP05.

## Contenu attendu

- **KMS** : 1 CMK avec rotation annuelle + alias
- **Security Groups** : alb (public 443/80), app (depuis alb), db (depuis app 5432)
- **Secrets Manager** : 2 secrets (db_password 24c, admin_password 20c) chiffrés KMS
- **IAM** : role assumable par EC2 + instance profile + policies scopées

## Interface

Voir `variables.tf` (inputs) et `outputs.tf` (outputs exposés).

Consultez [role-5-security.md](../../../cours/jour5/tp05-team-nextcloud/role-5-security.md) pour les étapes détaillées.
