#!/bin/sh

namespace=$(kubectl get ns | grep gpu-operator | awk '{print $1}')
if [ -n "$namespace" ]; then
  kubectl delete namespace $namespace
fi

kubectl delete -f config/timeslicing.yaml

helm uninstall gpu-operator || true

kubectl get deployment ollama || true
kubectl delete deployment ollama --cascade=true
kubectl get deployment webui || true
kubectl delete deployment webui --cascade=true