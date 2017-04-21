#!/usr/bin/bash
set -eux

sudo yum repolist -v enabled
sudo systemctl list-units 'openstack-*'

#sudo rhos-release 11

sudo subscription-manager repos --disable="rhel-7-server-openstack-10-rpms"
sudo su -c "cat <<EOF>/etc/yum.repos.d/redhat-local.repo
[redhat-local]
name=Red Hat Local (Proxy Server)
baseurl=http://10.60.19.51/rhos-11-repo/latest
enabled=1
gpgcheck=0
EOF"

sudo yum clean all

# disable OSP10 repos
#sudo yum-config-manager --disable 'rhelosp-10.0*'
sudo yum repolist -v enabled

# stop services as per [bz-1372040](https://bugzilla.redhat.com/show_bug.cgi?id=1372040#c6)
# this will exist in OSP10 upgrades docs.
sudo systemctl stop 'openstack-*'
sudo systemctl stop 'neutron-*'
sudo systemctl stop httpd

#if you are going to do a backwards compatibility install save the old tht dir
# cp -r /usr/share/openstack-tripleo-heat-templates ~/tht

# update instack-undercloud and friends before running the upgrade
sudo yum -y update instack-undercloud openstack-puppet-modules openstack-tripleo-common python-tripleoclient

# UPGRADE
openstack undercloud upgrade
