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

messages_log="/usr/irissys/mgr/messages.log"

# The Community licence lives inside the base image and expires about a year
# after that IRIS release. When it does, the instance refuses to start and the
# only clue is a line buried in messages.log — every job that depends on this
# image then fails with something that looks like a compilation problem. Saying
# it plainly here saves the next person the investigation.
report_expired_licence() {
  grep -qiE "licen[cs]e expired|Invalid Community Edition licen[cs]e" "$messages_log" 2> /dev/null || return 1

  echo -e "${red}iris-ci: the Community licence baked into this image has expired.${normal}"
  echo -e "${red}iris-ci: this is not a problem with the project being tested.${normal}"
  echo -e "${red}iris-ci: rebuild and republish the image to pick up a current base,${normal}"
  echo -e "${red}iris-ci: by running the 'Build and publish' workflow on rfns/iris-ci.${normal}"
  return 0
}

if ! iris start IRIS quietly; then
  echo -e "${red}iris-ci: the instance did not start.${normal}"
  report_expired_licence || tail -n 20 "$messages_log" 2> /dev/null
  exit 1
fi

iris session IRIS -U USER "##class(CI.Orchestrator).Orchestrate()"
send_exit_signal
iris stop IRIS quietly

exit $?
