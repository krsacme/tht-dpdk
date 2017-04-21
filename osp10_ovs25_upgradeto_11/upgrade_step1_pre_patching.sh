   # NOTE: these patches were applied to openstack-tripleo-heat-templates-6.0.0-2.el7ost.noarch

    #backup templates incase you want to do a diff/sanitycheck:
    sudo cp -r /usr/share/openstack-tripleo-heat-templates /usr/share/openstack-tripleo-heat-templates.ORIG

    # https://review.openstack.org/#/c/452828/ Ensure upgrade step orchestration accross roles.
    curl https://review.openstack.org/changes/452828/revisions/current/patch?download | \
        base64 -d | sudo patch  -d /usr/share/openstack-tripleo-heat-templates/ -p1

    # https://review.openstack.org/448602 Enforce upgrade_batch_tasks before upgrade_tasks order
    curl https://review.openstack.org/changes/448602/revisions/current/patch?download | \
        base64 -d | sudo patch  -d /usr/share/openstack-tripleo-heat-templates/ -p1

    # (in review)
    # https://review.openstack.org/#/c/449080/ [N->O] Fix wrong database connection for cell0 during upgrade.
    curl https://review.openstack.org/changes/449080/revisions/current/patch?download | base64 -d | sudo patch  -d /usr/share/openstack-tripleo-heat-templates/ -p1

    # (in review)
    # https://review.openstack.org/#/c/434346/ Add manual ovs upgrade script for workaround ovs upgrade issue
    curl https://review.openstack.org/changes/434346/revisions/current/patch?download | \
        base64 -d | sudo patch  -d /usr/share/openstack-tripleo-heat-templates/ -p1

    # https://review.openstack.org/#/c/450607/ Add special case upgrade from openvswitch 2.5.0-14
    curl https://review.openstack.org/changes/450607/revisions/current/patch?download | \
        base64 -d | sudo patch  -d /usr/share/openstack-tripleo-heat-templates/ -p1

