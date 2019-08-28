#!/bin/bash

openstack overcloud deploy \
--templates \
-e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/neutron-sriov.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/ovs-dpdk-permissions.yaml \
-e /home/stack/ospd-10-vxlan-dpdk-sriov-ctlplane-dataplane-bonding-hybrid/api-policies.yaml \
-e /home/stack/ospd-10-vxlan-dpdk-sriov-ctlplane-dataplane-bonding-hybrid/os-net-config-mappings.yaml \
-e /home/stack/ospd-10-vxlan-dpdk-sriov-ctlplane-dataplane-bonding-hybrid/network-environment.yaml \
--log-file overcloud_install.log &> overcloud_install.log
