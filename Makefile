.PHONY: help install-kiali install-prometheus install-ingress install all tools yq ytt helm-repos

all: install

help: ## Show this help message
	@echo 'Usage:'
	@echo '  make <target>'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

helm-repos: ## Add and update Helm repositories
	helm repo add kiali https://kiali.org/helm-charts
	helm repo update

install-prometheus: ## Install Prometheus using Istio sample
	kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.26/samples/addons/prometheus.yaml

install-kiali: istio-namespace-in-mesh tools helm-repos install-prometheus ## Install Kiali server using Helm
	HOSTNAME=$$(kubectl get configmap platform-operator-config -n domino-operator -o jsonpath='{.data.domino\.yml}' | ./.tools/yq e '.hostname' -) && \
	./.tools/ytt -f values/kiali.yaml --data-value hostname=https://$$HOSTNAME > /tmp/kiali-values.yaml && \
	helm upgrade --install --namespace istio-system kiali-server kiali/kiali-server --values /tmp/kiali-values.yaml && \
	rm -f /tmp/kiali-values.yaml

install-ingress: tools ## Apply ingress configuration
	HOSTNAME=$$(kubectl get configmap platform-operator-config -n domino-operator -o jsonpath='{.data.domino\.yml}' | ./.tools/yq e '.hostname' -) && \
	./.tools/ytt -f resources/ingress.yaml --data-value hostname=$$HOSTNAME | kubectl apply -f -

istio-namespace-in-mesh: ## Puts istio-system pods on it's own mesh so that kiali can talk to grafana
	kubectl label ns istio-system istio.io/dataplane-mode=ambient

.tools:
	mkdir -p .tools

yq: .tools ## Download yq tool
	@if [ ! -f .tools/yq ]; then \
		echo "Downloading yq..."; \
		curl -L "https://github.com/mikefarah/yq/releases/latest/download/yq_darwin_amd64" -o .tools/yq && \
		chmod +x .tools/yq; \
	fi

ytt: .tools ## Download ytt tool  
	@if [ ! -f .tools/ytt ]; then \
		echo "Downloading ytt..."; \
		curl -L "https://github.com/vmware-tanzu/carvel-ytt/releases/latest/download/ytt-darwin-amd64" -o .tools/ytt && \
		chmod +x .tools/ytt; \
	fi

tools: yq ytt ## Download all tools

install: install-prometheus install-kiali install-ingress


