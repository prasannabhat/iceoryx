#!/bin/bash

# Copyright (c) 2019-2020 by Robert Bosch GmbH. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This file runs all tests for Ice0ryx

COMPONENTS="utils posh binding_c"
GTEST_FILTER="*"
BASE_DIR=$PWD
GCOV_SCOPE="all"
CONTINUE_ON_ERROR=false

for arg in "$@"
do 
    case "$arg" in
        "with-dds-gateway-tests")
            COMPONENTS="utils posh dds_gateway"
            ;;
        "disable-timing-tests")
            GTEST_FILTER="-*.TimingTest_*"
            ;;
        "only-timing-tests")
            GTEST_FILTER="*.TimingTest_*"
            ;;
        "continue-on-error")
            CONTINUE_ON_ERROR=true
            ;;
        "all" | "component" | "unit" | "integration")
            GCOV_SCOPE="$arg"
            ;;
        *)
            echo ""
            echo "Test script for iceoryx."
            echo "By default all module-, integration- and componenttests are executed."
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "      skip-dds-tests              Skips tests for iceoryx_dds"
            echo "      disable-timing-tests        Disables all timing tests"
            echo "      only-timing-tests           Runs only timing tests"
            echo "      continue-on-error           Continue execution upon error"
            echo ""
            exit -1
            ;;
    esac
done 

# check if this script is sourced by another script,
# if yes then exit properly, so the other script can use this
# scripts definitions
[[ "${#BASH_SOURCE[@]}" -gt "1" ]] && { return 0; }

if [ -z "$TEST_RESULTS_DIR" ]
then
    TEST_RESULTS_DIR="$(pwd)/testresults"
fi

mkdir -p "$TEST_RESULTS_DIR"

echo ">>>>>> Running Ice0ryx Tests <<<<<<"

if [ $CONTINUE_ON_ERROR == false ]
then
    set -e
fi



test_result=0
for COMPONENT in $COMPONENTS; do
    echo ""
    echo "######################## executing moduletests & componenttests for $COMPONENT ########################"
    cd $BASE_DIR/$COMPONENT/test

    # Runs only tests available for the given component

    case $GCOV_SCOPE in    
        "unit" | "all")
            [ -f ./"$COMPONENT"_moduletests ] && ./"$COMPONENT"_moduletests --gtest_filter="${GTEST_FILTER}" --gtest_output="xml:$TEST_RESULTS_DIR/"$COMPONENT"_ModuleTestResults.xml"
            test_status=$?
            echo "Test status is $test_status"
            ;;
        "component" | "all")
            [ -f ./"$COMPONENT"_componenttests ] && ./"$COMPONENT"_componenttests --gtest_filter="${GTEST_FILTER}" --gtest_output="xml:$TEST_RESULTS_DIR/"$COMPONENT"_ComponenttestTestResults.xml"
            test_status=$?
            echo "Test status is $test_status"
            ;;
        "integration" | "all") 
            [ -f ./"$COMPONENT"_integrationtests ] && ./"$COMPONENT"_integrationtests --gtest_filter="${GTEST_FILTER}" --gtest_output="xml:$TEST_RESULTS_DIR/"$COMPONENT"_IntegrationTestResults.xml"
            test_status=$?
            echo "Test status is $test_status"
            ;;
    esac
done

# do not start RouDi while the module and componenttests are running;
# they might do things which hurts RouDi, like in the roudi_shm test where named semaphores are opened and closed

if [ $test_result != 0 ]
then
    echo "Not all the tests passed !"
fi
echo "test result is $test_result"
echo ">>>>>> Finished Running Iceoryx Tests <<<<<<"


