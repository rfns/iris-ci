#!/bin/bash

red="\033[0;31m"
normal="\033[0m"
light_green="\033[1;32m"
green="\033[0;32m"

display_test_errors() {
  local errorfile="/var/log/ci/errors.log"
  if [ -f "$errorfile" ]; then
    errorlog=$(<"$errorfile")
    echo -e "\n\n${red}$errorlog${normal}" >&2
  fi
}

display_assertion_count() {
  local successlog="/var/log/ci/testsuccess.log"
  local failurelog="/var/log/ci/testfailure.log"

  echo -e "\n\n"

  if [ -f "$successlog" ]; then
    log=$(</var/log/ci/testsuccess.log)
    echo -e "\n${light_green}$log${normal}"
  fi

  if [ -f "$failurelog" ]; then
    log=$(</var/log/ci/testfailure.log)
    echo -e "${red}$log${normal}"
  fi

  echo -e "\n\n"
  failures_count=$(echo "$log" | sed 's/[^0-9]*//g')

  if [ "$failures_count" != 0 ]; then
    echo -e "${red}EXITED WITH ERRORS.${normal}\n\n"
    exit 1
  else
    echo -e "${green}EXITED WITHOUT ERRORS.${normal}\n\n"
  fi
}

exit_if_error() {
  if [ $(($(echo "${PIPESTATUS[@]}" | tr -s ' ' +))) -ne 0 ]; then
    echo -e "{$red}$1${normal}"
    exit 1
  fi
}

iris start IRIS quietly
iris session IRIS -U USER "##class(CI.TestRunner.Orchestrator).Orchestrate()"

display_test_errors
display_assertion_count
exit_if_error "\n\nExited abnormally."
iris stop IRIS quietly

exit $?
