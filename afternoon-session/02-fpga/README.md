# 02 - X-HEEP on FPGA

In this activity you will:

1. Program the FPGA with one of the provided bitstreams.
2. Build software for the matching FPGA target.
3. Load code either through JTAG+GDB or through external flash.
4. Read UART output with picocom.

## Important context

The provided bitstreams were generated from the configurations of the previous task (`01-cofiguration`), so each bitstream corresponds to one of the MCU configurations you already explored.

Use the correct bitstream for your board and configuration.

## Enter the X-HEEP folder

```bash
cd x-heep-main
```

## 1) Load the provided bitstream with openFPGALoader

### 1.1 Identify your cable/programmer

```bash
openFPGALoader --detect-cable
```

### 1.2 Program SRAM (volatile, recommended for the lab)

```bash
openFPGALoader -c <detected_cable_name> <path_to_provided_bitstream.bit>
```

### 1.3 Optional: program FPGA flash (persistent)

```bash
openFPGALoader -c <detected_cable_name> -f <path_to_provided_bitstream.bit>
```

### 1.4 Examples for different FPGA targets

```bash
# Pynq-Z2
openFPGALoader -c <detected_cable_name> bitstreams/pynq-z2/<configuration>.bit

# ZCU104
openFPGALoader -c <detected_cable_name> bitstreams/zcu104/<configuration>.bit

# AUP-ZU3
openFPGALoader -c <detected_cable_name> bitstreams/aup-zu3/<configuration>.bit
```

Notes:

- Use the bitstream matching your board (`pynq-z2`, `zcu104`, `aup-zu3`, etc.).
- If more than one cable is connected, run `openFPGALoader --detect-cable` and select the right one explicitly.

## 2) Build software for the selected FPGA target

Compile an application with:

```bash
make app PROJECT=<app_name> TARGET=<target_name> LINKER=<on_chip|flash_load|flash_exec>
```

Examples:

```bash
make app PROJECT=hello_world TARGET=pynq-z2 LINKER=on_chip
make app PROJECT=hello_world TARGET=zcu104 LINKER=flash_load
make app PROJECT=example_matmul TARGET=aup-zu3 LINKER=flash_exec
```

## 3) Load code with GDB over JTAG (on-chip execution)

Use this path when your app is built with `LINKER=on_chip`.

### 3.1 Start OpenOCD (choose one setup)

If you use the EPFL programmer:

```bash
openocd -f ./tb/core-v-mini-mcu-esl-programmer.cfg
```

or:

```bash
make openOCD_epflp
```

If you use a Pynq-Z2 bitstream with Xilinx BSCAN/scanchain:

```bash
openocd -f ./tb/core-v-mini-mcu-pynq-z2-bscan.cfg
```

or:

```bash
make openOCD_bscan
```

### 3.2 Connect GDB and load the ELF

In a second terminal:

```bash
make gdb_connect
```

`make gdb_connect` uses `sw/gdbInit`, which does:

1. `target extended-remote :3333`
2. `load`
3. `continue`

So your compiled program is loaded automatically into memory and started.

If you want to do these steps manually, you can run `riscv64-unknown-elf-gdb sw/build/main.elf` and then execute the above GDB commands.

Some other useful GDB commands:
- `monitor reset halt` to reset and halt the board.
- `b main` to set a breakpoint at `main()`.
- `info registers` to see register values.
- `x/16xw 0x80000000` to examine memory at the start of the address space.
- `continue` to resume execution after hitting a breakpoint.
- `quit` to exit GDB.


## 4) Program and run from flash (EPFL programmer flow)

Use this path when your app is built with `LINKER=flash_load` (or `flash_exec`).

### 4.1 Build for flash

```bash
make app PROJECT=<app_name> TARGET=<target_name> LINKER=flash_load
```

### 4.2 Program flash from X-HEEP Makefile

```bash
make flash-prog
```

Useful extra commands:

```bash
make flash-readid
make flash-read FLASHREAD_ADDR=0x10000 FLASHREAD_BYTES=16
make flash-erase
```

Then reset the board to boot from flash.

Switch reminder from the X-HEEP docs:

- Load from flash: `boot_sel_i=1`, `execute_from_flash_i=0`
- Execute from flash: `boot_sel_i=1`, `execute_from_flash_i=1`

## 5) Read UART output with picocom

From X-HEEP documentation / Makefile:

```bash
picocom -b 9600 -r -l --imap lfcrlf /dev/serial/by-id/usb-FTDI_Quad_RS232-HS-if02-port0
```

If your system uses another serial name, replace it with your device (`/dev/ttyUSBx`, `/dev/tty.usbserial-*`, etc.).

Exit picocom with `Ctrl+A`, then `Ctrl+Q`.

## Recommended workflow

1. Choose the board and matching provided bitstream.
2. Load bitstream with `openFPGALoader`.
3. Build app for that board (`TARGET=<board>`).
4. If using on-chip linker: start OpenOCD + run `make gdb_connect`.
5. If using flash linker: run `make flash-prog`, set boot switches, reset.
6. Open picocom and verify UART output.

## 6) Validate with the same examples as previous exercise

Now test on FPGA the same applications you already used in the previous exercise (`01-cofiguration`).

At minimum, rerun your baseline examples (for example `hello_world`, `example_matmul`, and any DMA example you used before) and compare behavior/performance with your simulation results.

Suggested loop for each provided bitstream/configuration:

1. Load the matching bitstream on the board.
2. Build the same application with the matching `TARGET`.
3. Run it on FPGA (JTAG+GDB or flash flow).
4. Capture UART output with picocom.
5. Record quick notes: pass/fail, observed output, and (if relevant) cycle count.

If you want, you can also test other applications from `sw/applications` (for example `example_dma`, `example_dma_multichannel`, `example_spi_write`, `example_power_manager`) to explore more peripherals and stress different configurations.

## Troubleshooting

- `libusb_open() failed with LIBUSB_ERROR_ACCESS`:
	- check udev/permissions for your USB interface.
- OpenOCD cannot see the target:
	- verify you selected the correct config (`esl-programmer`, `pynq-z2-bscan`, or `nexsys-hs2`).
- Flash programming fails:
	- retry while holding board reset, then release and reset again.
- No UART output:
	- check baud rate (9600), serial port path, and boot switch positions.
