# =============================================================================
# modules/security/kms.tf
# KMS Customer Managed Key (CMK) qui chiffre : S3 buckets, RDS, Secrets Manager.
# =============================================================================
# Ressources a declarer :
#
#   - aws_kms_key   "main"    (description, enable_key_rotation = true,
#                              deletion_window_in_days = 10, policy = ...)
#   - aws_kms_alias "main"    (name = "alias/${local.name_prefix}-main")
#
# 🟥 REGLE CRITIQUE : le root account doit TOUJOURS avoir tous les droits sur
#   la cle. Sinon la cle devient irrecuperable (deletion window 7-30 jours).
#
# Pattern recommande de key policy (utiliser jsonencode()) :
#
#   {
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid       = "EnableRootAccountAccess"
#         Effect    = "Allow"
#         Principal = { AWS = "arn:aws:iam::<ACCOUNT_ID>:root" }
#         Action    = "kms:*"
#         Resource  = "*"
#       },
#       {
#         Sid       = "AllowAppRoleUsage"
#         Effect    = "Allow"
#         Principal = { AWS = aws_iam_role.app.arn }
#         Action    = ["kms:Decrypt", "kms:DescribeKey", "kms:Encrypt",
#                      "kms:GenerateDataKey", "kms:ReEncrypt*"]
#         Resource  = "*"
#       },
#       {
#         Sid       = "AllowServicesViaIAM"
#         Effect    = "Allow"
#         Principal = { AWS = "*" }
#         Action    = ["kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*",
#                      "kms:GenerateDataKey*", "kms:DescribeKey"]
#         Resource  = "*"
#         Condition = {
#           StringEquals = {
#             "kms:CallerAccount" = data.aws_caller_identity.current.account_id
#             "kms:ViaService"    = [
#               "s3.eu-west-1.amazonaws.com",
#               "rds.eu-west-1.amazonaws.com",
#               "secretsmanager.eu-west-1.amazonaws.com"
#             ]
#           }
#         }
#       }
#     ]
#   }
# =============================================================================

# TODO(role-5) : aws_kms_key "main" + aws_kms_alias "main"
