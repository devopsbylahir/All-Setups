#!/bin/bash

# INSTALL HELM
echo "Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod +x get_helm.sh
sudo ./get_helm.sh
helm version

# INSTALL ARGO CD USING HELM
echo "Adding ArgoCD Helm repository..."
helm repo add argo-cd https://argoproj.github.io/argo-helm
helm repo update

echo "Creating ArgoCD namespace..."
kubectl create namespace argocd || echo "Namespace 'argocd' already exists."

echo "Installing ArgoCD using Helm..."
helm install argocd argo-cd/argo-cd -n argocd --wait

echo "Checking ArgoCD deployment status..."
kubectl get all -n argocd

# EXPOSE ARGOCD SERVER
echo "Exposing ArgoCD server with a LoadBalancer..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

echo "Installing jq for JSON processing..."
sudo yum install -y jq

echo "Retrieving ArgoCD server LoadBalancer hostname..."
export ARGOCD_SERVER=$(kubectl get svc argocd-server -n argocd -o json | jq -r '.status.loadBalancer.ingress[0].hostname')
echo "ArgoCD Server: $ARGOCD_SERVER"

# TO GET ARGO CD PASSWORD
echo "Retrieving ArgoCD initial admin password..."
export ARGO_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD Admin Password: $ARGO_PWD"

# Display all necessary details
echo -e "\nArgoCD Login Details:"
echo "--------------------------------------"
echo "ArgoCD UI: https://$ARGOCD_SERVER"
echo "Username : admin"
echo "Password : $ARGO_PWD"
echo "--------------------------------------"

# END OF SCRIPT
