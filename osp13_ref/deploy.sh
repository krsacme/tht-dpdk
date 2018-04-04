#!/bin/bash

source base.sh

openstack overcloud deploy \
    --templates \
    --timeout 120 \
    -r common/roles_data.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/docker.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/docker-ha.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services-docker/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk-permissions.yaml \
    -e registry.yaml \
    -e common/environment.yaml \
    -e common/$ENV_FILE \
    -e docker_registry.yaml \
    -e ml2-ovs-dpdk-env.yaml


#    -e /usr/share/openstack-tripleo-heat-templates/environments/config-download-environment.yaml \
#    -e /usr/share/openstack-tripleo-heat-templates/environments/nonha-arch.yaml \
#    -e /usr/share/openstack-tripleo-heat-templates/environments/docker-ha.yaml \
#    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
#    -e /usr/share/openstack-tripleo-heat-templates/environments/services-docker/neutron-ovs-dpdk.yaml \
#    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk-permissions.yaml \
#    -r common/roles_data.yaml \
#    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
