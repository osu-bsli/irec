# IREC Monorepo
- [IREC Monorepo](#irec-monorepo)
- [Avionics System Overview](#avionics-system-overview)
  - [COTS Stackup](#cots-stackup)
  - [SRAD Stackup](#srad-stackup)
- [2026 Avionics System Plans](#2026-avionics-system-plans)
  - [COTS Stackup](#cots-stackup-1)
  - [SRAD Stackup](#srad-stackup-1)
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
* 

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

All 3 flight computers (2x EasyMini, 1x SRAD) have their own battery

### 2025 Interim Comms Stack
* ESP32+LoRa on ground side and rocket side
* We building our own 433 MHz yagi
* No laptop ground control on the ground side, instead a yagi with mounted ESP32+LoRa, display (maybe e-ink?) and battery.

# 2026 Avionics System Plans

## COTS Stackup
Same as the 2025 system above.

## SRAD Stackup

The 2023-2025 SRAD stack - the STM32-based flight computer sitting atop a power board - is technically impressive but creates a lonely, high-pressure working environment in which only a select few are able to contribute to the system due to its complexity. For the past two years, the SRAD stackup has existed in hardware but the IREC Avionics team has been unable to develop the software to a point where it is able to deploy parachutes. The team's slow progress is not being caused by a lack of manpower, discipline, or dedication, but the alienating nature of the SRAD stack itself. This is not only due to the technical complexity of the STM32 but also ST's extremely poor documentation and developer tools.

Next year, I (Brian) propose that we replace the board stackup with a single flight computer motherboard that runs an $20 off-the-shelf ESP32+LoRa+OLED module as its brains. This module, along with every other one of the flight computer's modules, will be soldered to the motherboard with the most universal connector of all: 2.54mm pins. Most of these modules can be designed in-house. If we properly modularize the flight computer, splitting it up into a pyro module, an eMMC module, a power module, among others, the avionics team will be able to distribute work far more efficiently among its software developers and PCB designers.

Currently, ordering the flight computer is an expensive, once-per-year ritual where a single mistake or error can threaten the success of the project for the forthcoming year. This is not okay for an experimental SRAD setup that flies in an experimental rocket at an event sanctioned by the Experimental Sounding Rocket Association. The SRAD Avionics team needs to be able to pivot and iterate rapidly. Modules on 2.54mm stilts facilitates this.

We currently have stack-level modularity, but in name only. We have a separate radio board, power board, and flight computer, but replacing any of those boards is unacceptably expensive. We need component-level modularity - the ability to design and test things like new pyro circuits, or another GPS chip, any time of year, without significant time or monetary investment.

Also, the ESP32 is simply of the most well-documented embedded platforms to ever exist. Even better than Arduino. And the only thing better than writing documentation is NOT NEEDING to write documentation in the first place. By switching to ESP32, we get to offload documentation about how our microcontroller works to the excellent existing Espressif wiki.

### Parts
* Brain: ESP32+LoRa+GPS+WiFi+Bluetooth module (https://heltec.org/project/wireless-tracker/)
* Everything is mounted as a module using SOLDERED 2.54mm pins on a 4-layer motherboard with no active components
* 2.54mm headers for ultimate breadboardability.
* Avionics stack split up into three boards:
  * Interface board: Contains pyro circuit, stepper interface, and remove-before-flight tags,
  * Upper board: Contains secondary modules and will contain empty module spaces for unforeseen needs. A large module space will be reserved for the radio capstone group.
  * Lower board: Contains the brain and modules for power, sensors, and flash memory (most likely will be eMMC).
* Each board will be connected to the next using 2.54mm pins, and only one row of pins so it can be breadboarded.
* With the current avionics bay size, each board can only have 28 pins of 2.54mm to the next. If we use them wisely, that should be enough.

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