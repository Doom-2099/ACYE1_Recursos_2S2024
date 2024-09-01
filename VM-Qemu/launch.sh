qemu-system-aarch64 \
  -M raspi3 \
  -cpu cortex-a53 \
  -m 1G -smp 4 \
  -kernel kernel8.img \
  -sd raspios.img  \
  -dtb bcm2710-rpi-3-b-plus.dtb \
  -append "rw earlyprintk loglevel=8 console=ttyAMA0,115200
  dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootdelay=1" \
  -nographic
  -netdev user,id=net0,hostfwd=tcp::5555-:22
