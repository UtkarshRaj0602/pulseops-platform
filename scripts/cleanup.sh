#!/usr/bin/env bash

set -euo pipefail

echo "=================================================="
echo "       PULSeOPS STAGE TERRAFORM DESTROY"
echo "=================================================="

AWS_REGION="${AWS_REGION:-ap-south-1}"
SECRET_NAME="pulseops-stage-database"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TF_DIR="$PROJECT_ROOT/infrastructure/terraform"
TFVARS="environments/stage/terraform.tfvars"

cd "$TF_DIR"

echo ""
echo "========== AWS IDENTITY =========="
aws sts get-caller-identity

echo ""
echo "========== TERRAFORM INIT =========="
terraform init -input=false

echo ""
echo "========== TERRAFORM STATE =========="
terraform state list || true

# =========================================================
# FORCE DELETE SECRET
# =========================================================

force_delete_secret() {

    echo ""
    echo "========== CHECKING DATABASE SECRET =========="

    if aws secretsmanager describe-secret \
        --secret-id "$SECRET_NAME" \
        --region "$AWS_REGION" \
        >/dev/null 2>&1; then

        echo "Secret found: $SECRET_NAME"
        echo "Force deleting secret without recovery window..."

        aws secretsmanager delete-secret \
            --secret-id "$SECRET_NAME" \
            --force-delete-without-recovery \
            --region "$AWS_REGION"

        echo "Secret force deletion requested."

    else
        echo "Secret $SECRET_NAME does not exist."
    fi
}

force_delete_secret

echo ""
echo "=================================================="
echo "WARNING: THIS WILL DESTROY STAGE INFRASTRUCTURE"
echo "=================================================="

terraform plan \
    -destroy \
    -var-file="$TFVARS" \
    -out=stage-destroy.tfplan

echo ""
echo "========== APPLYING DESTROY =========="

terraform apply \
    -auto-approve \
    stage-destroy.tfplan

echo ""
echo "========== TERRAFORM STATE AFTER DESTROY =========="

terraform state list || true

echo ""
echo "=================================================="
echo "Terraform destroy completed."
echo "=================================================="