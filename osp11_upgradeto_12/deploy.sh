#!/bin/bash

echo "ERROR - Upgrade only scripts"
exit

source base.sh

# NOTE:
# host-config-and-reboot.yaml should not be used during upgrade

openstack overcloud deploy --templates \
    --timeout 90 \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/docker.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/docker-ha.yaml \
    -e registry.yaml \
    -e dpdk-environment.yaml \
    -e common-environment.yaml \
    -e $ENV_FILE \
    -e docker_registry.yaml
