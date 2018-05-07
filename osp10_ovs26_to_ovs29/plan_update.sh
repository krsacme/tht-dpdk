openstack overcloud deploy --templates \
    --timeout 90 \
    --update-plan-only  \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e network-environment.yaml \
    -e ovs29.yaml \
    -e update.yaml
