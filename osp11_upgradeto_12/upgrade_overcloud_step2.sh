#!/usr/bin/bash

set -eux

. ~/stackrc
upgrade-non-controller.sh --upgrade overcloud-compute-0
