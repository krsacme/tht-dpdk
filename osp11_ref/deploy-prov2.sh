openstack overcloud deploy --templates \
    --timeout 90 \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e registry.yaml \
    -e dpdk-environment.yaml \
    -e common-environment.yaml \
    -e network-environment-prov2.yaml
