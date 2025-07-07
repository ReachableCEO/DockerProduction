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


export GIT_REPO_LIST
GIT_REPO_LIST=(

#https://projects.knownelement.com/issues/179
https://github.com/apache/apisix.git

#https://projects.knownelement.com/issues/189
https://github.com/consuldemocracy/consuldemocracy.git

#https://projects.knownelement.com/issues/195
https://github.com/fleetdm/fleet.git

#https://projects.knownelement.com/issues/227
https://github.com/fonoster/fonoster.git

#https://projects.knownelement.com/issues/192
https://github.com/healthchecks/healthchecks.git

#https://projects.knownelement.com/issues/209
https://github.com/juspay/hyperswitch

#https://projects.knownelement.com/issues/201
https://github.com/netbox-community/netbox-docker.git

# https://projects.knownelement.com/issues/205 
https://github.com/openboxes/openboxes-docker.git

#https://projects.knownelement.com/issues/316
https://github.com/openfiletax/openfile.git

#https://projects.knownelement.com/issues/211
https://github.com/GemGeorge/SniperPhish-Docker.git

#https://projects.knownelement.com/issues/309
https://github.com/datahub-project/datahub.git

#https://projects.knownelement.com/issues/54
https://github.com/wiredlush/easy-gate.git

#https://projects.knownelement.com/issues/208
https://github.com/Payroll-Engine/PayrollEngine.git

#https://projects.knownelement.com/issues/194
https://github.com/huginn/huginn.git

#https://projects.knownelement.com/issues/191
https://github.com/gristlabs/grist-core

#https://projects.knownelement.com/issues/277
https://github.com/jhpyle/docassemble.git

#https://projects.knownelement.com/issues/273
https://github.com/kazhuravlev/database-gateway.git

#https://projects.knownelement.com/issues/217
https://github.com/rundeck/rundeck.git

#https://projects.knownelement.com/issues/222
https://github.com/SchedMD/slurm.git
https://github.com/giovtorres/slurm-docker-cluster.git

#https://projects.knownelement.com/issues/225
https://github.com/rathole-org/rathole.git

#https://projects.knownelement.com/issues/234
https://github.com/jenkinsci/jenkins.git

#https://projects.knownelement.com/issues/322
https://github.com/runmedev/runme.git

#https://projects.knownelement.com/issues/301
https://github.com/apache/seatunnel

#https://projects.knownelement.com/issues/271
https://github.com/thecatlady/docker-webhook


)

cd Docker

IFS=$'\n\t'

for GIT_REPO in ${GIT_REPO_LIST[@]};do
	git clone --depth 1 $GIT_REPO || true
done