# 00 - DEMO

0. Check if you have all the necessary tools installed

```bash
if [[ "$CONDA_DEFAULT_ENV" == "core-v-mini-mcu" ]]; then echo "core-v-mini-mcu is active"; else echo "core-v-mini-mcu is NOT active"; fi

which fusesoc
which verilator
which openocd
which picocom
which verible-verilog-format
echo "RISCV_XHEEP: $RISCV_XHEEP"

```

1. Experiment with X-HEEP

```bash

cd x-heep-main

```

2. Generate the microcontroller with the default configuration

```bash

make mcu-gen

```

3. Build the verilator testbench

```bash

make verilator-build

```

4. Build the hello world firmware

```bash

make app

```

5. Run the verilator testbench

```bash

make verilator-run

```

6. Wait for the testbench to finish and check the output
