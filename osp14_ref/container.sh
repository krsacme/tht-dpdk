#!/bin/bash

source base.sh

if [[ ! -f 'common/roles_data.yaml' ]]; then
  openstack overcloud roles generate -o common/roles_data.yaml Controller ComputeOvsDpdk
fi

openstack overcloud container image prepare   \
  --namespace docker-registry.engineering.redhat.com/rhosp14  \
  -r common/roles_data.yaml \
  --prefix "openstack-" \
  --tag 2018-07-09.1 \
  --env-file docker_registry.yaml

