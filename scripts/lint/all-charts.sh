#!/usr/bin/env bash

source ./scripts/utils/logging.sh
source ./scripts/utils/parse-yaml.sh
source ./scripts/lint/chart.sh

# Create the `charts` and `repository` variables from the publish config file
create-variables publish.yaml

exit_code=0

# Lint charts
for chart in "${charts[@]}"
do
  ( lint-chart "$chart" ) || exit_code=1
done

if [ $exit_code = 0 ]; then
  log-success "Tests passed for ${#charts[@]} charts."
else
  log-error "There was a test failure for one or more charts;"\
            "see log output above."
fi

exit $exit_code
