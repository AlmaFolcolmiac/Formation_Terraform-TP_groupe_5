# =============================================================================
# modules/security/iam.tf
# IAM role + instance profile pour les EC2 Nextcloud.
# Policies scopees : Secrets Manager + KMS Decrypt.
# (La policy S3 scope sur le bucket primary est declaree dans envs/dev/main.tf
#  pour eviter la dependance circulaire entre data et security.)
# =============================================================================
# Ressources a declarer :
#
#   - aws_iam_role             "app"   (assume_role_policy pour ec2.amazonaws.com)
#   - aws_iam_role_policy      "app_secrets"  (Allow secretsmanager:GetSecretValue
#                                              sur les 2 secrets ARN)
#   - aws_iam_role_policy      "app_kms"      (Allow kms:Decrypt + kms:DescribeKey
#                                              sur var.kms_key_arn — celle de ce module)
#   - aws_iam_role_policy_attachment "app_ssm"        (bonus, pour SSM Session Manager)
#   - aws_iam_role_policy_attachment "app_cloudwatch" (bonus, pour CW Agent)
#   - aws_iam_instance_profile "app"   (role = aws_iam_role.app.name)
#
# Pattern assume_role_policy :
#   data "aws_iam_policy_document" "assume_ec2" {
#     statement {
#       actions = ["sts:AssumeRole"]
#       principals {
#         type        = "Service"
#         identifiers = ["ec2.amazonaws.com"]
#       }
#     }
#   }
#
# Pattern policy inline :
#   resource "aws_iam_role_policy" "app_secrets" {
#     name = "..."
#     role = aws_iam_role.app.id
#     policy = jsonencode({
#       Version = "2012-10-17"
#       Statement = [{
#         Effect   = "Allow"
#         Action   = ["secretsmanager:GetSecretValue"]
#         Resource = [aws_secretsmanager_secret.db_password.arn,
#                     aws_secretsmanager_secret.admin_password.arn]
#       }]
#     })
#   }
# =============================================================================

# TODO(role-5) : aws_iam_role "app" avec assume_role_policy ec2.amazonaws.com

# TODO(role-5) : aws_iam_role_policy "app_secrets" (scope = les 2 secrets ARN)

# TODO(role-5) : aws_iam_role_policy "app_kms" (scope = aws_kms_key.main.arn)

# TODO(role-5) : 2 aws_iam_role_policy_attachment (SSM + CloudWatch) — bonus

# TODO(role-5) : aws_iam_instance_profile "app"
