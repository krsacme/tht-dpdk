#!/usr/bin/env python

import libvirt
import libxml2
import os


def get_cpu_layout():
    cpu_layout = []
    numa_node_path = '/sys/devices/system/node/'
    numa_node_count = 0
    for numa_node_dir in os.listdir(numa_node_path):
        numa_node_dir_path = os.path.join(numa_node_path, numa_node_dir)
        if (os.path.isdir(numa_node_dir_path)
                and numa_node_dir.startswith("node")):
            cpu_layout.append([])
            numa_node_count += 1
    for item in range(numa_node_count):
        core_id_map = {}
        numa_node_dir = os.path.join(numa_node_path, 'node' + str(item))
        thread_dirs = os.listdir(numa_node_dir)
        for thread_dir in thread_dirs:
            if (not os.path.isdir(os.path.join(numa_node_dir, thread_dir))
                    or not thread_dir.startswith("cpu")):
                continue
            thread_id = int(thread_dir[3:])
            with open(os.path.join(numa_node_dir, thread_dir, 'topology',
                                   'core_id')) as core_id_file:
                cpu_id = int(core_id_file.read().strip())
                if cpu_id not in core_id_map:
                    core_id_map[cpu_id] = []
                core_id_map[cpu_id].append(thread_id)
        for k, v in core_id_map.items():
            cpu_layout[item].append(v)
    return cpu_layout


def get_cpus(conn, domainID, xpath):
    domain = conn.lookupByID(domainID)
    raw_xml = domain.XMLDesc(0)
    doc = libxml2.parseDoc(raw_xml)
    ctx = doc.xpathNewContext()
    cpu_list = []

    cpu_xml = ctx.xpathEval(xpath)
    for cpu in cpu_xml:
        cpu_list.append(cpu.prop('cpuset'))
    return cpu_list


def main():
    conn = libvirt.openReadOnly(None)
    if not conn:
        print('Failed to open connection to qemu:///system')
        exit(1)

    domainIDs = conn.listDomainsID()
    if domainIDs == None:
        print('Failed to get a list of domain IDs')
        exit(1)

    domain_info = {}
    for domainID in domainIDs:
        domain = conn.lookupByID(domainID)
        name = domain.name()
        domain_info[name] = {}
        vcpu_list = get_cpus(conn, domainID, "/domain/cputune/vcpupin")
        domain_info[name]['vcpus'] = vcpu_list

        emu_list = get_cpus(conn, domainID, "/domain/cputune/emulatorpin")
        domain_info[name]['emulator'] = emu_list

    cpu_layout = get_cpu_layout()
    for item, value in domain_info.iteritems():
        print(item)
        print(value)


if __name__ == "__main__":
    main()
