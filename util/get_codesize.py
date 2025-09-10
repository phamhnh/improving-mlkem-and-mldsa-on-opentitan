#!/usr/bin/env python3

import sys
import re
import argparse
import subprocess
import time
from datetime import datetime
from pathlib import Path
from itertools import islice
from tqdm import tqdm

STACK_SIZE_MLKEM = 20000
STACK_SIZE_MLDSA = 112000

MLKEM512_CRYPTO_PUBLICKEYBYTES = 800
MLKEM512_CRYPTO_SECRETKEYBYTES = 1632
MLKEM512_CRYPTO_CIPHERTEXTBYTES = 768
MLKEM768_CRYPTO_PUBLICKEYBYTES = 1184
MLKEM768_CRYPTO_SECRETKEYBYTES = 2400
MLKEM768_CRYPTO_CIPHERTEXTBYTES = 1088
MLKEM1024_CRYPTO_PUBLICKEYBYTES = 1568
MLKEM1024_CRYPTO_SECRETKEYBYTES = 3168
MLKEM1024_CRYPTO_CIPHERTEXTBYTES = 1568
MLKEM_CRYPTO_BYTE = 32
MLKEM_COINS_KEYPAIR_BYTES = 64
MLKEM_COINS_ENCAP_BYTES = 32
MLKEM_IO_CONST = MLKEM_CRYPTO_BYTE*2 + MLKEM_COINS_KEYPAIR_BYTES + MLKEM_COINS_ENCAP_BYTES

MLDSA44_CRYPTO_PUBLICKEYBYTES = 1312
MLDSA44_CRYPTO_SECRETKEYBYTES = 2560
MLDSA44_CRYPTO_BYTES = 2420 + 12 # for 32B alignment
MLDSA65_CRYPTO_PUBLICKEYBYTES = 1952
MLDSA65_CRYPTO_SECRETKEYBYTES = 4032
MLDSA65_CRYPTO_BYTES = 3309 + 19 # for 32B alignment
MLDSA87_CRYPTO_PUBLICKEYBYTES = 2592
MLDSA87_CRYPTO_SECRETKEYBYTES = 4896
MLDSA87_CRYPTO_BYTES = 4627 + 13 # for 32B alignment
MLDSA_MSG_BYTES = 3196 + 4 # for 32B alignment
MLDSA_CTX_BYTES = 32
MLDSA_ZETA_BYTES = 32
MLDSA_RESULT_BYTES = 32
MLDSA_IO_CONST = MLDSA_MSG_BYTES + MLDSA_CTX_BYTES + MLDSA_ZETA_BYTES + MLDSA_RESULT_BYTES

def elf_build(target):
    """Create elf file name from test target name
    """
    test_elf = target.replace(':', '/')
    test_elf = test_elf.replace('//', 'bazel-bin/')
    test_elf = test_elf + '.elf'

    return test_elf


def print_info(s):
    """Print info or error message
    """
    s_split = s.split(':', 1)
    if s_split[0] == 'ERROR':
        s_split[0] = f'\033[1;31m{s_split[0]}\033[0m'
    if s_split[0] == 'INFO':
        s_split[0] = f'\033[1;32m{s_split[0]}\033[0m'
    s_split[1] = f'\033[1m{s_split[1]}\033[0m'

    info = ': '.join(s_split)
    print(info)


def target_list(scheme, verbose):
    """List supported test targets
    """
    targets = []
    query_cmd = (
        "./bazelisk.sh query 'filter(.*_code_size_ver0, "
        f"kind(otbn_binary, //sw/otbn/crypto/tests/{scheme}/...))' "
        "&& "
        "./bazelisk.sh query 'filter(.*_code_size_ver1, "
        f"kind(otbn_binary, //sw/otbn/crypto/tests/{scheme}/...))' "
        "&& "
        "./bazelisk.sh query 'filter(.*_code_size_ver2, "
        f"kind(otbn_binary, //sw/otbn/crypto/tests/{scheme}/...))' "
        "&& "
        "./bazelisk.sh query 'filter(.*_code_size_ver3, "
        f"kind(otbn_binary, //sw/otbn/crypto/tests/{scheme}/...))' "
    )

    if verbose:
        print_info(f'INFO: {query_cmd}')
    results = \
        subprocess.run(query_cmd, stdout=subprocess.PIPE, text=True, shell=True, check=True)
    targets = results.stdout.strip().split('\n')
    targets = sorted(targets, key=lambda x: int(re.search(r'\d+', x).group()))

    return targets


def dict_print(cs):
    """Pretty-print a dictionary
    """
    max_len_keys = max(len(k) for k in cs.keys())
    n = 20
    for k, v in cs.items():
        line = f'{k.ljust(max_len_keys)} :'
        for vi in v:
            line += f' {vi:<{n}}|'
        print(line)


