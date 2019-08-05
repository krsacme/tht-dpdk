#!/bin/bash

PARAMS="$*"
USER_THT='/home/stack/ospd-13-vxlan-dpdk-sriov-ctlplane-dataplane-bonding-hybrid'
DEFAULT_THT='/usr/share/openstack-tripleo-heat-templates'

openstack overcloud deploy $PARAMS \
  --templates \
  -r $USER_THT/roles_data.yaml \
  -n $USER_THT/network_data.yaml \
  -e $DEFAULT_THT/environments/network-environment.yaml \
  -e $DEFAULT_THT/environments/network-isolation.yaml \
  -e $DEFAULT_THT/environments/host-config-and-reboot.yaml \
  -e $DEFAULT_THT/environments/services/neutron-ovs-dpdk.yaml \
  -e $DEFAULT_THT/environments/services/neutron-sriov.yaml \
  -e $DEFAULT_THT/environments/ovs-hw-offload.yaml \
  -e $USER_THT/docker-images.yaml \
  -e $USER_THT/api-policies.yaml \
  -e $USER_THT/os-net-config-mappings.yaml \
  -e $USER_THT/network-environment-overrides.yaml
