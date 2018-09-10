#!/usr/bin/bash

set -eux

. $HOME/stackrc
upgrade-non-controller.sh --upgrade overcloud-compute-0
upgrade-non-controller.sh --upgrade overcloud-compute-1

