<p align="center">
  <img src="img/heep-up.png" alt="HEEPup" width="600"/>
</p>

# HEEPup Workshop

A hands-on workshop on [X-HEEP](https://github.com/esl-epfl/x-heep), the eXtendable Heterogeneous Energy-Efficient Platform, jointly organized by **EPFL**, **UPM**, and **POLITO**.

**Date:** March 20, 2025 \
**Where:** Maxwell Conference room (DET, PoliTO) \
**Online:** https://didattica.polito.it/VClass/HEEPUP

## Agenda

### Morning -- Presentations

Talks and presentations by EPFL, UPM, and POLITO covering the X-HEEP platform architecture, ecosystem, and use cases.

### Afternoon -- Hands-on Session

A guided, practical session where participants configure, build, and simulate an X-HEEP-based microcontroller using Verilator.

## Repository Structure

```
.
├── morning-session/          # Presentation material
├── afternoon-session/        # Hands-on exercises and setup guide
│   ├── README.md             # Environment setup instructions
│   ├── conda_environment.yml # Conda environment definition
│   ├── python-requirements.txt
│   ├── 00-demo/              # Demo: generate, build, and run X-HEEP
│   ├── 01-cofiguration/      # Exercise: write Python configuration files
│   ├── 02-fpga/              # Exercise: generate FPGA bitstream and depoly the design
│   │   └── ...bitstream/     # Ready-to-go bitstreams
│   ├── 03-integration/       # Exercise: configure gr-heep with external accelerators
│   ├── 04-integration-fpga/  # Exercise: generate FPGA bitstream and depoly the accelerators
│   └── solutions/            # Reference solutions for ex. 01 & 03
└── img/
```

## Getting Started

Head to the [afternoon-session README](afternoon-session/README.md) for full environment setup instructions (toolchain, Verilator, Conda, etc.) before the workshop.
