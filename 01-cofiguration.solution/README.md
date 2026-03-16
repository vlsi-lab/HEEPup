# Configuration Exercise - Solution Guide

This document explains the intended behavior of the four Python configuration files in `x-heep-main/configs`:

- `00.py`
- `01.py`
- `02.py`
- `03.py`

The goal of the exercise is not only to reproduce the code, but also to understand why each system change matters.

## How to Regenerate and Inspect

Run the generator with the selected Python configuration:

```sh
make mcu-gen PYTHON_X_HEEP_CONFIG=configs/00.py X_HEEP_CFG=configs/python_unsupported.hjson
```

Then repeat with `01.py`, `02.py`, and `03.py`, and compare the generated hardware/software artifacts in `x-heep-main`.

## Architectural Concepts Used in This Exercise

### Bus topology: one-to-many vs N-to-M

In this exercise, the bus topology is one of the key design knobs:

- `BusType.onetoM` (one-to-many):
	- Conceptually, one main initiator path fans out to multiple targets.
	- This is simpler and useful for minimal systems.
	- It is easier to reason about and usually enough for introductory configurations.

- `BusType.NtoM` (N-to-M):
	- Multiple initiators can access multiple targets through a more flexible interconnect.
	- This scales better as the SoC grows (more memories, DMA activity, more peripherals).
	- It is better suited for richer systems where parallel accesses are expected.

So, moving from `onetoM` to `NtoM` reflects a transition from a basic setup to a more scalable and concurrent architecture.

### Memory organization

You will see two styles of memory growth:

- Standard RAM banks (`add_ram_banks`): straightforward capacity increase.
- Interleaved banks (`add_ram_banks_il`): memory is split across banks in a way that can improve throughput when accesses are distributed.

The linker sections remain structured as:

- `code` at the beginning of memory, with a fixed size.
- `data` starting right after `code`, occupying the remaining space.

This keeps software memory layout stable while hardware resources scale.

### CPU choices

Two RISC-V cores are used across the exercise:

- `cv32e20`: compact and suitable for baseline systems.
- `cv32e40p`: higher-performance option; here configured with:
	- `fpu=True` (floating-point support)
	- `corev_pulp=True` (CORE-V PULP extensions)

Switching from `cv32e20` to `cv32e40p` demonstrates how the same platform can be retargeted to a more capable compute core.

### DMA scaling

DMA parameters illustrate system-level parallelism:

- Small setup: 1 channel, 1 master port.
- Scaled setup: 4 channels, 4 master ports.

More channels and ports allow more concurrent transfers, which becomes relevant in systems with higher memory bandwidth demand.

## Detailed Description of Each Configuration

### `00.py`: Minimal baseline platform

This is the starting point and the simplest complete system.

- Bus: `BusType.onetoM`.
- CPU: `cv32e20(rv32e=False, rv32m="RV32MSlow")`.
- Memory:
	- 2 RAM banks of 32 KiB.
	- Linker `code` section from address `0` with size `0x00000E800`.
	- Linker `data` section starting at `0x00000E800`.
- Peripherals:
	- All mandatory base peripherals are present.
	- No optional user peripherals are enabled.
- DMA:
	- `num_channels=1`
	- `num_master_ports=1`
	- `num_channels_per_master_port=1`

Interpretation: this is a clean baseline used to validate that the minimal architecture works correctly before adding complexity.

### `01.py`: Memory and peripheral expansion

This configuration extends `00.py` into a richer MCU system.

- Bus: changed to `BusType.NtoM` for better scalability.
- CPU: still `cv32e20(rv32e=False, rv32m="RV32MSlow")`.
- Memory:
	- 8 RAM banks of 32 KiB.
	- 4 interleaved RAM banks of 16 KiB, labeled `"data_interleaved"`.
	- Same linker section strategy as in `00.py`.
- User peripherals added:
	- `RV_plic(0x00000000)`
	- `SPI_host(0x00010000)`
	- `GPIO(0x00020000)`
	- `I2C(0x00030000)`
	- `RV_timer(0x00040000)`
	- `SPI2(0x00050000)`
	- `I2S(0x00070000)`
	- `UART(0x00080000)`
- DMA unchanged (still 1 channel, 1 master port).

Interpretation: the platform now supports a broader embedded use case with more memory and common I/O peripherals, while keeping compute and DMA complexity moderate.

### `02.py`: Compute capability upgrade

This configuration keeps the SoC structure from `01.py`, but upgrades the CPU.

- Bus: `BusType.NtoM`.
- CPU: `cv32e40p(fpu=True, corev_pulp=True)`.
- Memory: same as `01.py`.
- Peripherals: same as `01.py`.
- DMA: same as `01.py` (1 channel, 1 master port).

Interpretation: this isolates the effect of the processor change. Students can see how moving to a more capable core does not require redesigning the rest of the platform.

### `03.py`: DMA parallelism upgrade

This is the most capable configuration in the sequence.

- Bus: same as `02.py` (`BusType.NtoM`).
- CPU: same as `02.py` (`cv32e40p` with FPU and PULP).
- Memory: same as `02.py`.
- Peripherals: same as `02.py`.
- DMA upgraded to:
	- `num_channels=4`
	- `num_master_ports=4`
	- `num_channels_per_master_port=1`

