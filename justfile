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

# Builds and pushes an amd64 safe-client-gateway image (Safe only publishes arm64 images upstream)
build-client-gateway version:
    #!/usr/bin/env bash
    set -euo pipefail
    image="europe-west3-docker.pkg.dev/hoprassociation/docker-images/safe-client-gateway:{{version}}"
    src="$(mktemp -d)"
    trap 'rm -rf "${src}"' EXIT
    gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin europe-west3-docker.pkg.dev
    git clone --quiet --depth 1 --branch {{version}} https://github.com/safe-global/safe-client-gateway.git "${src}"
    # VERSION must equal the tag: the app reports it on /v1/about
    docker buildx build --platform linux/amd64 \
        --build-arg VERSION={{version}} \
        --build-arg BUILD_NUMBER="$(git -C "${src}" rev-parse --short HEAD)" \
        --tag "${image}" --push "${src}"

# Builds and pushes a safe-wallet-web image with the static site prebuilt for an environment (staging|prod)
build-wallet-web version env:
    #!/usr/bin/env bash
    set -euo pipefail
    image="europe-west3-docker.pkg.dev/hoprassociation/docker-images/safe-wallet-web:{{version}}-{{env}}"
    src="$(mktemp -d)"
    trap 'rm -rf "${src}"' EXIT
    gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin europe-west3-docker.pkg.dev
    git clone --quiet --depth 1 --branch web-{{version}} https://github.com/safe-global/safe-wallet-monorepo.git "${src}"
    # NEXT_PUBLIC_* are inlined at build time, so the gateway URL of the environment is baked in
    docker buildx build --platform linux/amd64 \
        -f docker/safe-wallet-web/Dockerfile \
        --build-arg GATEWAY_URL=https://safe-client-gateway.{{env}}.hoprnet.link \
        --build-arg COMMIT_HASH="$(git -C "${src}" rev-parse --short HEAD)" \
        --tag "${image}" --push "${src}"
