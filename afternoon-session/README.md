<p align="center">
  <img src="../img/heep-up.png" alt="HEEPup" width="600"/>
</p>

# HEEPup Afternoon Session

Environment setup guide for the 20/03 tutorial HEEPup.

## What the setup installs

This setup installs and configures:

1. System dependencies (Homebrew on macOS, APT on Linux)
2. Verible
3. RISC-V toolchain for X-HEEP
4. Verilator `v5.040`
5. Conda environment from `conda_environment.yml`
6. openOCD
7. openFPGAloader
8. picocom

## Supported platforms

- macOS arm64
- macOS x86_64
- Linux x86_64

Any other OS/architecture is not supported (can be, but not tested).

## Before you start

1. Ensure `conda` is installed and available in your shell.
2. Run all commands from the repository root.

## Setup flow

### Step 1/5 - System dependencies

On macOS:

```bash
brew install libyaml libelf cmake ninja wget git flex bison systemc help2man autoconf automake meson
```

On Linux:

```bash
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
	build-essential make g++ cmake ninja-build wget git curl \
	flex bison autoconf automake help2man \
	libelf1 libelf-dev libyaml-dev libfl-dev libexpat-dev \
	zlib1g-dev libssl-dev libglib2.0-dev \
	python3 python3-dev python3-venv \
	meson
```

### Step 2/5 - Verible

If missing, download and extract Verible into `tools/verible`.

Install commands (manual):

Linux x86_64:

```bash
export VERIBLE_VERSION=v0.0-4023-gc1271a00
wget https://github.com/chipsalliance/verible/releases/download/${VERIBLE_VERSION}/verible-${VERIBLE_VERSION}-linux-static-x86_64.tar.gz
tar -xf verible-${VERIBLE_VERSION}-linux-static-x86_64.tar.gz
mkdir -p $HOME/tools/verible/${VERIBLE_VERSION}/
mv verible-${VERIBLE_VERSION}/* $HOME/tools/verible/${VERIBLE_VERSION}/
rm verible-${VERIBLE_VERSION}-linux-static-x86_64.tar.gz
rm -r verible-${VERIBLE_VERSION}
```

macOS (arm64 and x86_64):

```bash
export VERIBLE_VERSION=v0.0-4023-gc1271a00
wget https://github.com/chipsalliance/verible/releases/download/${VERIBLE_VERSION}/verible-${VERIBLE_VERSION}-macOS.tar.gz
tar -xf verible-${VERIBLE_VERSION}-macOS.tar.gz
mkdir -p $HOME/tools/verible/${VERIBLE_VERSION}/
mv verible-${VERIBLE_VERSION}/* $HOME/tools/verible/${VERIBLE_VERSION}/
rm verible-${VERIBLE_VERSION}-macOS.tar.gz
rm -r verible-${VERIBLE_VERSION}
```

After installation you need to add `$HOME/tools/verible/${VERIBLE_VERSION}/bin` to your `PATH` environment variable. Also consider adding it to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.) so that it's on the `PATH` in the future, like this:

```bash
export VERIBLE_VERSION=v0.0-4023-gc1271a00
export PATH=$HOME/tools/verible/${VERIBLE_VERSION}/bin:$PATH
```

### Step 3/5 - RISC-V toolchain

When installed, export `RISCV_XHEEP` to the selected location.

Install commands (manual):

macOS arm64:

```bash
mkdir -p tools/risc-v /tmp/riscv-extract
wget -q --show-progress \
	"https://buildbot.embecosm.com/job/corev-gcc-macos-arm64/8/artifact/corev-openhw-gcc-macos-20240530.zip" \
	-O riscv.zip
unzip -q riscv.zip -d /tmp/riscv-extract
mv /tmp/riscv-extract/corev-openhw-gcc-macos-20240530/* tools/risc-v/
rm -rf /tmp/riscv-extract riscv.zip
export RISCV_XHEEP="$(realpath tools/risc-v)"
```

macOS x86_64:

