#!/usr/bin/env bash

function is-chart-updated {
  local chart_name=$1
  local target_branch=${2:-"master"}
  local updated_charts=`git diff --find-renames --name-only $(git merge-base $target_branch HEAD) charts/ | awk -F/ '{print $2}' | uniq`

  for chart in ${updated_charts}; do
    if [ $chart == $chart_name ]; then
      return 0
    fi
  done

  return 1
}
