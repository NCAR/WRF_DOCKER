#!/bin/ksh

# Usage:  genQuilt.ksh <wrf_namelist_file> 
#
#  Takes an existing WRF namelist file and outputs a new one with output quilting turned on.
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


grep nio_tasks_per_group  $inputFile  | grep 0   > /dev/null 2>&1
found="( $? -eq 0 )" 
if [ ! $found ]; then
   echo "$0:  Namelist does not contain 'nio_tasks_per_group = 0'"
   exit 1
fi

#grep moist_adv_opt  $inputFile  | grep 1   > /dev/null 2>&1
#found="( $? -eq 0 )" 
#if [ ! $found ]; then
#   echo "$0:  Namelist does not contain 'moist_adv_opt = 1'"
#   exit 1
#fi



# Change the two existing parameter values. 
sed -e '/nio_tasks_per_group/s/0/1/' \
    $inputFile 

#    -e '/moist_adv_opt/s/1/1/' \

