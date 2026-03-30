# Show help of available commands
default:
    @just --list

# Login into GCP
login:
    gcloud auth application-default print-access-token | helm registry login -u oauth2accesstoken --password-stdin europe-west3-docker.pkg.dev

# Print helm resources
template chart:
    helm template --namespace safe --create-namespace -f ./charts/{{chart}}/values-testing.yaml {{chart}} ./charts/{{chart}}/

# Lint Helm
lint chart:
    helm lint ./charts/{{chart}}

# Creates helm package
package chart:
    helm package charts/{{chart}} --version $(yq '.version' charts/{{chart}}/Chart.yaml)

# Deploys helm package to GCP artifact registry
publish chart:
    helm push {{chart}}-$(yq '.version' charts/{{chart}}/Chart.yaml).tgz oci://europe-west3-docker.pkg.dev/hoprassociation/helm-charts
