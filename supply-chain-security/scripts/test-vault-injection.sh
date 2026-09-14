#!/usr/bin/env bash
set -euo pipefail

echo "[vault-test] applying checkout-svc sample deployment"
kubectl apply -f supply-chain-security/vault/sample-checkout-deployment-vault.yaml

echo "[vault-test] waiting for pod"
kubectl rollout status deployment/checkout-svc --timeout=180s

echo "[vault-test] checking mutation annotations"
kubectl get pod -l app=checkout-svc -o yaml | grep -E "vault.hashicorp.com/agent-inject|vault.hashicorp.com/role" -n

echo "[vault-test] done"
