#!/usr/bin/env bash
set -euo pipefail

echo "[kyverno] adding helm repo"
helm repo add kyverno https://kyverno.github.io/kyverno/ >/dev/null
helm repo update >/dev/null

echo "[kyverno] installing/upgrading chart"
helm upgrade --install kyverno kyverno/kyverno \
  --namespace kyverno \
  --create-namespace

echo "[kyverno] applying cluster policy"
kubectl apply -f supply-chain-security/kyverno/clusterpolicy.yaml

echo "[kyverno] done"
