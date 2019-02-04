#!/bin/bash

cd ~/osp10_ref/
python generate.py -r roles_data.yaml -i first-boot.role.j2.yaml
python generate.py -r roles_data.yaml -i dpdk-registry.j2.yaml

openstack overcloud deploy --templates \
    --timeout 90 \
    -r ~/osp10_ref/roles_data.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/ovs-dpdk-permissions.yaml \
    -e ~/osp10_ref/dpdk-registry.yaml \
    -e ~/osp10_ref/network-environment.yaml


