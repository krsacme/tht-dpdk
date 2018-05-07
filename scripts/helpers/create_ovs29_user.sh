function create_ovs_2_9_user {
    # Ovs uses openvswitch:hugetlbfs as user and group settings
    # when updating to 2.8 onwards, but openvswitch user is not
    # created during package update. This adds workaround to
    # make sure openvswitch user exist before running package
    # update. Details can be found at:
    # https://bugzilla.redhat.com/show_bug.cgi?id=1559374
    # 42477 is the kolla hugetlbfs gid value.
    getent group hugetlbfs >/dev/null || \
        groupadd hugetlbfs -g 42477 && groupmod -g 42477 hugetlbfs
    getent passwd openvswitch >/dev/null || \
        useradd -r -d / -s /sbin/nologin -c "Open vSwitch Daemons" openvswitch
    usermod -a -G hugetlbfs openvswitch
}

# Special case for OVS 2.9 where we need to change the OVS config file
# to run with the right user
function change_ovs_2_9_user {
    local ovs_config_file="/etc/sysconfig/openvswitch"

    if ! grep -q '^OVS_USER_ID="*openvswitch:hugetlbfs"*' $ovs_config_file; then
        if grep -q "^\#*OVS_USER_ID=" $ovs_config_file; then
            sed -i 's/^\#*OVS_USER_ID=.*/OVS_USER_ID="openvswitch:hugetlbfs"/' $ovs_config_file
        else
            sed -i '$ a OVS_USER_ID="openvswitch:hugetlbfs"' $ovs_config_file
        fi
    fi
}

# Special case for OVS 2.9 where we need to create a one-time service file,
# that will change any remaining permissions after reboot if needed
function change_ovs_2_9_perms {
    local ovs_owner=$(find /etc/openvswitch /var/log/openvswitch ! -user openvswitch ! -group hugetlbfs 2> /dev/null)
    if [ ! -z "${ovs_owner}" ]; then
            cat >/etc/systemd/system/multi-user.target.wants/fix-ovs-permissions.service <<EOL
[Unit]
Description=One time service to fix permissions in OpenvSwitch
Before=openvswitch.service

[Service]
Type=oneshot
User=root
ExecStart=/usr/bin/bash -c "/usr/bin/chown -R openvswitch:hugetlbfs /etc/openvswitch /var/log/openvswitch || true"
ExecStartPost=/usr/bin/rm /etc/systemd/system/multi-user.target.wants/fix-ovs-permissions.service
TimeoutStartSec=0
RemainAfterExit=no

[Install]
WantedBy=default.target
EOL
        chmod a+x /etc/systemd/system/multi-user.target.wants/fix-ovs-permissions.service
    fi
}


create_ovs_2_9_user
change_ovs_2_9_user
change_ovs_2_9_perms

