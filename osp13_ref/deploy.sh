#!/bin/bash

source base.sh

openstack overcloud deploy \
    --templates \
    -r common/roles_data.yaml \
    --timeout 90 \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services-docker/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk-permissions.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/docker.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/docker-ha.yaml \
    -e registry.yaml \
    -e common/environment.yaml \
    -e common/$ENV_FILE \
    -e ml2-ovs-dpdk-env.yaml \
    -e docker_registry.yaml

