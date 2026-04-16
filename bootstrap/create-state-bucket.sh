#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# bootstrap/create-state-bucket.sh
# One-shot : cree la KMS CMK de chiffrement du state puis le bucket S3 qui
# stockera les tfstate de tous les environnements.
#
# Cree deux ressources hors Terraform (probleme "chicken and egg") :
#   1. KMS CMK symetrique + alias alias/tf-state-kolab (rotation annuelle)
#   2. Bucket S3 versione, chiffre SSE-KMS, BPA 4/4, policy deny non-TLS
#
# Usage :
#   export AWS_PROFILE=adrien-semifir
#   USERNAME=kolab-team1 REGION=eu-west-1 ./bootstrap/create-state-bucket.sh
# -----------------------------------------------------------------------------

set -euo pipefail

USERNAME="${USERNAME:-kolab-formation}"
REGION="${REGION:-eu-west-1}"

BUCKET="tf-state-${USERNAME}-kolab"
KMS_ALIAS="alias/tf-state-${USERNAME}"

echo "==============================================="
echo " Bootstrap state Terraform Kolab"
echo "   Bucket : ${BUCKET}"
echo "   Alias  : ${KMS_ALIAS}"
echo "   Region : ${REGION}"
echo "==============================================="
echo ""

# -----------------------------------------------------------------------------
# 1. KMS CMK
# -----------------------------------------------------------------------------
echo "=== 1. Creation KMS CMK ==="

# Cherche un alias existant
KMS_KEY_ID=$(aws kms list-aliases --region "${REGION}" \
  --query "Aliases[?AliasName=='${KMS_ALIAS}'].TargetKeyId" \
  --output text)

if [ -z "${KMS_KEY_ID}" ] || [ "${KMS_KEY_ID}" = "None" ]; then
  echo "Creation d une nouvelle CMK..."
  KMS_KEY_ID=$(aws kms create-key \
    --region "${REGION}" \
    --description "CMK chiffrement du state Terraform Kolab" \
    --key-usage ENCRYPT_DECRYPT \
    --key-spec SYMMETRIC_DEFAULT \
    --tags "TagKey=Project,TagValue=kolab" "TagKey=ManagedBy,TagValue=bootstrap-script" \
    --query 'KeyMetadata.KeyId' --output text)

  # Rotation annuelle automatique (exigence securite)
  aws kms enable-key-rotation --region "${REGION}" --key-id "${KMS_KEY_ID}"

  # Alias humain pour retrouver la cle facilement
  aws kms create-alias --region "${REGION}" \
    --alias-name "${KMS_ALIAS}" \
    --target-key-id "${KMS_KEY_ID}"

  echo "CMK creee : ${KMS_KEY_ID}"
else
  echo "CMK ${KMS_ALIAS} existe deja (${KMS_KEY_ID})."
fi

KMS_KEY_ARN=$(aws kms describe-key --region "${REGION}" \
  --key-id "${KMS_KEY_ID}" \
  --query 'KeyMetadata.Arn' --output text)

echo "KMS CMK ARN : ${KMS_KEY_ARN}"
echo ""

# -----------------------------------------------------------------------------
# 2. Bucket S3 de state
# -----------------------------------------------------------------------------
echo "=== 2. Creation bucket S3 state ==="

if aws s3api head-bucket --bucket "${BUCKET}" 2>/dev/null; then
  echo "Bucket ${BUCKET} existe deja."
else
  echo "Creation du bucket ${BUCKET}..."
  aws s3api create-bucket \
    --bucket "${BUCKET}" \
    --region "${REGION}" \
    --create-bucket-configuration "LocationConstraint=${REGION}"
fi

# Versioning : indispensable pour recuperer un state corrompu
echo "Activation du versioning..."
aws s3api put-bucket-versioning \
  --bucket "${BUCKET}" \
  --versioning-configuration Status=Enabled

# Chiffrement SSE-KMS avec la CMK creee ci-dessus
echo "Activation du chiffrement SSE-KMS..."
aws s3api put-bucket-encryption \
  --bucket "${BUCKET}" \
  --server-side-encryption-configuration "{
    \"Rules\": [{
      \"ApplyServerSideEncryptionByDefault\": {
        \"SSEAlgorithm\": \"aws:kms\",
        \"KMSMasterKeyID\": \"${KMS_KEY_ARN}\"
      },
      \"BucketKeyEnabled\": true
    }]
  }"

# Block Public Access 4/4 (tfsec HIGH si absent)
echo "Activation du Block Public Access 4/4..."
aws s3api put-public-access-block \
  --bucket "${BUCKET}" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Policy : refuse toute requete non HTTPS (defense en profondeur)
echo "Application de la policy deny insecure transport..."
aws s3api put-bucket-policy \
  --bucket "${BUCKET}" \
  --policy "$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "DenyInsecureTransport",
    "Effect": "Deny",
    "Principal": "*",
    "Action": "s3:*",
    "Resource": [
      "arn:aws:s3:::${BUCKET}",
      "arn:aws:s3:::${BUCKET}/*"
    ],
    "Condition": {
      "Bool": { "aws:SecureTransport": "false" }
    }
  }]
}
EOF
)"

echo ""
echo "==============================================="
echo " Bootstrap OK."
echo "   Bucket : ${BUCKET}"
echo "   KMS    : ${KMS_ALIAS}"
echo "   ARN    : ${KMS_KEY_ARN}"
echo ""
echo " Adapter envs/dev/backend.tf avec :"
echo "   bucket     = \"${BUCKET}\""
echo "   kms_key_id = \"${KMS_ALIAS}\""
echo "==============================================="
