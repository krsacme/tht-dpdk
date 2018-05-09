#!/bin/bash

source base.sh

openstack overcloud container image prepare   \
  --namespace docker-registry.engineering.redhat.com/rhosp13  \
  --prefix "openstack-" \
  --tag 2018-05-07.2 \
  --env-file docker_registry.yaml

