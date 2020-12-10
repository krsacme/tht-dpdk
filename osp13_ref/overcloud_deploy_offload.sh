#!/bin/bash

PARAMS="$*"

if [ ! -d $HOME/images ]; then
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

# Always generate roles_data file
openstack overcloud roles generate -o $HOME/roles_data.yaml Controller ComputeSriov

openstack overcloud deploy $PARAMS \
    --templates \
    --timeout 120 \
    -r $HOME/roles_data.yaml \
    -n $HOME/osp13_ref/network_data.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/ovs-hw-offload.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e $HOME/osp13_ref/environment.yaml \
    -e $HOME/osp13_ref/network-environment-offload.yaml \
    -e $HOME/osp13_ref/ml2-ovs-nfv.yaml \
    -e $HOME/osp13_ref/docker-images.yaml

# FFU with tripleo_upgrade role requires 'redis' pcs entry else it will fail, so keep telemetry enabled
#-e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
