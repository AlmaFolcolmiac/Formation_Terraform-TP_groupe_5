# =============================================================================
# envs/dev/main.tf
# ROLE 1 (Platform Lead) — orchestration des 4 modules.
# =============================================================================
# OBJECTIF : faire dialoguer les 4 modules en passant les outputs du premier
#   en inputs du suivant. L ordre ne compte pas pour Terraform (il resout le
#   graphe de dependances via les references) — on ecrit dans un ordre logique
#   de lecture.
#
# Structure type :
#   module "networking" { source = "../../modules/networking" ... }
#   module "security"   { source = "../../modules/security"   ... }
#   module "data"       { source = "../../modules/data"       ... }
#   module "compute"    { source = "../../modules/compute"    ... }
#
# 🟡 DEPENDANCE CIRCULAIRE resolue ainsi :
#   security produit : kms_key_arn, db_password_secret_arn, admin_password_secret_arn,
#                      app_iam_role_name, instance_profile, SGs
#   data     produit : s3_primary_bucket_arn, s3_primary_bucket_name, s3_logs_bucket_*,
#                      db_endpoint, db_name, db_username
#
#   La policy IAM "app_s3_scoped" (qui accorde a l EC2 l acces au bucket S3 primary)
#   a besoin des deux : app_iam_role_name (security) ET s3_primary_bucket_arn (data).
#   -> on la declare ici, hors des modules, comme aws_iam_role_policy.
# =============================================================================

module "networking" {
  source = "../../modules/networking"

  project_name = "kolab"
  environment  = "dev"
  vpc_cidr     = "10.30.0.0/16"
  azs          = ["eu-west-3a", "eu-west-3b"]
}

module "security" {
  source             = "../../modules/security"
  project_name       = "kolab"
  environment        = "dev"
  vpc_id             = module.networking.vpc_id
  vpc_cidr           = module.networking.vpc_cidr
  allowed_admin_cidr = var.allowed_admin_cidr
}

module "data" {
  source                 = "../../modules/data"
  project_name           = "kolab"
  environment            = "dev"
  vpc_id                 = module.networking.vpc_id
  private_db_subnet_ids  = module.networking.private_db_subnet_ids
  db_security_group_id   = module.security.db_security_group_id
  kms_key_arn            = module.security.kms_key_arn
  db_password_secret_arn = module.security.db_password_secret_arn
}

module "compute" {
  source                    = "../../modules/compute"
  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.networking.vpc_id
  public_subnet_ids         = module.networking.public_subnet_ids
  private_app_subnet_ids    = module.networking.private_app_subnet_ids
  alb_security_group_id     = module.security.alb_security_group_id
  app_security_group_id     = module.security.app_security_group_id
  app_instance_profile_name = module.security.app_instance_profile_name
  db_endpoint               = module.data.db_endpoint
  db_name                   = module.data.db_name
  db_username               = module.data.db_username
  db_password_secret_arn    = module.security.db_password_secret_arn
  admin_password_secret_arn = module.security.admin_password_secret_arn
  s3_primary_bucket_name    = module.data.s3_primary_bucket_name
  s3_logs_bucket_name       = module.data.s3_logs_bucket_name
}

aws_iam_role_policy "app_s3_scoped" {
  name = "kolab-dev-app-s3-scoped"
  role = module.security.app_iam_role_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetObjectVersion",
        "s3:AbortMultipartUpload"
      ]
      Resource = [
        module.data.s3_primary_bucket_arn,
        "${module.data.s3_primary_bucket_arn}/*"
      ]
      }, {
      Effect   = "Allow"
      Action   = ["s3:ListBucket", "s3:GetBucketLocation"]
      Resource = module.data.s3_primary_bucket_arn
    }]
  })
}
