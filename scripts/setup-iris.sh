#!/bin/bash

error() {
  printf "%s Error: $1\n" $(date '+%Y%m%d-%H:%M:%S:%N')
}

exit_if_error() {
  if [ $(($(echo "${PIPESTATUS[@]}" | tr -s ' ' +))) -ne 0 ]; then
    error "$1"
    exit 1
  fi
}

iris start IRIS quietly
echo "do ##class(SYS.Container).QuiesceForBundling() halt" | iris session IRIS -U %SYS -B
echo "$@ halt" | iris session IRIS -U USER
exit_if_error "Could not prepare IRIS instance for container usage."
iris stop IRIS quietly


exit $?
