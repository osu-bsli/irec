# Flight Software 2026

Embedded Linux is the way forward.

## Developing

On Ubuntu x64 host:

```
sudo apt install -y build-essential cmake ninja-build autoconf-archive



Build and install one-liner:

```
cmake --build build -- package && scp build/flight-software.deb pi@raspberrypi: && ssh pi@raspberrypi "sudo apt install -y /home/pi/flight-software.deb --reinstall"
```
