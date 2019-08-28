#!/bin/bash

set -ex

infrared tripleo-upgrade \
   --deployment-files /home/saravanan/KRS/nfv-qe/ospd-10-vxlan-dpdk-sriov-ctlplane-dataplane-bonding-hybrid/ \
   -e provison_virsh_network_name=br-ctlplane \
   --overcloud-ffu-upgrade yes \
   --overcloud-ffu-releases '11,12,13' \
   --upgrade-ffu-workarounds yes \
   -e @workarounds.yaml \
   -e @ffu_repo.yaml \
   --ansible-args="skip-tags=create_ffu_scripts,ffu_overcloud_run,ffu_overcloud_upgrade_role,ffu_overcloud_ceph,ffu_overcloud_converge,ffu_overcloud_post"
echo "Prepare completed"

# run
infrared tripleo-upgrade \
   --deployment-files /home/saravanan/KRS/nfv-qe/ospd-10-vxlan-dpdk-sriov-ctlplane-dataplane-bonding-hybrid/ \
   -e provison_virsh_network_name=br-ctlplane \
   --overcloud-ffu-upgrade yes \
   --overcloud-ffu-releases '11,12,13' \
   --upgrade-ffu-workarounds yes \
   -e @workarounds.yaml \
   -e @ffu_repo.yaml \
   --ansible-args="skip-tags=create_ffu_scripts,ffu_overcloud_prepare,ffu_overcloud_upgrade_role,ffu_overcloud_ceph,ffu_overcloud_converge,ffu_overcloud_post"
echo "Run compelted"

# controller upgrade
infrared tripleo-upgrade \
   --deployment-files /home/saravanan/KRS/nfv-qe/ospd-10-vxlan-dpdk-sriov-ctlplane-dataplane-bonding-hybrid/ \
   -e provison_virsh_network_name=br-ctlplane \
   --overcloud-ffu-upgrade yes \
   --overcloud-ffu-releases '11,12,13' \
   --upgrade-ffu-workarounds yes \
   -e @workarounds.yaml \
   -e @ffu_repo.yaml \
   --ansible-args="skip-tags=create_ffu_scripts,ffu_overcloud_prepare,ffu_overcloud_run,ffu_overcloud_upgrade_compute,ffu_overcloud_ceph,ffu_overcloud_converge,ffu_overcloud_post"
echo "Controller upgrade compelted"

# compute upgrade
infrared tripleo-upgrade \
   --deployment-files /home/saravanan/KRS/nfv-qe/ospd-10-vxlan-dpdk-sriov-ctlplane-dataplane-bonding-hybrid/ \
   -e provison_virsh_network_name=br-ctlplane \
   --overcloud-ffu-upgrade yes \
   --overcloud-ffu-releases '11,12,13' \
   --upgrade-ffu-workarounds yes \
   -e @workarounds.yaml \
   -e @ffu_repo.yaml \
   --ansible-args="skip-tags=create_ffu_scripts,ffu_overcloud_prepare,ffu_overcloud_run,ffu_overcloud_upgrade_controller,ffu_overcloud_ceph,ffu_overcloud_converge,ffu_overcloud_post"
echo "Compute upgrade compelted"
