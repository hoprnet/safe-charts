#!/usr/bin/env bash

# exit on errors, undefined variables, ensure errors in pipes are not hidden
set -Eeuo pipefail

: ${1:?"1st parameter <name> missing"}
: ${2:?"2nd parameter <version> missing"}
: ${3:?"3rd parameter <repository> missing"}

declare name version repository
name="${1}"
version="${2}"
repository="${3}"

helm package "charts/${name}" --version "${version}"

helm push "${name}-${version}.tgz" "${repository}"
