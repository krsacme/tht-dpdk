openstack overcloud deploy --templates \
    --timeout 180 \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /home/stack/templates/network-environment.yaml

