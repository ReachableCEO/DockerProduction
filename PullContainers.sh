#!/bin/bash
export container_list="
        elabftw/elabimg \
        huginn/huginn \
        phpipam/phpipam-www \
        securecompliance/gvm:debian-master-data-full \
        securecompliance/gvm:debian-master-data \
        securecompliance/gvm:debian-master-full \
        securecompliance/gvm:debian-master \
        killbill/killbill \
        killbill/kaui \
        inventree/inventree \
        seknox/trasa \
        beanbag/reviewboard:latest \
        pihole/pihole \
        stedolan/jq \
        containrrr/watchtower \
        r7wx/easy-gate \
        xetusoss/archiva"

#git subtree add --prefix upstream/rundeck https://github.com/rundeck/docker-zoo.git master --squash
#git subtree add --prefix upstream/ er-archiva.git
#git subtree add --prefix upstream/bastillion https://github.com/e-COSI/docker-bastillion.git master --squash
#git subtree add --prefix upstream/openvas https://github.com/mikesplain/openvas-docker.git  master --squash
#git subtree add --prefix upstream/openfaas https://github.com/openfaas/faas.git master --squash
#git subtree add --prefix upstream/wazuh https://github.com/wazuh/wazuh-docker.git master --squash
#git subtree add --prefix upstream/librenms  https://github.com/librenms/docker.git master --squash
#git subtree add --prefix upstream/  https://github.com/xetus-oss/dockgit 
#git subtree add --prefix upstream/graylog2 https://github.com/Graylog2/graylog-docker.git  master --squash
#sipwise
#mailman
#Mailpile
#Portus
#flyve (mdm)
#easyforms
#easy-gate

#TSYS3 (usb passthrough)
#git subtree add --prefix upstream/cloudflare-cfssl  https://github.com/rjrivero/docker-cfssl.git master --squash
#git subtree add --prefix upstream/cloudflare-certmgr https://github.com/cloudflare/certmgr.git master --squash

for container in $container_list;
do
        docker pull $container &
done
