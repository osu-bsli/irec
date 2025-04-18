# IREC Monorepo

Welcome to the monorepo for the BSLI International Rocket Engineering Competition (IREC) project team.

This monorepo contains:
* `flight-software` - Flight Software for the SRAD Flight Computer
* `flight-data-logs` - Flight data logs
* `ground-control` - Ground Control software written in Rust using egui
* `radio-board-software` - Code for the ground-side and rocket-side SRAD radio boards
* Documentation for the avionics system

# AVIONICS NO BUY LIST

Here is a list of parts that should not be used.


## STMicroelectronics S2-LP

### Description
Radio transceiver that requires a custom RF frontend.

### Victims
* Reliable Radio Regiment (2023-2024 Radio Capstone Group)
* Responsive Reliable Radio Regiment (2024-2025 Radio Capstone Group)

### Why it seems like a good idea
* It is an ST part, so it must be easy to use with our STM32 microcontroller, right?

### Why it should be avoided
* You have to design and build your own RF frontend.
* Crystal oscillator is tough to get working.
* Poor community support.
* Extremely poor documentation.
  
### Alternatives
* LoRA radio module (proven long-range communications with great community support)


## SPI Flash Chips

### Description
Any flash chip that uses SPI as its main form of communication.

### Victims
* Responsive Reliable Radio Regiment (2024-2025 Radio Capstone Group)

### Why it seems like a good idea
* SPI flash comes in non-BGA packages, so it's easy to lay out, right?
  
### Why it should be avoided
* SPI flash is relatively expensive.
* Manufacturer driver support is poor (especially for Winbond SPI flash).
* SPI flash is relatively small, so multiple chips are needed to achieve a reasonable storage capacity. That also means multiple CS lines, and even a mux if you don't have enough MCU pins.

### Alternatives
* eMMC. Should not be too hard to lay out since most of the BGA pins are N/C. This also means all storage comms can be handled by the STM32 SDIO/SDMMC peripheral.