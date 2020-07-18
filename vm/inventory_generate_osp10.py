#!/usr/bin/env python
import json
import subprocess
import yaml

result = subprocess.check_output(['tripleo-ansible-inventory', '--list'])
obj = json.loads(result)
hosts = {}
for key, value in obj.items():
    hosts[key] = {'hosts': {}}
    if type(value) is list:
        for i in value:
            hosts[key]['hosts'][i] = {}
    elif value.get('children'):
        hosts[key]['children'] = {}
        for i in value.get('children'):
            hosts[key]['children'][i] = {}
    elif value.get('hosts'):
        hosts[key]['hosts'] = {}
        for i in value.get('hosts'):
            hosts[key]['hosts'][i] = {}
    if type(value) is not list and value.get('vars'):
        hosts[key]['vars'] = value.get('vars')

ystr = yaml.safe_dump(hosts, default_flow_style=False)
with open('/home/stack/hosts', 'w') as f:
    f.write(ystr)
