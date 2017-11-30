#!/bin/bash

openstack overcloud container image prepare   \
  --namespace 10.60.19.51:5000/rhosp12  \
  --prefix "openstack-" \
  --suffix "docker" \
  --tag latest \
  --env-file docker_registry.yaml \
  --service-environment-file /usr/share/openstack-tripleo-heat-templates/environments/docker.yaml

#sed -i 's/docker:/-docker:/g' docker_registry.yaml
echo "  DockerInsecureRegistryAddress: 10.60.19.51:5000" >> docker_registry.yaml
echo "  DockerNamespace: 10.60.19.51:5000/rhosp12" >> docker_registry.yaml
echo "  DockerNamespaceIsRegistry: true" >> docker_registry.yaml
