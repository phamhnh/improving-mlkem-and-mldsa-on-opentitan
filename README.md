# Improving ML-KEM and ML-DSA on OpenTitan - Efficient Multiplication Vector Instructions for OTBN

## About this repository

This repository is the artifact of the paper **Improving ML-KEM and ML-DSA on
OpenTitan - Efficient Multiplication Vector Instructions for OTBN** which
contains changes to the hardware design as well as the Python simulator to
support our proposed vector multiplication instructions for OTBN. In the
following, we will give a description to guide the readers on how to reproduce
the results presented in our paper.

## Getting Started
For setting up testing environment, please follow the
[OpenTitan's official guide](https://opentitan.org/book/doc/getting_started/index.html).

In case you are also using Python virtual environment, we recommend using
Python 3.10. Then run:
```
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -U pip "setuptools<66.0.0"
pip3 install -r python-requirements.txt --require-hashes
```

You also need Verilator with version 5.022:
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

To run ASIC synthesis with OpenRoad in our paper, you need `sv2v` to
translate SystemVerilog source files to Verilog files, which can be downloaded
at [sv2v GitHub](https://github.com/zachjs/sv2v/releases/tag/v0.0.13). Then you
need to move the executable to your desired install directory, e.g.,
`/tools/sv2v/` and add it to your `PATH`.

## Software

In order to get the software testing environment working properly, please run the following command:
```
./bazelisk test //sw/otbn/crypto/tests:sha3_shake_test
```
This will trigger Bazel to load the docker container for Bazel-ORFS flow, which
needs Python 3.13. Then this test will fail due to Python 3.13 is not compatible
with software flow. Then you need to change Python version in `third_party/python/python.MODULE.bazel` to 3.10, instead of 3.13. Now, software tests can be run without errors.

### Benchmarking software (Table 4, 5 and 6)

Software benchmarking of ML-KEM and ML-DSA are done with `otbn_sim_py_test`
Bazel rule, which feeds a same random input generated in Python to both Python
reference implementation (by Giacomo Pope, for
[ML-KEM](https://github.com/GiacomoPope/kyber-py) and
[ML-DSA](https://github.com/GiacomoPope/dilithium-py)) and OTBN implementation,
then compares their results. For each `otbn_sim_py_test` target, it can be run
for `ITERATIONS` number of iterations with `N_PROC` number of threads, which is
found in
`sw/otbn/crypto/tests/{mlkem,mldsa}/{kyberpy,dilithiumpy}_bench_otbn/bench_{kyber,dilithium}.py`.

There are four software versions for ML-KEM and ML-DSA:
- `ver0_base`: base implementations with KMAC interface and without ISE from
  [Towards ML-KEM and ML-DSA on
  OpenTitan](https://eprint.iacr.org/2024/1192.pdf).
- `ver0`: implementations with KMAC interface and with ISE (multi-cycle
  multiplication approach) from [Towards ML-KEM and ML-DSA on
  OpenTitan](https://eprint.iacr.org/2024/1192.pdf).
- `ver1`: our implementations with Variant 1 (OTBNV1) of the new multiplication vector instruction.
- `ver2`: our implementations with Variant 2 (OTBNV2) of the new multiplication vector instruction.
- `ver3`: our implementations with Variant 3 (OTBNV3) of the new multiplication vector instruction.

The results obtained in the following commands are the software benchmark of
ML-KEM and ML-DSA in Table 6 in our paper:

For ML-DSA:
```
./bazelisk.sh test --test_timeout=10000 --cache_test_results=no 
--action_env=PATH --sandbox_writable_path="path/to/this/repo" 
//sw/otbn/crypto/tests/mldsa:mldsa{44,65,87}_{keypair,sign,verify}_bench_{ver0_base,ver0,ver1,ver2,ver3}
```

For ML-KEM:
```
./bazelisk.sh test --test_timeout=10000 --cache_test_results=no 
--action_env=PATH --sandbox_writable_path="path/to/this/repo" 
//sw/otbn/crypto/tests/mlkem:mlkem{512,768,1024}_{keypair,encap,decap}_bench_{ver0_base,ver0,ver1,ver2,ver3}
```

The commands above will log the results to a DB file (`mldsa_bench.db` and
`mlkem_bench.db`). We also provide a script to parse the results in the DB
files, in which numbers for NTT, INTT, (pair-)pointwise and ciphertext packing
can be found. In the followings, `start` is the start row of your benchmarked
target in the DB and `end` is the end row of your benchmarked target in the DB.

```
util/get_benchmark.py -f mldsa_bench.db -o mldsa_eval.txt -i start end --scheme mldsa
util/get_benchmark.py -f mlkem_bench.db -o mlkem_eval.txt -i start end --scheme mldsa
```

### Running fixed-input tests

We also provide fixed-input tests for fast testing with `otbn_sim_test` rule. To run these test,
execute the following commands:

For ML-DSA:
```
./bazelisk.sh test --test_output=streamed --cache_test_results=no
--action_env=PATH --sandbox_writable_path="path/to/this/repo"
//sw/otbn/crypto/tests/mldsa:mldsa{44,65,87}_{keypair,sign,verify}_test_{ver0_base,ver0,ver1,ver2,ver3}
```

For ML-KEM:
```
./bazelisk.sh test --test_output=streamed --cache_test_results=no
--action_env=PATH --sandbox_writable_path="path/to/this/repo"
//sw/otbn/crypto/tests/mlkem:mlkem{512,768,1024}_{keypair,encap,decap}_test_{ver0_base,ver1,ver2,ver3}
```

### Running all software tests

To run all the tests available for ML-{KEM,DSA}, you can execute the following commands:
```
./bazelisk.sh test //sw/otbn/crypto/tests/mldsa:*
./bazelisk.sh test //sw/otbn/crypto/tests/mlkem:*
```

### Obtaining code size (Table 7)

The code size numbers in Table 7 can be obtained with the following command:
```
util/get_codesize.py --mlkem --mldsa --compare
```

In case you want to obtain the code size manually, Bazel binary targets for code
size are:
- `otbn_mlkem{512,768,1024}_code_size_{ver0_base,ver0,ver1,ver2,ver3}`
- `otbn_mldsa{44,65,87}_code_size_{ver0_base,ver0,ver1,ver2,ver3}`

And you need to run the following, for example:
```
./bazelisk.sh build //sw/otbn/crypto/tests/mlkem:otbn_mlkem512_code_size_ver1
size bazel-bin/sw/otbn/crypto/tests/mlkem/otbn_mlkem512_code_size_ver1.elf
```
## Hardware

To obtain ASIC numbers with ORFS flow, please change Python version in
`third_party/python/python.MODULE.bazel` back to 3.13 if you run software tests
before this.

### Obtaining hardware synthesis results (Table 1, 2 and 3)

ASIC synthesis with OpenRoad is integrated into our Bazel workflow.
Bazel will download the docker container of OpenRoad and synthesize the
design. In order to run this flow, you need to be able to run `docker` without
root permission. This can be done by:
```
 sudo gpasswd -a $USER docker
```
Then you may have to restart your PC for this to take effect. After this, you're
set to run our script to get the results in Table 1, 2 and 3.

If you want to synthesize the designs with a specific tool (Vivado, Genus or ORFS),
add `--tool={Vivao,Genus,ORFS}`. If you want to synthesize with all the tools,
use `--tool=all`. The results are in `reports/FPGA-Vivado`, `reports/ASIC-Genus`
and `reports/ASIC-ORFS`.

To obtain synthesis numbers for the multiplier (Table 1):
```
./gen_tables.py --run_synthesis --tool={all,Vivado,ORFS,Genus} --mul
```

To obtain synthesis numbers for the adders (Table 2):
```
./gen_tables.py --run_synthesis --tool={all,Vivado,ORFS,Genus} --adders
```

To obtain synthesis numbers for BN-ALU, BN-MAC and OTBN (Table 3):
```
./gen_tables.py --run_synthesis --tool={all,Vivado,ORFS,Genus} --otbn_sub
./gen_tables.py --run_synthesis --tool={all,Vivado,ORFS,Genus} --otbn
```

### Verifying new RTL modules with cocotb and pytest

We provide cocotb tests, which simulate the RTL with Verilator and compare the
result with reference Python implementation, for our new modules.
There are three test `TARGET`:
- `test/test_vector_adder_pytest.py`: test all vectorized adders mentioned in our paper.
- `test/test_non_vector_adder_pytest.py`: test all non-vectorized adders mentioned in our paper.
- `test/test_unified_mul_pytest.py`: test our vectorized multiplier.

In `hw/ip/otbn/rtl/`, run:
```
pytest TARGET
```

### Running Top Earlgrey chip-level tests

We also provide chip-level tests for ML-KEM and ML-DSA on `top_earlgrey`. Ibex
will run C-reference implementations of
[Kyber](https://github.com/pq-crystals/kyber) and
[Dilithium](https://github.com/pq-crystals/dilithium) from
[pq-crystals](https://pq-crystals.org/) and commands OTBN to run ML-KEM and
ML-DSA with the same inputs. The results read from OTBN will then be compared
with those of the reference ones. This test can either be run with Verilator
simulation or with our provided bitstreams for CW310.

#### With Verilator

For ML-DSA:
```
./bazelisk.sh test --test_output=streamed --test_timeout=10000 --action_env=PATH 
--copt="-DBNMULV_VER={1,2,3}" --copt="-DDILITHIUM_MODE={2,3,5}" 
//sw/device/tests:otbn_mldsa_test_sim_verilator_ver{1,2,3}
```

For ML-KEM:
```
./bazelisk.sh test --test_output=streamed --test_timeout=10000 --action_env=PATH
--copt="-DBNMULV_VER={1,2,3}" --copt="-DKYBER_K={2,3,4}" 
//sw/device/tests:otbn_mlkem_test_sim_verilator_ver{1,2,3}
```

Note that the version in `sim_verilator_ver*` must match the
`--copt="-DBNMULV_VER*`. 

#### With FPGA

For setting up the FPGA board ChipWhisperer CW310, please see [OpenTitan's
guide](https://opentitan.org/book/doc/getting_started/setup_fpga.html#connecting-chipwhisperer-fpga-and-hyperdebug-boards-to-your-pc).

We provide bitstreams for the two hardware variants OTBNV1 and OTBNV2 in the
paper. In both variants, buffer-bit adder is set as the adder in both BN-ALU and
BN-MAC.

To load the bitstream onto the FPGA, run:
```
./bazelisk.sh run //sw/host/opentitantool -- fpga load-bitstream 
hw/top_earlgrey/bitstream_cw310/bnmulv_ver{1,2,3}/lowrisc_systems_chip_earlgrey_cw310_0.1.bit
```

To run ML-KEM chip-level tests with this bitstream:
```
./bazelisk.sh test --define bitstream=skip --test_output=streamed --action_env=PATH
--copt="-DKYBER_K={2,3,4}" --copt="-DBNMULV_VER={1,2,3}" 
//sw/device/tests:otbn_mlkem_test_fpga_cw310_test_rom_ver{1,2,3}
```

To run ML-DSA chip-level tests with this bitstream:
```
./bazelisk.sh test --define bitstream=skip --test_output=streamed --action_env=PATH
--copt="-DDILITHIUM_MODE={2,3,5}" --copt="-DBNMULV_VER={1,2,3}" 
//sw/device/tests:otbn_mldsa_test_fpga_cw310_test_rom_ver{1,2,3}
```

Note that by loading the bitstream onto the FPGA before running the tests, the
version in the tag `_fpga_cw310_test_rom_ver*` does not have to match that in
`--copt`. These two must only match if we pass `--define bitstream=vivado`
instead of `--define bitstream=skip` to build the bitstream directly in the
Bazel test command (which means the bitstream does not have to be pre-loaded onto
the FPGA).
