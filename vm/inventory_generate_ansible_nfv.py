#!/usr/bin/env python

## NOTE - Not applicable for OSP10 deployments

import json
import subprocess
import yaml


def get_valid_keys(src1, src2={}):
    dst = {}
    keys = ['ansible_connection', 'ansible_host', 'ansible_remote_tmp', 'ansible_ssh_user']
    for key in keys:
        if key in src1:
            dst[key] = src1[key]
        elif key in src2:
            dst[key] = src2[key]
    return dst

result = subprocess.check_output(['tripleo-ansible-inventory', '--list'])
obj = json.loads(result)
host_vars = obj["_meta"]["hostvars"]

hosts = {}
for key, value in obj.items():
    if 'children' in value:
        continue
    if '_meta' in key:
        continue;
    hosts[key] = {'hosts': {}}
    for host in value['hosts']:
        hosts[key]['hosts'][host] = {}
        if key == 'Undercloud':
            hosts[key]['vars'] = get_valid_keys(value['vars'])
        else:
            hosts[key]['vars'] = get_valid_keys(host_vars[host], value['vars'])

hosts['overcloud_nodes'] = {}
hosts['overcloud_nodes']['children'] = {}
for key, value in hosts.items():
    if key not in ['Undercloud', 'overcloud_nodes']:
        hosts['overcloud_nodes']['children'][key] = {}

hosts['tester'] = {}
hosts['tester']['children'] = {'Undercloud': {}}

hosts['undercloud'] = {}
hosts['undercloud']['children'] = {'Undercloud': {}}


ystr = yaml.safe_dump(hosts, default_flow_style=False)
with open('/home/stack/ansible-nfv-hosts.yaml', 'w') as f:
    f.write(ystr)
