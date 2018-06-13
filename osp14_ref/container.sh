#!/bin/bash

source base.sh

openstack overcloud container image prepare   \
  --namespace docker-registry.engineering.redhat.com/rhosp14  \
  --prefix "openstack-" \
  --tag 2018-06-04.1 \
  --env-file docker_registry.yaml

