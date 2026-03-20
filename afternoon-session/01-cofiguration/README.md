# 01 - Configuration Study Lab 🧠

This section is where architecture decisions become measurable. Instead of treating configuration as a static setup task, we use it as an experimental framework to reason about performance, data movement, and system-level trade-offs.

The goal is not just to "make it run", but to explain *why* specific choices affect cycle count.

## Big-picture objective 🎯

You will build and compare eight X-HEEP configurations and evaluate how they behave under the same workload.

Main design dimensions:

- CPU core family and ISA extensions.
- Interconnect topology.
- Memory organization (contiguous vs interleaved).
- DMA parallelism (channels and master ports).

Across all configurations, memory remains fixed to 10 banks of 32 KB each (320 KB total), so the comparison stays fair.

## Terminology quick guide 📚

- `NORMAL` memory: contiguous bank organization. Addresses map in larger continuous regions, simple and predictable, but may expose hotspots when many accesses target nearby locations.
- `INTL` memory: interleaved bank organization. Consecutive addresses are spread across banks, which can improve parallel memory throughput for streaming/access-heavy workloads.
- `ONE2M` bus: a simpler interconnect style with more centralized arbitration behavior. Good baseline for understanding non-aggressive fabric behavior.
- `N2M` bus: a more scalable interconnect style that better supports concurrent traffic between multiple initiators and memory/peripheral targets.
- `CV32E20`: compact, lower-complexity core option; useful as a baseline CPU.
- `CV32E40P`: more performance-oriented core than CV32E20.
- `XPULP`: ISA extension set on top of CV32E40P, adding instructions that can accelerate DSP-like and tight compute kernels.
- `DMA channels`: number of independent DMA transfer contexts that can be scheduled.
- `DMA master ports`: number of bus master interfaces available to DMA; more master ports can increase real transfer concurrency when traffic patterns allow it.

Rule of thumb: channels describe "how many transfers can be managed", while master ports describe "how many transfers can contend for the bus in parallel".

## Configuration files to implement 🧩

Work inside `x-heep-main/configs`:

- `00.py`
- `01.py`
- `02.py`
- `03.py`
- `04.py`
- `05.py`
- `06.py`
- `07.py`

Use `configs/general.py` as your structural reference pattern.

## Recommended workflow 🔁

Move in small, verifiable increments:

1. Generate one configuration.
2. Build firmware.
3. Run simulation.
4. Capture output and cycle count.
5. Move to the next configuration.

Generation command template:

```bash
make mcu-gen PYTHON_X_HEEP_CFG=configs/00.py X_HEEP_CFG=configs/python_unsupported.hjson
```

Repeat by replacing `00.py` with `01.py` ... `07.py`.

Firmware build examples:

```bash
make app PROJECT=hello_world
make app PROJECT=example_matmul
```

For XPULP-enabled builds, use:

```bash
make app PROJECT=example_matmul ARCH=rv32imc_zicsr_zifencei_xcvhwlp_xcvmem_xcvmac_xcvbi_xcvalu_xcvsimd_xcvbitmanip
```

Simulation loop:

```bash
make verilator-build
make verilator-run
```

## What to compare scientifically 📊

- Boot correctness (`hello_world` as a sanity gate).
- Kernel behavior (`example_matmul` under comparable inputs).
- Cycle count trends across the 8 architectural points.
- Optional DMA-focused experiments with `example_dma`.

If needed, instrument `example_matmul` so cycles are printed in a consistent format for every run.

## Interpretation map for the 8 configs 🗺️

- `00.py`: CV32E20, ONE2M, NORMAL, 1 DMA channel.
- `01.py`: CV32E40P, N2M, INTL, 1 DMA channel.
- `02.py`: CV32E40P, ONE2M, NORMAL, 1 DMA channel.
- `03.py`: CV32E40P + XPULP, N2M, INTL, 1 DMA channel.
- `04.py`: CV32E20, N2M, INTL, 2 DMA channels.
- `05.py`: CV32E20, ONE2M, NORMAL, 2 DMA channels, 1 DMA master port.
- `06.py`: CV32E40P, ONE2M, NORMAL, 2 DMA channels, 2 DMA master ports.
- `07.py`: CV32E40P + XPULP, N2M, INTL, 2 DMA channels, 2 DMA master ports.

## How and why the configurations evolve 🔄

Use the sequence as a controlled architecture study:

1. `00 -> 01`: major jump in core + interconnect + memory style to observe upper-bound gains.
2. `01 -> 02`: keep CPU upgrade but revert memory/interconnect to isolate core contribution.
3. `02 -> 03`: enable XPULP and evaluate ISA-level acceleration impact.
4. `03 -> 04`: switch back to CV32E20 but increase DMA channels to study data-movement leverage.
5. `04 -> 05`: keep dual DMA channels while reverting bus/memory topology, isolating fabric effects.
6. `05 -> 06`: upgrade core and DMA master parallelism for stronger transfer concurrency.
7. `06 -> 07`: combine XPULP with N2M + INTL for a fully featured high-parallelism design.

Practical expectation:

- Compute-heavy kernels generally benefit most from CPU/XPULP upgrades.
- Memory-intensive behavior is often where `N2M` + `INTL` becomes visible.
- DMA resources help when software actually schedules overlapping transfers.

## Suggested reporting table 📝

| Config | Cycles | Notes |
|--------|--------|-------|
| 00.py  |        |       |
| 01.py  |        |       |
| 02.py  |        |       |
| 03.py  |        |       |
| 04.py  |        |       |
| 05.py  |        |       |
| 06.py  |        |       |
| 07.py  |        |       |

## Suggested implementation order ✅

To keep debugging cost low, follow this progression:

1. `00.py`
2. `01.py`
3. `02.py`
4. `03.py`
5. `04.py`
6. `05.py`
7. `06.py`
8. `07.py`

By the end, you should be able to defend your performance conclusions with evidence, not only with configuration descriptions. 🔬
