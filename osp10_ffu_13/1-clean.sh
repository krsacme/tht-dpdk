#!/bin/bash
set -ex
infrared virsh -v --host-address panther07.qa.lab.tlv.redhat.com --host-key ~/.ssh/id_rsa --cleanup yes
infrared workspace cleanup ci
