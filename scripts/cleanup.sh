#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# PULSEOPS STAGE - FORCE CLEANUP
#
# Purpose:
#   Destroy the entire PulseOps Stage environment even when
#   Kubernetes/Helm cleanup cannot communicate with EKS.
#
# WARNING:
#   THIS IS DESTRUCTIVE.
#
#   This script is intended ONLY for the disposable Stage
#   environment.
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
# LOGGING
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

# ------------------------------------------------------------
# ERROR HANDLING
# ------------------------------------------------------------

trap 'error "Command failed at line ${LINENO}: ${BASH_COMMAND}"' ERR

# ------------------------------------------------------------
# SAFETY CHECK
# ------------------------------------------------------------

section "PULSEOPS STAGE FORCE CLEANUP"

echo "THIS WILL DESTROY THE STAGE ENVIRONMENT."
echo ""
echo "Project      : ${PROJECT_NAME}"
echo "Environment  : ${ENVIRONMENT}"
echo "AWS Region   : ${AWS_REGION}"
echo "EKS Cluster  : ${CLUSTER_NAME}"
echo "Namespace    : ${NAMESPACE}"
echo ""

read -r -p "Type yes to continue: " CONFIRM

if [[ "${CONFIRM}" != "yes" ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

# ------------------------------------------------------------
# REQUIRED TOOLS
# ------------------------------------------------------------

section "CHECKING REQUIRED TOOLS"

for command in aws terraform kubectl helm; do
    if ! command -v "${command}" >/dev/null 2>&1; then
        warn "${command} is not installed or not in PATH."
    else
        echo "${command}: $(command -v "${command}")"
    fi
done

success "Tool check completed."

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

if [[ ! -f "${TFVARS_FILE}" ]]; then
    error "Terraform variables file not found:"
    error "${TERRAFORM_DIR}/${TFVARS_FILE}"
    exit 1
fi

echo ""
echo "Terraform variables:"
echo "${TFVARS_FILE}"

# ------------------------------------------------------------
# TERRAFORM INIT
# ------------------------------------------------------------

section "TERRAFORM INIT"

terraform init -input=false

success "Terraform initialized."

# ------------------------------------------------------------
# CURRENT TERRAFORM STATE
# ------------------------------------------------------------

section "CURRENT TERRAFORM STATE"

terraform state list 2>/dev/null || true

# ============================================================
# EKS DISCOVERY
# ============================================================

section "CHECKING EKS CLUSTER"

EKS_EXISTS=false

if aws eks describe-cluster \
    --name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    >/dev/null 2>&1; then

    EKS_EXISTS=true
    success "EKS cluster ${CLUSTER_NAME} exists."

else
    warn "EKS cluster ${CLUSTER_NAME} does not exist."
fi

# ============================================================
# TRY KUBERNETES CLEANUP
# ============================================================

K8S_ACCESS=false

if [[ "${EKS_EXISTS}" == "true" ]]; then

    section "CONFIGURING KUBECTL"

    aws eks update-kubeconfig \
        --region "${AWS_REGION}" \
        --name "${CLUSTER_NAME}" || true

    if kubectl cluster-info >/dev/null 2>&1; then

        K8S_ACCESS=true

        success "Kubernetes API is reachable."

        echo ""
        kubectl get nodes || true

    else

        warn "Kubernetes authentication failed."
        warn "Falling back to AWS-level EKS cleanup."
    fi
fi

# ============================================================
# KUBERNETES CLEANUP
# ============================================================

if [[ "${K8S_ACCESS}" == "true" ]]; then

    section "KUBERNETES APPLICATION CLEANUP"

    echo "Services:"
    kubectl get svc --all-namespaces || true

    echo ""
    echo "Ingress:"
    kubectl get ingress --all-namespaces || true

    echo ""
    echo "Pods:"
    kubectl get pods --all-namespaces || true

    # --------------------------------------------------------
    # Delete project namespace
    # --------------------------------------------------------

    if kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1; then

        echo ""
        echo "Deleting namespace ${NAMESPACE}..."

        kubectl delete namespace "${NAMESPACE}" \
            --ignore-not-found=true \
            --wait=true || true

        success "Namespace cleanup attempted."

    else

        warn "Namespace ${NAMESPACE} does not exist."
    fi

    # --------------------------------------------------------
    # Helm releases
    # --------------------------------------------------------

    section "HELM RELEASES"

    helm list --all-namespaces || true

    # Known platform releases
    for RELEASE_NAMESPACE in \
        "external-secrets:external-secrets" \
        "metrics-server:kube-system" \
        "aws-load-balancer-controller:kube-system"
    do

        RELEASE="${RELEASE_NAMESPACE%%:*}"
        NS="${RELEASE_NAMESPACE##*:}"

        if helm status "${RELEASE}" -n "${NS}" >/dev/null 2>&1; then

            echo "Uninstalling ${RELEASE} from ${NS}..."

            helm uninstall "${RELEASE}" \
                -n "${NS}" \
                --wait || true

        fi
    done

    success "Helm cleanup attempted."

else

    warn "Skipping Kubernetes/Helm cleanup because Kubernetes API is unavailable."

fi

# ============================================================
# EKS AWS-LEVEL CLEANUP
# ============================================================

if [[ "${EKS_EXISTS}" == "true" ]]; then

    section "AWS-LEVEL EKS CLEANUP"

    # --------------------------------------------------------
    # Managed Node Groups
    # --------------------------------------------------------

    echo "Checking managed node groups..."

    NODEGROUPS="$(
        aws eks list-nodegroups \
            --cluster-name "${CLUSTER_NAME}" \
            --region "${AWS_REGION}" \
            --query 'nodegroups[]' \
            --output text 2>/dev/null || true
    )"

    if [[ -n "${NODEGROUPS}" ]]; then

        for NODEGROUP in ${NODEGROUPS}; do

            echo ""
            echo "Deleting node group: ${NODEGROUP}"

            aws eks delete-nodegroup \
                --cluster-name "${CLUSTER_NAME}" \
                --nodegroup-name "${NODEGROUP}" \
                --region "${AWS_REGION}" || true

        done

        echo ""
        echo "Waiting for managed node groups to disappear..."

        for NODEGROUP in ${NODEGROUPS}; do

            aws eks wait nodegroup-deleted \
                --cluster-name "${CLUSTER_NAME}" \
                --nodegroup-name "${NODEGROUP}" \
                --region "${AWS_REGION}" || true

        done

        success "Managed node group cleanup completed."

    else

        warn "No managed node groups found."
    fi

    # --------------------------------------------------------
    # Fargate Profiles
    # --------------------------------------------------------

    echo ""
    echo "Checking Fargate profiles..."

    FARGATE_PROFILES="$(
        aws eks list-fargate-profiles \
            --cluster-name "${CLUSTER_NAME}" \
            --region "${AWS_REGION}" \
            --query 'fargateProfileNames[]' \
            --output text 2>/dev/null || true
    )"

    if [[ -n "${FARGATE_PROFILES}" ]]; then

        for PROFILE in ${FARGATE_PROFILES}; do

            echo "Deleting Fargate profile: ${PROFILE}"

            aws eks delete-fargate-profile \
                --cluster-name "${CLUSTER_NAME}" \
                --fargate-profile-name "${PROFILE}" \
                --region "${AWS_REGION}" || true

            aws eks wait fargate-profile-deleted \
                --cluster-name "${CLUSTER_NAME}" \
                --fargate-profile-name "${PROFILE}" \
                --region "${AWS_REGION}" || true

        done

        success "Fargate profile cleanup completed."

    else

        warn "No Fargate profiles found."
    fi

    # --------------------------------------------------------
    # EKS Add-ons
    # --------------------------------------------------------

    section "EKS ADD-ONS"

    ADDONS="$(
        aws eks list-addons \
            --cluster-name "${CLUSTER_NAME}" \
            --region "${AWS_REGION}" \
            --query 'addons[]' \
            --output text 2>/dev/null || true
    )"

    if [[ -n "${ADDONS}" ]]; then

        for ADDON in ${ADDONS}; do

            echo "Deleting addon: ${ADDON}"

            aws eks delete-addon \
                --cluster-name "${CLUSTER_NAME}" \
                --addon-name "${ADDON}" \
                --region "${AWS_REGION}" \
                --preserve || true

        done

    else

        warn "No EKS add-ons found."
    fi

    # --------------------------------------------------------
    # EKS Cluster
    # --------------------------------------------------------

    section "DELETING EKS CLUSTER"

    echo "Deleting EKS cluster ${CLUSTER_NAME}..."

    aws eks delete-cluster \
        --name "${CLUSTER_NAME}" \
        --region "${AWS_REGION}" || true

    echo ""
    echo "Waiting for EKS cluster deletion..."

    aws eks wait cluster-deleted \
        --name "${CLUSTER_NAME}" \
        --region "${AWS_REGION}" || true

    success "EKS cluster deletion requested/completed."

