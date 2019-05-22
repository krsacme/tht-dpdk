#!/bin/bash

PARAMS="$*"

openstack overcloud deploy $PARAMS \
--templates \
-r /home/stack/osp14/roles_data.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovs-dpdk.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-sriov.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/ovs-hw-offload.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/collectd-environment.yaml \
-e /home/stack/osp14/api-policies.yaml \
-e /home/stack/osp14/network-environment.yaml \
-e /home/stack/osp14/nic-mapping-env.yaml \
-e /home/stack/containers-prepare-parameter.yaml
