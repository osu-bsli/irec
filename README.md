# 🚀 IREC Avionics Monorepo 🚀

Welcome! This is the Monorepo for the Avionics Sub-team of the Buckeye Space Launch Initiative's International Rocket Engineering Competition (IREC) team.

The BSLI IREC team is competing in the 45,000ft, student-researched-and-developed (45k SRAD) category. For the exact definition of what it means to be a "45K SRAD" team, please consult Section 2.0 in the [IREC Rules & Requirements Document](https://www.soundingrocket.org/irec-documents--forms.html).

## Index

The repository is structured as follows.

1. [Flight Computer Pico Zig](#Flight Computer Pico Zig)
1. [Flight Computer Pico C](#Flight Computer Pico C)
1. [Data Visualization & Processing](#Data Visualization & Processing)
1. [Flight Computer Testing Suite](#Flight Computer Testing Suite)
1. [Flight Data Logs](#Flight Data Logs)
1. [Obsolete](#Obsolete)
1. [Style](#Style)

# Flight Computer Pico Zig

The ```fc-pico-zig``` folder contains our most thoroughly tested and modern firmware for the SRAD Flight Computer.
The entire codebase is hand written in Zig and compiles for the Raspberry Pi Pico 2 (RP2350 chipset).
For additional design details and intent refer to (fc-pico-zig/README.md)[fc-pico-zig].

# Flight Computer Pico C

The ```fc-pico-c``` folder contains our obsolete firmware for the SRAD Flight Computer.
This firmware has inhereted code structure and design from several flight computer's and cohorts prior.
While some of the previous design decisions are acceptable, there are substantial flaws and the code base reached a degree of complexity that needs to be remidied.
For our most modern and sophisticated firmware please refer to [Flight Computer Pico Zig](#Flight Computer Pico Zig).

# Data Visualization & Processing

The ```DVAP``` folder contains the source code and documentation for the *Data Visualization And Processing* desktop software.
*DVAP* is designed and intended to fascilitate and standardize the extraction of Flight Logs from the fc-pico-zig firmware.
*DVAP* can also be used to visualize the flight logs in "offline" mode meaning you can play back and step through the rocket moment to moment in flight.
*DVAP* can also be used to produce a visual from live telemetry data for integration with *Open Broadcasting Software* (*OBS*) for live streaming during the competition.

Additional information about the *DVAP* can be found here: [DVAP/README.MD](DVAP)

# Flight Computer Testing Suite

The *Flight Computer Testing Suite* is a collection of our utilities to perform *Machine-In-Loop* (MIL), *Software-In-Loop* (SIL), *Processor-In-Loop* (PIL), *Hardware-In-Loop* (HIL), and Real World reproducible testing.
These utilities will be used to automatically thoroughly test, verify, and validate our SRAD controls and firmware for competition.

# Flight Data Logs

The ```flight-data-logs``` folder contains all data records of previous IREC flights in binary and CSV formats.

# Obsolete

The ```obsolete``` folder contains old projects that are not important enough for us to have in the root of this repository.
Many of these have been used as references for our current software/firmware.

# Style

Structs Are CamelCase.
functions are snake_case.
constants are ALL_CAPS.

Adhere to the zig style guide, its good.

For the most part just let the unofficial zig linter/formatter do its thing.

<!-- 1. [Credit](#credit) -->

<!-- # Credit -->

<!-- The following IREC members have collaborated on this repo as of 2026: -->


<!-- This monorepo contains: -->
<!-- * `flight-software` - Flight Software for the SRAD Flight Computer -->
<!-- * `flight-data-logs` - Flight data logs -->
<!-- * `ground-control` - Ground Control software written in Rust using egui -->
<!-- * `radio-board-software` - Code for the ground-side and rocket-side SRAD radio boards -->

<!-- **For Resources & Documentation, see [awesome-irec](https://github.com/Powerlated/awesome-irec).** -->
