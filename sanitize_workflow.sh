#!/bin/bash

set -e

./tools/iceoryx_build_test.sh clean clang sanitize
cd build
../tools/run_all_tests.sh 2>&1 | tee test_log.txt
code test_log.txt

