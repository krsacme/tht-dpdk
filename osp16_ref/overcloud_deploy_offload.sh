#!/bin/bash

PARAMS="$*"
USER_THT="$HOME/osp16_ref"

# Always generate roles_data file
openstack overcloud roles generate -o $HOME/roles_data.yaml Controller ComputeSriov:ComputeSriovOffload

openstack overcloud deploy $PARAMS \
    --templates \
    --timeout 120 \
    -r $HOME/roles_data.yaml \
    -n $USER_THT/network_data.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovs.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/ovs-hw-offload.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
    -e $USER_THT/environment.yaml \
    -e $USER_THT/network-environment-offload.yaml \
    -e $USER_THT/ml2-ovs-nfv.yaml \
    -e $HOME/containers-prepare-parameter.yaml

