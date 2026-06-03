#!/bin/bash

# Immediately exit script upon any error
set -e

cd flight-software-pico
uvx --system-certs platformio run
cd ..

cd ground-computer-pico
uvx --system-certs platformio run
cd ..

cd airbrakes-gnc-tuning-gui
cmake -GNinja -Bbuild
cmake --build build
cd ..

cd openrocket-plugin-airbrakes
./gradlew_with_asan.sh test
cd ..

