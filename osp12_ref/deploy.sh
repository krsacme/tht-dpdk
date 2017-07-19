openstack overcloud deploy \
    --templates /home/stack/templates/openstack-tripleo-heat-templates \
    -r roles_data.yaml \
    --timeout 90 \
    -e /home/stack/templates/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e /home/stack/templates/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /home/stack/templates/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e network-environment.yaml

