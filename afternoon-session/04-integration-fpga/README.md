# 04 - GR-HEEP Integration on FPGA 🌍

This final stage brings your accelerator integration to hardware. After validating functionality in simulation, you now execute the same idea on FPGA and observe real-system behavior through JTAG and UART.

The objective is to close the loop from design intent to physical execution.

## What this stage demonstrates 🎯

- The integrated GR-HEEP system can be generated and built for an FPGA target.
- Accelerator-aware software runs on board.
- Bring-up and observability flows (bitstream, debug, UART) are consistent and repeatable.

## Bitstreams availability 📦

The bitstreams are already included in this repository for the tutorial flow, so you can program the board directly from the provided files.

Use `make vivado-fpga` only if you explicitly want to regenerate bitstreams from sources.

## Important: same FPGA flow as Part 02 🔁

For board bring-up, cable detection, programming, OpenOCD/GDB, flash flow, and UART monitoring, use exactly the same FPGA flow from Part 02.

This section (04) reuses that operational flow and focuses only on the integration-specific objective: validating GR-HEEP accelerator applications on hardware.

## Enter GR-HEEP

```bash
cd GR-HEEP
```

## 1) Regenerate platform after integration edits 🏗️

```bash
make mcu-gen TARGET=<board_target>
```

Typical board targets include `pynq-z2`, `nexys-a7-100t`, `genesys2`, `aup-zu3`, `zcu102`, and `zcu104`.

## 2) Build an application for FPGA execution 🧠

```bash
make app PROJECT=gr_heep_hello_world TARGET=<board_target>
```

Then test accelerator-focused apps as needed:

- `PROJECT=SHA3-384-baseline`
- `PROJECT=SHA3-384-loosely`
- `PROJECT=SHA3-384-tightly`

## 3) Build/program FPGA bitstream (when required) ⚡

To build bitstream artifacts with FuseSoC/Vivado:

```bash
make vivado-fpga FPGA_BOARD=<board_target>
```

To program the generated bitstream:

```bash
make vivado-fpga-pgm FPGA_BOARD=<board_target>
```

If prebuilt bitstreams are provided during the tutorial, use those for faster turnaround.

## 4) Runtime validation flow on board 🔍

Apply the exact same runtime procedure used in Part 02, then run the integration-focused applications from this section.

## 5) Recommended comparison plan 📊

Use one board and keep clock/setup fixed while switching only software projects:

1. Run `gr_heep_hello_world` as system sanity check.
2. Run `SHA3-384-baseline`.
3. Run `SHA3-384-loosely`.
4. Run `SHA3-384-tightly`.

Record:

- Pass/fail status.
- Functional correctness (expected output).
- Runtime observations (latency/cycles where available).

## Final takeaway ✨

At this point, you should have a complete story from configuration exploration to accelerator integration and FPGA validation, with enough evidence to discuss both architectural and implementation trade-offs.
