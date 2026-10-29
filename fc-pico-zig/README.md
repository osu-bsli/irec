# Student Research And Designed Flight Computer Zig (SRAD FC)

This is IREC 2026's firmware for the SRAD FC.
It is written in Zig to bring our code base up to best practices and avoid tools like PlatformIO.
This should help reduce dependencies, provide more control without sacrificing accessibility, and bring the
firmware to a more modern standard.

Glossary:
1. [Build](#Build)
1. [Debug](#Debug)
1. [Contributing](#Contributing)
1. [Bugs](#Bugs)
1. [Credit](#credit)

# Build

Run ```zig build``` to compile the UF2 binary for use with the RP2350 target. The binary is in the zig-out/firmware/ folder.

Mount the RP2350 to a directory and drag and drop the UF2 file into it's directory. This will flash your code onto the RP2350, your code will run upon restart.

# Debug

```probe-rs run --chip RP235x <firmware location> ``` Flashes the firmware onto the chip

SWD debugging is your best option if you aren't able to get serial out.

The base memory address of the SRAM is 0x20000000 and has a total size of 520KB (520 * 1024 bytes).
The base memory address of the ROM is 0x0 and has a total size of 32KB (32 * 1024 bytes).

```probe-rs attach --chip RP235x --scan-region <start-memory-address>..<end-memory-address>``` reads the RTT buffer back to the host.
Make sure your scan range is correct otherwise you will not recieve any messages.
A good starting range is 0x20000000..0x20000400.

```probe-rs read --format binary --chip RP235x <word-size> <base-address> <word-count>``` dumps specified memory space into stdio.

```probe-rs gdb --chip RP235x``` start a gdb server connected to the probe.

# Bugs

We are not accepting public issues or pull requests at this time.

# Contributing

## No LLM / AI policy

Use of generative AI/LLMs is strictly forbidden for **all** related to the Zig rewrite of the SRAD FC Firmware.
contributions:

* Patches, in any form (merge requests, email etc)
* Bug reports
* Comments, on both the issue and pull request trackers
* **Everything**, really
