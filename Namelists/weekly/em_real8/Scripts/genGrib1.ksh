#!/bin/ksh

# Usage:  genGrib1.ksh <wrf_namelist_file> 
#
#  Takes an existing WRF namelist file and outputs a new one with GRIB1 output turned on.
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


grep io_form_history  $inputFile  | egrep '[0-9]'   > /dev/null 2>&1
found="( $? -eq 0 )" 
if [ ! $found ]; then
   echo "$0:  Namelist does not contain 'io_form_history = <digit>'"
   exit 1
fi

#grep moist_adv_opt  $inputFile  | grep 1   > /dev/null 2>&1
#found="( $? -eq 0 )" 
#if [ ! $found ]; then
#   echo "$0:  Namelist does not contain 'moist_adv_opt = 1'"
#   exit 1
#fi



# Change the two existing parameter values. 
sed -e '/io_form_history/s/[0-9]/5/' \
    $inputFile 

#    -e '/moist_adv_opt/s/1/1/' \


