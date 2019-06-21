#!/bin/bash

if [[ ! -f 'roles_data.yaml' ]]; then
  openstack overcloud roles generate -o ~/roles_data.yaml Controller ComputeOvsDpdkSriov
fi

openstack overcloud deploy --templates \
    --timeout 90 \
    -r ~/roles_data.yaml \
    -n ~/osp13_ref/network_data.yaml \
    -p /usr/share/openstack-tripleo-heat-templates/plan-samples/plan-environment-derived-params.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-sriov.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e ~/osp13_ref/environment.yaml \
    -e ~/osp13_ref/docker-images.yaml