else

    warn "EKS cluster does not exist. Skipping EKS cleanup."
fi

# ============================================================
# REMOVE ORPHANED KUBERNETES / HELM STATE
# ============================================================

section "CLEANING TERRAFORM KUBERNETES / HELM STATE"

STATE_RESOURCES="$(terraform state list 2>/dev/null || true)"

if [[ -n "${STATE_RESOURCES}" ]]; then

    echo "Removing Kubernetes/Helm resources from Terraform state"
    echo "because the EKS cluster has been removed or Kubernetes is"
    echo "otherwise unavailable."
    echo ""

    while IFS= read -r RESOURCE; do

        if [[ "${RESOURCE}" =~ ^module\.helm\. ]] ||
           [[ "${RESOURCE}" =~ ^module\.kubernetes\. ]]; then

            echo "Removing from Terraform state:"
            echo "  ${RESOURCE}"

            terraform state rm "${RESOURCE}" || true

        fi

    done <<< "${STATE_RESOURCES}"

else

    warn "Terraform state is already empty."
fi

# ============================================================
# TERRAFORM DESTROY
# ============================================================

section "TERRAFORM DESTROY"

echo "Destroying remaining Terraform-managed AWS infrastructure."
echo ""

terraform destroy \
    -input=false \
    -auto-approve \
    -var-file="${TFVARS_FILE}" || {

    error "Terraform destroy encountered errors."

    echo ""
    echo "Current Terraform state:"
    terraform state list || true

    exit 1
}

