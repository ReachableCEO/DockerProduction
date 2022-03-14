#!/bin/bash

export container_list="
        jenkins/jenkins \
        elabftw/elabimg \
        huginn/huginn \
        phpipam/phpipam-www \
        photoprism/photoprism \
        deamos/openstreamingplatform \
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
        linuxserver/swag \
        authelia/authelia \
        beanbag/reviewboard:latest \
        containrrr/watchtower:latest \
        perara/wg-manager \
        xetusoss/archiva
        "
for container in $container_list;
do
        docker pull $container
done
