This PR adds a supply-chain security pipeline and cluster templates.

Changes included:
- CI workflow: `.github/workflows/supply-chain-security.yml` — builds images, runs Trivy, generates SBOMs (Syft), signs images with Cosign, verifies signatures, generates SLSA provenance, and uploads artifacts.
- Kyverno ClusterPolicy template to require image signature and SBOM annotation.
- Vault Helm values (dev-mode example) and sample deployment annotations for Vault Agent Injector.
- Documentation and architecture diagram.

Follow-up tasks (to be done after merge or separately):
- Configure GitHub repo secrets: `ECR_REGISTRY`, `AWS_ROLE_TO_ASSUME`.
- Configure AWS OIDC trust and IAM role for GitHub Actions to push to ECR and sign images.
- Replace placeholders in `clusterpolicy.yaml` with your Cosign public key or attestor configuration.
- Run Helm installs on the EKS cluster to install Kyverno and Vault, then apply policies and test admission/injection.
