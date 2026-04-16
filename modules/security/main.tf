# =============================================================================
# modules/security/main.tf
# ROLE 5 (Security Engineer) — a completer
# =============================================================================
# OBJECTIF : centraliser tout ce qui concerne la securite.
#
# Fichiers de ce module (chacun a completer) :
#   - kms.tf      : KMS CMK + alias + key policy
#   - sg.tf       : 3 Security Groups (alb / app / db)
#   - iam.tf      : IAM role + instance profile + policies scopees
#   - secrets.tf  : 2 Secrets Manager (db_password + admin_password)
#
# Ce fichier main.tf contient uniquement les data sources partages.
# =============================================================================

# TODO(role-5) : data sources utilitaires pour construire les policies KMS/IAM.
#
# Exemple :
#   data "aws_caller_identity" "current" {}
#   data "aws_partition" "current" {}
#
# Ces data sources fournissent :
#   - data.aws_caller_identity.current.account_id -> "039497794217"
#   - data.aws_partition.current.partition         -> "aws"
#
# Utilises pour construire les ARN dans les key policies (root account) et
# les assume role policies.
