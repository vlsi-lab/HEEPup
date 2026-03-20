# 03 - Accelerator Integration in GR-HEEP 🔧

This stage is where platform architecture and hardware design meet. You will integrate a Keccak accelerator into GR-HEEP, rebuild the generated system, and validate behavior in simulation before moving to FPGA.

The focus is architectural clarity: where the accelerator is instantiated, how it is connected, and how the software stack observes the result.

## Integration storyline 🧭

1. Sync accelerator vendor sources.
2. Instantiate the accelerator in the peripheral template.
3. Connect interfaces at top level.
4. Regenerate, rebuild, and simulate.

## Enter GR-HEEP

```bash
cd GR-HEEP
```

## 1) Update vendored accelerator modules 📦

Run the two updates explicitly:

```bash
make vendor-update MODULE_NAME=keccak_loosely
make vendor-update MODULE_NAME=keccak_tightly
```

If you need to refresh everything:

```bash
make vendor-update-all
```

## 2) Instantiate the accelerator in the peripheral template 🧩

Edit:

- `hw/gr-heep/gr_heep_peripherals.sv.tpl`

Add the accelerator module instance and wire the expected control/data signals. Keep naming consistent and explicit so generated files remain readable.

## 3) Connect the integration points at top level 🔌

Edit:

- `hw/gr-heep/gr_heep.sv.tpl`

Route the accelerator-facing signals through the top-level integration fabric and verify reset/clock behavior.

## 4) Regenerate and simulate ✅

After every meaningful RTL/template update:

```bash
make mcu-gen
make app
make verilator-build
make verilator-run
```

## Suggested application progression 🧪

The following applications are available in `sw/applications`:

- `gr_heep_hello_world`
- `SHA3-384-baseline`
- `SHA3-384-loosely`
- `SHA3-384-tightly`

Practical flow:

1. Start with `gr_heep_hello_world` to confirm platform integrity.
2. Move to `SHA3-384-baseline` for reference behavior.
3. Compare loosely and tightly coupled flows to evaluate integration impact.

## What to document as you go 📝

- What you changed in each template and why.
- Which run is your baseline.
- What changed in runtime behavior and/or cycle count.
- Any assumptions on bus interactions, latency, or contention.

This framing turns the task into a reproducible integration narrative, not just a checklist.

## Troubleshooting hints 🧯

- Generation errors: check template syntax and signal names first.
- Simulation mismatch: confirm that regenerated files are up to date after edits.
- Silent runtime failures: verify that software project selection matches your intended accelerator path.
