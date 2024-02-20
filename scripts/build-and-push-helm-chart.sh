#!/usr/bin/env bash

# exit on errors, undefined variables, ensure errors in pipes are not hidden
set -Eeuo pipefail

: ${1:?"1st parameter <name> missing"}
: ${2:?"2nd parameter <repository> missing"}

declare name version repository
name="${1}"
repository="${2}"

version="$(grep version charts/${name}/Chart.yaml | awk '{print $2;}')"

helm package "charts/${name}" --version "${version}"

helm push "${name}-${version}.tgz" "${repository}"
