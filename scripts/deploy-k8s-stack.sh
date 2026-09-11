#!/bin/bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-ap-south-1}"
CLUSTER_NAME="${CLUSTER_NAME:-dr-automator-dev-eks}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
KUBERNETES_DIR="${ROOT_DIR}/kubernetes"

echo "[INFO] Verifying EKS cluster: ${CLUSTER_NAME} (${AWS_REGION})"
aws eks describe-cluster \
  --name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" >/dev/null

if ! kubectl get ns dr-automator >/dev/null 2>&1; then
  echo "[INFO] Creating namespace dr-automator"
  kubectl apply -f "${KUBERNETES_DIR}/namespace.yaml"
fi

kubectl apply -f "${KUBERNETES_DIR}/configmap.yaml"
kubectl apply -f "${KUBERNETES_DIR}/secret.yaml"
kubectl apply -f "${KUBERNETES_DIR}/backend/deployment.yaml"
kubectl apply -f "${KUBERNETES_DIR}/backend/service.yaml"
kubectl apply -f "${KUBERNETES_DIR}/frontend/deployment.yaml"
kubectl apply -f "${KUBERNETES_DIR}/frontend/service.yaml"

if ! kubectl get sa -n kube-system aws-load-balancer-controller >/dev/null 2>&1; then
  kubectl apply -f "${KUBERNETES_DIR}/aws-load-balancer-controller-sa.yaml"
fi

if ! kubectl get deployment -n kube-system aws-load-balancer-controller >/dev/null 2>&1; then
  echo "[INFO] Installing AWS Load Balancer Controller"
  helm repo add eks https://aws.github.io/eks-charts >/dev/null 2>&1
  helm repo update >/dev/null 2>&1

  VPC_ID=$(aws eks describe-cluster \
    --name "${CLUSTER_NAME}" \
    --region "${AWS_REGION}" \
    --query 'cluster.resourcesVpcConfig.vpcId' \
    --output text)

  helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName="${CLUSTER_NAME}" \
    --set region="${AWS_REGION}" \
    --set vpcId="${VPC_ID}" \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set ingressClass=alb \
    --wait
fi

kubectl apply -f "${KUBERNETES_DIR}/ingress/ingressclass.yaml"
kubectl apply -f "${KUBERNETES_DIR}/ingress/ingress.yaml"

kubectl rollout status deployment/backend -n dr-automator --timeout=180s
kubectl rollout status deployment/frontend -n dr-automator --timeout=180s
kubectl rollout status deployment/aws-load-balancer-controller -n kube-system --timeout=180s

echo
kubectl get ingress -n dr-automator -o wide
kubectl get svc -n dr-automator -o wide

echo
echo "[INFO] ALB is being provisioned by the AWS Load Balancer Controller"
