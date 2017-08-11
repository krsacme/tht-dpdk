#!/usr/bin/env python

from subprocess import check_output
import requests
import yaml

REPO_URL = "10.60.19.51:5000"

def get_config():
    r = requests.get("http://download-node-02.eng.bos.redhat.com/rcm-guest/puddles/OpenStack/12.0-RHEL-7/latest_containers/container_images.yaml")
    out = yaml.safe_load(r.content)
    return out.get('container_images')

def main():
    imgs = get_config()
    for img in imgs:
        name = img.get('imagename').split(':')[0]
        source = img.get('pull_source')
        image_to_pull = source + '/' + name
        print("Pulling %s ..." % image_to_pull)
        stdout = check_output(['docker', 'pull', image_to_pull])
        print(stdout)
        new_name = REPO_URL + '/' + name
        stdout = check_output(['docker', 'tag', image_to_pull, new_name])
        print(stdout)
        print("Pushing %s to local registry ..." % new_name)
        stdout = check_output(['docker', 'push', new_name])
        print(stdout)
        print

if __name__ == "__main__":
    main()