#!/bin/bash

red="\033[0;31m"
normal="\033[0m"

exit_if_error() {
  if [ $(($(echo "${PIPESTATUS[@]}" | tr -s ' ' +))) -ne 0 ]; then
    echo -e "${red}$1${normal}"
    exit 1
  fi
}

iris start IRIS quietly
echo "do ##class(SYS.Container).QuiesceForBundling() halt" | iris session IRIS -U %SYS -B
echo "$@ halt" | iris session IRIS -U USER
exit_if_error "Failed to prepare the IRIS instance."
iris stop IRIS quietly


exit $?
