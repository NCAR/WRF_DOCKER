#!/bin/ksh

# Usage:  genBin.ksh <wrf_namelist_file> 
#
#  Takes an existing WRF namelist file and outputs a new one with binary output turned on.
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

grep io_form_restart  $inputFile  | grep '[0-9]'   > /dev/null 2>&1
found="( $? -eq 0 )" 
if [ ! $found ]; then
   echo "$0:  Namelist does not contain 'io_form_restart = <digit>'"
   exit 1
fi

grep io_form_input  $inputFile  | grep '[0-9]'   > /dev/null 2>&1
found="( $? -eq 0 )" 
if [ ! $found ]; then
   echo "$0:  Namelist does not contain 'io_form_input = <digit>'"
   exit 1
fi

grep io_form_boundary  $inputFile  | grep '[0-9]'   > /dev/null 2>&1
found="( $? -eq 0 )" 
if [ ! $found ]; then
   echo "$0:  Namelist does not contain 'io_form_boundary = <digit>'"
   exit 1
fi



# Set the four existing parameters from some digit to 1. 
sed -e '/io_form_history/s/[0-9]/1/' \
    -e '/io_form_restart/s/[0-9]/1/' \
    -e '/io_form_input/s/[0-9]/1/' \
    -e '/io_form_boundary/s/[0-9]/1/' \
    $inputFile 


