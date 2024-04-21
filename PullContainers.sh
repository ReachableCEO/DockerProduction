#!/bin/bash
export container_list="
        elabftw/elabimg \
        huginn/huginn \
        phpipam/phpipam-www \
        killbill/killbill \
        killbill/kaui \
        inventree/inventree \
        seknox/trasa \
        beanbag/reviewboard:latest \
        pihole/pihole \
        stedolan/jq \
        r7wx/easy-gate \
        rundeck/rundeck \
        librenms/librenms \
        graylog/graylog:5.1 \
        r7wx/easy-gate \
        xetusoss/archiva"

for container in $container_list;
do
        docker pull $container &
done

#Mailpile
#easyforms (not a docker container)

#TSYS3 (usb passthrough)
#git subtree add --prefix upstream/cloudflare-cfssl  https://github.com/rjrivero/docker-cfssl.git master --squash
#git subtree add --prefix upstream/cloudflare-certmgr https://github.com/cloudflare/certmgr.git master --squash

#Need to deep dive...
#git subtree add --prefix upstream/wazuh https://github.com/wazuh/wazuh-docker.git master --squash
#git subtree add --prefix upstream/openvas https://github.com/mikesplain/openvas-docker.git  master --squash
#        greenbone/vulnerability-tests \
#        greenbone/notus-data \
#        greenbone/scap-data \
#        securecompliance/gvm:debian-master-data-full \
#        securecompliance/gvm:debian-master-data \
#        securecompliance/gvm:debian-master-full \
#        securecompliance/gvm:debian-master \
#mailman

