#!/bin/bash

PARAMS="$*"
USER_THT="$HOME/osp16_ref"

if [[ ! -f 'roles_data.yaml' ]]; then
	openstack overcloud roles generate -o $HOME/roles_data.yaml Controller ComputeOvsDpdkSriov
fi

openstack overcloud deploy $PARAMS \
    --templates \
    --timeout 120 \
    -r $HOME/roles_data.yaml \
    -n $USER_THT/network_data_routed_pool3.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovs.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/netcontrold.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-sriov.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
    -e $USER_THT/environment.yaml \
    -e $USER_THT/network-environment.yaml \
    -e $USER_THT/ml2-ovs-dpdk.yaml \
    -e $HOME/containers-prepare-parameter.yaml

