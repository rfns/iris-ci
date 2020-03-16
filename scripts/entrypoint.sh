#!/bin/bash

red="\033[0;31m"
normal="\033[0m"
light_green="\033[1;32m"
green="\033[0;32m"

write_lines() {
  local color=$1
  local file=$2

  while IFS= read -r line || [ -n "$line" ]
  do
    echo -e "${color}$line${normal}"
  done <"$file"
}


send_exit_signal() {
  local code=$(echo "${PIPESTATUS[@]}" | tr -s ' ' +)

  if [ "$code" -ne 0 ]; then
    echo -e "${red}EXITED WITH ERRORS.${normal}"
    exit 1
  else
    echo -e "${green}EXITED WITHOUT ERRORS.${normal}"
  fi
}

iris start IRIS quietly
iris session IRIS -U USER "##class(CI.Orchestrator).Orchestrate()"
send_exit_signal
iris stop IRIS quietly

exit $?
