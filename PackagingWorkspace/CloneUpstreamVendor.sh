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

####################
# Vp techops stuff
####################

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

####################
# CTO Stuff
####################

#https://projects.knownelement.com/issues/173
https://github.com/inventree/InvenTree.git

#https://projects.knownelement.com/issues/180
https://github.com/Cloud-RF/tak-server

#https://projects.knownelement.com/issues/178
https://github.com/midday-ai/midday.git

#https://projects.knownelement.com/issues/181
https://github.com/killbill/killbill.git

#https://projects.knownelement.com/issues/184
https://github.com/chirpstack/chirpstack.git

#https://projects.knownelement.com/issues/185
https://github.com/CraigChat/craig.git

#https://projects.knownelement.com/issues/188
https://github.com/elabftw/elabftw.git

#https://projects.knownelement.com/issues/196
https://github.com/jamovi/jamovi.git

#https://projects.knownelement.com/issues/197
https://github.com/INTI-CMNB/KiBot.git

#https://projects.knownelement.com/issues/214
https://github.com/Resgrid/Core

#https://projects.knownelement.com/issues/216
https://github.com/reviewboard/reviewboard.git

#https://projects.knownelement.com/issues/218
https://gitlab.com/librespacefoundation/satnogs/docker-kaitai.git
https://gitlab.com/librespacefoundation/satnogs/docker-satnogs-webgui.git

#https://projects.knownelement.com/issues/219
https://github.com/f4exb/sdrangel-docker

#https://projects.knownelement.com/issues/221
https://github.com/SigNoz/signoz.git

#https://projects.knownelement.com/issues/228
https://github.com/sebo-b/warp.git

#https://projects.knownelement.com/issues/272
https://github.com/jgraph/docker-drawio

#https://projects.knownelement.com/issues/274
https://github.com/openblocks-dev/openblocks.git

#https://projects.knownelement.com/issues/276
https://github.com/wireviz/wireviz-web.git

#https://projects.knownelement.com/issues/278
https://github.com/opulo-inc/autobom.git

#https://projects.knownelement.com/issues/279
https://github.com/PLMore/PLMore



)

cd Docker

IFS=$'\n\t'

for GIT_REPO in ${GIT_REPO_LIST[@]};do
	git clone --depth 1 $GIT_REPO || true
done