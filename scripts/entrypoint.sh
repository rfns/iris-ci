#!/bin/bash

red="\033[0;31m"
normal="\033[0m"
light_green="\033[1;32m"
green="\033[0;32m"
yellow="\033[1;33m"

write_lines() {
  local color=$1
  local file=$2

  while IFS= read -r line || [ -n "$line" ]
  do
    echo -e "${color}$line${normal}"
  done <"$file"
}

display_test_errors() {
  local errorfile="/var/log/ci/errors.log"

  if [ -f "$errorfile" ]; then
    echo -e "\n"
    write_lines "$red" "$errorfile"
  fi
}

display_statistics() {
  local successlogpath="/var/log/ci/testsuccess.log"

  if [ -f "$successlogpath" ]; then
    local successlog=$(<"$successlogpath")
    local failurelog=$(</var/log/ci/testfailure.log)

    failures_count=$(echo "$failurelog" | sed 's/[^0-9]*//g')
    success_count=$(echo "$successlog" | sed 's/[^0-9]*//g')

    echo -e "\n"

    if [ "$failures_count" == 0 ] && [ "$success_count" == 0 ]; then
      echo -e "${yellow}No tests suites were found. The runner has been aborted.${normal}"
      exit 0
    fi

    echo -e "${green}$successlog${normal}"
    echo -e "${red}$failurelog${normal}\n"

    if [ "$failures_count" != 0 ]; then
      echo -e "${red}EXITED WITH ERRORS.${normal}\n"
      exit 1
    else
      echo -e "${green}EXITED WITHOUT ERRORS.${normal}\n"
    fi
  fi
}

exit_if_error() {
  if [ $(($(echo "${PIPESTATUS[@]}" | tr -s ' ' +))) -ne 0 ]; then
    echo -e "${red}$1${normal}"
    exit 1
  fi
}

iris start IRIS quietly
iris session IRIS -U USER "##class(CI.Orchestrator).Orchestrate()"

display_test_errors
display_statistics
exit_if_error "\n\nEXITED WITH FATAL ERROR."
iris stop IRIS quietly

exit $?
