#!/bin/bash

# Get the list of running pods
PODS=$(kubectl get pods -o jsonpath='{.items[*].metadata.name}')

# Loop through each pod
for POD in $PODS; do
  # Check if the pod is running
  STATUS=$(kubectl get pod $POD -o jsonpath='{.status.phase}')
  if [ "$STATUS" == "Running" ]; then
    # Exec into the pod and run the script
    kubectl exec -it $POD -- ./base_vol_central/initialize.sh &
  fi
done
