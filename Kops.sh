#!/bin/bash

# Ensure AWS CLI, curl, wget are installed
if ! command -v aws &>/dev/null || ! command -v curl &>/dev/null || ! command -v wget &>/dev/null; then
  echo "Error: AWS CLI, curl, or wget not installed."
  exit 1
fi

# Set AWS credentials (replace with actual values if automating)
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-south-1"

# Download kubectl and kops binaries
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
wget -O kops "https://github.com/kubernetes/kops/releases/download/v1.25.0/kops-linux-amd64"

# Make binaries executable
chmod +x kubectl kops

# Move binaries to /usr/local/bin
sudo mv kubectl /usr/local/bin/
sudo mv kops /usr/local/bin/

# Refresh command cache
export PATH=$PATH:/usr/local/bin
hash -r  # Refresh command cache

# Validate kops installation
if ! command -v kops &>/dev/null; then
  echo "Error: kops command not found. Please check /usr/local/bin permissions."
  exit 1
fi

# Set bucket name and cluster parameters
BUCKET_NAME="lahir123.k8s.local"
CLUSTER_NAME="bobby123.k8s.local"
REGION="ap-south-1"
ZONE="ap-south-1a"
MASTER_SIZE="t2.medium"
NODE_SIZE="t2.micro"

# Check if S3 bucket exists before creating
if aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'; then
  aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION"
  aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled
else
  echo "Bucket $BUCKET_NAME already exists, skipping creation."
fi

# Export KOPS state store
export KOPS_STATE_STORE="s3://$BUCKET_NAME"
echo "export KOPS_STATE_STORE=s3://$BUCKET_NAME" >> ~/.bashrc
source ~/.bashrc

# Wait for S3 sync (if needed)
sleep 10

# Create Kubernetes cluster with Kops
kops create cluster --name "$CLUSTER_NAME" --zones "$ZONE" --master-count=1 --master-size "$MASTER_SIZE" --node-count=2 --node-size "$NODE_SIZE"

# Apply cluster changes
kops update cluster --name "$CLUSTER_NAME" --yes --admin

# Explicitly apply the cluster (important)
kops rolling-update cluster --yes

# Validate the cluster with extended wait time
kops validate cluster --wait 15m
