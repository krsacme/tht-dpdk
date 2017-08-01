#!/bin/bash

source base.sh

openstack overcloud deploy --templates \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e registry.yaml \
    -e dpdk-environment.yaml \
    -e common-environment.yaml \
    -e $ENV_FILE \
    -e dpdk-upgrade-env.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/major-upgrade-composable-steps.yaml \
    -e init-repo.yaml
