Set-Location $PSScriptRoot\flight-software-pico
pio run 

Set-Location $PSScriptRoot\flight-software-pico\pc-testing
cmake --preset=default
cmake --build build

Set-Location $PSScriptRoot\openrocket-plugin-airbrakes
cmake --preset=default
cmake --build cmake-build
./gradlew jar

Set-Location $PSScriptRoot