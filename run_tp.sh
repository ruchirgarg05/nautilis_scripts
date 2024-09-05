#!/bin/bash

# Get the list of pods
pods=$(kubectl get pods -o jsonpath='{.items[*].metadata.name}')

# Loop through each pod
for pod in $pods; do
  # Execute the command in the pod
  kubectl exec -it $pod -c gpu-container -- /bin/bash -c "screen -d -m -S tp python /base_vol_central/tp.py"
done
