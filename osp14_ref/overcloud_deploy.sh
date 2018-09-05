#!/bin/bash

if [[ ! -f 'roles_data.yaml' ]]; then
  openstack overcloud roles generate -o ~/roles_data.yaml Controller ComputeOvsDpdk
fi

openstack overcloud deploy \
    --templates \
    --timeout 120 \
    -r ~/roles_data.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e /home/stack/osp14_ref/environment.yaml \
    -e /home/stack/osp14_ref/network-environment.yaml \
    -e /home/stack/osp14_ref/docker-images.yaml \
    -e /home/stack/osp14_ref/ml2-ovs-dpdk-env.yaml

