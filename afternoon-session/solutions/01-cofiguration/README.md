# Solutions - 01 Configuration Study ✅

This folder contains the reference implementation for the configuration study. Use it as a comparison companion, not as a blind copy source.

## How to use this solution effectively 🧭

- First, complete your own attempt in `../01-cofiguration`.
- Then compare structure and parameter choices file by file.
- Focus on understanding *why* each change was made.

## Reference scope

The solution covers the eight configuration files in `x-heep-main/configs`:

- `00.py`
- `01.py`
- `02.py`
- `03.py`
- `04.py`
- `05.py`
- `06.py`
- `07.py`

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

## What each configuration is doing 🧩

The table below summarizes the architectural intent behind each configuration.

| Config | CPU | Bus | Memory | DMA setup | Main intent |
|--------|-----|-----|--------|-----------|-------------|
| `00.py` | CV32E20 | ONE2M | NORMAL | 1 channel | Baseline reference point |
| `01.py` | CV32E40P | N2M | INTL | 1 channel | Better core + more parallel memory/interconnect behavior |
| `02.py` | CV32E40P | ONE2M | NORMAL | 1 channel | Isolate core effect while reverting interconnect/memory |
| `03.py` | CV32E40P + XPULP | N2M | INTL | 1 channel | Add ISA acceleration on top of a high-throughput fabric |
| `04.py` | CV32E20 | N2M | INTL | 2 channels | Test DMA parallelism with simpler core |
| `05.py` | CV32E20 | ONE2M | NORMAL | 2 channels, 1 master | More DMA channels without full interconnect scaling |
| `06.py` | CV32E40P | ONE2M | NORMAL | 2 channels, 2 masters | Push DMA concurrency while keeping memory contiguous |
| `07.py` | CV32E40P + XPULP | N2M | INTL | 2 channels, 2 masters | Full-feature configuration for peak parallelism |

## How configurations change from one to the next 🔄

Read the sequence as an experimental design, not as random variants:

1. `00 -> 01`: changes core, bus, and memory model together to observe an aggressive architecture jump.
2. `01 -> 02`: keeps the stronger core but rolls back bus/memory to separate CPU gains from fabric gains.
3. `02 -> 03`: enables XPULP to evaluate ISA-level acceleration impact.
4. `03 -> 04`: drops back to CV32E20 while increasing DMA channels, probing data-movement vs compute balance.
5. `04 -> 05`: reverts bus/memory to ONE2M/NORMAL while keeping dual DMA channels, isolating topology effects.
6. `05 -> 06`: upgrades core and DMA master parallelism, still on contiguous memory.
7. `06 -> 07`: combines XPULP with N2M + INTL for the most capable setup.

## What to expect in practice 📈

- `example_matmul` usually reacts strongly to CPU class and XPULP support.
- Interleaved memory (`INTL`) and `N2M` are more visible when access patterns are memory intensive.
- Extra DMA channels or master ports help only when software actually drives concurrent transfers.
- The best configuration depends on workload mix, not on one metric alone.

## Verification flow 🔁

Use the same flow as in the exercise:

```bash
make mcu-gen PYTHON_X_HEEP_CFG=configs/00.py X_HEEP_CFG=configs/python_unsupported.hjson
make app PROJECT=hello_world
make verilator-build
make verilator-run
```

Then repeat for all configurations and compare against your own logs.

XPULP-enabled build reminder:

```bash
make app PROJECT=example_matmul ARCH=rv32imc_zicsr_zifencei_xcvhwlp_xcvmem_xcvmac_xcvbi_xcvalu_xcvsimd_xcvbitmanip
```

## What to compare when reviewing 🔬

- CPU/interconnect/memory coherence.
- DMA channel and master-port settings.
- Consistency of generation outputs.
- Impact on workload cycle counts.

## Suggested reflection prompts ✍️

- Which parameters had the largest measured impact?
- Where did intuition and measured behavior diverge?
- Which configuration offers the best balance for your use case?

Treat this solution as a benchmark for reasoning quality, not only for final values.
