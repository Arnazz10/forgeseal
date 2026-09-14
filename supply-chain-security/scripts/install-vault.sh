#!/usr/bin/env bash
set -euo pipefail

echo "[vault] adding helm repo"
helm repo add hashicorp https://helm.releases.hashicorp.com >/dev/null
helm repo update >/dev/null

echo "[vault] installing/upgrading chart"
helm upgrade --install vault hashicorp/vault \
  --namespace vault \
  --create-namespace \
  -f supply-chain-security/vault/values.yaml

echo "[vault] waiting for rollout"
kubectl -n vault rollout status deployment/vault --timeout=180s

echo "[vault] done"
