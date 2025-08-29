<!-- TODO: Replace this by the paper title -->
# New vector multiplication instruction for OTBN-OpenTitan

## About this repository

This repository is the artifact of the paper [paper-title] which contains
changes to the hardware design as well as the Python simulator to support our
proposed vector multiplication instruction for OTBN. We copied over the changes
for the KMAC interface and `bn.{addv,subv}(m)`, `bn.shv`, `bn.trn{1,2}` from
Towards ML-KEM and ML-DSA on OpenTitan.

Our contributions:
- Replace their vector adders in `BN-ALU` by different adders to improve latency.
- Our multiplication instruction does not perform modular multiplication with
Montgomery as in the Towards adder. This is done from the software side.
- Use different adders in `BN-MAC` to compare resources/latency. 

In the following, we will give a description to guide the readers on how to
reproduce the results presented in our paper.

## Getting Started
For setting up software testing environment, please follow the
[OpenTitan's official guide](https://opentitan.org/book/doc/getting_started/index.html).

In case you are also using Python virtual environment like us, we recommend to
use Python 3.10.12 and then run:
```
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -U pip "setuptools<66.0.0"
pip3 install -r python-requirements.txt --require-hashes
```
If you're using a different version than 3.10.12 (either natively or in venv),
in all bazel tests below, you need to pass `--action_env=PATH` to the bazel
command before the target.

You also need Verilator with version >=5.022.
```
export VERILATOR_VERSION=5.022

# Install Verilator
git clone https://github.com/verilator/verilator.git
cd verilator
git checkout v$VERILATOR_VERSION

autoconf
CC=gcc-11 CXX=g++-11 ./configure --prefix=/tools/verilator/$VERILATOR_VERSION
CC=gcc-11 CXX=g++-11 make
sudo CC=gcc-11 CXX=g++-11 make install

# Add Verilator to your PATH
export PATH=/tools/verilator/$VERILATOR_VERSION/bin:$PATH
``` 

To run ASIC synthesis with OpenLane/OpenRoad in our paper, you need `sv2v` to
translate SystemVerilog source files to Verilog files. To install `sv2v`, you
can download the release from [sv2v
GitHub](https://github.com/zachjs/sv2v/releases/tag/v0.0.13) and move the
executable to your desired install directory, e.g., `/tools/sv2v/`. Then add
this to your `PATH`.

## Relevant Files
We propose 3 approaches for the new vector multiplication instruction:

- Version 1 reuses the multiplier in `BN-MAC` to support either 8 16x16-bit,
  4 32x32-bit or 1 64x64-bit multiplication(s) in one cycle.
- Version 2 also reuses the multiplier in `BN-MAC` but with a second accumulator
  register, called `ACCH`, to further support all 16 16x16-bit multiplications
  in one cycle.
- Version 3 is Version 2 but with a conditional subtraction unit added.

In software-related files, Version 1, 2 and 3 are denoted by `BNMULV_VER1`,
`BNMULV_VER2` and `BNMULV_VER3` respectively, or by `BNMULV_VER = {1,2,3}`.
In hardware-related files (RTL), all three versions are marked with `BNMULV`,
while Version 2 is further marked with `BNMULV_ACCH` and Version 3 is Version 2
with `BNMULV_COND_SUB`.

The encoding and definition of our multiplication is defined in the following
files:
- `hw/ip/otbn/data/enc-schemes-bnmulv.yml`: This file contains the encoding for
  our multiplication.
- `hw/ip/otbn/data/bignum-insns-ver{1,2,3}.yml`: These files contains the
  definitions of our multipliation for the corresponding version.
- `hw/ip/otbn/data/insn-ver{1,2,3}.yml`: These file make sure that the correct
  `bignum-insns-ver{1,2,3}.yml` is seen by the OTBN assembler.
- `hw/ip/otbn/dv/otbnsim/sim/insn-ver{1,2,3}.py`: These files contains the
    Python semantics of the new multiplication.

The assembly codes for ML-KEM and ML-DSA for each `BNMULV_VER` are found in
`sw/otbn/crypto/{mlkem, mldsa}_ver{1,2,3}` respectively.

Note that if all the files/folders mentioned above are not tagged with `_ver*`,
they are for the baseline implementations from Towards ML-KEM and ML-DSA on
OpenTitan paper.

From hardware side, we provide these new RTL modules under
`hw/ip/otbn/rtl/bn_vec_core/`:
- `buffer_bit.sv`: Vector Carry Propagate Adder (CPA) with buffer bits added for
  killing the carries or propagating them to the next vector element. This
  module can do addition and subtraction.
- `brent_kung_adder_256.sv`: Vector Brent-Kung Adder.
- `sklansky_adder_256.sv`: Vector Sklansky Adder.
- `kogge_stone_adder_256.sv`: Vector Kogge-Stone Adder.
  <!-- TODO: mention `_double.sv` files if we don't merge it with normal version. -->

## Software
### Benchmarking software
Software benchmarking of ML-KEM and ML-DSA are done with `otbn_sim_py_test`
bazel rule, which feeds a same random input generated in Python to both Python
reference implementation (by Giacomo Pope) and OTBN implementation, then
compares their results. For each `otbn_sim_py_test` target, it can be run for
`ITERATIONS` number of iterations, which is found in
`sw/otbn/crypto/tests/{mlkem,mldsa}/{kyberpy,dilithiumpy}_bench_otbn/bench_{kyber,dilithium}.py`.
In the same file, you can change `NPROC` to define the number of threads. The
results obtained here can be found in the paper at **Table ?** and **Table ?**.
<!-- TODO: Add ML-KEM/ML-DSA performance table -->

Now to run the test, execute the following command:

For ML-DSA:
```
./bazelisk.sh test --test_timeout=10000 --cache_test_results=no --sandbox_writable_path="/home/dev/src/"
//sw/otbn/crypto/tests/mldsa:mldsa{44,65,87}_{keypair,sign,verify}_bench{_ver1,ver2,ver3}
```

For ML-KEM:
```
./bazelisk.sh test --test_timeout=10000 --cache_test_results=no --sandbox_writable_path="/home/dev/src/"
//sw/otbn/crypto/tests/mlkem:mlkem{512,768,1024}_{keypair,encap,decap}_bench{_ver1,ver2,ver3}
```

Without passing in the tag `ver*`, you are benchmarking the baseline
implementations.

### Running fixed-input tests
We also provide a fixed-input test with `otbn_sim_test` rule. To run these test,
execute the following command.

For ML-DSA with new multiplication instruction:
```
./bazelisk.sh test --test_output=streamed --cache_test_results=no
//sw/otbn/crypto/tests/mldsa:mldsa{44,65,87}_{keypair,sign,verify}_test_ver{1,2,3}
```

For baseline ML-DSA:
```
./bazelisk.sh test --test_output=streamed --cache_test_results=no
//sw/otbn/crypto/tests/mldsa:dilithium{2,3,5}_{keypair,sign,verify}_test
```

For ML-KEM with new multiplication instruction:
```
./bazelisk.sh test --test_output=streamed --cache_test_results=no
//sw/otbn/crypto/tests/mlkem:mlkem{512,768,1024}_{keypair,encap,decap}_test_ver{1,2,3}
```

For baseline ML-KEM:
```
./bazelisk.sh test --test_output=streamed --cache_test_results=no
//sw/otbn/crypto/tests/mlkem:kyber{512,768,1024}_mlkem_{keypair,enc,dec}_test
```

### Running all software tests
To run all the tests available for ML-{KEM,DSA}, run:
```
./bazelisk.sh test //sw/otbn/crypto/tests/mldsa:*
./bazelisk.sh test //sw/otbn/crypto/tests/mlkem:*
```

## Hardware
### Obtaining hardware synthesis results
<!-- Synthesis on CW310 with Vivado -->
<!-- TODO: List fusesoc command -->
<!-- TODO: List Vivado synth target for CW310 -->
<!-- TODO: List Vivado command to synthesize the results -->
<!-- TODO: Mention which tables in the paper correspond to these results -->

<!-- Synthesis using resources.py -->
<!-- TODO: Show how to use the script -->
<!-- TODO: Mention which tables in the paper correspond to these results -->

<!-- Synthesis with OpenLane/OpenROAD -->
<!-- TODO: With Sky130 -->
<!-- TODO: With ASAP7 PDK -->
<!-- TODO: Mention which tables in the paper correspond to these results -->
ASIC synthesis with OpenLane/OpenRoad is integrated into our bazel workflow.
Bazel will download the docker container of OpenLane/OpenRoad and synthesize the
design. In order to run this flow, you need to be able to run `docker` without
root permission. This can be done by:
```
 sudo gpasswd -a $USER docker
```
Then you may have to restart your PC for this to take effect. After this, you're
set to run our ASIC flow with:
```
./bazelisk.sh build //hw/ip/otbn:otbn_alu_bignum_VER2_sky130hd_all_results
```
<!-- TODO: Update targets -->

<!-- Synthesis with Cadence Genus -->
<!-- TODO: Mention which tables in the paper correspond to these results -->

<!-- TODO: Mention how to choose which adder to be used -->
### Verifying new RTL modules with cocotb
We provide cocotb tests, which simulate the RTL and compare the result with
reference Python implementation, for our new modules. In `hw/ip/otbn/rtl/`, run:
```
pytest test/bnmulv_ver{1,2,3}/TEST_NAME
```
<!-- TODO: Merge all bnmulv_ver* folders -->

### Running RTL-ISS tests
OpenTitan provides an RTL-ISS test for OTBN. This test simulates the OTBN
`otbn_top_sim` with Verilator while running the Python simulator at the same
time, and checks if the RTL trace matches that of the ISS for every cycle. There
are four scripts for this test under `hw/ip/otbn/dv/smoke/`:
- `run_smoke.sh`: This is given by OpenTitan team to verify their base
  instructions.
- `run_smoke_isaext.sh`: This is given by Towards paper team to verify their
  ISAEXT including `bn.addv(m)`, `bn.subv(m)`, `bn.shv` and `bn.trn{1,2}`.
- `run_smoke_bnmulv.sh`: This is our script for running RTL-ISS test for all
  variants of the new multiplication instruction.
- `run_pqc.sh`: This is our script for running RTL-ISS test for full-scheme
  ML-KEM and ML-DSA.

For the original script, you can run:
```
hw/ip/otbn/dv/smoke/run_smoke.sh
```

An example for running one of the other three scripts is:
```
hw/ip/otbn/dv/smoke/run_pqc.sh -v {1,2,3} [-s] [-l] [-t TARGET]
```
`-v` specifies the `BNMULV_VER` to simulate the RTL with, `-s` is optional for
skipping Verilator simulation step (e.g., when you already built it before),
`-l` for listing all supported bazel targets for this script and `-t` for
specifying a particular target that you want to test (otherwise, all targets will
be tested).

For further information, use `-h`:
```
hw/ip/otbn/dv/smoke/run_{smoke_isaext,smoke_bnmulv,pqc}.sh -h
```

You can also run the RTL-ISS manually with the following commands:
```
# Produce binary file for testing
hw/ip/otbn/util/otbn_as.py --bnmulv_version_id={0,1,2,3} -o test.o test.s
hw/ip/otbn/util/otbn_ld.py -o test.elf test.o

# Build Verilator simulation with fusesoc
fusesoc --core-root=. run --target=sim --setup --build --flag bnmulv_ver{1,2,3} \
--mapping=lowrisc:prim_generic:all:0.1 lowrisc:ip:otbn_top_sim

# Start the simulation
./build/lowrisc_ip_otbn_top_sim_0.1/sim-verilator/Votbn_top_sim --load-elf=test.elf
```

Note that `--flag bnmulv_ver{1,2,3}` can be removed if you want to simulate the
baseline OTBN. Also note that the default adder chosen for `BN-ALU` is our
buffer-bit adder. To switch to baseline adder, add `--flag old_adder` in the
above command.
<!-- TODO: mention flags for different adders -->

If you want to run the full-scheme ML-{KEM,DSA} test manually, you need to
build the binaries from `otbn_binary` targets defined in
`sw/otbn/crypto/tests/{mlkem,mldsa}/BUILD` as follows for example:
```
./bazelisk.sh build --copt="-DRTL_ISS_TEST" //sw/otbn/crypto/tests/mlkem:otbn_mlkem512_keypair_test
```

### Running Top Earlgrey Chip-level Tests
We also provide chip-level tests for ML-KEM and ML-DSA on `top_earlgrey`. Ibex
will run C-reference implementations of
[Kyber](https://github.com/pq-crystals/kyber) and
[Dilithium](https://github.com/pq-crystals/dilithium) from
[pq-crystals](https://pq-crystals.org/) and commands OTBN to run ML-KEM and
ML-DSA with the same inputs. The results read from OTBN will then be compared
with those of the reference ones. This test can either be run with Verilator
simulation or with our provided bitstreams for CW310.
<!-- TODO: Generate bitstreams for CW340 -->
#### With Verilator
For ML-DSA:
```
./bazelisk.sh test --test_output=streamed --test_timeout=10000 \
--copt="-DBNMULV_VER={1,2,3}" --copt="-DDILITHIUM_MODE={2,3,5}" \
//sw/device/tests:otbn_mldsa_test_sim_verilator_ver{1,2,3}
```

For ML-DSA:
```
./bazelisk.sh test --test_output=streamed --test_timeout=10000 \
--copt="-DBNMULV_VER={1,2,3}" --copt="-DKYBER_K={2,3,4}" \
//sw/device/tests:otbn_mldsa_test_sim_verilator_ver{1,2,3}
```
Note that the version in `sim_verilator_ver*` must match the
`--copt="-DBNMULV_VER*`. 

#### With FPGA
For setting up the FPGA (CW310/CW340), please see [OpenTitan's guide](https://opentitan.org/book/doc/getting_started/setup_fpga.html#connecting-chipwhisperer-fpga-and-hyperdebug-boards-to-your-pc).
<!-- TODO: Mention setting up --interface -->
To load the btistream onto the FPGA, run:
```
./bazelisk.sh run //sw/host/opentitantool -- fpga load-bitstream \
hw/top_earlgrey/bitstream_{cw310,cw340}/bnmulv_ver{1,2,3}/lowrisc_systems_chip_earlgrey_{cw310,cw340}_0.1.bit
```
To run ML-KEM chip-level tests with this bitstream:
```
./bazelisk.sh test --define bitstream=skip --test_output=streamed \
--copt="-DKYBER_K={2,3,4}" --copt="-DBNMULV_VER={1,2,3}" \
//sw/device/tests:otbn_mlkem_test_fpga_{cw310,cw340}_test_rom_ver{1,2,3}
```
To run ML-KEM chip-level tests with this bitstream:
```
./bazelisk.sh test --define bitstream=skip --test_output=streamed \
--copt="-DDILITHIUM_MODE={2,3,5}" --copt="-DBNMULV_VER={1,2,3}" \
//sw/device/tests:otbn_mldsa_test_fpga_{cw310,cw340}_test_rom_ver{1,2,3}
```
Note that by loading the bitstream onto the FPGA before running the tests, the
version in the tag `_fpga_cw310_test_rom_ver*` does not have to match that in
`--copt`. These two must only match if we pass `--define bitstream=vivado`
instead of `--define bitstream=skip` to build the bitstream directly in the
bazel test command (which means the bitstream does not have to be pre-loaded onto
the FPGA).
