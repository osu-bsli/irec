# 🚀 IREC Monorepo 🚀
- [🚀 IREC Monorepo 🚀](#-irec-monorepo-)
- [Awesome Resources](#awesome-resources)
  - [Everyone Should Read! ☺️](#everyone-should-read-️)
  - [Electricals](#electricals)
  - [GNC / State Estimation / Control Theory](#gnc--state-estimation--control-theory)
  - [Software](#software)
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


# Awesome Resources

## Everyone Should Read! ☺️
* [IREC Rules & Requirements Document](https://www.soundingrocket.org/irec-documents--forms.html)
* [IREC Design, Test, & Evaluation Guide](https://www.soundingrocket.org/irec-documents--forms.html)

> [!NOTE]
> These documents set the *basic rules* for the *competition we participate in*, so we should all read them.

## Electricals
* [Starter Guide to BJT Transistors - ElectroBOOM](https://www.youtube.com/watch?v=2uowMENwiHQ) - ElectroBOOM video on BJT transistors, useful for amplifiers and switching circuits (like for parachute deployment!)
* [This CHIP Changed the WORLD! - ElectroBOOM](https://www.youtube.com/watch?v=lyfx8CL7AkI) -  ElectroBOOM video on MOSFET transistors, also useful for high-power switching circuits.
* [Altium Education](https://education.altium.com/) - PCB Design Courses by Altium

## GNC / State Estimation / Control Theory
* [Aftershock II Apogee Analysis](https://static1.squarespace.com/static/549ce89be4b0cddb26c4894b/t/67391d08fd8679272697d0e6/1731796246789/Aftershock_II_Apogee_Whitepaper) - USC Rocket Propulsion Laboratory's uses advanced modeling to estimate an apogee of 470,400 ft ± 27,300 ft (3σ) for their record-breaking spaceshot. Apogees of this altitude are necessarily estimated as the air is too thin in the thermosphere for pressure altimeters to function. In addition, GPS receivers available to students typically disable themselves at high altitudes/speeds, so that bad actors cannot produce guided missiles that use them.
* [Kalman Filter for Beginners, Part 1 - Recursive Filters & MATLAB Examples](https://www.youtube.com/watch?v=HCd-leV8OkU) - Lesson on the *Kalman Filter*, a technique for estimating the state of a dynamical system (i.e. a rocket), using noisy and incomplete information (all real-world sensors return noisy and incomplete information!!). 
  
  A Kalman Filter is the analytically proven optimal solution to the state estimation problem ***WHEN ALL OF THESE ARE TRUE***: 
    * the system dynamics are fully linear such that they can be represented by a linear transformation
    * your sensors act like they sample errors from a Gaussian distribution
    * your system acts like any deviations from its linear dynamical model are sampled from a Gaussian distribution
    * ***AND*** the probability distribution of the system's state can be perfectly represented with a Gaussian distribution
   
  The regular Kalman Filter *may* function, although with degraded performance, for systems that do not fit these criteria.
  However, variants of the Kalman Filter, namely the Extended Kalman Filter or the Unscented Kalman Filter, have been designed 
  to perform well when these ideal constraints do not exist.

* [The Unscented Kalman Filter for Nonlinear Estimation](https://groups.seas.harvard.edu/courses/cs281/papers/unscented.pdf) - Paper on the *Unscented Kalman Filter*, an extension to the *Kalman Filter* that is able to handle non-Gaussian, unimodal probability distributions that evolve according to nonlinear dynamics.
* [The Fall of Minecraft's 2b2t](https://www.youtube.com/watch?v=elqAh3GWRpA) - Vide o on the use of a *Particle Filter* to estimate the position of players in a Minecraft server. A particle filter was used because the probability distribution of a player's state is multi-modal, and any form of Kalman Filter is unsuitable for multi-modal distributions.  
* [Controls Engineering in the FIRST Robotics Competition](https://file.tavsys.net/control/controls-engineering-in-frc.pdf) - Free textbook on Controls Engineering, intended as a resource for high schoolers to learn graduate-level control theory for use in the FIRST Robotics Competition.

## Software
* [LWN - ELC: SpaceX Lessons Learned](https://lwn.net/Articles/540368/) - On SpaceX's use of Embedded Linux
* [Linus Torvalds on C++](https://harmful.cat-v.org/software/c++/linus) - Thoughts of Linus Torvalds, the creator of the Linux Kernel, on why C++ should not be used in the Kernel.

  This is worth reading as most of the reasons that C++ does not belong in the Kernel fundamentally ***do not apply*** to the type of work that is taking place in this club. Why?
    * Linus is working on a codebase of millions of lines that has to be maintained for decades. A college flight software codebase is a few thousand lines, max.
    * The kernel does not need to use numerical methods and linear algebra to perform its regular functions. Because Flight Software and GNC code ***does***, using C would lock the code out of excellent C++ scientific libraries like *boost::numeric::odeint* and *Eigen*.
     
  HOWEVER, Linus's criticism that it is easy to generate "total and utter crap" with C++ still applies. When he says this, he is aiming at programmers that use C++ features like classes, STL containers, and references *just because they have them*, and not because there is a well-reasoned justification to use them. This means that to create a maintainble C++ codebase, this club must be very disciplined in choosing the C++ features that we *do* use. 
  
  We've justified the use of *the C++ language itself* by showing that C++ gives us access to excellent, type-safe scientific libraries. However, each C++ feature to be used still requires its own justification, independent of the one that allows us to use the language itself. 
  
* [Rust Programming Language - Website](https://www.rust-lang.org/)
* [The Rust Programming Language - The Book](https://doc.rust-lang.org/book/foreword.html)
* [A Simpler Way to See Results](https://www.youtube.com/watch?v=s5S2Ed5T-dc) - Video on the Result type in the Rust Programming Language. 
* [Choosing the Right Option](https://www.youtube.com/watch?v=6c7pZYP_iIE) - Video on the Option type in the Rust Programming Language.
  
> [!NOTE]
> The videos about Rust are firmly in the territory of *advanced programming language theory* and are intended for programmers already familiar with Rust.
> Even if Rust is not used in this club, it is very valuable to learn as the language forces you to program in a way that makes you a better software engineer
> in any context.

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
* This stratification also created a team that is not able to reason about the entire avionics stack as a single unit, which is not ideal when the team's main purpose is to create a robotic apogee control system (the airbrakes).

## Avionics 2026 - The Plan

* Reading the above, you're probably thinking to yourself, "Just make them talk more." But what if the team was structured so they just naturally communicate? **With the guiding principle that the team's structure should naturally facilitate communication:**
* Strata will be deleted. Project management will be done in a "figure it out amongst ourselves" manner, where individuals voluntarily pick up work that there is to do, which is perfectly appropriate or even ideal for an R&D team of this size (6-10 people).
* "Figure it out amongst ourselves" is a form of communication, in my opinion.
* At my internship at Vertiv, where I work on software and dev tooling for a ridiculously tightly coupled embedded Linux system, we do not have static assignments of responsibility for each part of the system. You just do whatever you need to do, PR any repository you need to PR to move things along.

### SRAD

* The SRAD R&D effort for 2024 and 2025 was directed at creating an avionics stack with as few COTS PCBs as much as possible. These efforts never produced a working stack that is able to deploy parachutes or control airbrakes.
* While you can argue that using all SRAD PCBs has a certain cool factor to it, you know what's cooler? Launching the rocket and deploying parachutes yourself. And deploying airbrakes. And winning the IREC. When you spend all your resources on making your systems "look professional" (e.g. by using only custom PCBs), there is no time or money to do the REAL cool things with your stack. 
* So, if we want to win the 2026 IREC, we must redirect our efforts toward the well-executed integration of COTS parts, creating SRAD PCBs when only necessary. Even when trying to maximize the use of COTS parts, there will be a lot of SRAD PCBs that have to be made (pyro PCB, flight computer mount, etc.). So there will be plenty of chances for us to spin our own boards, still.
* Nintendo created the Switch, the 3rd best-selling console of all time, by performing an extremely well-executed integration of mostly boring COTS parts.
* The Falcon 9 is the well-executed integration of ancient rocket engine technology (gas-generator cycle lol), COMBINED with the ability to perform retropropulsive landings.
* A good question: "How do I write an SPI/I2C sensor driver for the MS5607 barometer? What should our naming conventions be?"  
* A **$#%@ing amazing great question**: "Do we even need to write this MS5607 barometer driver? Should we copy paste it from Altus Metrum, so that if our rocket lawn darts, we know it's not that piece of code that did it?"
* Also, my opinion is that manual assembly of PCBs, especially the installation of passives, should generally be avoided, mostly because of environmental concerns. If we have JLCPCB assemble passives, they use their pick&place machines which already have common passives loaded into them. If we install passives ourselves, that means DigiKey has to package those parts with an outrageous amount of single-use plastics, and then ship them to us.

### An example of an SRAD stack that adheres to this philosophy

This is not a declaration of what we will use this year. This is just an ***example*** of ***a*** possible SRAD stack. There's also a pretty good chance this is just a bad idea. Idk, it really depends on if the Pi Zero 2 W is able to remount its SD card if vibration temporarily disconnects it.

* Raspberry Pi Zero 2 W. It's $15, 4c4t, 512 MB of RAM, WiFi, as much storage as you want on the SD card. And you get Linux, the world's most well-documented HAL. No more banging your head against STM32 documentation. It's also 5x more powerful than the most powerful STM32 MCU you can get. That'll be great for the airbrakes algorithm. By the way, SpaceX runs all their GNC algorithms on x86 Linux computers.
* Raspberry Pi Pico (1 or 2). This can be a companion to the Pi Zero 2 W that handles hard-real-time tasks. 
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