#!/bin/bash
#
# Script to create rednet server VM on a RHEL/Fedora box
#

SERVER=rednet
virsh destroy  $SERVER
virsh undefine $SERVER

#
# Storage is created on a part of the filesystem with space
#
FORMAT=qcow2
VMDIR=/home/vmm/$SERVER
mkdir -p $VMDIR
chmod 755 $VMDIR
DISK=$VMDIR/root.$FORMAT
rm -f $DISK
qemu-img create -f $FORMAT $DISK 10G
chown qemu.qemu $DISK

# First of all, when doing an install, you can't actually have the
# guest reboot at completion. The initial guest configuration for
# launching the installer is different, from the configuration for
# launching it post-boot. Thus virt-install "fakes" the reboot
# by waiting for the guest to exit, and then manually restarts
# it.  By when you add  --noautoconsole this won't happen. To
# get virt-install to hang around, either remove that option, or
# add '--wait'

virt-install --name=$SERVER --hvm --accelerate --ram=2048 --vcpus=1 \
	     --description "Dialin Server" \
	     --uuid ab6b5056-33e0-49ac-86fa-d154a6adbe6a \
	     --autostart \
	     --graphics vnc \
	     --noautoconsole \
             --network bridge=br0,mac=00:E0:09:D1:A1:19 \
             --disk path=$DISK,format=$FORMAT \
             --os-type=linux \
             --os-variant=rhel6 \
	     --cdrom $PWD/kvmrednet.iso

[ $? -ne 0 ] && {
    echo "failed to create VM"
    exit 1
}

let start=$(date +%s)
while true
do
    state=$(virsh domstate $SERVER)
    case "$state" in
    "shut off") break ;;
    *) echo waiting for vm to reboot
       sleep 12
       ;;
    esac
    let elapsed=$(date +%s)-$start
    [ $elapsed -gt 600 ] && {
	echo "Problem loading VM : $elapsed seconds"
        exit 1
    }
done

echo "Restarting VM"
virsh start $SERVER

# vim:autoindent
