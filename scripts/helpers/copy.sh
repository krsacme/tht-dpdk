#!/bin/bash

source /home/stack/stackrc

set -x

SSHP="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
set -x

CONTROL=$(openstack server list | grep controller | awk '{ print $8}' | cut -d '=' -f 2)

for i in $CONTROL; do
  scp $SSHP launch.sh overcloudrc* /home/stack/rhel* heat-admin@$i:~
done

NODES=$(openstack server list | grep ctlplane | awk '{ print $8}' | cut -d '=' -f 2)
for i in $NODES; do
  scp $SSHP vhost.repo ovs_service_patch.sh create_ovs29_user.sh heat-admin@$i:~
  ssh $SSHP heat-admin@$i 'sudo mv /home/heat-admin/vhost.repo /etc/yum.repos.d/'
  ssh $SSHP heat-admin@$i 'sudo yum localinstall -y http://download.lab.bos.redhat.com/rcm-guest/puddles/OpenStack/rhos-release/rhos-release-latest.noarch.rpm'
  ssh $SSHP heat-admin@$i 'sudo rhos-release 10'
done

COMPUTES=$(openstack server list | grep compute | awk '{ print $8}' | cut -d '=' -f 2)
for i in $COMPUTES; do
  ssh $SSHP heat-admin@$i 'sudo yum update os-net-config -y; sudo os-net-config -c /etc/os-net-config/config.json --no-activate'
done

