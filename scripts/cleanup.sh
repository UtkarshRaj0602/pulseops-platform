#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# PULSEOPS STAGE CLEANUP
# ============================================================

PROJECT_NAME="pulseops"
ENVIRONMENT="stage"
AWS_REGION="ap-south-1"
CLUSTER_NAME="pulseops-stage"
NAMESPACE="pulseops"

TERRAFORM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../infrastructure/terraform" && pwd)"
TFVARS_FILE="environments/${ENVIRONMENT}/terraform.tfvars"

# ------------------------------------------------------------
# COLORS
# ------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ------------------------------------------------------------
# FUNCTIONS
# ------------------------------------------------------------

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

section() {
    echo ""
    echo "============================================================"
    echo " $1"
    echo "============================================================"
    echo ""
}

cleanup_on_error() {
    error "Cleanup failed."
    error "The environment may be partially destroyed."
    error "Check Terraform state before attempting another cleanup."
}

trap cleanup_on_error ERR

# ------------------------------------------------------------
# SAFETY CHECK
# ------------------------------------------------------------

section "PULSEOPS STAGE TERRAFORM DESTROY"

echo "This script will destroy:"
echo ""
echo "  Project      : ${PROJECT_NAME}"
echo "  Environment  : ${ENVIRONMENT}"
echo "  AWS Region   : ${AWS_REGION}"
echo "  EKS Cluster  : ${CLUSTER_NAME}"
echo "  Namespace    : ${NAMESPACE}"
echo ""
echo "This is DESTRUCTIVE."
echo ""

read -r -p "Type yes to continue: " CONFIRM

