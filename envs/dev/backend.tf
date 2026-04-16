# -----------------------------------------------------------------------------
# envs/dev/backend.tf
# Backend S3 natif (TF >= 1.10) avec locking via use_lockfile + KMS CMK.
# Le bucket + la CMK sont crees par bootstrap/create-state-bucket.sh.
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    # 🟣 A ADAPTER : nom du bucket cree par bootstrap/create-state-bucket.sh
    # Par defaut le script cree "tf-state-kolab-formation-<USERNAME>".
    # Remplacez la valeur ci-dessous par le nom exact renvoye par le script.
    bucket = "tf-state-kolab-formation-TEAM"
    key    = "envs/dev/terraform.tfstate"
    region = "eu-west-1"

    # Chiffrement cote objet state via la CMK bootstrap (alias cree par le script)
    encrypt    = true
    kms_key_id = "alias/tf-state-kolab-formation"

    # Locking natif S3 (TF 1.10+). Remplace DynamoDB.
    use_lockfile = true
  }
}
