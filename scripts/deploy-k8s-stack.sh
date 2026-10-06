#!/bin/bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-ap-south-1}"
CLUSTER_NAME="${CLUSTER_NAME:-dr-automator-dev-eks}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
KUBERNETES_DIR="${ROOT_DIR}/kubernetes"
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BACKEND_IMAGE="${BACKEND_IMAGE:-${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/backend:v1}"
FRONTEND_IMAGE="${FRONTEND_IMAGE:-${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/frontend:v2}"
PRIMARY_DB_HOST="$(aws rds describe-db-instances --db-instance-identifier dr-automator-dev-mysql --region "${AWS_REGION}" --query 'DBInstances[0].Endpoint.Address' --output text 2>/dev/null || echo "dr-automator-dev-mysql.cro6me0wg643.ap-south-1.rds.amazonaws.com")"

ensure_ecr_repo() {
  local repo_name="$1"
  if ! aws ecr describe-repositories --region "${AWS_REGION}" --repository-names "${repo_name}" >/dev/null 2>&1; then
    echo "[INFO] Creating ECR repository: ${repo_name}"
    aws ecr create-repository --repository-name "${repo_name}" --region "${AWS_REGION}" >/dev/null
  fi
}

build_and_push_image() {
  local repo_name="$1"
  local tag="$2"
  local context_dir="$3"
  local image_ref="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${repo_name}:${tag}"

  echo "[INFO] Building image ${image_ref} from ${context_dir}"
  aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
  docker build -t "${image_ref}" "${context_dir}"
  docker push "${image_ref}"
}

echo "[INFO] Verifying EKS cluster: ${CLUSTER_NAME} (${AWS_REGION})"
aws eks describe-cluster \
  --name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" >/dev/null

ensure_ecr_repo backend
ensure_ecr_repo frontend
build_and_push_image backend v1 "${ROOT_DIR}/backend"
build_and_push_image frontend v2 "${ROOT_DIR}/frontend"

if ! kubectl get ns dr-automator >/dev/null 2>&1; then
  echo "[INFO] Creating namespace dr-automator"
  kubectl apply -f "${KUBERNETES_DIR}/namespace.yaml"
fi

kubectl create configmap dr-automator-config -n dr-automator \
  --from-literal=NODE_ENV=production \
  --from-literal=AWS_REGION="${AWS_REGION}" \
  --from-literal=LOG_LEVEL=info \
  --from-literal=PORT=5000 \
  --from-literal=FRONTEND_PORT=3000 \
  --from-literal=DB_HOST="${PRIMARY_DB_HOST}" \
  --from-literal=DB_PORT=3306 \
  --from-literal=DB_NAME=drautomator \
  --from-literal=DB_SSL=false \
  --from-literal=HEALTH_CHECK_PATH=/health \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic dr-automator-secret -n dr-automator \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASSWORD=Laptop#2026 \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f "${KUBERNETES_DIR}/backend/service.yaml"
kubectl apply -f "${KUBERNETES_DIR}/frontend/service.yaml"

cat > /tmp/backend-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: dr-automator
  labels:
    app: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: ${BACKEND_IMAGE}
        imagePullPolicy: Always
        ports:
        - containerPort: 5000
        envFrom:
        - configMapRef:
            name: dr-automator-config
        - secretRef:
            name: dr-automator-secret
        resources:
          requests:
            cpu: "250m"
            memory: "256Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 20
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
EOF

cat > /tmp/frontend-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: dr-automator
  labels:
    app: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: ${FRONTEND_IMAGE}
        imagePullPolicy: Always
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          valueFrom:
            configMapKeyRef:
              name: dr-automator-config
              key: NODE_ENV
        - name: PORT
          value: "3000"
        resources:
          requests:
            cpu: "250m"
            memory: "256Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
        readinessProbe:
          httpGet:
            path: /
            port: 3000
          initialDelaySeconds: 20
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        livenessProbe:
          httpGet:
            path: /
            port: 3000
          initialDelaySeconds: 40
          periodSeconds: 20
          timeoutSeconds: 5
          failureThreshold: 3
EOF

kubectl apply -f /tmp/backend-deployment.yaml
kubectl apply -f /tmp/frontend-deployment.yaml

if ! kubectl get sa -n kube-system aws-load-balancer-controller >/dev/null 2>&1; then
  kubectl apply -f "${KUBERNETES_DIR}/aws-load-balancer-controller-sa.yaml"
fi

if kubectl get deployment -n kube-system aws-load-balancer-controller >/dev/null 2>&1; then
  echo "[INFO] Reinstalling AWS Load Balancer Controller to refresh stale webhook state"
  helm uninstall aws-load-balancer-controller -n kube-system --wait >/dev/null 2>&1 || true
  kubectl delete mutatingwebhookconfigurations,validatingwebhookconfigurations -l app.kubernetes.io/name=aws-load-balancer-controller --ignore-not-found=true >/dev/null 2>&1 || true
  kubectl delete secret -n kube-system aws-load-balancer-tls --ignore-not-found=true >/dev/null 2>&1 || true
  kubectl delete service -n kube-system aws-load-balancer-webhook-service --ignore-not-found=true >/dev/null 2>&1 || true
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
