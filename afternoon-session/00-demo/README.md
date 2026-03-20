# 00 - Demo Warm-Up 🚀

Welcome to the afternoon hands-on flow. This first step is a confidence builder: we verify that your environment is healthy, generate a baseline SoC, and run a full firmware simulation end-to-end.

Think of this as your "known-good checkpoint" before diving into architectural exploration and accelerator integration.

## Why this step matters 🧭

- It validates your toolchain and paths before more complex changes.
- It confirms that generation, compilation, and simulation are all wired correctly.
- It gives you a clean baseline log that you can compare against later runs.

## Quick environment sanity check 🔎

Run from this folder:

```bash
if [[ "$CONDA_DEFAULT_ENV" == "core-v-mini-mcu" ]]; then echo "core-v-mini-mcu is active"; else echo "core-v-mini-mcu is NOT active"; fi

which fusesoc
which verilator
which openocd
which picocom
which verible-verilog-format
echo "RISCV_XHEEP: $RISCV_XHEEP"
```

If one command is missing, fix it now. It is much faster than debugging failures later.

## Baseline flow in X-HEEP 🛠️

```bash
cd x-heep-main
```

1. Generate the default MCU:

```bash
make mcu-gen
```

2. Build the Verilator model:

```bash
make verilator-build
```

3. Build firmware (default app):

```bash
make app
```

4. Run the simulation:

```bash
make verilator-run
```

## What to observe 📌

- The generation step completes without template/configuration errors.
- Firmware is built into `sw/build` successfully.
- UART/simulation output is coherent and ends cleanly.

If this passes, you are ready for configuration experiments with high confidence. ✅
