#!/bin/bash

set +x

echo "Updating repo file to OSP12.."
sudo rm -rf /etc/yum.repos.d/*
sudo su -c "cat > /etc/yum.repos.d/rhos-release.repo <<EOF
[rhos12-proxy2]
name = RHOS Proxy2 Repo for OSP12
baseurl = http://10.60.19.71/rhosp-12-repo
enabled = 1
gpgcheck = 0
EOF"

echo "Stopping openstack, neutron and httpd services.."
sudo systemctl stop openstack-*
sudo systemctl stop neutron-*
sudo systemctl stop httpd

echo "Updating packages.."
sudo yum -y update instack-undercloud openstack-puppet-modules openstack-tripleo-common python-tripleoclient

echo "Starting Undercloud upgrade.."
mkdir -p ~/logs
openstack undercloud upgrade 2>&1 | tee ~/logs/openstack_upgrade.log

curl https://review.openstack.org/changes/503484/revisions/5624e75de374742175bab870ae12248e7a39e8cd/patch?download | base64 -d | sudo patch -d /usr/share/openstack-tripleo-heat-templates/ -p1
