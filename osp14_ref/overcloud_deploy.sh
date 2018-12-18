#!/bin/bash

PARAMS="$*"

openstack overcloud deploy $PARAMS \
    --templates \
    --timeout 120 \
    -r ~/osp14_ref/roles_data.yaml \
    -n ~/osp14_ref/network_data_routed_pool3.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
    -e ~/osp14_ref/environment.yaml \
    -e ~/osp14_ref/network-environment.yaml \
    -e ~/osp14_ref/ml2-ovs-dpdk-env.yaml \
    -e ~/containers-prepare-parameter.yaml

#    -e ~/osp14_ref/routed-environment.yaml \
