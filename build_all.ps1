Set-Location $PSScriptRoot\flight-software-pico
pio run 

Set-Location $PSScriptRoot\flight-software-pico\pc-testing
cmake --preset=default
cmake --build build

Set-Location $PSScriptRoot