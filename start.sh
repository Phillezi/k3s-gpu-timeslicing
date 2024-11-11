#!/bin/sh

namespace="gpu-operator"

errors=0

if ! command -v kubectl &> /dev/null; then
    echo "Error: 'kubectl' command not found. Please install it."
    errors=$((errors+1))
fi

if ! command -v helm &> /dev/null; then
    echo "Error: 'helm' command not found. Please install Helm."
    errors=$((errors+1))
fi

if [ $errors -ne 0 ]; then 
    exit 1
fi

echo "Creating namespace $namespace..."
if ! kubectl get namespace $namespace > /dev/null; then
    kubectl create namespace $namespace
fi

echo "Applying timeslicing configuration..."
kubectl apply -f config/timeslicing.yaml

echo "Installing GPU operator..."
helm upgrade gpu-operator --name gpu-operator nvidia/gpu-operator --values values.yaml

if ! kubectl get deployment ollama > /dev/null || ! kubectl get deployment webui > /dev/null; then
    echo "Applying applications..."
    kubectl apply -f depls/ollama.yaml
    kubectl apply -f depls/webui.yaml
else
    echo "Resources already exist."
fi

echo "GPU operator setup complete."