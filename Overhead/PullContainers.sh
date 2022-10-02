#!/bin/bash
export container_list="
        jenkins/jenkins \
        elabftw/elabimg \
        huginn/huginn \
        phpipam/phpipam-www \
        photoprism/photoprism \
        securecompliance/gvm:debian-master-data-full \
        securecompliance/gvm:debian-master-data \
        securecompliance/gvm:debian-master-full \
        securecompliance/gvm:debian-master \
        killbill/killbill \
        killbill/kaui \
        drone/drone \
        archivebox/archivebox \
        apache/tika \
        thecodingmachine/gotenberg \
        inventree/inventree \
        jonaswinkler/paperless-ng \
        seknox/guacd \
        seknox/trasa \
        authelia/authelia \
        beanbag/reviewboard:latest \
        pihole/pihole \
        stedolan/jq \
        containrrr/watchtower \
        r7wx/easy-gate \
        lazyteam/lazydocker \
        portainer/portainer-ce:latest \
        xetusoss/archiva

for container in $container_list;
do
        docker pull $container &
done