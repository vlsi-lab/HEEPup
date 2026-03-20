# 02 - X-HEEP on FPGA ⚡

This stage moves from simulation to real hardware. The objective is to reproduce your software flow on FPGA, keep observability high (JTAG + UART), and preserve comparability with your previous configuration study.

## What you are proving here 🧪

- The selected bitstream boots correctly on your board.
- The software build matches the board target and linker mode.
- Program loading works via JTAG/GDB or flash.
- UART output confirms runtime behavior.

The provided bitstreams are aligned with the configurations explored in the previous step, so keep board/configuration pairing consistent.

## Enter the working directory

```bash
cd x-heep-main
```

## 1) Program the FPGA bitstream 🧷

Detect the cable first:

```bash
openFPGALoader --detect-cable
```

Program SRAM (volatile, recommended for iterative labs):

```bash
openFPGALoader -c <detected_cable_name> <path_to_bitstream.bit>
```

Optional persistent flash programming:

```bash
openFPGALoader -c <detected_cable_name> -f <path_to_bitstream.bit>
```

Examples:

```bash
openFPGALoader -c <detected_cable_name> ../bitstream/pynq-z2/<configuration>.bit
openFPGALoader -c <detected_cable_name> ../bitstream/zcu104/<configuration>.bit
openFPGALoader -c <detected_cable_name> ../bitstream/aup-zu3/<configuration>.bit
```

## 2) Build firmware for the board target 🏗️

```bash
make app PROJECT=<app_name> TARGET=<target_name> LINKER=<on_chip|flash_load|flash_exec>
```

Examples:

```bash
make app PROJECT=hello_world TARGET=pynq-z2 LINKER=on_chip
make app PROJECT=hello_world TARGET=zcu104 LINKER=flash_load
make app PROJECT=example_matmul TARGET=aup-zu3 LINKER=flash_exec
```

## 3) On-chip execution flow (JTAG + GDB) 🐞

Use this when `LINKER=on_chip`.

Start OpenOCD (choose one path):

```bash
openocd -f ./tb/core-v-mini-mcu-esl-programmer.cfg
```

or:

```bash
make openOCD_epflp
```

For Pynq-Z2 BSCAN flow:

```bash
openocd -f ./tb/core-v-mini-mcu-pynq-z2-bscan.cfg
```

or:

```bash
make openOCD_bscan
```

Then, from a second terminal:

```bash
make gdb_connect
```

This connects to `:3333`, loads the ELF, and continues execution.

## 4) Flash execution flow 💾

Use this when firmware is built with `LINKER=flash_load` or `LINKER=flash_exec`.

```bash
make app PROJECT=<app_name> TARGET=<target_name> LINKER=flash_load
make flash-prog
```

Helpful auxiliary commands:

```bash
make flash-readid
make flash-read FLASHREAD_ADDR=0x10000 FLASHREAD_BYTES=16
make flash-erase
```

Boot switch reminder:

- Load from flash: `boot_sel_i=1`, `execute_from_flash_i=0`
- Execute from flash: `boot_sel_i=1`, `execute_from_flash_i=1`

## 5) Observe UART output with picocom 📟

```bash
picocom -b 9600 -r -l --imap lfcrlf /dev/serial/by-id/usb-FTDI_Quad_RS232-HS-if02-port0
```

Replace the serial path if needed (`/dev/ttyUSBx`, `/dev/tty.usbserial-*`, ...).

Exit sequence: `Ctrl+A`, then `Ctrl+Q`.

## Suggested validation loop 🔁

1. Pick one board/configuration pair.
2. Program the matching bitstream.
3. Build and run one baseline app (`hello_world`).
4. Run one workload app (`example_matmul` and optionally `example_dma`).
5. Capture pass/fail + notable logs + performance notes.

This gives you reproducible evidence when comparing FPGA behavior with simulation results.

## Troubleshooting quick notes 🧯

- `LIBUSB_ERROR_ACCESS`: check USB permissions/udev rules.
- OpenOCD not finding target: verify the selected config file and cable.
- Flash programming instability: retry with reset timing control.
- No UART text: verify baud rate (9600), serial node, and boot-mode switches.
