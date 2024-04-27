#!/bin/bash

for container in $(cat ./($hostname -s)/$(hostname -s)-containers.txt;
do
        docker pull $container 
done