#!/bin/bash
set -x
function get_mask()
{
  local list=$1
  local mask=0
  declare -a bm
  max_idx=0
  for core in $(echo $list | sed 's/,/ /g')
  do
      index=$(($core/32))
      bm[$index]=0
      if [ $max_idx -lt $index ]; then
         max_idx=$(($index))
      fi
  done
  for ((i=$max_idx;i>=0;i--));
  do
      bm[$i]=0
  done
  for core in $(echo $list | sed 's/,/ /g')
  do
      index=$(($core/32))
      temp=$((1<<$(($core % 32))))
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

function set_dpdk_config()
{
  PMD_CORES=$1
  LCORE_LIST=$2
  SOCKET_MEMORY=$3
  pmd_cpu_mask=$( get_mask $PMD_CORES )
  host_cpu_mask=$( get_mask $LCORE_LIST )
  socket_mem=$(echo $SOCKET_MEMORY | sed s/\'//g )
  ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-socket-mem=$socket_mem
  ovs-vsctl --no-wait set Open_vSwitch . other_config:pmd-cpu-mask=$pmd_cpu_mask
  ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-lcore-mask=$host_cpu_mask
  ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
}


function set_tuned_config()
{
  TUNED_CORES=$1
  yum install -y tuned-profiles-cpu-partitioning
  tuned_conf_path="/etc/tuned/cpu-partitioning-variables.conf"
  if [ -n "$TUNED_CORES" ]; then
    grep -q "^isolated_cores" $tuned_conf_path
    if [ "$?" -eq 0 ]; then
      sed -i 's/^isolated_cores=.*/isolated_cores=$TUNED_CORES/' $tuned_conf_path
    else
      echo "isolated_cores=$TUNED_CORES" >> $tuned_conf_path
    fi
    tuned-adm profile cpu-partitioning
  fi
}

function set_kernel_args()
{
  KERNEL_ARGS=$1
  sed "s|^\(GRUB_CMDLINE_LINUX=\".*\)\"|\1 $KERNEL_ARGS\"|g" -i /etc/default/grub;
  grub2-mkconfig -o /etc/grub2.cfg
  reboot
}
