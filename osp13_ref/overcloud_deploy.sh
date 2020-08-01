#!/bin/bash

PARAMS="$*"

if [ ! -d $HOME/images ]; then
    # OSP13 Derive PCI fix
    curl -4 https://review.opendev.org/changes/741922/revisions/788d282960cf21c9687e85e721abd236db8699c8/patch?download | base64 -d | sudo patch  -d /usr/share/openstack-tripleo-heat-templates/ -p1

    mkdir -p $HOME/images
    pushd $HOME/images
    for i in /usr/share/rhosp-director-images/overcloud-full-latest-13.0.tar /usr/share/rhosp-director-images/ironic-python-agent-latest-13.0.tar; do tar -xvf $i; done
    sudo yum install libguestfs-tools -y
    export LIBGUESTFS_BACKEND=direct
    virt-customize --root-password password:redhat -a overcloud-full.qcow2
    openstack overcloud image upload --image-path /home/stack/images/ --update-existing
    for i in $(openstack baremetal node list -c UUID -f value); do openstack overcloud node configure $i; done
    popd
fi

openstack overcloud roles generate -o $HOME/roles_data.yaml Controller ComputeOvsDpdkSriov

openstack overcloud deploy $PARAMS \
    --templates \
    --timeout 120 \
    -r $HOME/roles_data.yaml \
    -n $HOME/osp13_ref/network_data.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-ovs-dpdk.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/services/neutron-sriov.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
    -e $HOME/osp13_ref/environment.yaml \
    -e $HOME/osp13_ref/network-environment.yaml \
    -e $HOME/osp13_ref/ml2-ovs-dpdk.yaml \
    -e $HOME/osp13_ref/docker-images.yaml

