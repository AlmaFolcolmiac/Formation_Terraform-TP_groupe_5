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


# iam.tf
#############################################
# 1. Assume role policy : qui peut assumer ce role ?
#############################################
data "aws_iam_policy_document" "app_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#############################################
# 2. Role IAM runtime pour les EC2 Nextcloud
#############################################
resource "aws_iam_role" "app" {
  name               = "${local.name_prefix}-app"
  description        = "Role runtime pour EC2 Nextcloud (via instance profile)"
  assume_role_policy = data.aws_iam_policy_document.app_assume_role.json

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-role"
  })
}

#############################################
# 3a. Policy S3 scopee au bucket primary UNIQUEMENT
#############################################
data "aws_iam_policy_document" "app_s3" {
  # Actions sur les OBJETS du bucket
  statement {
    sid    = "NextcloudS3Objects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObjectVersion",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "${var.s3_primary_bucket_arn}/*" # <- scope aux objets du bucket primary
    ]
  }

  # Actions sur le BUCKET lui-meme (list)
  statement {
    sid    = "NextcloudS3Bucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads"
    ]
    resources = [
      var.s3_primary_bucket_arn # <- scope au bucket primary
    ]
  }
}

resource "aws_iam_role_policy" "app_s3" {
  name   = "${local.name_prefix}-app-s3"
  role   = aws_iam_role.app.id
  policy = data.aws_iam_policy_document.app_s3.json
}

#############################################
# 3b. Policy Secrets Manager scopee aux 2 ARN UNIQUEMENT
#############################################
data "aws_iam_policy_document" "app_secrets" {
  statement {
    sid    = "NextcloudSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      aws_secretsmanager_secret.db_password.arn,
      aws_secretsmanager_secret.admin_password.arn
    ]
  }
}

resource "aws_iam_role_policy" "app_secrets" {
  name   = "${local.name_prefix}-app-secrets"
  role   = aws_iam_role.app.id
  policy = data.aws_iam_policy_document.app_secrets.json
}

#############################################
# 3c. Policy KMS : dechiffrer les secrets
#############################################
data "aws_iam_policy_document" "app_kms" {
  statement {
    sid    = "NextcloudKmsDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [
      aws_kms_key.main.arn # <- scope a la CMK du projet uniquement
    ]
  }
}

resource "aws_iam_role_policy" "app_kms" {
  name   = "${local.name_prefix}-app-kms"
  role   = aws_iam_role.app.id
  policy = data.aws_iam_policy_document.app_kms.json
}

#############################################
# 4. Policies managees AWS (bonus) : SSM + CloudWatch
#############################################

# SSM Session Manager : permet de se connecter a l EC2 via la console AWS,
# sans SSH, sans key pair. Tres utile pour debug.
resource "aws_iam_role_policy_attachment" "app_ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# CloudWatch Agent : permet de pousser logs + metriques depuis l EC2.
resource "aws_iam_role_policy_attachment" "app_cloudwatch" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/CloudWatchAgentServerPolicy"
}

#############################################
# 5. Instance Profile : wrapper pour attacher le role a l EC2
#############################################
resource "aws_iam_instance_profile" "app" {
  name = "${local.name_prefix}-app"
  role = aws_iam_role.app.name

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-profile"
  })
}
