#!/bin/bash

if [ $# != 1 ] ; then
  echo "Usage: $0 <num>"
  echo "  num should 1 or 2"
  echo "  Provisioning Network should be provided as input!!"
  exit 1
fi

PROV=$1
if [[ $PROV != 1 && $PROV != 2 ]] ; then
  echo "Provisioning Network should be either 1 or 2 but $PROV given."
  exit 1
fi

ENV_FILE="network-environment-prov$PROV.yaml"
echo "Using provisioning environment file as $ENV_FILE ..."

openstack overcloud deploy --templates \
    --timeout 90 \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e registry.yaml \
    -e dpdk-environment.yaml \
    -e common-environment.yaml \
    -e $ENV_FILE \
    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml
