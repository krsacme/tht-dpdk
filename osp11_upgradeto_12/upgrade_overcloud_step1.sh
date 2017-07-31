openstack overcloud deploy --templates \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e network-environment.yaml \
    -e dpdk-upgrade-env.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/major-upgrade-composable-steps.yaml \
    -e init-repo.yaml