def latex_print(cs, filename):
    """Export a .tex file including code size
    """
    # Check if file exists, otherwise create one in REPO_TOP
    filepath = Path(filename)
    if filepath.exists():
        print_info(f'INFO: {filename} exists and new data will be appended')
    else:
        print_info(f'INFO: {filename} does not exist and will be created')
        filepath.touch(exist_ok=True)

    # Remove first item
    del cs['TARGET']

    # This is specific for only two schemes: ML-KEM and ML-DSA.
    lines = (
        "%------------------- W A R N I N G: A U T O - G E N E R A T E D   F I L E !! -------------------%\n"
        "% PLEASE DO NOT HAND-EDIT THIS FILE. IT HAS BEEN AUTO-GENERATED WITH THE FOLLOWING COMMAND:\n"
        "%\n"
        "% util/get_codesize.py --mlkem --mldsa --output_latex --latex_filename = codesize.tex\n"
        "%\n"
        f"% Generated on {datetime.now().date()}.\n\n"
    )
    start = 0
    cs_len = len(cs)
    for i in range(start, start + cs_len, 4):
        if 'mldsa44' in list(cs.keys())[i]:
            scheme = 'ML-DSA-44'
        elif 'mldsa65' in list(cs.keys())[i]:
            scheme = 'ML-DSA-65'
        elif 'mldsa87' in list(cs.keys())[i]:
            scheme = 'ML-DSA-87'
        elif 'mlkem512' in list(cs.keys())[i]:
            scheme = 'ML-KEM-512'
        elif 'mlkem768' in list(cs.keys())[i]:
            scheme = 'ML-KEM-768'
        else: # 'mlkem1024' in list(cs.keys())[i]:
            scheme = 'ML-KEM-1024'
        lines += f'% {scheme} code size %\n'
        text_lines = ""
        const_lines = ""
        io_lines = ""
        imp_lines = ""
        for k, v in islice(cs.items(), i, i + 4):
            k_split = k.rsplit(':', 1)
            var_name = k_split[1].replace('_', '-')
            text_name = var_name + '-textsize'
            const_name = var_name + '-constsize'
            io_name = var_name + '-iosize'
            imp_name = var_name + '-spdup'
            text_lines += f'\\DefineVar{{{text_name}}}{{{v[0]}}}\n'
            const_lines += f'\\DefineVar{{{const_name}}}{{{v[2]}}}\n'
            io_lines += f'\\DefineVar{{{io_name}}}{{{v[3]}}}\n'
            imp_lines += f'\\DefineVar{{{imp_name}}}{{{v[1]}}}\n'
        lines += text_lines + '\n' + const_lines + '\n' + io_lines + '\n'
        lines += '% Text size improvement vs BNMULV_VER0: VERX/VER0 %\n'
        lines += imp_lines + '\n'
    start += 12

    with filepath.open("a") as f:
        f.write(lines)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Please provide at least one argument as follows to run this script (except -v)",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument(
        '-v', '--verbose',
        action="store_true",
        help=("Print out executed commands")
    )
    parser.add_argument(
        '--mlkem',
        action="store_true",
        help=("Get code size for all ML-KEM targets. Not used with --build_target")
    )
    parser.add_argument(
        '--mldsa',
        action="store_true",
        help=("Get code size for all ML-DSA targets. Not used with --build_target")
    )
    parser.add_argument(
        '--compare',
        action="store_true",
        help=("Give code size improvement of BNMULV_VER{1,2,3} vs BNMULV_VER0")
    )
    parser.add_argument(
        '-l', '--list_target',
        action="store_true",
        help=("List all supported build targets")
    )
    parser.add_argument(
        '--output_latex',
        action="store_true",
        help=("If given, output code size in a LaTex-formatted variables\n"
              "Must be used with --latex_filename")
    )
    parser.add_argument(
        '--latex_filename',
        type=str,
        metavar="LATEX_FILENAME",
        help=("Output file of --output_latex option. If file does not exist, it will be created\n"
              "Must be given with full path")
    )

    # Start timer
    start_time = time.perf_counter()

    args = parser.parse_args()

    verbose = args.verbose

    # If --mlkem or --mldsa is not given, abort
    if not args.mlkem and not args.mldsa:
        print_info('ERROR: Please provide at least one of --mlkem or --mldsa')
        return 1

    # Abort if --output_latex is given without --latex_filename
    if args.output_latex and not args.latex_filename:
        print_info('ERROR: --output_latex must be used with --latex_filename')
        return 1

    # List supported targets
    targets = []
    if args.mlkem:
        targets += target_list('mlkem', verbose)
    if args.mldsa:
        targets += target_list('mldsa', verbose)

    if args.list_target:
        print_info('INFO: List supported targets')
        print('\n'.join(targets))
        return 0

    # Compute IO_SIZE
    mlkem512_io_size = MLKEM512_CRYPTO_PUBLICKEYBYTES + MLKEM512_CRYPTO_SECRETKEYBYTES + \
        MLKEM512_CRYPTO_CIPHERTEXTBYTES + MLKEM_IO_CONST
    mlkem768_io_size = MLKEM768_CRYPTO_PUBLICKEYBYTES + MLKEM768_CRYPTO_SECRETKEYBYTES + \
        MLKEM768_CRYPTO_CIPHERTEXTBYTES + MLKEM_IO_CONST
    mlkem1024_io_size = MLKEM1024_CRYPTO_PUBLICKEYBYTES + MLKEM1024_CRYPTO_SECRETKEYBYTES + \
        MLKEM1024_CRYPTO_CIPHERTEXTBYTES + MLKEM_IO_CONST
    mldsa44_io_size = MLDSA44_CRYPTO_PUBLICKEYBYTES + MLDSA44_CRYPTO_SECRETKEYBYTES + \
        MLDSA44_CRYPTO_BYTES + MLDSA_IO_CONST
    mldsa65_io_size = MLDSA65_CRYPTO_PUBLICKEYBYTES + MLDSA65_CRYPTO_SECRETKEYBYTES + \
        MLDSA65_CRYPTO_BYTES + MLDSA_IO_CONST
    mldsa87_io_size = MLDSA87_CRYPTO_PUBLICKEYBYTES + MLDSA87_CRYPTO_SECRETKEYBYTES + \
        MLDSA87_CRYPTO_BYTES + MLDSA_IO_CONST

    # Build a bazel otbn_binary target, then run "size" for the "elf" file located in bazel-bin to
    # get code size.
    cs = {'TARGET': ['TEXT SIZE (bytes)', 'CONST_SIZE (bytes)', 'IO_SIZE (bytes)']}
    for target in tqdm(targets):
        # Run bazel build to obtain elf file in bazel-bin
        print_info(f'INFO: Get code size for {target}')
        cmd = f'./bazelisk.sh build {target}'
        if verbose:
            print_info(f'INFO: Running command {cmd}')
        subprocess.run(cmd, shell=True, check=True)

        # Run size command to get code size
        target_elf = elf_build(target)
        cmd = f'size {target_elf}'
        if verbose:
            print_info(f'INFO: Running command {cmd}')
        results = subprocess.run(cmd, stdout=subprocess.PIPE, text=True, shell=True, check=True)

        # Parse code size from stdout
        results_split = results.stdout.strip().split('\n')
        codesize = results_split[1].split('\t')
        codesize = [cs.strip() for cs in codesize[0:2]]

        # DATA_SIZE = CONST_SIZE + IO_SIZE + STACK_SIZE
        if 'mlkem512' in target:
            io_size = mlkem512_io_size
            const_size = int(codesize[1]) - io_size - STACK_SIZE_MLKEM
        elif 'mlkem768' in target:
            io_size = mlkem768_io_size
            const_size = int(codesize[1]) - io_size - STACK_SIZE_MLKEM
        elif 'mlkem1024' in target:
            io_size = mlkem1024_io_size
            const_size = int(codesize[1]) - io_size - STACK_SIZE_MLKEM
        elif 'mldsa44' in target:
            io_size = mldsa44_io_size
            const_size = int(codesize[1]) - io_size - STACK_SIZE_MLDSA
        elif 'mldsa65' in target:
            io_size = mldsa65_io_size
            const_size = int(codesize[1]) - io_size - STACK_SIZE_MLDSA
        else: # 'mldsa87' in target:
            io_size = mldsa87_io_size
            const_size = int(codesize[1]) - io_size - STACK_SIZE_MLDSA

        # Add code size to cs
        cs[target] = [int(codesize[0]), const_size, io_size]

    # Once done, sort cs based on security level
    value_hr = cs.pop('TARGET')
    cs_sorted = {'TARGET': value_hr}

    # Compare if given --compare
    if args.compare:
        cs_sorted['TARGET'].insert(1, 'VERX/VER0')
        cs_list = list(cs.items())
        cs_len = len(cs_list)
        for i in range(0, cs_len, 4):
            ki, vi = cs_list[i]
            vi.insert(1, 1.00)
            # Update cs_sorted
            cs[ki] = vi
            for j in range(i + 1, i + 4):
                kj, vj = cs_list[j]
                cs_vji = round((vj[0] / vi[0]), 2)
                vj.insert(1, cs_vji)
                # Update cs_sorted
                cs[kj] = vj

    # Update cs_sorted
    cs_sorted.update(cs)

    # Print out cs_sorted
    if not args.output_latex:
        print_info('INFO: Print out code size')
        dict_print(cs_sorted)
    else:
        print_info('INFO: Create LaTex file')
        latex_print(cs_sorted, args.latex_filename)

    # End timer
    end_time = time.perf_counter()
    elapsed = end_time - start_time
    print_info(f'INFO: Code size benchmarking done in {elapsed:.4f} seconds')
    return 0


if __name__ == "__main__":
    sys.exit(main())
