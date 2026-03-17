## Configuration Exercise

In this exercise, you must implement four Python configuration files in `x-heep-main/configs`:

- `00.py`
- `01.py`
- `02.py`
- `03.py`

You can use `configs/general.py` as a reference for the configuration structure.

## How to Generate

Run `make mcu-gen` with the Python config you want to test:

```sh
make mcu-gen PYTHON_X_HEEP_CONFIG=configs/00.py X_HEEP_CFG=configs/python_unsupported.hjson
```

Replace `configs/00.py` with `configs/01.py`, `configs/02.py`, or `configs/03.py` as needed.

Then inspect the generated output in `x-heep-main`.

## Target Behavior of Each Configuration

### `00.py` (Baseline Minimal System)

- Use a one-to-many bus.
- Use the cv32e20 CPU, with rv32e disabled and slow multiply/divide support.
- Configure memory with:
	- 2 RAM banks of 32 KiB each.
	- a code linker section starting at address 0 with size 0x00000E800.
	- a data linker section starting at 0x00000E800 and continuing to the end.
- Add all required base peripherals.
- Do not add optional user peripherals.
- DMA must be configured as:
	- 1 channel
	- 1 master port
	- 1 channel per master port

### `01.py` (Extended Memory and User Peripherals)

Start from `00.py`, then:

- Change the bus to an N-to-M interconnect.
- Keep the same cv32e20 CPU setup as in 00.py.
- Increase memory to:
	- 8 RAM banks of 32 KiB.
	- interleaved RAM with 4 banks of 16 KiB, named data_interleaved.
- Keep the same linker sections (code and data).
- Keep base peripherals.
- Add these user peripherals with their addresses:
	- RV_plic at 0x00000000
	- SPI_host at 0x00010000
	- GPIO at 0x00020000
	- I2C at 0x00030000
	- RV_timer at 0x00040000
	- SPI2 at 0x00050000
	- I2S at 0x00070000
	- UART at 0x00080000
- DMA remains 1 channel / 1 master port.

### `02.py` (CPU Upgrade)

Start from `01.py`, then:

- Keep the N-to-M bus.
- Replace the CPU with cv32e40p, enabling both floating-point support and CORE-V PULP extensions.
- Keep memory and peripherals the same as in `01.py`.
- DMA remains 1 channel / 1 master port.

### `03.py` (DMA Parallelism Upgrade)

Start from `02.py`, then:

- Keep bus, CPU, memory, and peripherals the same as in `02.py`.
- Change DMA to:
	- 4 channels
	- 4 master ports
	- 1 channel per master port

## Suggested Implementation Order

1. Implement `00.py` first.
2. Extend to `01.py`.
3. Upgrade CPU for `02.py`.
4. Upgrade DMA for `03.py`.



