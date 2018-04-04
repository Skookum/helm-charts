#!/usr/bin/env bash

source ./scripts/utils/logging.sh
source ./scripts/utils/change-target-ref.sh
source ./scripts/utils/is-chart-updated.sh
source ./scripts/utils/is-chart-version-updated.sh

function lint-chart {
  local chart_name=$1
  local directory="charts/$chart_name"
  local helm_lint_cmd="helm lint $directory --strict\
                      --set nameOverride=myapp,fullnameOverride=myapp-test"
  local exit_code=0

  if [ -d $directory ]; then
    log-info "Testing chart $chart_name ..."

    # Use example-values.yaml for applying override values if present
    if [ -f ${directory}/example-values.yaml ]; then
      $helm_lint_cmd -f $directory/example-values.yaml || exit_code=1
    else
      $helm_lint_cmd || exit_code=1
    fi

    # Check for an update to version field in Chart.yaml
    if [ "$CHANGE_TARGET" = "" ]; then
      log-info "No target branch is available to compare against;"\
               "cannot determine if $chart_name has been updated."
    else
      # Get the change target's git ref
      local remote_ref=$(change-target-ref $CHANGE_TARGET)

      # Fail if chart is updated but does not have an updated version
      if is-chart-updated $chart_name $remote_ref; then
        if is-chart-version-updated $chart_name $remote_ref; then
          echo "Version of chart $chart_name has been updated."
        else
          log-error "Chart $chart_name was updated but does not have a new version."\
                    "Please update the version key in $directory/Chart.yaml"
          exit_code=1
        fi
      else
        echo "Chart $chart_name has not been updated since the $CHANGE_TARGET branch."
      fi
    fi

    # Check for the existence of the NOTES.txt file. This is required for charts
    # in this repo.
    if [ ! -f ${directory}/templates/NOTES.txt ]; then
      log-error "NOTES.txt template not found. Please create one."
      echo "For more information see"\
           "https://docs.helm.sh/developing_charts/#chart-license-readme-and-notes"
      exit_code=1
    fi
  fi

  exit $exit_code
}
