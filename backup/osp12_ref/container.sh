#!/bin/bash

#docker pull docker-registry.engineering.redhat.com/rhosp12/openstack-aodh-api:12.0-20180625.2

openstack overcloud container image prepare \
     --namespace=docker-registry.engineering.redhat.com/rhosp12 \
     --prefix=openstack- \
     --tag=12.0-20180625.2 \
     --set ceph_namespace=docker-registry.engineering.redhat.com/ceph \
     --set ceph_image=rhceph-2-rhel7 \
     --set ceph_tag=latest \
     --env-file docker_registry.yaml
