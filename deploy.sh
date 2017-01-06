openstack overcloud deploy --templates \
    --timeout 180 \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /home/stack/templates/network-environment.yaml

#openstack overcloud deploy --templates \
#    --timeout 180 \
#    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
#    -e /home/stack/templates/network-environment.yaml \
#    -e motd-environment.yaml -r roles_data.yaml
#    -e /home/stack/templates/network-isolation.yaml \
#
#    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
#/usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
