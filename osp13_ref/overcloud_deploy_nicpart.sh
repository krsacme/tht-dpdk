#!/bin/bash

PARAMS="$*"

if [ ! -d /home/stack/images ]; then
    mkdir -p /home/stack/images
    pushd /home/stack/images
    for i in /usr/share/rhosp-director-images/overcloud-full-latest-13.0.tar /usr/share/rhosp-director-images/ironic-python-agent-latest-13.0.tar; do tar -xvf $i; done
    sudo yum install libguestfs-tools -y
    export LIBGUESTFS_BACKEND=direct
    virt-customize --root-password password:redhat -a overcloud-full.qcow2

    # https://review.opendev.org/c/openstack/os-net-config/+/727634
    mkdir -p mount_image
    guestmount -a overcloud-full.qcow2 -m /dev/sda mount_image
    sed -i 's/processutils.execute(\*cmd, \*\*kwargs)/processutils.execute(\*cmd, delay_on_retry=True, attempts=10, \*\*kwargs)/' mount_image/usr/lib/python2.7/site-packages/os_net_config/sriov_config.py
    guestunmount mount_image

    openstack overcloud image upload --image-path /home/stack/images/ --update-existing
    for i in $(openstack baremetal node list -c UUID -f value); do openstack overcloud node configure $i; done
    popd
fi

# Always generate roles_data file
openstack overcloud roles generate -o /home/stack/roles_data.yaml Controller ComputeOvsDpdkSriov

openstack overcloud deploy $PARAMS \
    --templates \
    --timeout 120 \
    -r /home/stack/roles_data.yaml \
    -n /home/stack/osp13_ref/network_data.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-sriov.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e /home/stack/osp13_ref/environment.yaml \
    -e /home/stack/osp13_ref/network-environment.yaml \
    -e /home/stack/osp13_ref/network-environment-nicpart.yaml \
    -e /home/stack/osp13_ref/ml2-ovs-nfv.yaml \
    -e /home/stack/osp13_ref/docker-images.yaml

