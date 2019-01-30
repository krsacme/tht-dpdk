#!/bin/bash

if [[ ! -f 'roles_data.yaml' ]]; then
  openstack overcloud roles generate -o ~/roles_data.yaml Controller ComputeOvsDpdk
fi

openstack overcloud deploy --templates \
    --timeout 90 \
    -r ~/roles_data.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services-docker/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/ovs-dpdk-permissions.yaml \
    -e ~/osp13_ref/network-environment.yaml \
    -e ~/osp13_ref/docker-images.yaml \
    -e ~/osp13_ref/ml2-ovs-dpdk-env.yaml
