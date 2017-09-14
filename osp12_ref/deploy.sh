#!/bin/bash

source base.sh

openstack overcloud deploy \
    --templates \
    -r roles_data.yaml \
    --timeout 90 \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/docker.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/docker-ha.yaml \
    -e registry.yaml \
    -e dpdk-environment.yaml \
    -e common-environment.yaml \
    -e $ENV_FILE \
    -e docker_registry.yaml \
    -e temp-env.yaml

# Post Deploy Workarounds
# systemctl start virtlogd.socket

