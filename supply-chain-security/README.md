# Supply Chain Security

This folder contains configuration and templates to add a supply-chain security pipeline on top of the existing DriftGuard EKS cluster and GitOps flow.

Folders:
- `trivy/` : Trivy CI notes and config
- `syft/` : Syft SBOM examples
- `cosign/`: Cosign signing notes
- `slsa/`: SLSA provenance config
- `kyverno/`: Kyverno ClusterPolicy templates
- `vault/`: Vault Helm values and injector examples
- `arch/`: Architecture diagram (mermaid)

Follow each folder's README for usage and placeholders that must be replaced with your environment values (ECR registry, IAM role ARNs, public keys, etc.).
