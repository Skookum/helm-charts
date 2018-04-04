#!/usr/bin/env bash

function change-target-ref {
  local target_branch=${1:-"master"}
  local remotes="refs/remotes/"

  echo "$(git show-ref $target_branch | grep $remotes | awk -F $remotes '{print $2}' | uniq)"
}
