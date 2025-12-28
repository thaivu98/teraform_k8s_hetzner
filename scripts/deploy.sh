#!/bin/bash
set -e

# Usage: ./deploy.sh <environment> <cluster_name>
# Example: ./deploy.sh prod k8s-cluster-1

ENV=$1
CLUSTER=$2

if [ -z "$ENV" ] || [ -z "$CLUSTER" ]; then
  echo "Usage: $0 <environment> <cluster_name>"
  exit 1
fi

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
INFRA_DIR="$BASE_DIR/infrastructure/live/$ENV/$CLUSTER"
KUBESPRAY_DIR="$BASE_DIR/kubespray"
INVENTORY_FILE="$KUBESPRAY_DIR/inventory/$ENV/$CLUSTER/inventory.ini"

echo ">>> Deploying Infrastructure for $CLUSTER ($ENV)..."
cd "$INFRA_DIR"
terragrunt run-all apply --terragrunt-non-interactive

echo ">>> Infrastructure deployed."

if [ ! -f "$INVENTORY_FILE" ]; then
  echo "Error: Inventory file not found at $INVENTORY_FILE"
  exit 1
fi

echo ">>> Starting Kubespray Deployment..."
cd "$KUBESPRAY_DIR"

# Ensure requirements are installed (optional, maybe check first)
# pip install -r requirements.txt

echo ">>> Running Ansible Playbook..."
ansible-playbook -i "$INVENTORY_FILE" \
  --become \
  --become-user=root \
  cluster.yml

echo ">>> Deployment Complete!"
