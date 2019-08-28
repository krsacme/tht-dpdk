#/bin/bash
set -ex

infrared virsh -v \
  --topology-nodes undercloud:1,controller:3 \
  -e override.controller.memory=15360 \
  -e override.undercloud.memory=16384 \
  -e override.controller.cpu=4 \
  -e override.undercloud.cpu=4 \
  --host-address panther07.qa.lab.tlv.redhat.com \
  --host-key ~/.ssh/id_rsa \
  --topology-network 4_nets_3_bridges_hybrid \
  -e override.networks.net1.nic=eno2 \
  -e override.networks.net1.ip_address=192.0.90.150 \
  --host-mtu-size 9000 \
  --image-url https://url.corp.redhat.com/rhel-guest-image-7-6-210-x86-64-qcow2

infrared tripleo-undercloud -v -o install.yml \
  --config-file /home/saravanan/KRS/nfv-qe/ospd-10-vxlan-dpdk-sriov-ctlplane-dataplane-bonding-hybrid/undercloud.conf \
  --version 10 \
  --build latest \
  --mirror tlv \
  --splitstack no \
  --images-task rpm \
  --upload-extra-repos False \
  --overcloud-update-kernel false

infrared tripleo-overcloud \
   -o overcloud-install.yml \
   --version 10 \
   --deployment-files /home/saravanan/KRS/nfv-qe/ospd-10-vxlan-dpdk-sriov-ctlplane-dataplane-bonding-hybrid/ \
   --hybrid /home/saravanan/KRS/nfv-qe/ospd-10-vxlan-dpdk-sriov-ctlplane-dataplane-bonding-hybrid/hybrid.json \
   -e provison_virsh_network_name=br-ctlplane \
   --tagging no \
   --introspect yes \
   --deploy no \
   --mirror tlv \
   --vbmc-force yes

infrared tripleo-overcloud \
   -o overcloud-install.yml \
   --version 10 \
   --deployment-files /home/saravanan/KRS/nfv-qe/ospd-10-vxlan-dpdk-sriov-ctlplane-dataplane-bonding-hybrid/ \
   --hybrid /home/saravanan/KRS/nfv-qe/ospd-10-vxlan-dpdk-sriov-ctlplane-dataplane-bonding-hybrid/hybrid.json \
   -e provison_virsh_network_name=br-ctlplane \
   --tagging yes \
   --introspect yes \
   --deploy no \
   --mirror tlv \
   --vbmc-force yes

infrared tripleo-overcloud \
   -o overcloud-install.yml \
   --version 10 \
   --containers false \
   --deployment-files /home/saravanan/KRS/nfv-qe/ospd-10-vxlan-dpdk-sriov-ctlplane-dataplane-bonding-hybrid/ \
   --overcloud-script /home/saravanan/KRS/nfv-qe/ospd-10-vxlan-dpdk-sriov-ctlplane-dataplane-bonding-hybrid/overcloud_deploy.sh \
   --hybrid /home/saravanan/KRS/nfv-qe/ospd-10-vxlan-dpdk-sriov-ctlplane-dataplane-bonding-hybrid/hybrid.json \
   -e provison_virsh_network_name=br-ctlplane \
   --tagging no \
   --introspect no \
   --mirror tlv \
   --vbmc-force yes \
   --deploy yes

