#!/bin/bash

# Check if the deployment name and number of deployments are provided as arguments
if [ $# -ne 2 ]; then
  echo "Please provide the deployment name and number of deployments as arguments"
  exit 1
fi

# Set the deployment name and number of deployments from the arguments
DEPLOYMENT_NAME=$1
NUM_DEPS=$2

# Check if the number of deployments is a positive integer
if ! [[ $NUM_DEPS =~ ^[0-9]+$ ]] || [ $NUM_DEPS -le 0 ]; then
  echo "Number of deployments must be a positive integer"
  exit 1
fi

# Create the deployments
for ((i=1; i<=$NUM_DEPS; i++)); do
  # Create a temporary yaml file with the updated deployment name
  sed "s/gpu-dep22/${DEPLOYMENT_NAME}-${i}/g" deployment_central_copy.yaml > dep-tmp.yaml

  # Create the deployment using the temporary yaml file
  kubectl create -f dep-tmp.yaml

  # Delete the temporary yaml file
  rm dep-tmp.yaml
done
