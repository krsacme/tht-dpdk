#!/bin/bash

source base.sh

if [[ $LAB == '' ]]; then 
  openstack overcloud container image prepare   \
    --namespace 10.60.19.51:5000/rhosp13  \
    --prefix "openstack-" \
    --tag latest \
    --service-environment-file /usr/share/openstack-tripleo-heat-templates/environments/docker.yaml \
    --env-file docker_registry.yaml

else

  openstack overcloud container image prepare   \
    --namespace docker-registry.engineering.redhat.com/rhosp13  \
    --prefix "openstack-" \
    --tag 2018-03-16.1 \
    --service-environment-file /usr/share/openstack-tripleo-heat-templates/environments/docker.yaml \
    --env-file docker_registry.yaml
fi

