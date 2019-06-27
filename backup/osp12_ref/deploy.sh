#!/bin/bash

source base.sh

if [[ ! -f 'common/roles_data.yaml' ]]; then
  openstack overcloud roles generate -o common/roles_data.yaml Controller ComputeOvsDpdk
fi

openstack overcloud deploy \
    --templates \
    -r common/roles_data.yaml \
    --timeout 90 \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/docker.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/docker-ha.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/ovs-dpdk-permissions.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/extraconfig/pre_deploy/rhel-registration/rhel-registration-resource-registry.yaml \
    -e environment-rhel-registration.yaml \
    -e common/environment.yaml \
    -e common/$ENV_FILE \
    -e ml2-ovs-dpdk-env.yaml \
    -e docker_registry.yaml

