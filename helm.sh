# Download the Helm installation script
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

# Grant execute permissions to the script
chmod +x get_helm.sh

# Run the installation script with root privileges
sudo ./get_helm.sh

# Verify Helm installation
helm version
