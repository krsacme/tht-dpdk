#!/usr/bin/env python

import json
import sys


def main(file):
    modified = {'nodes': []}
    start_port = 6230
    host_cmd = []
    uc_cmd = []
    with open(file, 'r') as f:
        data = f.read()
        instack = json.loads(data)
        for node in instack['nodes']:
            if node['pm_type'] == 'pxe_ssh':
                node['pm_type'] = 'pxe_ipmitool'
                node['pm_user'] = 'admin'
                node['pm_port'] = str(start_port)
                start_port += 1
                node['pm_password'] = 'redhat'
                if 'disks' in node:
                    del node['disks']
                host_cmd.append('vbmc add ' + node['name'] +
                                ' --port ' + node['pm_port'] +
                                ' --username ' + node['pm_user'] +
                                ' --password ' + node['pm_password'])
                host_cmd.append('vbmc start ' + node[name])
                uc_cmd.append('openstack baremetal node set ' +
                              node['name'] + ' --driver ' + node['pm_type'] +
                              ' --driver-info ipmi_address=' + node['pm_addr'] +
                              ' --driver-info ipmi_port=' + node['pm_port'] +
                              ' --driver-info ipmi_username="' + node['pm_user'] + '" ' +
                              ' --driver-info ipmi_password="' + node['pm_password'] + '"')
            modified['nodes'].append(node)
    modified_content = json.dumps(modified, sort_keys=True, indent=2)
    with open(file, 'w') as f:
        f.write(modified_content)
    print("######")
    print("# Run below commands in the hybrid host")
    print("\n".join(host_cmd))
    print("######")
    print("# Run below commands in the undercloud node")
    print("\n".join(uc_cmd))


if __name__ == "__main__":
    if len(sys.argv) > 1:
        main(sys.argv[1])
    else:
        print("Provide instackenv.json file as input")