success "Terraform destroy completed."

# ============================================================
# FINAL TERRAFORM STATE
# ============================================================

section "VERIFYING TERRAFORM STATE"

REMAINING_RESOURCES="$(terraform state list 2>/dev/null || true)"

if [[ -z "${REMAINING_RESOURCES}" ]]; then

    success "Terraform state is empty."

else

    warn "Terraform state still contains:"
    echo ""
    echo "${REMAINING_RESOURCES}"
fi

# ============================================================
# EKS VERIFICATION
# ============================================================

section "VERIFYING EKS"

if aws eks describe-cluster \
    --name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    >/dev/null 2>&1; then

    warn "EKS cluster still exists."

else

    success "EKS cluster removed."
fi

# ============================================================
# ECR
# ============================================================

section "VERIFYING ECR"

aws ecr describe-repositories \
    --region "${AWS_REGION}" \
    --query "repositories[?starts_with(repositoryName, \`${PROJECT_NAME}-${ENVIRONMENT}-\`)].repositoryName" \
    --output table \
    2>/dev/null || true

# ============================================================
# RDS
# ============================================================

section "VERIFYING RDS"

aws rds describe-db-instances \
    --region "${AWS_REGION}" \
    --query "DBInstances[?contains(DBInstanceIdentifier, \`${PROJECT_NAME}-${ENVIRONMENT}\`)].DBInstanceIdentifier" \
    --output table \
    2>/dev/null || true

# ============================================================
# ELASTICACHE
# ============================================================

section "VERIFYING ELASTICACHE"

aws elasticache describe-cache-clusters \
    --region "${AWS_REGION}" \
    --query "CacheClusters[?contains(CacheClusterId, \`${PROJECT_NAME}-${ENVIRONMENT}\`)].CacheClusterId" \
    --output table \
    2>/dev/null || true

# ============================================================
# SECRETS
# ============================================================

section "VERIFYING SECRETS MANAGER"

aws secretsmanager list-secrets \
    --region "${AWS_REGION}" \
    --query "SecretList[?contains(Name, \`${PROJECT_NAME}-${ENVIRONMENT}\`)].Name" \
    --output table \
    2>/dev/null || true

# ============================================================
# FINAL
# ============================================================

section "PULSEOPS STAGE CLEANUP COMPLETE"

success "Cleanup process finished."

echo ""
echo "Final recommended checks:"
echo ""
echo "  terraform state list"
echo "  aws eks list-clusters --region ${AWS_REGION}"
echo "  aws rds describe-db-instances --region ${AWS_REGION}"
echo "  aws elasticache describe-cache-clusters --region ${AWS_REGION}"
echo "  aws ecr describe-repositories --region ${AWS_REGION}"
echo "  aws secretsmanager list-secrets --region ${AWS_REGION}"
echo ""
