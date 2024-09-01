# Maquina Virtual Con QEMU - Raspberry 3B+ - 64 bits

## Pasos para poder levantar la maquina virtual en su equipo.

# Linux

1. Instalar QEMU

2. Descargar la imagen del sistema operativo raspbian de 64 bits lite. ``` Raspberry Pi OS Lite ```

[RaspbianURL](https://www.raspberrypi.com/software/operating-systems/)

3. Cambiar el nombre a la imagen descargada a ``` raspios.img ```

4. Ejecutar el archivo launch.sh con el siguiente comando ``` sh launch.sh ```


# Windows
1. Instalar QEMU

2. Descargar la imagen del sistema operativo raspbian de 64 bits lite. ``` Raspberry Pi OS Lite ```

[RaspbianURL](https://www.raspberrypi.com/software/operating-systems/)

3. Cambiar el nombre a la imagen descargada a ``` raspios.img ```

4. reemplazar el archivo launch.sh por el archivo launch.bat

5. Colocar el siguiente script en el archivo launch.bat, corrigiendo el nombre de la ruta ejecutable de qemu de su computador

```
"c:\Program Files\qemu\qemu-system-aarch64.exe"
  -M raspi3 ^
  -cpu cortex-a53 ^
  -m 1G -smp 4 ^
  -kernel kernel8.img ^
  -sd raspios.img  ^
  -dtb bcm2710-rpi-3-b-plus.dtb ^
  -append "rw earlyprintk loglevel=8 console=ttyAMA0,115200
  dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootdelay=1" ^
  -nographic ^
  -netdev user,id=net0,hostfwd=tcp::5555-:22
 ```
 
 

