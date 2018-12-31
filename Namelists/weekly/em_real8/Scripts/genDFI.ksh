#!/bin/ksh

# Usage:  genDFI.ksh <wrf_namelist_file> 
#
#  Takes an existing WRF namelist file and outputs a new one with Digital Filtering turned on.
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


grep dfi_opt  $inputFile  | grep 0    > /dev/null 2>&1
found1="( $? -eq 0 )" 
if [ ! $found1 ]; then
   echo "$0:  Namelist does not contain 'dfi_opt = 0'"
   exit 1
fi


# Set the digital filtering switch from 0 to 3.
sed -e '/dfi_opt/s/0/3/' $inputFile 

