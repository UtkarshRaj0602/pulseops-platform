#!/usr/bin/env bash

set -uo pipefail

# ============================================================
# PulseOps Stage Deployment Validation
# ============================================================

ENVIRONMENT="stage"
AWS_REGION="${AWS_REGION:-ap-south-1}"
NAMESPACE="pulseops"
CLUSTER_NAME="${CLUSTER_NAME:-pulseops-stage}"

ACCOUNT_ID="${AWS_ACCOUNT_ID:-051826706795}"

ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

BACKEND_REPO="pulseops-stage-backend"
WORKER_REPO="pulseops-stage-worker"
FRONTEND_REPO="pulseops-stage-frontend"

DATABASE_SECRET="pulseops-stage-database"

SECRET_NAME="backend-secret"

FAILURES=0


# ============================================================
# Helpers
# ============================================================

section() {
    echo ""
    echo "============================================================"
    echo " $1"
    echo "============================================================"
}

pass() {
    echo "[PASS] $1"
}

fail() {
    echo "[FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

warn() {
    echo "[WARN] $1"
}

info() {
    echo "[INFO] $1"
}


# ============================================================
# AWS IDENTITY
# ============================================================

section "AWS IDENTITY"

aws sts get-caller-identity \
    --region "$AWS_REGION" >/tmp/pulseops-identity.json 2>/dev/null

if [ $? -eq 0 ]; then
    pass "AWS credentials are valid"
    cat /tmp/pulseops-identity.json
else
    fail "AWS credentials are invalid"
fi


# ============================================================
# EKS CLUSTER
# ============================================================

section "EKS CLUSTER"

EKS_STATUS=$(aws eks describe-cluster \
    --name "$CLUSTER_NAME" \
    --region "$AWS_REGION" \
    --query 'cluster.status' \
    --output text 2>/dev/null)

if [ "$EKS_STATUS" = "ACTIVE" ]; then
    pass "EKS cluster $CLUSTER_NAME is ACTIVE"
else
    fail "EKS cluster status is: ${EKS_STATUS:-NOT_FOUND}"
fi


# ============================================================
# KUBECTL ACCESS
# ============================================================

section "KUBECTL ACCESS"

if kubectl cluster-info >/dev/null 2>&1; then
    pass "kubectl can access EKS"
else
    fail "kubectl cannot access EKS"
fi


# ============================================================
# NODE STATUS
# ============================================================

section "EKS NODES"

kubectl get nodes -o wide || true

NOT_READY=$(kubectl get nodes \
    --no-headers 2>/dev/null |
    awk '$2 != "Ready" {count++} END {print count+0}')

if [ "$NOT_READY" -eq 0 ]; then
    pass "All EKS nodes are Ready"
else
    fail "$NOT_READY EKS node(s) are not Ready"
fi


# ============================================================
# NAMESPACE
# ============================================================

section "PULSEOPS NAMESPACE"

if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    pass "Namespace $NAMESPACE exists"
else
    fail "Namespace $NAMESPACE does not exist"
fi


# ============================================================
# ECR REPOSITORIES
# ============================================================

section "ECR REPOSITORIES"

for REPO in \
    "$BACKEND_REPO" \
    "$WORKER_REPO" \
    "$FRONTEND_REPO"
do

    if aws ecr describe-repositories \
        --repository-names "$REPO" \
        --region "$AWS_REGION" >/dev/null 2>&1
    then
        pass "ECR repository exists: $REPO"
    else
        fail "ECR repository missing: $REPO"
    fi

done


# ============================================================
# ECR IMAGE TAGS
# ============================================================

section "ECR IMAGE TAGS"

for REPO in \
    "$BACKEND_REPO" \
    "$WORKER_REPO" \
    "$FRONTEND_REPO"
do

    TAGS=$(aws ecr describe-images \
        --repository-name "$REPO" \
        --region "$AWS_REGION" \
        --query 'imageDetails[*].imageTags[]' \
        --output text 2>/dev/null)

    echo ""
    echo "$REPO:"
    echo "$TAGS"

    if echo "$TAGS" | grep -qw "latest"; then
        pass "$REPO has latest tag"
    else
        warn "$REPO does NOT have latest tag"
    fi

    if echo "$TAGS" | grep -qE '[0-9a-f]{40}'; then
        pass "$REPO has SHA-based image tag"
    else
        warn "$REPO does not appear to have a SHA-based tag"
    fi

done


# ============================================================
# SECRETS MANAGER
# ============================================================

section "AWS SECRETS MANAGER"

if aws secretsmanager describe-secret \
    --secret-id "$DATABASE_SECRET" \
    --region "$AWS_REGION" >/dev/null 2>&1
then
    pass "Secrets Manager secret exists: $DATABASE_SECRET"
else
    fail "Secrets Manager secret missing: $DATABASE_SECRET"
fi


# ============================================================
# SECRET CONTENT VALIDATION
# ============================================================

section "SECRETS MANAGER CONTENT"

SECRET_VALUE=$(aws secretsmanager get-secret-value \
    --secret-id "$DATABASE_SECRET" \
    --region "$AWS_REGION" \
    --query 'SecretString' \
    --output text 2>/dev/null)

if [ -n "$SECRET_VALUE" ] && [ "$SECRET_VALUE" != "None" ]; then

    if echo "$SECRET_VALUE" | jq -e '.username' >/dev/null 2>&1; then
        pass "Secrets Manager contains username"
    else
        fail "Secrets Manager is missing username"
    fi

    if echo "$SECRET_VALUE" | jq -e '.password' >/dev/null 2>&1; then
        pass "Secrets Manager contains password"
    else
        fail "Secrets Manager is missing password"
    fi

else
    fail "Unable to retrieve Secrets Manager secret"
fi


# ============================================================
# EXTERNAL SECRETS CRDs
# ============================================================

section "EXTERNAL SECRETS CRDs"

if kubectl get crd secretstores.external-secrets.io >/dev/null 2>&1; then
    pass "SecretStore CRD exists"
else
    fail "SecretStore CRD missing"
fi

if kubectl get crd externalsecrets.external-secrets.io >/dev/null 2>&1; then
    pass "ExternalSecret CRD exists"
else
    fail "ExternalSecret CRD missing"
fi

if kubectl get crd clustersecretstores.external-secrets.io >/dev/null 2>&1; then
    pass "ClusterSecretStore CRD exists"
else
    fail "ClusterSecretStore CRD missing"
fi


# ============================================================
# EXTERNAL SECRETS SERVICE ACCOUNT
# ============================================================

section "EXTERNAL SECRETS SERVICE ACCOUNT"

ESO_SA="external-secrets"

if kubectl get sa "$ESO_SA" \
    -n external-secrets >/dev/null 2>&1
then

    pass "External Secrets ServiceAccount exists"

    ESO_ROLE=$(kubectl get sa "$ESO_SA" \
        -n external-secrets \
        -o jsonpath='{.metadata.annotations.eks\.amazonaws\.com/role-arn}' \
        2>/dev/null)

    if [ -n "$ESO_ROLE" ]; then
        pass "External Secrets ServiceAccount has Pod Identity/IRSA role"
        echo "Role: $ESO_ROLE"
    else
        fail "External Secrets ServiceAccount has no AWS role annotation"
    fi

else
    fail "External Secrets ServiceAccount does not exist"
fi


# ============================================================
# CLUSTER SECRET STORE
# ============================================================

section "CLUSTER SECRET STORE"

if kubectl get clustersecretstore aws-secretsmanager >/dev/null 2>&1; then

    pass "ClusterSecretStore exists"

    kubectl get clustersecretstore \
        aws-secretsmanager

    READY=$(kubectl get clustersecretstore \
        aws-secretsmanager \
        -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' \
        2>/dev/null)

    if [ "$READY" = "True" ]; then
        pass "ClusterSecretStore is Ready"
    else
        fail "ClusterSecretStore is NOT Ready"
        kubectl describe clustersecretstore aws-secretsmanager || true
    fi

else
    fail "ClusterSecretStore aws-secretsmanager does not exist"
fi


# ============================================================
# EXTERNAL SECRET
# ============================================================

section "EXTERNAL SECRET"

if kubectl get externalsecret "$SECRET_NAME" \
    -n "$NAMESPACE" >/dev/null 2>&1
then

    pass "ExternalSecret $SECRET_NAME exists"

    kubectl get externalsecret "$SECRET_NAME" \
        -n "$NAMESPACE"

    READY=$(kubectl get externalsecret "$SECRET_NAME" \
        -n "$NAMESPACE" \
        -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' \
        2>/dev/null)

    if [ "$READY" = "True" ]; then
        pass "ExternalSecret is Ready"
    else
        fail "ExternalSecret is NOT Ready"
        kubectl describe externalsecret "$SECRET_NAME" \
            -n "$NAMESPACE" || true
    fi

else
    fail "ExternalSecret $SECRET_NAME does not exist"
fi


# ============================================================
# KUBERNETES SECRET
# ============================================================

section "KUBERNETES SECRET"

if kubectl get secret "$SECRET_NAME" \
    -n "$NAMESPACE" >/dev/null 2>&1
then

    pass "Kubernetes Secret $SECRET_NAME exists"

    SECRET_KEYS=$(kubectl get secret "$SECRET_NAME" \
        -n "$NAMESPACE" \
        -o json \
        | jq -r '.data | keys[]' 2>/dev/null)

    echo "Keys:"
    echo "$SECRET_KEYS"

    if echo "$SECRET_KEYS" | grep -qx "username"; then
        pass "backend-secret contains username"
    else
        fail "backend-secret missing username"
    fi

    if echo "$SECRET_KEYS" | grep -qx "password"; then
        pass "backend-secret contains password"
    else
        fail "backend-secret missing password"
    fi

else
    fail "Kubernetes Secret backend-secret does not exist"
fi


# ============================================================
# CONFIGMAPS
# ============================================================

section "CONFIGMAPS"

for CM in backend-config worker-config; do

    if kubectl get configmap "$CM" \
        -n "$NAMESPACE" >/dev/null 2>&1
    then
        pass "ConfigMap exists: $CM"
    else
        fail "ConfigMap missing: $CM"
    fi

done


# ============================================================
# KUBERNETES DEPLOYMENTS
# ============================================================

section "DEPLOYMENTS"

kubectl get deployments \
    -n "$NAMESPACE" || true

for APP in backend worker frontend; do

    if kubectl get deployment "$APP" \
        -n "$NAMESPACE" >/dev/null 2>&1
    then
        pass "Deployment exists: $APP"
    else
        fail "Deployment missing: $APP"
    fi

done


# ============================================================
# DEPLOYMENT IMAGE VALIDATION
# ============================================================

section "DEPLOYMENT IMAGES"

for APP in backend worker frontend; do

    IMAGE=$(kubectl get deployment "$APP" \
        -n "$NAMESPACE" \
        -o jsonpath='{.spec.template.spec.containers[0].image}' \
        2>/dev/null)

    echo "$APP -> $IMAGE"

    if [ -z "$IMAGE" ]; then
        fail "$APP has no container image"
        continue
    fi

    if echo "$IMAGE" | grep -q ":latest"; then
        warn "$APP uses :latest"
    else
        pass "$APP uses immutable image tag"
    fi

done


# ============================================================
# POD STATUS
# ============================================================

section "PODS"

kubectl get pods \
    -n "$NAMESPACE" \
    -o wide || true


# ============================================================
# CHECK POD FAILURE STATES
# ============================================================

section "POD FAILURE CHECK"

BAD_PODS=$(kubectl get pods \
    -n "$NAMESPACE" \
    --no-headers 2>/dev/null |
    awk '$3 ~ /CrashLoopBackOff|ImagePullBackOff|ErrImagePull|CreateContainerConfigError|CreateContainerError|Error|Pending/ {print $1}')

if [ -n "$BAD_PODS" ]; then

    fail "Pods are not healthy"

    echo "$BAD_PODS"

    for POD in $BAD_PODS; do

        echo ""
        echo "---------- $POD ----------"

        kubectl describe pod "$POD" \
            -n "$NAMESPACE" || true

    done

else

    pass "No obvious pod failure states detected"

fi


# ============================================================
# SERVICES
# ============================================================

section "SERVICES"

kubectl get svc \
    -n "$NAMESPACE" || true

for APP in backend frontend; do

    if kubectl get svc "$APP" \
        -n "$NAMESPACE" >/dev/null 2>&1
    then
        pass "Service exists: $APP"
    else
        fail "Service missing: $APP"
    fi

done


# ============================================================
# SERVICE ENDPOINTS
# ============================================================

section "SERVICE ENDPOINTS"

for APP in backend frontend; do

    echo ""
    echo "Service: $APP"

    kubectl get endpointslice \
        -n "$NAMESPACE" \
        -l "kubernetes.io/service-name=$APP" \
        -o wide 2>/dev/null || true

    READY_ENDPOINTS=$(kubectl get endpointslice \
        -n "$NAMESPACE" \
        -l "kubernetes.io/service-name=$APP" \
        -o json 2>/dev/null |
        jq '[.items[].endpoints[]? | select(.conditions.ready == true)] | length')

    if [ "$READY_ENDPOINTS" -gt 0 ]; then
        pass "$APP has $READY_ENDPOINTS ready endpoint(s)"
    else
        fail "$APP has NO ready endpoints"
    fi

done


# ============================================================
# INGRESS
# ============================================================

section "INGRESS"

kubectl get ingress \
    -n "$NAMESPACE" \
    -o wide || true

INGRESS_COUNT=$(kubectl get ingress \
    -n "$NAMESPACE" \
    --no-headers 2>/dev/null | wc -l)

if [ "$INGRESS_COUNT" -gt 0 ]; then
    pass "Ingress exists"
else
    fail "No ingress found"
fi


# ============================================================
# ALB CONTROLLER
# ============================================================

section "AWS LOAD BALANCER CONTROLLER"

ALB_PODS=$(kubectl get pods \
    -n kube-system \
    -l app.kubernetes.io/name=aws-load-balancer-controller \
    --no-headers 2>/dev/null |
    awk '$3 == "Running" {count++} END {print count+0}')

if [ "$ALB_PODS" -gt 0 ]; then
    pass "AWS Load Balancer Controller is running"
else
    fail "AWS Load Balancer Controller is not running"
fi


# ============================================================
# ALB TARGET GROUPS
# ============================================================

section "ALB TARGET GROUPS"

TG_ARNS=$(aws elbv2 describe-target-groups \
    --region "$AWS_REGION" \
    --query "TargetGroups[?contains(TargetGroupName, \`k8s-${NAMESPACE}\`)].TargetGroupArn" \
    --output text 2>/dev/null)

if [ -z "$TG_ARNS" ]; then

    warn "No Kubernetes ALB target groups found"

else

    for ARN in $TG_ARNS; do

        echo ""
        echo "Target Group:"
        echo "$ARN"

        TARGET_COUNT=$(aws elbv2 describe-target-health \
            --target-group-arn "$ARN" \
            --region "$AWS_REGION" \
            --query 'length(TargetHealthDescriptions)' \
            --output text 2>/dev/null)

        HEALTHY_COUNT=$(aws elbv2 describe-target-health \
            --target-group-arn "$ARN" \
            --region "$AWS_REGION" \
            --query "length(TargetHealthDescriptions[?TargetHealth.State=='healthy'])" \
            --output text 2>/dev/null)

        echo "Targets : ${TARGET_COUNT:-0}"
        echo "Healthy : ${HEALTHY_COUNT:-0}"

        if [ "${TARGET_COUNT:-0}" -gt 0 ]; then
            pass "Target group has registered targets"
        else
            fail "Target group has ZERO targets"
        fi

        if [ "${HEALTHY_COUNT:-0}" -gt 0 ]; then
            pass "Target group has healthy targets"
        else
            warn "Target group currently has no healthy targets"
        fi

    done

fi


# ============================================================
# CLUSTER AUTOSCALER
# ============================================================

section "CLUSTER AUTOSCALER"

CA_PODS=$(kubectl get pods \
    -n kube-system \
    -l app.kubernetes.io/name=aws-cluster-autoscaler \
    --no-headers 2>/dev/null |
    awk '$3 == "Running" {count++} END {print count+0}')

if [ "$CA_PODS" -gt 0 ]; then
    pass "Cluster Autoscaler is running"
else
    fail "Cluster Autoscaler is not running"
fi


# ============================================================
# HPA
# ============================================================

section "HPA"

kubectl get hpa \
    -n "$NAMESPACE" || true


# ============================================================
# PDB
# ============================================================

section "PDB"

kubectl get pdb \
    -n "$NAMESPACE" || true


# ============================================================
# NETWORK POLICIES
# ============================================================

section "NETWORK POLICIES"

kubectl get networkpolicy \
    -n "$NAMESPACE" || true


# ============================================================
# KUBE MANIFEST VALIDATION
# ============================================================

section "KUBERNETES MANIFEST VALIDATION"

if command -v kubeconform >/dev/null 2>&1; then

    echo "Running kubeconform..."

    if find infrastructure/kubernetes \
        -name "*.yaml" \
        -print0 |
        xargs -0 kubeconform \
        -strict \
        -summary \
        -kubernetes-version 1.36.0
    then
        pass "All Kubernetes manifests passed kubeconform"
    else
        fail "Kubernetes manifest validation failed"
    fi

else

    warn "kubeconform is not installed; skipping local schema validation"

fi


# ============================================================
# TERRAFORM STATE
# ============================================================

section "TERRAFORM STATE"

if [ -d "infrastructure/terraform" ]; then

    cd infrastructure/terraform

    terraform state list 2>/dev/null || true

    echo ""
    echo "Checking important Terraform modules..."

    for MODULE in \
        module.vpc \
        module.security \
        module.iam \
        module.ecr \
        module.sqs \
        module.secrets \
        module.rds \
        module.redis \
        module.eks \
        module.irsa \
        module.helm \
        module.namespace \
        module.k8s_secrets \
        module.configmap \
        module.cluster_autoscaler
    do

        if terraform state list 2>/dev/null |
            grep -q "^${MODULE}"
        then
            pass "Terraform state contains $MODULE"
        else
            warn "Terraform state does not contain $MODULE"
        fi

    done

    cd - >/dev/null

else

    warn "infrastructure/terraform directory not found"

fi


# ============================================================
# FINAL SUMMARY
# ============================================================

section "FINAL VALIDATION SUMMARY"

if [ "$FAILURES" -eq 0 ]; then

    echo ""
    echo "============================================================"
    echo "                 VALIDATION PASSED"
    echo "============================================================"
    echo ""
    echo "PulseOps stage infrastructure appears healthy."
    echo ""
    echo "Safe to continue with application deployment."
    echo ""

    exit 0

else

    echo ""
    echo "============================================================"
    echo "                 VALIDATION FAILED"
    echo "============================================================"
    echo ""
    echo "Failures detected: $FAILURES"
    echo ""
    echo "DO NOT continue with application deployment."
    echo "Fix the failures above first."
    echo ""

    exit 1

fi