#!/bin/bash

set -x

function tuned_service_patch() {
    tuned_service=/usr/lib/systemd/system/tuned.service
    grep -q "network.target" $tuned_service
    if [ "$?" -eq 0 ]; then
        sed -i '/After=.*/s/network.target//g' $tuned_service
    fi
    grep -q "Before=.*network.target" $tuned_service
    if [ ! "$?" -eq 0 ]; then
        grep -q "Before=.*" $tuned_service
        if [ "$?" -eq 0 ]; then
            sed -i 's/^\(Before=.*\)/\1 network.target openvswitch.service/g' $tuned_service
        else
            sed -i '/After/i Before=network.target openvswitch.service' $tuned_service
        fi
    fi
}

function ovs_service_permission_patch() {
    ovs_service_path="/usr/lib/systemd/system/ovs-vswitchd.service"
    restart_ovs=false
    grep -q "RuntimeDirectoryMode=.*" $ovs_service_path
    if [ "$?" -eq 0 ]; then
        sed -i 's/RuntimeDirectoryMode=.*/RuntimeDirectoryMode=0775/' $ovs_service_path
    else
        echo "RuntimeDirectoryMode=0775" >> $ovs_service_path
    fi
        grep -Fxq "Group=qemu" $ovs_service_path
    if [ ! "$?" -eq 0 ]; then
        echo "Group=qemu" >> $ovs_service_path
        restart_ovs=true
    fi
    grep -Fxq "UMask=0002" $ovs_service_path
    if [ ! "$?" -eq 0 ]; then
        echo "UMask=0002" >> $ovs_service_path
        restart_ovs=true
    fi
    ovs_ctl_path='/usr/share/openvswitch/scripts/ovs-ctl'
    grep -q "umask 0002 \&\& start_daemon \"\$OVS_VSWITCHD_PRIORITY\"" $ovs_ctl_path
    if [ ! "$?" -eq 0 ]; then
        sed -i 's/start_daemon \"\$OVS_VSWITCHD_PRIORITY.*/umask 0002 \&\& start_daemon \"$OVS_VSWITCHD_PRIORITY\" \"$OVS_VSWITCHD_WRAPPER\" \"$@\"/' $ovs_ctl_path
        restart_ovs=true
    fi

    systemctl daemon-reload
    if [ $restart_ovs == true ]; then
        systemctl restart openvswitch
        systemctl restart network
        systemctl restart neutron-openvswitch-agent
    fi
}

if hiera -c /etc/puppet/hiera.yaml service_names | grep -q neutron_ovs_dpdk_agent; then
    tuned_service_patch
    ovs_service_permission_patch
fi
