# IREC Monorepo
- [IREC Monorepo](#irec-monorepo)
- [Avionics System Overview](#avionics-system-overview)
  - [COTS Stackup](#cots-stackup)
  - [SRAD Stackup](#srad-stackup)
- [AVIONICS NO BUY LIST](#avionics-no-buy-list)
  - [STMicroelectronics S2-LP](#stmicroelectronics-s2-lp)
  - [STMicroelectronics TESEO-LIV3S GNSS Module](#stmicroelectronics-teseo-liv3s-gnss-module)
  - [SPI Flash Chips](#spi-flash-chips)

This monorepo contains:
* `flight-software` - Flight Software for the SRAD Flight Computer
* `flight-data-logs` - Flight data logs
* `ground-control` - Ground Control software written in Rust using egui
* `radio-board-software` - Code for the ground-side and rocket-side SRAD radio boards
* Documentation for the avionics system

# Avionics System Overview

As of 4/24/2025 this is the current avionics setup.

## COTS Stackup
* Altus Metrum EasyMini - Primary parachute deployment computer 
* Altus Metrum EasyMini - Backup parachute deployment computer
* Altus Metrum TeleGPS for recovery

## SRAD Stackup
* Radio Board
* Interface Board (for airbrakes servo)
* Flight Computer
* Power Board

All 3 flight computers (2x EasyMini, 1x SRAD) have their own battery.

# AVIONICS NO BUY LIST

Here is a list of parts that should not be used.


## STMicroelectronics S2-LP

### Description
Radio transceiver that requires a custom RF frontend.

### Victims
* Reliable Radio Regiment (2023-2024 Radio Capstone Group)
* Responsive Reliable Radio Regiment (2024-2025 Radio Capstone Group)

Both groups ended the year with non-functioning radio boards.

### Why it seems like a good idea
* It is an ST part, so it must be easy to use with our STM32 microcontroller, right?

### Why it should be avoided
* You have to design and build your own RF frontend.
* Crystal oscillator is tough to get working.
* Poor community support.
* Extremely poor documentation.
  
### Alternatives
* LoRA radio module (proven long-range communications with great community support)

## STMicroelectronics TESEO-LIV3S GNSS Module

### Description

GPS receiver from STMicro.

### Victims
* Avionics 2024
* Avionics 2025

### Why it seems like a good idea
* It is an ST part, so it must be easy to use with our STM32 microcontroller, right? (again)

### Why it should be avoided
* It is NOT EASY TO USE AND NOT WELL DOCUMENTED.

### Alternatives
* Any GPS chip that you can find a driver for in 30 minutes, that tells you exactly how to hook it into a system.
* Even if an alternative is moderately more expensive, if that cost pays for good documentation and customer support, THAT COST IS WORTH IT.

## SPI Flash Chips

### Description
Any flash chip that uses SPI as its main form of communication.

### Victims
* Responsive Reliable Radio Regiment (2024-2025 Radio Capstone Group)

### Why it seems like a good idea
* SPI flash comes in non-BGA packages, so it's easy to lay out, right?
  
### Why it should be avoided
* SPI flash is expensive.
* Manufacturer driver support is poor (especially for Winbond SPI flash).
* SPI flash is relatively small, so multiple chips are needed to achieve a reasonable storage capacity. That also means multiple CS lines, and even a mux if you don't have enough MCU pins.
* I sat in on the 2025 radio board capstone presentation and the ECE Capstone advisor told us that she would be up in the flash manufacturer's DMs giving them hell if they didn't supply a driver.

### Alternatives
* eMMC. Should not be too hard to lay out since most of the BGA pins are N/C. This also means all storage comms can be handled by the STM32 SDIO/SDMMC peripheral.