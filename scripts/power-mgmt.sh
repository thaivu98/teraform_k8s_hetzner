#!/bin/bash
set -e

# Usage: ./power-mgmt.sh <cluster_name> <nodegroup_name> <on|off>
# Example: ./power-mgmt.sh k8s-cluster-1 gpu-nodes off

CLUSTER=$1
NODEGROUP=$2
ACTION=$3

if [ -z "$CLUSTER" ] || [ -z "$NODEGROUP" ] || [ -z "$ACTION" ]; then
  echo "Usage: $0 <cluster_name> <nodegroup_name> <on|off>"
  exit 1
fi

if [[ "$ACTION" != "on" && "$ACTION" != "off" ]]; then
  echo "Error: Action must be 'on' or 'off'"
  exit 1
fi

CMD="poweron"
if [ "$ACTION" == "off" ]; then
  CMD="poweroff"
fi

echo ">>> Turning $ACTION nodes in cluster '$CLUSTER', group '$NODEGROUP'..."

# Find servers with matching labels
# Labels: cluster=<cluster>, nodegroup=<nodegroup>
SERVERS=$(hcloud server list --label "cluster=$CLUSTER,nodegroup=$NODEGROUP" -o no-header -o columns=id)

if [ -z "$SERVERS" ]; then
  echo "No servers found for cluster=$CLUSTER, nodegroup=$NODEGROUP"
  exit 0
fi

for SERVER_ID in $SERVERS; do
  echo "Running $CMD on server ID: $SERVER_ID"
  hcloud server $CMD "$SERVER_ID" &
done

wait
echo ">>> Done."
