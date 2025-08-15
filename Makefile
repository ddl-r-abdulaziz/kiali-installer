.PHONY: help install-kiali install-ingress install all

all: install

help: ## Show this help message
	@echo 'Usage:'
	@echo '  make <target>'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install-kiali: ## Install Kiali server using Helm
	helm upgrade --install --namespace istio-system kiali-server kiali/kiali-server --set auth.strategy=anonymous

install-ingress: ## Apply ingress configuration
	HOSTNAME=$$(kubectl get configmap platform-operator-config -n domino-operator -o jsonpath='{.data.domino\.yml}' | yq e '.hostname' -) && \
	ytt -f resources/ingress.yaml --data-value hostname=$$HOSTNAME | kubectl apply -f -

install: install-kiali install-ingress


