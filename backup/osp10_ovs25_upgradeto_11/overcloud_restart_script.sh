#!/bin/bash

# NOT WORKING
set -x

NO_OVS_AGENT=0
systemctl status neutron-openvswitch-agent
if [[ $? -ne 0 ]]; then
  NO_OVS_AGENT=1
fi

sudo systemctl stop openvswitch
if [[ $NO_OVS_AGENT -eq 0 ]]; then
  systemctl stop neutron-openvswitch-agent
fi
for i in $(ps aux | grep -v grep | grep ovs | awk '{print $2}'); do kill -9 $i; done
sudo systemctl daemon-reload
sudo systemctl start openvswitch
if [[ $NO_OVS_AGENT -eq 0 ]]; then
  systemctl start neutron-openvswitch-agent
fi
