openstack overcloud deploy --templates \
    --timeout 180 \
    -e /home/stack/templates/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /home/stack/templates/network-environment.yaml

#    -e /home/stack/templates/network-isolation.yaml \
#/usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
