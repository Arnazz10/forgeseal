Vault install and Vault Agent Injector usage

This folder contains a sample `values.yaml` (`supply-chain-security/vault/values.yaml`) which configures Vault in dev-mode with the injector enabled for quick testing.

Install Vault (dev example):

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault -n vault --create-namespace -f supply-chain-security/vault/values.yaml
```

Enable Kubernetes auth and create a policy/role for services:

```bash
# Example: run inside the vault pod
kubectl -n vault exec -it deployment/vault -- vault auth enable kubernetes
# Configure kubernetes auth (replace placeholders)
kubectl -n vault exec -it deployment/vault -- vault write auth/kubernetes/config token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" kubernetes_host="https://$KUBERNETES_SERVICE_HOST:443" kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

vault policy write checkout-policy - <<EOF
path "secret/data/checkout/*" { capabilities = ["read"] }
EOF

vault write auth/kubernetes/role/checkout-role bound_service_account_names=checkout-sa bound_service_account_namespaces=default policies=checkout-policy ttl=1h
```

Example annotation for `checkout-svc` Deployment to inject DB credentials:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: checkout-svc
spec:
  template:
    metadata:
      annotations:
        vault.hashicorp.com/agent-inject: "true"
        vault.hashicorp.com/role: "checkout-role"
        vault.hashicorp.com/agent-inject-secret-DB_CREDS: "secret/data/checkout/db"
        vault.hashicorp.com/agent-inject-template-DB_CREDS: |
          {{- with secret "secret/data/checkout/db" -}}
          export DB_USER={{ .Data.data.username }}
          export DB_PASS={{ .Data.data.password }}
          {{- end }}
    spec:
      serviceAccountName: checkout-sa
      containers:
      - name: checkout
        image: your-registry/checkout-svc:tag
        command: ["/bin/sh","-c","source /vault/secrets/DB_CREDS && exec ./start-server"]

```

Ready-to-use examples in this repo:
- `supply-chain-security/vault/sample-checkout-deployment-vault.yaml`
- `supply-chain-security/vault/sample-payments-deployment-vault.yaml`

Quick scripts:
- Install Vault: `supply-chain-security/scripts/install-vault.sh`
- Test injection: `supply-chain-security/scripts/test-vault-injection.sh`

Notes
- For production, do not use dev-mode Vault. Configure HA, persistent storage and secure auth backends.
- You will need to create the Vault secrets (e.g., `secret/data/checkout/db`) before injection.
