# Module `networking`

Module VPC pour le projet Nextcloud Kolab.

Créé par le **Rôle 2 — Network Engineer** lors du TP05.

## Contenu attendu

- VPC `10.30.0.0/16` (eu-west-1)
- 6 subnets : 2 publics / 2 privés app / 2 privés DB
- Internet Gateway + NAT Gateway (single-AZ)
- Route tables et associations
- 3 VPC Endpoints : S3 (Gateway), Secrets Manager et KMS (Interface)

## Interface

Voir `variables.tf` (inputs) et `outputs.tf` (outputs exposés aux autres modules).

Consultez [role-2-network.md](../../../cours/jour5/tp05-team-nextcloud/role-2-network.md) pour les étapes détaillées.

## Génération README automatique

Bonus : `terraform-docs markdown table --output-file README.md --output-mode inject .`
