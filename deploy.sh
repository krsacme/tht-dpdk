openstack overcloud deploy --templates \
    --timeout 180 \
    -r /home/stack/templates/roles_data.yaml \
    -e /home/stack/templates/network-environment.yaml

#    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
