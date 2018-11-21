#!/bin/bash

source /home/stack/overcloudrc

mkdir -p ~/.config/openstack
cat <<EOF >~/.config/openstack/clouds.yaml
clouds:
  overcloud:
    auth:
      auth_url: $OS_AUTH_URL
      project_name: $OS_PROJECT_NAME
      project_domain_name: $OS_PROJECT_DOMAIN_NAME
      user_domain_name: $OS_USER_DOMAIN_NAME
      username: $OS_USERNAME
      password: $OS_PASSWORD
    identity_api_version: 3
EOF

source /home/stack/stackrc

cat <<EOF >>~/.config/openstack/clouds.yaml
  undercloud:
    auth:
      auth_url: $OS_AUTH_URL
      project_name: $OS_PROJECT_NAME
      project_domain_name: $OS_PROJECT_DOMAIN_NAME
      user_domain_name: $OS_USER_DOMAIN_NAME
      username: $OS_USERNAME
      password: $OS_PASSWORD
    identity_api_version: 3
EOF
