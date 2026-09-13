Trivy CI integration

This folder documents how the CI uses Trivy to scan built images. The workflow created at `.github/workflows/supply-chain-security.yml` runs Trivy and fails the job when HIGH or CRITICAL vulnerabilities are found.

Outputs in CI:
- `trivy-results` (JSON) uploaded as an artifact
- `trivy-summary` (human-readable) uploaded as an artifact

Customization:
- Adjust severities in the workflow step (`severity: HIGH,CRITICAL`).
- Provide any `trivy.ignore` files here if needed.
