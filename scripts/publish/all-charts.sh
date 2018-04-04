#!/usr/bin/env bash

source ./scripts/utils/logging.sh
source ./scripts/utils/parse-yaml.sh
source ./scripts/publish/chart.sh

# Delete any existing .tgz packages so they can be rebuilt from scratch
find . -name '*.tgz' -delete &&

# Create the `charts` and `repository` variables from the publish config file
create-variables publish.yaml

# Set the chartmuseum URL to the first argument, or the default repository
# from the publish configuration
chartmuseum_url=${1:-$repository}

# Log the charts to be published, and the target repository
log-info "Publishing ${#charts[@]} charts to $chartmuseum_url:"
for chart in "${charts[@]}"
do
  echo "$chart"
done

# Publish charts
exit_code=0
for chart in "${charts[@]}"
do
  (publish-chart "$chart" "$chartmuseum_url") || exit_code=1
done

if [ $exit_code = 0 ]; then
  log-success "${#charts[@]} charts have been published to $chartmuseum_url."
else
  log-error "There was an issue publishing one or more charts;"\
            "see log output above."
fi

exit $exit_code