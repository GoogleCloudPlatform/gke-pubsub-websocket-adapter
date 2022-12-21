# kubernetes-manifests

## Description
sample description

## Usage

### Fetch the package
`kpt pkg get REPO_URI[.git]/PKG_PATH[@VERSION] kubernetes-manifests`
Details: https://kpt.dev/reference/cli/pkg/get/

### View package content
`kpt pkg tree kubernetes-manifests`
Details: https://kpt.dev/reference/cli/pkg/tree/

### Apply the package
```
kpt live init kubernetes-manifests
kpt live apply kubernetes-manifests --reconcile-timeout=2m --output=table
```
Details: https://kpt.dev/reference/cli/live/
