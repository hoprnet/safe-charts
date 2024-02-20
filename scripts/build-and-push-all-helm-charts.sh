#!/usr/bin/env bash

# exit on errors, undefined variables, ensure errors in pipes are not hidden
set -Eeuo pipefail

: ${1:?"1st parameter <repository> missing"}

declare name version repository
repository="${1}"

for d in `find ./charts -mindepth 1 -maxdepth 1 -type d`; do
	name="$(basename ${d})"
	version="$(grep version ${d}/Chart.yaml | awk '{print $2;}')"
	./scripts/build-and-push-helm-chart.sh "${name}" "${version}" "${repository}"
done
