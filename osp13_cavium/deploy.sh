#!/bin/bash

if [[ ! -f 'roles_data.yaml' ]]; then
  openstack overcloud roles generate -o roles_data.yaml Controller ComputeLiquidio
fi

openstack overcloud deploy \
    --templates \
    --timeout 240 \
    -r roles_data.yaml \
    -n network_data.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services-docker/neutron-opendaylight.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/net-multiple-nics.yaml \
    -e environment.yaml \
    -e network-environment.yaml \
    -e overcloud_images.yaml   \
    -e /usr/share/openstack-tripleo-heat-templates/environments/cavium-liquidio.yaml
