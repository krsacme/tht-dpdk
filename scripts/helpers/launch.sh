#!/bin/bash

source overcloudrc
set -xe

openstack image create rhel --container-format bare --disk-format qcow2 --file rhel-server-7.4-x86_64-kvm.qcow2
openstack keypair create test >test.pem
chmod 600 test.pem

nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0

openstack flavor create --vcpus 4 --ram 4096 --disk 40 m1.nano
openstack flavor set m1.nano --property hw:mem_page_size=large --property hw:emulator_threads_policy=isolate --property hw:cpu_policy=dedicated

openstack network create public --provider-network-type flat --provider-physical-network datacentre --external
openstack subnet create public --subnet-range 172.120.0.0/24 --network public --allocation-pool start=172.120.0.210,end=172.120.0.230 --dns-nameserver 8.8.8.8 --no-dhcp

neutron net-create dpdk1 --provider:network_type vlan --provider:segmentation_id 210 --provider:physical_network dpdknet
neutron subnet-create dpdk1 192.0.10.0/24 --name dpdk1
neutron router-create router1
neutron router-gateway-set router1 public
neutron router-interface-add router1 dpdk1

dpdk1_net=$(openstack network list | awk ' /dpdk1/ {print $2;}')
openstack server create --flavor m1.nano --nic net-id=$dpdk1_net --image rhel --key-name test  dpdk1


