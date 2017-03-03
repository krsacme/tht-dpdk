#!/bin/bash

set -x

function get_core_mask() {
    local list=$1
    local mask=0
    declare -a bm
    max_idx=0
    for core in $(echo $list | sed 's/,/ /g')
    do
        index=$(($core/32))
        bm[$index]=0
        if [ $max_idx -lt $index ]; then
           max_idx=$index
        fi
    done
    for ((i=$max_idx;i>=0;i--));
    do
        bm[$i]=0
    done
    for core in $(echo $list | sed 's/,/ /g')
    do
        index=$(($core/32))
        temp=$((1<<$core))
        bm[$index]=$((${bm[$index]} | $temp))
    done
    printf -v mask "%x" "${bm[$max_idx]}"
    for ((i=$max_idx-1;i>=0;i--));
    do
        printf -v hex "%08x" "${bm[$i]}"
        mask+=$hex
    done
    printf "%s" "$mask"
}

function ovs_update_with_dpdk_special_case() {
    # Check if DPDK enabled
    if [[ -n $(ovs-vsctl get Open_vSwitch . iface_types | grep dpdk) ]]; then
        # Check if the current package is OvS2.5 version
        if [[ -n $(ovs-vsctl --version | grep ovs-vsctl | grep 2.5.) ]]; then
            # Read the /etc/sysconfig/openvswitch file for DPDK_OPTIONS
            DPDK_OPTIONS=""
            while read line; do
                if [[  $line == "DPDK_OPTIONS"* ]]; then
                    DPDK_OPTIONS=$line
                fi
            done < /etc/sysconfig/openvswitch
            if [[ -n $DPDK_OPTIONS ]]; then
                # Parse -l and --socket-mem parameter and set it accordingly
                DPDK_OPTIONS=$(echo $DPDK_OPTIONS | cut -d '"' -f 2)
                #echo $DPDK_OPTIONS
                PARAM_ARR=($DPDK_OPTIONS)
                if [[ ${#PARAM_ARR[@]} -ge 6 ]]; then
                    if [[ ${PARAM_ARR[0]} == "-l" ]]; then
                        LCORE_LIST=${PARAM_ARR[1]}
                    fi
                    if [[ ${PARAM_ARR[4]} == "--socket-mem" ]]; then
                        SOCKET_MEMORY=${PARAM_ARR[5]}
                    fi
                fi
                LCORE_MASK=$(get_core_mask $LCORE_LIST)
                #echo "LCORE_LIST=$LCORE_LIST"
                echo "SOCKET_MEMORY=$SOCKET_MEMORY"
                echo "LCORE_MASK=$LCORE_MASK"
                ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
                ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-socket-mem=$SOCKET_MEMORY
                ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-lcore-mask=$LCORE_MASK
            fi
        fi
    fi
}


if hiera -c /etc/puppet/hiera.yaml service_names | grep -q neutron_ovs_dpdk_agent; then
    ovs_update_with_dpdk_special_case
fi

