#!/usr/bin/env bash

set -e

#--------------------
# Start machine
#--------------------
qemu-kvm -hda umbrel.img -smp 4 -m 8192 -net nic -net user,hostfwd=tcp::8888-:80,hostfwd=tcp::2222-:22,hostfwd=tcp::8082-:8082,hostfwd=tcp::8083-:8083
