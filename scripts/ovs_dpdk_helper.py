#!/usr/bin/env python

import argparse
import os
import re
from subprocess import check_output
import sys
import yaml

# cpu_layout:
#           [
#               [ # numa0
#                   [0,1], # numa0 - core0
#                   [2,3]  # numa0 - core1
#               ],
#               [ # numa1
#                   [8,9], # numa1 - core0
#               ]
#           ]

NOVA_HOST_RESRVED_MEMORY = 4096

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

def get_pmd_core_list(args, cpu_layout):
    num_of_cores = args.cores_per_numa
    pmd_core_list = []

    # TODO: Get this value from the DPDK nic config in compute nodes (ovs-vsctl)
    dpdk_enabled_numa = [0]
    for numa in range(len(cpu_layout)):
        if numa in dpdk_enabled_numa:
            # DPDK enabled
            num_of_cores = args.cores_per_numa
        else:
            # Non-DPDK NUMA will have 1 core dedicated
            num_of_cores = 1

        if (num_of_cores + 1) >= len(cpu_layout[numa]):
            print("Not enough cores for PMD. requested(%s) available(%s)"
                  % (num_of_cores, len(cpu_layout[numa])))
            sys.exit(1)

        for core in range(1, (num_of_cores + 1)):
            pmd_core_list.extend(cpu_layout[numa][core])

    pmd_core_list.sort()
    pmd_core_list_str = ','.join(map(str, pmd_core_list))
    return pmd_core_list_str

def get_host_core_list(cpu_layout):
    host_core_list = []
    for numa in range(len(cpu_layout)):
        host_core_list.extend(cpu_layout[numa][0])

    host_core_list.sort()
    host_core_list_str = ','.join(map(str, host_core_list))
    return host_core_list_str

def get_nova_cpus_list(args, cpu_layout):
    nova_cpu_list = []
    pmd_core_list = get_pmd_core_list(args, cpu_layout).split(',')
    host_core_list = get_host_core_list(cpu_layout).split(',')
    exclude = host_core_list + pmd_core_list
    for numa in range(len(cpu_layout)):
        for core in range(len(cpu_layout[numa])):
            if str(cpu_layout[numa][core][0]) not in exclude:
                nova_cpu_list.extend(cpu_layout[numa][core])

    nova_cpu_list.sort()
    nova_cpu_list_str = ','.join(map(str, nova_cpu_list))
    return nova_cpu_list_str

def get_isolated_core_list(args, cpu_layout):
    pmd_core_list = get_pmd_core_list(args, cpu_layout).split(',')
    nova_cpu_list = get_nova_cpus_list(args, cpu_layout).split(',')
    isol_cpus = pmd_core_list + nova_cpu_list
    isol_cpus.sort()
    isol_cpus_str = ','.join(isol_cpus)
    return isol_cpus_str

def get_memory_channels(args, cpu_layout):
    stdout = check_output(['dmidecode', '-t', 'memory']).split('\n')
    regex = re.compile(r'^\tLocator:.*')
    dimms_list = [i for i in stdout if regex.search(i)]
    dimms_all = [i.split(':')[1].strip(' ') for i in dimms_list]
    dimm_stripped = [re.sub(r'[0-9]', '', i) for i in dimms_all]
    dimm = list(set(dimm_stripped))
    mem_channel = len(dimm) / len(cpu_layout)
    return str(mem_channel)

def get_socket_memory():
    pass

def get_huge_page_count():
    stdout = check_output(['cat', '/proc/meminfo']).split('\n')
    for item in stdout:
        if 'MemTotal' in item:
            mem_str = item.split(':')[1].strip(' ').strip('\n')
            mem_str = mem_str.split(' ')[0]
            mem = int(mem_str) / (1024 * 1024)
            return mem

def get_kernel_args(args):
    kernel_args = "iommu=pt"
    stdout = check_output(['dmidecode']).split('\n')
    regex = re.compile(r'Intel.*CPU')
    cpu = [i for i in stdout if regex.search(i)]
    if cpu:
        kernel_args += " intel_iommu=on"
    kernel_args += " default_hugepagesz=1GB hugepagesz=1G"
    huge_page_count = get_huge_page_count()
    if huge_page_count:
        count = huge_page_count - (NOVA_HOST_RESRVED_MEMORY / 1024)
        count = int(count * args.huge_page_allocation / 100)
        kernel_args += (" hugepages=%s" % count)
    else:
        print("ERROR: Huge page calculation failed")
    return kernel_args

def convert_to_range(list):
    num_list = [int(num) for num in list.split(",")]
    num_list.sort()
    range_list = []
    range_min = num_list[0]
    for num in num_list:
        next_val = num + 1
        if next_val not in num_list:
            if range_min != num and (range_min + 1) != num :
                range_list.append(str(range_min) + '-' + str(num))
            else:
                range_list.append(str(range_min))
                if range_min != num:
                    range_list.append(str(num))
            next_index = num_list.index(num) + 1
            if next_index < len(num_list):
                range_min = num_list[next_index]
    return ','.join(range_list)

