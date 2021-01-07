#!/bin/bash

set -e

BASE_DIR=$(git rev-parse --show-toplevel)

build_with_sanitizer() {
    ./tools/iceoryx_build_test.sh build-strict build-test clean sanitize clang
}

set_sanitizer_options () {

    echo "Project root is BASE_DIR"

    ASAN_OPTIONS=detect_leaks=1:detect_stack_use_after_return=1:detect_stack_use_after_scope=1:check_initialization_order=true:strict_init_order=true:new_delete_type_mismatch=0:suppressions=$BASE_DIR/sanitizer_blacklist/asan_runtime.txt
    export ASAN_OPTIONS
    LSAN_OPTIONS=suppressions=$BASE_DIR/sanitizer_blacklist/lsan_runtime.txt
    export LSAN_OPTIONS
    UBSAN_OPTIONS=print_stacktrace=1
    export UBSAN_OPTIONS

    echo "ASAN_OPTIONS : $ASAN_OPTIONS"
    echo "LSAN_OPTIONS : $LSAN_OPTIONS"
    echo "UBSAN_OPTIONS : $UBSAN_OPTIONS"
}

run_all_tests() {
    cd $BASE_DIR/build
    ../tools/run_all_tests.sh
}

echo "Rebuilding iceoryx with sanitizer options"
# build_with_sanitizer
# set_sanitizer_options
run_all_tests


exit 0

cd build
set_sanitizer_options
cd ..

# LeakSanitizer is enabled by default in ASan builds of x86_64 Linux, and can be enabled with ASAN_OPTIONS=detect_leaks=1 on x86_64 OS X
# PROJECT_ROOT=/home/pbt2kor/data/aos/repos/iceoryx_oss/iceoryx
# export ASAN_OPTIONS=suppressions=$PROJECT_ROOT/asan_extlib_suppress.txt
# export LSAN_OPTIONS=suppressions=$PROJECT_ROOT/iceoryx_meta/leaksanitizer_blacklist.txt

# export ASAN_SYMBOLIZER_PATH=llvm-symbolizer
# export ASAN_OPTIONS=detect_leaks=1
# export LSAN_OPTIONS=suppressions=$PROJECT_ROOT/leak_suppressions.txt

# echo $ASAN_OPTIONS
# echo $LSAN_OPTIONS
# cd build/binding_c/test
# ./binding_c_integrationtests 2>&1 | tee log_file_ignore.txt
# code log_file_ignore.txt
# cd ../../..

# cd build/utils/test
# ./utils_moduletests --gtest_filter="*sanitizer*" 2>&1  | tee log_func_ignore.txt
# code log_func_ignore.txt
# cd ../../..

# exit 0

# cd build/utils/test
# # ./utils_moduletests --gtest_filter="*expected_test*" 2>&1  | tee log_func_ignore.txt
# ./utils_moduletests 2>&1  | tee $PROJECT_ROOT/log.txt
# code $PROJECT_ROOT/log.txt
# cd ../../..


# cd build
# ../tools/run_all_tests.sh continue-on-error 2>&1 | tee $PROJECT_ROOT/log.txt
# code $PROJECT_ROOT/log.txt
# cd ..

# cd build/posh/test
# ./posh_integrationtests 2>&1  | tee log.txt
# # ./posh_moduletests 2>&1  | tee log.txt
# code log.txt
# cd ../../..

cd build/posh/test
./posh_moduletests  --gtest_filter="*PoshRuntime_test.ValidAppName*"
echo "Return  code is $?"
code log.txt
cd ../../..

exit 0

./tools/iceoryx_build_test.sh build-test sanitize clean

cd build
../tools/run_all_tests.sh 2>&1 | tee log.txt
code log.txt

# Summary
# - fsanitize=address enabled for iceoryx_utils
# - 