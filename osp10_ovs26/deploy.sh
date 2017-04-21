openstack overcloud deploy --templates \
    --timeout 90 \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e network-environment.yaml

