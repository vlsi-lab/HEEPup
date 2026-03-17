## Configuration Exercise

In this activity, you will design and compare eight X-HEEP configurations, then measure their impact on execution cycles.

Your implementation targets are the following Python files in `x-heep-main/configs`:

- `00.py`
- `01.py`
- `02.py`
- `03.py`
- `04.py`
- `05.py`
- `06.py`
- `07.py`

Use `configs/general.py` as your structural reference.

## Exercise Goal

In this exercise, you will explore how different architectural choices in the X-HEEP platform affect the performance of a simple matrix multiplication workload (`example_matmul`). By implementing and comparing eight distinct configurations, you will gain insights into the trade-offs between CPU microarchitecture, bus topology, memory subsystem design, and data movement capabilities.

- CPU microarchitecture changes (`CV32E20`, `CV32E40P`, `CV32E40P with PULP extensions`)
- Bus topology changes (`ONE2M` vs `N2M`)
- Memory subsystem changes (`NORMAL` contiguous vs `INTL` interleaved)
- Data movement and concurrency changes (number of DMA channels and DMA master ports) (use `example_dma` for testing)

Across all eight configurations, memory is fixed to 10 banks of 32 KB each (320 KB total).

At the end, you should be able to explain not only what each config contains, but also why some configs complete `example_matmul` in fewer cycles.

## Build and Generate

Generate with:

```sh
make mcu-gen PYTHON_X_HEEP_CFG=configs/00.py X_HEEP_CFG=configs/python_unsupported.hjson
```

Then repeat for `configs/01.py` through `configs/07.py`.

After each generation, inspect the produced output in `x-heep-main` and verify that the expected architecture choices were applied.

To use the pulp extensions, compile with:

```sh
make app PROJECT=example_matmul ARCH=32imc_zicsr_zifencei_xcvhwlp_xcvmem_xcvmac_xcvbi_xcvalu_xcvsimd_xcvbitmanip
```

## Functional Validation

For every configuration:

1. Run Verilator simulation of `hello_world` to ensure the platform boots correctly.
2. Run Verilator simulation of `example_matmul` for a comparable workload.
3. Modify `example_matmul` to print cycle count so results are directly comparable across all 8 configurations.

## Report Template

Fill this table after collecting the cycle counts:

| Config | Cycles |
|--------|--------|
| 00.py  |        |
| 01.py  |        |
| 02.py  |        |
| 03.py  |        |
| 04.py  |        |
| 05.py  |        |
| 06.py  |        |
| 07.py  |        |

## Configuration Targets

### `00.py`

It uses `CV32E20`, `ONE2M` bus, the `NORMAL` memory subsystem (contiguous), and 1 DMA channel, with 10 banks of 32 KB each.

### `01.py`

Here you move to `CV32E40P` and also change interconnect and memory subsystem (`N2M` + `INTL`), while keeping 1 DMA channel. Memory is interleaved, still with 10 banks of 32 KB each.

### `02.py`

You keep `CV32E40P`, but return to `ONE2M` and `NORMAL`, still with 1 DMA channel. Memory remains fixed at 10 banks of 32 KB in contiguous mode.

### `03.py`

This configuration uses the `CV32E40P` core with PULP extensions enabled while keeping `N2M`, `INTL`, and 1 DMA channel. Memory is again interleaved with 10 x 32 KB banks.

### `04.py`

You switch back to `CV32E20`, keep `N2M` + `INTL`, and increase to 2 DMA channels. Memory is interleaved (10 banks, 32 KB each).

### `05.py`

This setup uses `CV32E20`, `ONE2M`, `NORMAL`, 2 DMA channels, and 1 DMA master port. Memory stays at 10 contiguous 32 KB banks.

### `06.py`

This configuration combines `CV32E40P`, `ONE2M`, `NORMAL`, 2 DMA channels, and 2 DMA master ports. Memory stays at 10 contiguous 32 KB banks.

### `07.py` - Full-feature high-end setup

This is the richest configuration in the set: `CV32E40P XPULP` (PULP extensions enabled), `N2M`, `INTL`, 2 DMA channels, and 2 DMA master ports. Memory is interleaved with 10 banks of 32 KB.

## Suggested Implementation Order

Use this progression to reduce debugging time and keep diffs understandable:

1. Implement `00.py` first as your known-good baseline.
2. Continue with `01.py`.
3. Then `02.py`.
4. Then `03.py`.
5. Then `04.py`.
6. Then `05.py`.
7. Then `06.py`.
8. Finally `07.py`.
