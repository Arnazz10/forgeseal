#!/usr/bin/env bash
set -euo pipefail

echo "[kyverno-test] applying unsigned pod (should be denied)"
if kubectl apply -f supply-chain-security/kyverno/test/unsigned-pod.yaml; then
  echo "[kyverno-test] ERROR: unsigned pod was admitted unexpectedly"
  exit 1
else
  echo "[kyverno-test] unsigned pod denied as expected"
fi

echo "[kyverno-test] applying signed pod template (replace image first)"
kubectl apply -f supply-chain-security/kyverno/test/signed-pod.yaml
kubectl get pod signed-test -o wide

echo "[kyverno-test] done"
