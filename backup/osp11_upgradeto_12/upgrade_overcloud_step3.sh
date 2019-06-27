#!/bin/bash

source base.sh

openstack overcloud deploy --templates \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/docker.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/docker-ha.yaml \
    -e registry.yaml \
    -e dpdk-environment.yaml \
    -e common-environment.yaml \
    -e $ENV_FILE \
    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
    -e docker_registry.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/major-upgrade-converge.yaml

