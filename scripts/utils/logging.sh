#!/usr/bin/env bash

function log-message {
  local message="$1"
  local color="$2"
  local no_color='\033[0m'

  printf "$color\n$1$no_color\n\n"
}

function log-info {
  local color='\033[0;34m'
  log-message "[INFO] $*" $color
}

function log-error {
  local color='\033[0;31m'
  # Write to stderr
  (>&2 log-message "[ERROR] $*" $color)
}

function log-success {
  local color='\033[0;32m'
  log-message "[SUCCESS] $*" $color
}
