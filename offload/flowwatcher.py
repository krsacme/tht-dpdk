#!/usr/bin/env python

import subprocess
import curses
import time

flow_map = {}

def list_dp_ovs_flows(window):
	for i in range(30):
		cmd = ['ovs-dpctl', 'dump-flows', 'type=offloaded', '-m', '--names']
		p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		out, err = p.communicate()
		flow_list = []
		flow_new = {}
		for line in out.split('\n'):
			if 'ufid' not in line:
				continue
			ufid = line.split(',')[0].split(':')[1]
			flow_list.append(ufid)
			if ufid in flow_map:
				flow_map[ufid] = line
			else:
				flow_new[ufid] = line

		flows_in_map = flow_map.keys()
		older = diff(flows_in_map, flow_list)
		deleted = []
		for item in older:
			deleted.append(flow_map.pop(item))

		out = '\n\n'.join(flow_map.values())
		if deleted:
			out += '\n\nDELETED FLOWS\n'
			out += '----------------\n'
			out += '\n'.join(deleted)
		if flow_new:
			out += '\n\nNEW FLOWS \n'
			out += '------------\n'
			out += '\n'.join(flow_new.values())

		window.clear()
		window.addstr(0, 0, out)
		window.refresh()
		time.sleep(1)

		flow_map.update(flow_new)


def diff(first, second):
    second = set(second)
    return [item for item in first if item not in second]


if __name__ == "__main__":
	#list_dp_ovs_flows()
	curses.wrapper(list_dp_ovs_flows)

