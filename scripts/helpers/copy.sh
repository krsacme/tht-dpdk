#!/bin/bash

source /home/stack/stackrc

set -x

SSHP="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
set -x

CONTROL=$(openstack server list | grep controller | awk '{ print $8}' | cut -d '=' -f 2)

for i in $CONTROL; do
  scp $SSHP launch.sh overcloudrc* /home/stack/rhel* heat-admin@$i:~
done

