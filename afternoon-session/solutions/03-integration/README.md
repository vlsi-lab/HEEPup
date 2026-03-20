# Solutions - 03 Accelerator Integration ✅

This folder provides a reference integration for the GR-HEEP accelerator step. It is meant to support review and discussion, especially around template wiring and verification strategy.

## How to get the most from this solution 🧭

- Start from your own integrated version first.
- Compare interface wiring and template edits with the reference.
- Validate in simulation and explain any behavioral differences.

## Core flow recap

From the `GR-HEEP` directory:

```bash
make vendor-update MODULE_NAME=keccak_loosely
make vendor-update MODULE_NAME=keccak_tightly
make mcu-gen
make app
make verilator-build
make verilator-run
```

## Suggested software progression 🧪

Use applications in `sw/applications`:

- `gr_heep_hello_world`
- `SHA3-384-baseline`
- `SHA3-384-loosely`
- `SHA3-384-tightly`

Move from baseline to accelerator-specific variants and log observations for each run.

## Review checklist 🔍

- Vendor modules are updated with the expected names.
- Accelerator is instantiated coherently in peripheral template logic.
- Top-level connections are complete and reset/clock clean.
- Regeneration is executed after each relevant template change.
- Simulation output is consistent with the selected software target.

## Discussion angle for advanced audiences 🎓

When presenting results, prioritize system-level interpretation:

- coupling style vs software complexity,
- integration cost vs performance gain,
- verification effort vs architectural flexibility.

That framing makes the solution transferable beyond this specific lab setup.
