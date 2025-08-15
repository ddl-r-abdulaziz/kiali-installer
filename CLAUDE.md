# Project Context: Kiali with Fleet Command Deploy

## Overview
This project sets up Kiali ingress configuration for a Kubernetes cluster, dynamically extracting hostname information from the domino-operator platform configuration.

## Project Structure
```
.
├── Makefile              # Build automation with tool management
├── resources/
│   └── ingress.yaml     # YTT template for Kiali ingress
├── .tools/              # Local tool binaries (created by make targets)
│   ├── yq               # YAML processor
│   └── ytt              # YAML templating tool
└── CLAUDE.md            # This context file
```

## Key Components

### Makefile Targets
- `make help`: Show available targets
- `make tools`: Download yq and ytt tools to `./.tools/`
- `make yq`: Download yq tool only
- `make ytt`: Download ytt tool only
- `make install-kiali`: Install Kiali server using Helm
- `make install-ingress`: Apply ingress configuration (extracts hostname dynamically)
- `make install`: Run both install-kiali and install-ingress
- `make all`: Alias for install

### Technology Stack
- **Kubernetes**: Target deployment platform
- **YTT**: YAML templating for dynamic configuration
- **yq**: YAML processing for data extraction
- **Helm**: Kiali server installation
- **kubectl**: Kubernetes CLI operations

## Critical Implementation Details

### Hostname Extraction
The `install-ingress` target dynamically extracts the hostname from the `platform-operator-config` ConfigMap in the `domino-operator` namespace:

```bash
HOSTNAME=$(kubectl get configmap platform-operator-config -n domino-operator -o jsonpath='{.data.domino\.yml}' | ./.tools/yq e '.hostname' -)
```

The hostname is stored within the `domino.yml` field as nested YAML content, requiring parsing to extract the value.

### YTT Template Structure
The `resources/ingress.yaml` file uses YTT templating:
- Loads `@ytt:data` for accessing data values
- Uses `data.values.hostname` to inject the dynamically extracted hostname
- Creates a Kubernetes Ingress resource for the `kiali` service

### Tool Management
Local tools are downloaded to `./.tools/` directory:
- **yq**: `yq_darwin_amd64` from mikefarah/yq GitHub releases
- **ytt**: `ytt-darwin-amd64` from vmware-tanzu/carvel-ytt GitHub releases
- Tools are only downloaded if not already present
- Ensures reproducible builds independent of system tools

## Previous Issues Resolved

1. **Original Problem**: YTT template failed with "Expected to find file 'domino-operator/platform-operator-config'"
2. **Root Cause**: YTT's `data.read()` expected file paths, not ConfigMap references
3. **Solution**: Implemented dynamic hostname extraction via kubectl + yq, passed to YTT as data values

## Development Workflow

1. **Setup**: Run `make tools` to download required binaries
2. **Install Kiali**: Run `make install-kiali` 
3. **Configure Ingress**: Run `make install-ingress`
4. **Full Deploy**: Run `make install` or `make all`

## Dependencies
- kubectl (system installed)
- Access to domino-operator namespace
- Internet access for tool downloads
- Kubernetes cluster with nginx ingress controller

## Notes
- The ingress points to `kiali` service on port 20001 in `istio-system` namespace
- Uses nginx ingress class
- Hostname format: `{deployment-id}.infra-team-sandbox.domino.tech`
- Current deployment hostname: `rashamb93134.infra-team-sandbox.domino.tech`