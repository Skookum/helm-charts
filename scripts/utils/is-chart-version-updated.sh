#!/usr/bin/env bash

function is-chart-version-updated {
  local chart_name=$1
  local target_branch=${2:-"master"}
  local chartYaml="charts/$chart_name/Chart.yaml"

  git diff HEAD $target_branch --find-renames -- $chartYaml | grep "version: " >/dev/null
}
