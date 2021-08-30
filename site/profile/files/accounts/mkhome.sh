#!/bin/bash
tail -F /var/log/dirsrv/slapd-*/access |
grep --line-buffered -oP 'ADD dn=\"uid=\K([a-z0-9A-Z_]*)(?=,cn=users)' |
while read USERNAME; do
    USER_HOME="/mnt/home/$USERNAME"
    rsync -opg -r -u --chown=$USERNAME:$USERNAME --chmod=D700,F700 /etc/skel/ $USER_HOME
    restorecon -F -R $USER_HOME

    USER_SCRATCH="/scratch/$USERNAME"
    SERVER_SCRATCH="/mnt/$USER_SCRATCH"
    if [[ ! -d "$MOUNT_SCRATCH" ]]; then
        mkdir -p $SERVER_SCRATCH
        ln -sfT $USER_SCRATCH "$USER_HOME/scratch"
        chown -h $USERNAME:$USERNAME $SERVER_SCRATCH "$USER_HOME/scratch"
        chmod 750 $SERVER_SCRATCH
        restorecon -F -R $SERVER_SCRATCH
    fi
done