#!/bin/bash
set -ex

infrared plugin remove tripleo-upgrade
infrared plugin add --revision stable/queens tripleo-upgrade
#use mv instead of symbolic link to avoid too many levels of symbolic links issue
mkdir -p $(pwd)/plugins/tripleo-upgrade/infrared_plugin/roles/tripleo-upgrade
find $(pwd)/plugins/tripleo-upgrade -maxdepth 1 -mindepth 1 -not -name infrared_plugin \
   -exec mv '{}' $(pwd)/plugins/tripleo-upgrade/infrared_plugin/roles/tripleo-upgrade \;

curl -s -o ffu_repo.yaml http://file.emea.redhat.com/~mcornea/tripleo/osp13/ffu_repo.yaml
sed -i s/MIRROR=default_repo_mirror/MIRROR=tlv/ ffu_repo.yaml
curl -s -o workarounds.yaml 'http://file.emea.redhat.com/~mcornea/tripleo/osp13/workarounds.yaml'
