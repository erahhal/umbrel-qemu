umbrel-qemu
===========

Scripts to build and run Umbrel in qemu-kvm.

## To use

* Change the "umbrel" user password from "changeme" in preseed.cfg
* Run ./setup-umbrel.sh

* ```ssh -p 2222 umbrel@localhost```
* run ```/tmp/install-umbrel.sh``` inside VM
* For subsequent runs, run ```./umbrel.sh```

## Todos

* The preseed.cfg has the execution of the umbrel install script commented out as it fails to run. Figure this out.
* Figure out if there is a way to forward a range of ports to the host. Currently only forwards 80, 8082, and 8083
