#!/bin/bash

# Usage: ./log-collector.sh <namespace> <output_directory>

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <namespace> <output_directory>"
    exit 1
fi

KUBE_NAMESPACE="$1"
OUTPUT_DIR="$2"

mkdir -p "$OUTPUT_DIR"

echo "Collecting logs from namespace: $KUBE_NAMESPACE"
POD_LIST=$(kubectl get pods -n "$KUBE_NAMESPACE" --field-selector=status.phase=Running --no-headers -o custom-columns=":metadata.name")

for pod in $POD_LIST; do
    echo "kubectl logs $pod -n $KUBE_NAMESPACE &> $OUTPUT_DIR/${pod}.log"
    kubectl logs "$pod" -n "$KUBE_NAMESPACE" &> "$OUTPUT_DIR/${pod}.log"
done

echo "Log collection complete. Logs saved to: $OUTPUT_DIR"
