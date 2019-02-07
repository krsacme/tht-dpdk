#!/bin/bash

openstack overcloud ffwd-upgrade prepare --templates --yes \
    --timeout 90 \
    -r ~/osp10_ref/roles_data.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e ~/osp10_ref/network-environment.yaml \
    -e ~/osp10_ref/ffu_repo_env.yaml \
    -e ~/overcloud_images.yaml
