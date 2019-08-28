#!/bin/bash
set -ex
infrared tripleo-upgrade \
   --undercloud-ffu-upgrade yes \
   --undercloud-ffu-releases '11,12,13' \
   --mirror tlv \
   --upgrade-ffu-workarounds true \
   -e @workarounds.yaml