def get_expected_parameters(args):
    cpu_layout = get_cpu_layout()
    params = {}
    pmd = get_pmd_core_list(args, cpu_layout)
    pmd_range = convert_to_range(pmd)
    host = get_host_core_list(cpu_layout)
    host_range = convert_to_range(host)
    vcpu = get_nova_cpus_list(args, cpu_layout)
    vcpu_range = convert_to_range(vcpu)
    isol = get_isolated_core_list(args, cpu_layout)
    isol_range = convert_to_range(isol)
    params.update({'OvsPmdCoreList': pmd_range})
    params.update({'OvsDpdkCoreList': host_range})
    params.update({'NovaVcpuPinSet': vcpu_range})
    params.update({'OvsDpdkMemoryChannels': get_memory_channels(args, cpu_layout)})
    params.update({'OvsDpdkSocketMemory': get_socket_memory()})
    params.update({'NovaReservedHostMemory': str(NOVA_HOST_RESRVED_MEMORY)})

    role_specific = {}
    role_specific.update({'IsolCpusList': isol_range})
    role_specific.update({'KernelArgs': get_kernel_args(args)})
    role_specific.update({'TunedProfileName': 'cpu-partitioning'})
    params.update({'ComputeOvsDpdkParameters': role_specific})
    return params

def get_hiera(name):
     stdout = check_output(['hiera', '-c', '/etc/puppet/hiera.yaml', name])
     return stdout

def get_host_isol_cpus():
    with open('/etc/tuned/cpu-partitioning-variables.conf') as conf:
        content = conf.read().split('\n')
        for line in content:
            if line.startswith('isolated_cores'):
                return line.split('=')[1].strip(' ')

def get_actual_parameters():
     pmd = get_hiera('vswitch::dpdk::pmd_core_list')
     host = get_hiera('vswitch::dpdk::host_core_list')
     mem_channel = get_hiera('vswitch::dpdk::memory_channels')
     socket_mem = get_hiera('vswitch::dpdk::socket_mem')
     isol = get_host_isol_cpus()
     print(pmd)
     print(host)
     print(mem_channel)
     print(socket_mem)
     print(isol)

def validate_parameters(expected_params, actual_params):
    pass

def validate_huge_pages(kargs_list):
    default_hugepagesz = None
    hugepagesz = None
    hugepages = None
    for arg in kargs_list:
        if '=' not in arg:
            continue
        key = arg.split('=')[0].strip(' ').strip('\n')
        val = arg.split('=')[1].strip(' ').strip('\n')
        if key == 'default_hugepagesz':
            default_hugepagesz = val
        elif key == 'hugepagesz':
            hugepagesz = val
        elif key == 'hugepages':
            hugepages = val

    if not default_hugepagesz or default_hugepagesz != '1GB':
        print("Boot Parameter hugepagesize is recommended as 1GB")
    if not hugepagesz or hugepagesz != '1G':
        print("Boot Parameter hugepagesz is recommended as 1G")
    if not hugepages or int(hugepages) > 1:
        print("Boot Parameter hugepages should be defined. Refer other logs "
              "for recommended value")

def validate_iommu(kargs_list):
    intel_iommu = None
    iommu = None
    for arg in kargs_list:
        if '=' not in arg:
            continue
        key = arg.split('=')[0].strip(' ').strip('\n')
        val = arg.split('=')[1].strip(' ').strip('\n')
        if key == 'intel_iommu':
            intel_iommu = val
        elif key == 'iommu':
            iommu = val
    if not intel_iommu or intel_iommu != 'on':
        print("Boot Parameter intel_iommu is recommended as 'on'")
    if not iommu or iommu != 'pt':
        print("Boot Parameter iommu is recommended as 'pt'")

def validate_host_configuration():
    with open('/proc/cmdline') as kargs:
        content = kargs.read()
        kargs_list = content.split(' ')
        validate_huge_pages(kargs_list)
        validate_iommu(kargs_list)

def pretty_print_params(params):
    print("------------------------------------------------------------------")
    print("                    Recommended DPDK Parameters                   ")
    print("------------------------------------------------------------------")
    print(yaml.safe_dump(params, default_flow_style=False))
    print("------------------------------------------------------------------")
    print

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--no-validate", help="Validate the OVS-DPDK parameters",
                        action="store_true")
    parser.add_argument("--cores-per-numa",
                        help="Number of cores per NUMA for PMD threads",
                        action='store_const', const=2)
    parser.add_argument("--huge-page-allocation",
                        help="Percentage of remaining memory to be allocated as huge pages",
                        action='store_const', const=90)
    args = parser.parse_args(['--cores-per-numa', '--huge-page-allocation'])

    expected_params = get_expected_parameters(args)
    pretty_print_params(expected_params)
    if not args.no_validate:
        validate_host_configuration()
        actual_params = get_actual_parameters()
        validate_parameters(expected_params, actual_params)

if __name__ == '__main__':
    main()