```bash
mkdir -p tools/risc-v /tmp/riscv-extract
wget -q --show-progress \
	"https://buildbot.embecosm.com/job/corev-gcc-macos/48/artifact/corev-openhw-gcc-macos-20240530.zip" \
	-O riscv.zip
unzip -q riscv.zip -d /tmp/riscv-extract
mv /tmp/riscv-extract/corev-openhw-gcc-macos-20240530/* tools/risc-v/
rm -rf /tmp/riscv-extract riscv.zip
export RISCV_XHEEP="$(realpath tools/risc-v)"
```

Linux x86_64 (Ubuntu >= 22.04):

```bash
mkdir -p tools/risc-v
wget -q --show-progress \
	"https://buildbot.embecosm.com/job/corev-gcc-ubuntu2204/47/artifact/corev-openhw-gcc-ubuntu2204-20240530.tar.gz" \
	-O riscv.tar.gz
tar -xzf riscv.tar.gz -C tools/risc-v --strip-components=1
rm riscv.tar.gz
export RISCV_XHEEP="$(realpath tools/risc-v)"
```

Linux x86_64 (Ubuntu 20.04):

```bash
mkdir -p tools/risc-v
wget -q --show-progress \
    "https://buildbot.embecosm.com/job/corev-gcc-ubuntu2004/47/artifact/corev-openhw-gcc-ubuntu2004-20250316.tar.gz" \
    -O riscv.tar.gz
tar -xzf riscv.tar.gz -C tools/risc-v --strip-components=1
rm riscv.tar.gz
export RISCV_XHEEP="$(realpath tools/risc-v)"
```

### Step 4/5 - Verilator v5.040

If missing, build it in `tools/verilator` (or another path you prefer).

Build notes:

- Clones `https://github.com/verilator/verilator.git`
- Checks out `v5.040`
- Runs `autoconf`, `./configure --enable-longtests`, then `make -j...`
- On macOS, applies a patch in `src/V3Hash.h` for Clang compatibility with `v5.040`
- On macOS, uses Homebrew `flex` and `systemc` paths

Build commands (manual):

```bash
git clone https://github.com/verilator/verilator.git tools/verilator
cd tools/verilator
git checkout v5.040
# macOS only:
sed -i '' 's|V3Hash{reinterpret_cast<uintptr_t>(val)} {}|V3Hash{static_cast<uint64_t>(reinterpret_cast<uintptr_t>(val))} {}|g' src/V3Hash.h
autoconf
./configure --enable-longtests
make -j"$(sysctl -n hw.ncpu 2>/dev/null || nproc)"
cd ../..
```

### Step 5/5 - Conda environment

Use the environment files in this folder:

- `conda_environment.yml`
- `python-requirements.txt`

Create/activate commands:

```bash
CONDA_BASE="$(conda info --base)"
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda env create -f conda_environment.yml
conda activate core-v-mini-mcu
pip install -r python-requirements.txt
```

If the environment already exists:

```bash
conda activate core-v-mini-mcu
```

If `conda env create -f conda_environment.yml` fails because of a missing
`../docs/python-requirements.txt`, use this fallback:

```bash
conda create -y -n core-v-mini-mcu python=3.8 pip
conda activate core-v-mini-mcu
pip install -r python-requirements.txt
```

Add the toolchain to your shell if needed:

```bash
export RISCV_XHEEP="$(realpath tools/risc-v)"
```

### Step 6/5 - openOCD

Install commands (manual):

```bash
# macOS
brew install openocd
# Linux
sudo apt-get install -y openocd
```

### Step 7/5 - openFPGAloader
Install commands (manual):

```bash
# macOS
brew install openfpgaloader
# Linux
sudo apt-get install -y openfpgaloader
```

### Step 8/5 - picocom
Install commands (manual):

```bash
# macOS
brew install picocom
# Linux
sudo apt-get install -y picocom
```


## Notes and troubleshooting

- RISC-V toolchain download is large (~1.3 GB) and may be slow.
- If `conda` is not found, install [Miniconda/Anaconda](https://www.anaconda.com/docs/getting-started/miniconda/instal) and re-run.
