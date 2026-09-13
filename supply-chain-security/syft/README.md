Syft SBOM generation

The CI workflow uses `anchore/syft` container to generate CycloneDX SBOMs for each built image. SBOM files are uploaded as artifacts (`sbom-<service>.json`).

Defaults:
- Format: CycloneDX JSON

Customization:
- To switch to SPDX change the `-o` in the workflow step to `spdx-json`.
