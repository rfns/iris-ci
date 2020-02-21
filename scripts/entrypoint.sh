#!/bin/bash

error() {
  printf "%s Error: $1\n" $(date '+%Y-%m-%d-%H:%M:%S')
}

exit_if_error() {
  if [ $(($(echo "${PIPESTATUS[@]}" | tr -s ' ' +))) -ne 0 ]; then
    error "$1"
    exit 1
  fi
}

iris start IRIS quietly
iris session IRIS -U USER "run^testrunner"

exit_if_error "Failed to complete the operation."
iris stop IRIS quietly

exit $?
