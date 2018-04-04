#!/usr/bin/env bash

source ./scripts/utils/parse-yaml.sh
source ./scripts/utils/logging.sh

function publish-chart {
  local chart_name=$1
  local chartmuseum_url=$2
  local directory="charts/$chart_name"

  log-info "Packaging chart $chart_name ..." &&
  helm package $directory --dependency-update &&

  log-info "Uploading chart $chart_name ..." &&
  create-variables $directory/Chart.yaml &&
  local result=$(curl --data-binary "@$chart_name-$version.tgz" $chartmuseum_url/api/charts) &&

  if [ "$result" = '{"saved":true}' ]; then
    log-success "Chart $chart_name version $version upload complete!"
  elif [ "$result" = '{"error":"file already exists"}' ]; then
    log-info "Chart $chart_name version $version already exists"
  else
    log-error "$result"
    exit 1
  fi
}
