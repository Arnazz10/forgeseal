Cosign (Sigstore) signing

The CI workflow performs keyless Cosign signing using GitHub Actions OIDC identity. Signatures are pushed to the same registry as OCI artifacts.

Placeholders you must set in the repository secrets:
- `ECR_REGISTRY` - registry host
- `AWS_ROLE_TO_ASSUME` - role ARN that GitHub OIDC can assume to push images

Notes:
- Keyless signing requires proper OIDC trust between GitHub and your AWS role and registry permissions.
- The workflow uses `cosign sign --keyless` and `cosign verify --keyless` to confirm signatures.
