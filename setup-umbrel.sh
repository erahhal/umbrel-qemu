#!/usr/bin/env bash

set -e

DEBIAN_MIRROR=https://saimei.ftp.acc.umu.se
DEBIAN_IMAGE=debian-12.2.0-amd64-netinst.iso

# @TODO: map folder

#--------------------
# Clear previous
#--------------------

sudo rm -rf ISOFILES preseed-$DEBIAN_IMAGE umbrel.img

#--------------------
# Get image
#--------------------
mkdir -p ~/VMs/umbrel
cd ~/VMs/umbrel
if [ ! -f $DEBIAN_IMAGE ]; then
  axel -n 8 $DEBIAN_MIRROR/debian-cd/current/amd64/iso-cd/$DEBIAN_IMAGE
fi

#--------------------
# Extract image
#--------------------
7z x -aoa -oISOFILES $DEBIAN_IMAGE

#--------------------
# Add preseed.cfg
#--------------------
chmod +w -R ISOFILES/install.amd/
gunzip -f ISOFILES/install.amd/initrd.gz
echo preseed.cfg | cpio -H newc -o -A -F ISOFILES/install.amd/initrd
gzip ISOFILES/install.amd/initrd
chmod -w -R ISOFILES/install.amd/

# cat <<EOT >> ISOFILES/isolinux/gtk.cfg
# label auto
# 	menu label ^Automated install
# 	menu default
# 	kernel /install.amd/vmlinuz
# 	append auto=true priority=critical vga=788 initrd=/install.amd/initrd.gz --- quiet
# EOT
sed -i 's/vesamenu.c32/install/g' ISOFILES/isolinux/isolinux.cfg

#--------------------
# Generate md5 sum
#--------------------
cd ISOFILES
chmod +w md5sum.txt
find -follow -type f ! -name md5sum.txt -print0 | xargs -0 md5sum > md5sum.txt
chmod -w md5sum.txt
cd ..

#--------------------
# Recreate image
#--------------------
genisoimage -r -J -b isolinux/isolinux.bin -c isolinux/boot.cat \
            -no-emul-boot -boot-load-size 4 -boot-info-table \
            -o preseed-$DEBIAN_IMAGE ISOFILES

#--------------------
# Create Umbrel disk
#--------------------
qemu-img create -f qcow2 umbrel.img 32G

#--------------------
# Start installation
#
# TO SEE ERROR CONSOLE:
#   Use Ctrl + Alt + 2 to switch to the QEMU console.
#   Type "sendkey ctrl-alt-f4" and press Enter.
#--------------------
qemu-kvm -hda umbrel.img -cdrom preseed-$DEBIAN_IMAGE -smp 4 -m 8192 -net nic -net user,hostfwd=tcp::8888-:80,hostfwd=tcp::2222-:22
