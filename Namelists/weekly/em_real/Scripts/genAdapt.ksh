#!/bin/ksh

# Usage:  genAdapt.ksh <wrf_namelist_file> 
#
#  Takes an existing WRF namelist file and outputs a new one with adaptive time stepping turned on. 
#  Output should be redirected to a new file with a slightly modified name. 
# 

if [ $# -ne 1 ]; then
   echo "Usage: $0 <wrf_namelist_file>" 
   exit 1
fi 

inputFile=$1

if [ ! -f $inputFile ]; then
   echo "$0: namelist file does not exist: $inputFile"
   exit 1
fi


grep use_adaptive_time_step  $inputFile  | grep -i FALSE > /dev/null 2>&1 
found1="( $? -eq 0 )" 
if [ ! $found1 ]; then
   echo "$0:  Namelist does not contain 'use_adaptive_time_step = .FALSE.'"
   exit 1
fi

grep step_to_output_time  $inputFile | grep -i FALSE > /dev/null 2>&1
found2="( $? -eq 0 )" 
if [ ! $found2 ]; then
   echo "$0:  Namelist does not contain 'step_to_output_time = .FALSE.'"
   exit 1
fi


# Set the two existing parameters from FALSE to TRUE. 
sed -e '/use_adaptive_time_step/s/FALSE/TRUE/' \
    -e '/step_to_output_time/s/FALSE/TRUE/' \
    $inputFile 

