#!/bin/bash

export PS4='(${BASH_SOURCE}:${LINENO}): - [${SHLVL},${BASH_SUBSHELL},$?] $ '

function error_out()
{
        echo "Bailing out. See above for reason...."
        exit 1
}

function handle_failure() {
  local lineno=$1
  local fn=$2
  local exitstatus=$3
  local msg=$4
  local lineno_fns=${0% 0}
  if [[ "$lineno_fns" != "-1" ]] ; then
    lineno="${lineno} ${lineno_fns}"
  fi
  echo "${BASH_SOURCE[0]}: Function: ${fn} Line Number : [${lineno}] Failed with status ${exitstatus}: $msg"
}

trap 'handle_failure "${BASH_LINENO[*]}" "$LINENO" "${FUNCNAME[*]:-script}" "$?" "$BASH_COMMAND"' ERR

set -o errexit
set -o nounset
set -o pipefail
set -o functrace


cd Docker

GIT_REPO_LIST="$(ls -d */)"

IFS=$'\n\t'

for GIT_REPO in ${GIT_REPO_LIST[@]};
do
  CURRENT_DIR=$(realpath $PWD)
  echo "Updating from $GIT_REPO..."
  cd $GIT_REPO 
  git pull
  cd $CURRENT_DIR
done