#!/bin/bash

openstack overcloud ffwd-upgrade prepare --templates --yes \
    --timeout 90 \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e ~/osp10_ffu_13/network-environment.yaml \
    -e ~/osp10_ffu_13/repo-env.yaml \
    -e ~/overcloud_images.yaml
