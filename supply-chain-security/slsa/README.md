SLSA provenance

We generate SLSA provenance using `slsa-framework/slsa-github-generator` in CI. The provenance file is uploaded as an artifact `slsa-provenance`.

This provenance can be attached to the release or stored in a provenance store that your cluster admission controller can consult.
