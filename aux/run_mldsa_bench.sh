SANDBOX_PATH=$PWD
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_keypair_bench_ver0_base
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_sign_bench_ver0_base
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_verify_bench_ver0_base
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_keypair_bench_ver0_base
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_sign_bench_ver0_base
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_verify_bench_ver0_base
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_keypair_bench_ver0_base
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_sign_bench_ver0_base
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_verify_bench_ver0_base

./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_keypair_bench_ver0
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_sign_bench_ver0
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_verify_bench_ver0
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_keypair_bench_ver0
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_sign_bench_ver0
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_verify_bench_ver0
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_keypair_bench_ver0
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_sign_bench_ver0
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_verify_bench_ver0

./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_keypair_bench_ver1_nold
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_sign_bench_ver1_nold
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_verify_bench_ver1_nold
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_keypair_bench_ver1_nold
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_sign_bench_ver1_nold
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_verify_bench_ver1_nold
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_keypair_bench_ver1_nold
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_sign_bench_ver1_nold
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_verify_bench_ver1_nold

./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_keypair_bench_ver1
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_sign_bench_ver1
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_verify_bench_ver1
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_keypair_bench_ver1
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_sign_bench_ver1
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_verify_bench_ver1
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_keypair_bench_ver1
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_sign_bench_ver1
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_verify_bench_ver1

./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_keypair_bench_ver2_nold
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_sign_bench_ver2_nold
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_verify_bench_ver2_nold
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_keypair_bench_ver2_nold
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_sign_bench_ver2_nold
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_verify_bench_ver2_nold
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_keypair_bench_ver2_nold
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_sign_bench_ver2_nold
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_verify_bench_ver2_nold

./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_keypair_bench_ver2
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_sign_bench_ver2
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_verify_bench_ver2
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_keypair_bench_ver2
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_sign_bench_ver2
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_verify_bench_ver2
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_keypair_bench_ver2
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_sign_bench_ver2
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_verify_bench_ver2

./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_keypair_bench_ver3
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_sign_bench_ver3
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa44_verify_bench_ver3
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_keypair_bench_ver3
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_sign_bench_ver3
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa65_verify_bench_ver3
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_keypair_bench_ver3
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_sign_bench_ver3
./bazelisk.sh test --cache_test_results=no --action_env=PATH --test_timeout=100000 --sandbox_writable_path="$SANDBOX_PATH" //sw/otbn/crypto/tests/mldsa:mldsa87_verify_bench_ver3
