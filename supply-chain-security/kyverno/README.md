Kyverno install and test

Install Kyverno via Helm (recommended):

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno --namespace kyverno --create-namespace
```

Apply the example ClusterPolicy (already provided):

```bash
kubectl apply -f supply-chain-security/kyverno/clusterpolicy.yaml
```

Test admission (unsigned image):

```bash
kubectl apply -f supply-chain-security/kyverno/test/unsigned-pod.yaml
# Expect Kyverno to reject the admission when policy is enforced
kubectl get events -n default --field-selector reason=AdmissionReviewError -w
```

Test admission (signed-compliant image):

```bash
# Replace the image with one signed by Cosign in your registry
kubectl apply -f supply-chain-security/kyverno/test/signed-pod.yaml
# Should be admitted
kubectl get pod signed-test -o wide
```

Notes
- The `verifyImages` rule in `clusterpolicy.yaml` is a template. For keyless Cosign verification you may configure Kyverno's `verifyImages` with an `attestations` field or use an external admission controller that understands Cosign. See Kyverno docs for `verifyImages` and Sigstore integration patterns.
- The policy now requires two annotations on Pods: `supply-chain/sbom` and `supply-chain/provenance`.

Quick scripts:
- Install Kyverno + policy: `supply-chain-security/scripts/install-kyverno.sh`
- Run admission tests: `supply-chain-security/scripts/test-kyverno.sh`
