#!/bin/bash

source base.sh

if [[ -f 'common/roles_data.yaml' ]]; then
  openstack overcloud role generate -o common/roles_data.yaml Controller ComputeOvsDpdk
fi

openstack overcloud deploy \
    --templates \
    --timeout 120 \
    -r common/roles_data.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services-docker/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/ovs-dpdk-permissions.yaml \
    -e registry.yaml \
    -e common/environment.yaml \
    -e common/$ENV_FILE \
    -e docker_registry.yaml \
    -e ml2-ovs-dpdk-env.yaml

