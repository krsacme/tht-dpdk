#!/bin/bash

set -x

cp /usr/lib/systemd/system/ovsdb-server.service /etc/systemd/system/ovsdb-server.service
ovs_service_path="/etc/systemd/system/ovsdb-server.service"
grep -q "RuntimeDirectoryMode=.*" $ovs_service_path
if [ "$?" -eq 0 ]; then
    sed -i 's/RuntimeDirectoryMode=.*/RuntimeDirectoryMode=0775/' $ovs_service_path
else
    echo "RuntimeDirectoryMode=0775" >> $ovs_service_path
fi

cp /usr/lib/systemd/system/ovs-vswitchd.service /etc/systemd/system/ovs-vswitchd.service
ovs_service_path="/etc/systemd/system/ovs-vswitchd.service"
grep -q "RuntimeDirectoryMode=.*" $ovs_service_path
if [ "$?" -eq 0 ]; then
    sed -i 's/RuntimeDirectoryMode=.*/RuntimeDirectoryMode=0775/' $ovs_service_path
else
    echo "RuntimeDirectoryMode=0775" >> $ovs_service_path
fi

grep -Fxq "UMask=0002" $ovs_service_path
if [ ! "$?" -eq 0 ]; then
    echo "UMask=0002" >> $ovs_service_path
fi

ovs_ctl_path='/usr/share/openvswitch/scripts/ovs-ctl'
grep -q "umask 0002 \&\& start_daemon \"\$OVS_VSWITCHD_PRIORITY\"" $ovs_ctl_path
if [ ! "$?" -eq 0 ]; then
    sed -i 's/start_daemon \"\$OVS_VSWITCHD_PRIORITY\"\(.*\)/umask 0002 \&\& start_daemon \"$OVS_VSWITCHD_PRIORITY\"\1/' $ovs_ctl_path
fi

sed -i 's/^#group.*/group = \"hugetlbfs\"/' /etc/libvirt/qemu.conf

