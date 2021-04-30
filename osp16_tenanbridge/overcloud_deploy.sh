#!/bin/bash

PARAMS="$*"

openstack overcloud deploy $PARAMS \
--timeout 100 \
--templates /usr/share/openstack-tripleo-heat-templates \
--stack overcloud \
--libvirt-type kvm \
--ntp-server clock1.rdu2.redhat.com \
-e /home/stack/osp16_ref/config_lvm.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovs.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-sriov.yaml \
-e /usr/share/openstack-tripleo-heat-templates/environments/services/octavia.yaml \
-n /home/stack/osp16_ref/network/network_data.yaml \
-r /home/stack/osp16_ref/roles/roles_data.yaml \
-e /home/stack/osp16_ref/network/network-environment.yaml \
-e /home/stack/osp16_ref/hostnames.yml \
-e /home/stack/osp16_ref/environment.yaml \
-e /home/stack/osp16_ref/ml2-ovs-nfv.yaml \
-e /home/stack/osp16_ref/network-environment-sriovonly.yaml \
-e /home/stack/osp16_ref/network-environment.yaml \
-e /home/stack/osp16_ref/debug.yaml \
-e /home/stack/osp16_ref/nodes_data.yaml \
-e ~/containers-prepare-parameter.yaml \
-e /home/stack/osp16_ref/docker-images.yaml \
--log-file overcloud_deployment_77.log
#-e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovn-ha.yaml \
