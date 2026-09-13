# ForgeSeal — Supply Chain Security Add-on for DriftGuard

This repository contains the ForgeSeal supply-chain security integration for the DriftGuard EKS cluster and GitOps flow. It provides CI templates and cluster manifests to add vulnerability scanning, SBOM generation, image signing, provenance attestation, admission-time enforcement and secret injection.

Goals
- Add automated image scanning (Trivy) that fails CI on HIGH/CRITICAL vulnerabilities.
- Generate SBOMs (Syft) and attach them to builds/releases.
- Sign images using Cosign (keyless, GitHub OIDC) and verify signatures in CI.
- Produce SLSA provenance attestations for each build.
- Enforce image signature and SBOM/provenance at admission time with Kyverno.
- Replace plaintext secrets with Vault Agent Injector for runtime secret delivery.

Layout
- `.github/workflows/supply-chain-security.yml` — CI workflow template (build, Trivy, Syft, Cosign, SLSA, artifacts)
- `supply-chain-security/` — per-tool configuration and documentation
  - `trivy/`, `syft/`, `cosign/`, `slsa/`, `kyverno/`, `vault/`, `arch/`

High-level flow

```mermaid
flowchart TD
  A[Code push] -->|GitHub Actions| B[Build + Trivy scan]
  B --> C[Syft -> SBOM]
  B --> D[Cosign -> Sign image]
  B --> E[SLSA provenance]
  C --> F[ECR (image + SBOM)]
  D --> F
  E --> F
  F --> G[ArgoCD sync -> EKS]
  G --> H[Kyverno admission checks]
  H --> I[Vault injector provides secrets]
  I --> J[Pod runs]
```

Architecture diagram (mermaid)

```mermaid
%%{init: {"theme":"neutral"}}%%
graph TD
  A[Code push] -->|GitHub Actions| B[Build + Trivy]
  B --> C[Syft SBOM]
  B --> D[Cosign sign]
  B --> E[SLSA provenance]
  D --> F[ECR with signatures]
  C --> F
  E --> F
  F --> G[ArgoCD sync to EKS]
  G --> H[Kyverno admission checks]
  H --> I[Vault injector pulls secrets]
  I --> J[Pod running (checkout-svc/payments-svc)]

```

Prerequisites / Secrets to set in GitHub
- `ECR_REGISTRY` — your ECR registry (e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com)
- `AWS_ROLE_TO_ASSUME` — IAM role ARN GitHub will assume via OIDC to push images and access ECR
- Ensure your GitHub OIDC trust relationship allows the Actions runner to assume that role. See AWS docs for "Configure OIDC for GitHub Actions".

CI notes
- The CI workflow will build and push images for `checkout-svc` and `payments-svc`. Adjust Dockerfile paths in `.github/workflows/supply-chain-security.yml` if services have separate contexts.
- Trivy is run with `severity: HIGH,CRITICAL` and `exit-code: 1` so the job fails on these severities. Scan artifacts (JSON + summary) are uploaded.
- Syft runs in CI to emit CycloneDX SBOMs (`sbom-<service>.json`) and artifacts are uploaded.
- Cosign signs images keylessly; `cosign verify` runs to ensure signatures are present.
- SLSA provenance is generated using `slsa-github-generator` and uploaded as an artifact.

Kyverno (Admission control)
- The template ClusterPolicy is in `supply-chain-security/kyverno/clusterpolicy.yaml`.
- To install Kyverno on the existing EKS cluster:

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno --namespace kyverno --create-namespace
kubectl apply -f supply-chain-security/kyverno/clusterpolicy.yaml
```

Notes on `clusterpolicy.yaml`:
- Replace `REPLACE_WITH_COSIGN_PUBLIC_KEY` with your Cosign public key, or adapt the policy to perform keyless verification using an attestor setup.
- The policy enforces that Pods include an annotation `supply-chain/sbom` which should reference the SBOM/provenance location. You can extend the policy to fetch and validate SBOM contents.

Vault (Secrets management)
- `supply-chain-security/vault/values.yaml` contains a minimal dev-mode Helm values file with the injector enabled. For production, enable HA, persistent storage and configure proper storage backends.
- Install Vault (dev mode example):

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault -n vault --create-namespace -f supply-chain-security/vault/values.yaml
```

- After Vault is running, enable Kubernetes auth and create policies/roles that allow the service accounts for `checkout-svc` and `payments-svc` to read their secrets. Example (high level):

```bash
kubectl -n vault exec deployment/vault -- vault auth enable kubernetes
# Configure the kubernetes auth method with the cluster CA/token/service account
vault policy write checkout-policy - <<EOF
# policy allowing read to secret/data/checkout
path "secret/data/checkout/*" { capabilities = ["read"] }
EOF
vault write auth/kubernetes/role/checkout-role bound_service_account_names=checkout-sa bound_service_account_namespaces=default policies=checkout-policy ttl=1h
```

Injector usage
- Annotate `checkout-svc` and `payments-svc` deployments to request secrets via the Vault Agent Injector. See `supply-chain-security/vault/README.md` for example annotations.

Testing the admission policy and vault injection
- To test Kyverno rejects unsigned images, try deploying a Pod with an unsigned image and observe Kyverno deny the admission. Example:

```bash
kubectl run unsigned-test --image=busybox:latest --restart=Never -- sleep 3600
# Should be rejected by Kyverno if policy is enforced
```

- To test Vault injection, annotate a deployment and create the corresponding secret in Vault; the injector will mutate the Pod to add env vars/volumes with credentials.

Attaching SBOMs and provenance to releases
- The CI workflow uploads SBOMs and provenance as workflow artifacts. On release events, you can attach those artifacts to the GitHub Release via the API or use an upload action.

How to open a PR (recommended)
- If you have the GitHub CLI installed and authenticated locally:

```bash
gh pr create --base main --head feat/supply-chain-security --title "feat: supply chain security CI and cluster templates" --body-file .github/PR_BODY.md
```

If you prefer, I can open the PR for you if you provide a GitHub Token with `repo` permissions.

Next steps I can take for you
- Open a PR from `feat/supply-chain-security` -> `main`.
- Prepare concrete Kyverno verification steps to perform keyless Cosign verification (attestor config).
- Create concrete Helm/Kustomize patches for `checkout-svc` and `payments-svc` to wire Vault Agent Injector.

Contact
- If you want me to proceed with any of the next steps, tell me which and whether I should act directly on the cluster (I will need kubeconfig) or just provide the manifests/commands for you to run.
