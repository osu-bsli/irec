# IREC Monorepo
- [IREC Monorepo](#irec-monorepo)
- [Avionics Systems Overview](#avionics-systems-overview)
  - [2026 Planned Stackup](#2026-planned-stackup)
  - [2025 Stackup](#2025-stackup)
- [Leadership Manual](#leadership-manual)
  - [Case Study: Avionics 2024 and 2025](#case-study-avionics-2024-and-2025)
  - [Avionics 2026 - The Plan](#avionics-2026---the-plan)
  - [AVIONICS NO BUY LIST](#avionics-no-buy-list)

This monorepo contains:
* `flight-software` - Flight Software for the SRAD Flight Computer
* `flight-data-logs` - Flight data logs
* `ground-control` - Ground Control software written in Rust using egui
* `radio-board-software` - Code for the ground-side and rocket-side SRAD radio boards
* Documentation for the avionics system
* 

# Avionics Systems Overview



## 2026 Planned Stackup

### COTS Stackup
Same as the 2025 system below.

### SRAD Stackup
To be determined.



## 2025 Stackup

### COTS Stackup
* Altus Metrum EasyMini - Primary parachute deployment computer 
* Altus Metrum EasyMini - Backup parachute deployment computer
* Altus Metrum TeleGPS for recovery

### SRAD Stackup
* Radio Board
* Interface Board (for airbrakes servo)
* Flight Computer
* Power Board

All 3 flight computers (2x EasyMini, 1x SRAD) have their own battery

### 2025 Interim Comms Stack
* ESP32+LoRa on ground side and rocket side
* We building our own 433 MHz yagi
* No laptop ground control on the ground side, instead a yagi with mounted ESP32+LoRa, display (maybe e-ink?) and battery.



# Leadership Manual

Written by Brian Jia, 2025.

## Case Study: Avionics 2024 and 2025

* Avionics work was divided into strata managed by appointed Responsible Engineers. This created a team where the Responsible Engineer had ultimate responsibility for their layer (flight software, electronics, airbrakes, etc.) but **nobody**, except for the PM-appointed Avionics Lead, actually felt responsibility for the final outcome (i.e. the actual goddamn rocket launch and recovery.) This bottleneck meant the entire team's output depended on the capabilties of a single person. Sometimes, that single person can lock in and make it work. Most of the time, they can't.
* This stratification also created a team that is not able to reason about the entire avionics stack as a single unit, which is very bad when the team's main purpose is to create a robotic apogee control system (the airbrakes).

## Avionics 2026 - The Plan

* Reading the above, you're probably thinking to yourself, "Just make them talk more." But what if the team was structured so they just naturally communicate? With the guiding principle that the team's structure should naturally facilitate communication:
* Strata will be deleted. Project management will be done in a "figure it out amongst ourselves" manner, where individuals voluntarily pick up work that there is to do, which is perfectly appropriate or even ideal for an R&D team of this size (6-10 people).
* "Figure it out amongst ourselves" is LITERALLY communication.
* At my internship at Vertiv, where I work on software and dev tooling for a ridiculously tightly coupled embedded Linux system, we do not have static assignments of responsibility for each part of the system. You just do whatever you need to do, PR any repository you need to PR to move things along.

### SRAD

* The SRAD R&D effort for 2024 and 2025 was directed at creating an avionics stack with as few COTS PCBs as much as possible. These efforts never produced a working stack that is able to deploy parachutes or control airbrakes.
* While you can argue that using all SRAD PCBs has a certain cool factor to it, you know what's cooler? Launching the rocket and deploying parachutes yourself. And deploying airbrakes. And winning the IREC. When you spend all your resources on making your systems "look professional" (e.g. by using only custom PCBs), you have no time or money to do the REAL cool things with your stack. 
* So, if we want to win the 2026 IREC, we must redirect our efforts toward the well-executed integration of COTS parts, creating SRAD PCBs when only necessary. Even when trying to maximize the use of COTS parts, there will be a lot of SRAD PCBs that have to be made (pyro PCB, flight computer mount, etc.). So there will be plenty of chances for us to spin our own boards, still.
* Nintendo created the Switch, the 3rd best-selling console of all time, by performing an extremely well-executed integration of mostly boring COTS parts.
* The Falcon 9 is the well-executed integration of ancient rocket engine technology (gas-generator cycle lol), COMBINED with the ability to perform retropropulsive landings.
* A good question: "How do I write an SPI/I2C sensor driver for the MS5607 barometer? What should our naming conventions be?"  
* A **$#%@ing amazing great question**: "Do we even need to write this MS5607 barometer driver? Should we copy paste it from Altus Metrum, so that if our rocket lawn darts, we know it's not that piece of code that did it?"
* Also, my opinion is that manual assembly of PCBs, especially the installation of passives, should generally be avoided, mostly because of environmental concerns. If we have JLCPCB assemble passives, they use their pick&place machines which already have common passives loaded into them. If we install passives ourselves, that means DigiKey has to package those parts (with an outrageous amount of single-use plastics), and then ship them to us.

### An example of an SRAD stack that adheres to this philosophy

This is not a declaration of what we will use this year. This is just an ***example*** of ***a*** possible SRAD stack. There's also a pretty good chance this is just a bad idea. Idk, it really depends on if the Pi Zero 2 W is able to remount its SD card if vibration temporarily disconnects it.

* Raspberry Pi Zero 2 W. It's $15, 4c4t, 512 MB of RAM, WiFi, as much storage as you want on the SD card. And you get Linux, the world's most well-documented HAL. No more banging your head against STM32 documentation. It's also 5x more powerful than the most powerful STM32 MCU you can get. That'll be great for the airbrakes algorithm. By the way, SpaceX runs all their GNC algorithms on x86 Linux computers.
* Raspberry Pi Pico (1 or 2). This can be a companion to the Pi Zero 2 W that handles absolute hard-real-time tasks. 
* The dual MPU-MCU setup frees us from the PITA of running business logic on a frigging microcontroller.
* Custom radio PCB module. Radio Capstone will be working with us to develop it.
* Custom pyro PCB module
* Custom sensors PCB module
* Everything soldered into a custom PCB backplane.
* We can use 2.54mm headers to stack a 2nd backplane on top of the 1st if one isn't enough. 


## AVIONICS NO BUY LIST

Here is a list of parts that should not be used.

### STMicroelectronics S2-LP

Radio transceiver that requires a custom RF frontend. 

It is an ST part, so it must be easy to use with our STM32 microcontroller, right?

#### Victims
* Reliable Radio Regiment (2023-2024 Radio Capstone Group)
* Responsive Reliable Radio Regiment (2024-2025 Radio Capstone Group)

Both groups ended the year with non-functioning radio boards.

#### Why it should be avoided
* You have to design and build your own RF frontend.
* Crystal oscillator is tough to get working.
* Poor community support.
* Extremely poor documentation.
  
#### Alternatives
* LoRA radio module (proven long-range communications with great community support)

### STMicroelectronics TESEO-LIV3S GNSS Module

#### Description

GPS receiver from STMicro.

It is an ST part, so it must be easy to use with our STM32 microcontroller, right? (again)

#### Victims
* Avionics 2024
* Avionics 2025

#### Why it should be avoided
* It is NOT EASY TO USE AND NOT WELL DOCUMENTED.

#### Alternatives
* Any GPS chip that you can find a driver for in 30 minutes, that tells you exactly how to hook it into a system.
* Even if an alternative is moderately more expensive, if that cost pays for good documentation and customer support, THAT COST IS WORTH IT.

### SPI Flash Chips

#### Description
Any flash chip that uses SPI as its main form of communication.

SPI flash comes in non-BGA packages, so it's easy to lay out, right?

#### Victims
* Responsive Reliable Radio Regiment (2024-2025 Radio Capstone Group)

#### Why it should be avoided
* SPI flash is expensive.
* Manufacturer driver support is poor (especially for Winbond SPI flash).
* SPI flash is relatively small, so multiple chips are needed to achieve a reasonable storage capacity. That also means multiple CS lines, and even a mux if you don't have enough MCU pins.
* I sat in on the 2025 radio board capstone presentation and the ECE Capstone advisor told us that she would be up in the flash manufacturer's DMs giving them hell if they didn't supply a driver.

#### Alternatives
* eMMC. Should not be too hard to lay out since most of the BGA pins are N/C. 