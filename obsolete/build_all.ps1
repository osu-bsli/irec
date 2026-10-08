Set-Location $PSScriptRoot\flight-software-pico
pio run 

Set-Location $PSScriptRoot\airbrakes-gnc-tuning-gui
cmake --preset=default
cmake --build build

Set-Location $PSScriptRoot