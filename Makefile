
.PHONY: help
help: ## Show help of available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

login: ## Login into GCP
	gcloud auth application-default print-access-token | helm registry login -u oauth2accesstoken --password-stdin https://europe-west3-docker.pkg.dev

template: ## Print helm resources
	helm template --namespace safe --create-namespace -f ./charts/$(chart)/values-testing.yaml $(chart) ./charts/$(chart)/

lint: ## Lint Helm
	helm lint ./charts/$(chart)

package: ## Creates helm package
	helm package charts/$(chart) --version $$(yq '.version' charts/$(chart)/Chart.yaml)

publish: ## Deploys helm package to GCP artifact registry
	helm push $(chart)-$$(yq '.version' charts/$(chart)/Chart.yaml).tgz oci://europe-west3-docker.pkg.dev/hoprassociation/helm-charts
