#!/bin/bash

if [[ ! -f 'roles_data.yaml' ]]; then
  openstack overcloud roles generate -o ~/roles_data.yaml Controller ComputeOvsDpdk
fi

openstack overcloud container image prepare   \
  --namespace docker-registry.engineering.redhat.com/rhosp14  \
  -r ~/roles_data.yaml \
  --prefix "openstack-" \
  --tag 2018-07-09.1 \
  --env-file docker_registry.yaml