if [[ "${CONFIRM}" != "yes" ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

# ------------------------------------------------------------
# CHECK REQUIRED COMMANDS
# ------------------------------------------------------------

section "CHECKING REQUIRED TOOLS"

for command in aws terraform kubectl; do
    if ! command -v "${command}" >/dev/null 2>&1; then
        error "${command} is not installed or not in PATH."
        exit 1
    fi

    echo "${command}: $(command -v "${command}")"
done

success "Required tools are available."

# ------------------------------------------------------------
# AWS IDENTITY
# ------------------------------------------------------------

section "AWS IDENTITY"

aws sts get-caller-identity

# ------------------------------------------------------------
# TERRAFORM DIRECTORY
# ------------------------------------------------------------

section "TERRAFORM DIRECTORY"

cd "${TERRAFORM_DIR}"

echo "Terraform directory:"
pwd

echo ""
echo "Terraform variables:"
echo "${TFVARS_FILE}"

if [[ ! -f "${TFVARS_FILE}" ]]; then
    error "Terraform variables file not found:"
    error "${TERRAFORM_DIR}/${TFVARS_FILE}"
    exit 1
fi

# ------------------------------------------------------------
# TERRAFORM INIT
# ------------------------------------------------------------

section "TERRAFORM INIT"

terraform init -input=false

success "Terraform initialized."

# ------------------------------------------------------------
# TERRAFORM STATE
# ------------------------------------------------------------

section "TERRAFORM STATE"

terraform state list || true

# ------------------------------------------------------------
# EKS CHECK
# ------------------------------------------------------------

section "CHECKING EKS CLUSTER"

if aws eks describe-cluster \
    --name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    >/dev/null 2>&1; then

    success "EKS cluster ${CLUSTER_NAME} exists."

else

    warn "EKS cluster ${CLUSTER_NAME} does not exist."

fi

# ------------------------------------------------------------
# CONFIGURE KUBECTL
# ------------------------------------------------------------

section "CONFIGURING KUBECTL"

if aws eks describe-cluster \
    --name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    >/dev/null 2>&1; then

    aws eks update-kubeconfig \
        --region "${AWS_REGION}" \
        --name "${CLUSTER_NAME}"

    success "kubectl configured for ${CLUSTER_NAME}."

else

    warn "Skipping kubeconfig because EKS cluster does not exist."

fi

# ------------------------------------------------------------
# VERIFY KUBERNETES ACCESS
# ------------------------------------------------------------

section "VERIFYING KUBERNETES ACCESS"

if kubectl cluster-info >/dev/null 2>&1; then

    success "Kubernetes API is reachable."

    echo ""
    kubectl get nodes || true

else

    warn "Unable to authenticate to Kubernetes."

    if aws eks describe-cluster \
        --name "${CLUSTER_NAME}" \
        --region "${AWS_REGION}" \
        >/dev/null 2>&1; then

        error "EKS exists but kubectl authentication failed."
        error "Refusing to continue because Terraform Kubernetes/Helm resources may still exist."

        exit 1
    fi

    warn "EKS does not exist. Continuing with Terraform-only cleanup."

fi

# ============================================================
# KUBERNETES CLEANUP
# ============================================================

section "KUBERNETES APPLICATION CLEANUP"

if kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1; then

    echo "Current resources in ${NAMESPACE}:"
    echo ""

    kubectl get all -n "${NAMESPACE}" || true

    echo ""
    echo "Ingress:"
    kubectl get ingress -n "${NAMESPACE}" || true

    echo ""
    echo "ConfigMaps:"
    kubectl get configmaps -n "${NAMESPACE}" || true

    echo ""
    echo "Secrets:"
    kubectl get secrets -n "${NAMESPACE}" || true

    echo ""
    echo "Deleting application namespace..."

    kubectl delete namespace "${NAMESPACE}" \
        --ignore-not-found=true \
        --wait=true

    success "Namespace ${NAMESPACE} deleted."

else

    warn "Namespace ${NAMESPACE} does not exist."

fi

# ============================================================
# VERIFY HELM RELEASES
# ============================================================

section "HELM RELEASES"

if kubectl cluster-info >/dev/null 2>&1; then

    echo "Helm releases:"
    helm list --all-namespaces || true

fi

# ============================================================
# TERRAFORM DESTROY
# ============================================================

section "TERRAFORM DESTROY"

echo "Terraform will now destroy resources managed in state."
echo ""

terraform destroy \
    -input=false \
    -auto-approve \
    -var-file="${TFVARS_FILE}"

success "Terraform destroy completed."

# ============================================================
# VERIFY TERRAFORM STATE
# ============================================================

section "VERIFYING TERRAFORM STATE"

REMAINING_RESOURCES="$(terraform state list 2>/dev/null || true)"

if [[ -z "${REMAINING_RESOURCES}" ]]; then

    success "Terraform state is empty."

else

    warn "Terraform state still contains resources:"
    echo ""
    echo "${REMAINING_RESOURCES}"
    echo ""

fi

# ============================================================
# VERIFY AWS RESOURCES
# ============================================================

section "VERIFYING AWS CLEANUP"

echo "EKS:"
if aws eks describe-cluster \
    --name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    >/dev/null 2>&1; then

    warn "EKS cluster still exists."

else

    success "EKS cluster removed."

fi

echo ""
echo "ECR repositories:"

aws ecr describe-repositories \
    --region "${AWS_REGION}" \
    --query "repositories[?starts_with(repositoryName, \`${PROJECT_NAME}-${ENVIRONMENT}-\`)].repositoryName" \
    --output table \
    2>/dev/null || true

echo ""
echo "RDS:"

aws rds describe-db-instances \
    --region "${AWS_REGION}" \
    --query "DBInstances[?contains(DBInstanceIdentifier, \`${PROJECT_NAME}-${ENVIRONMENT}\`)].DBInstanceIdentifier" \
    --output table \
    2>/dev/null || true

echo ""
echo "ElastiCache:"

aws elasticache describe-cache-clusters \
    --region "${AWS_REGION}" \
    --query "CacheClusters[?contains(CacheClusterId, \`${PROJECT_NAME}-${ENVIRONMENT}\`)].CacheClusterId" \
    --output table \
    2>/dev/null || true

echo ""
echo "Secrets Manager:"

aws secretsmanager list-secrets \
    --region "${AWS_REGION}" \
    --query "SecretList[?contains(Name, \`${PROJECT_NAME}-${ENVIRONMENT}\`)].Name" \
    --output table \
    2>/dev/null || true

# ============================================================
# COMPLETE
# ============================================================

section "CLEANUP COMPLETE"

success "PulseOps ${ENVIRONMENT} cleanup finished."

echo ""
echo "Recommended final verification:"
echo ""
echo "  terraform state list"
echo "  aws eks list-clusters --region ${AWS_REGION}"
echo "  aws rds describe-db-instances --region ${AWS_REGION}"
echo "  aws elasticache describe-cache-clusters --region ${AWS_REGION}"
echo "  aws ecr describe-repositories --region ${AWS_REGION}"
echo ""