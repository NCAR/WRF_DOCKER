#!/bin/ksh

# Usage:  gen_All.ksh <wrf_namelist_directory>
#
#  Takes a directory full of ARW scripts and creates derived scripts with different "special features" 
#  turned on.   
# 

if [ $# -ne 1 ]; then
   echo "Usage: $0 <wrf_namelist_directory>" 
   exit 1
fi 

namelistDir=$1

if [ ! -d $namelistDir ]; then
   echo "$0: namelist directory does not exist: $namelistDir"
   exit 1
fi


namelistFiles=`ls $namelistDir/namelist.input.*`

for f in $namelistFiles; do
    # Strip away the path to the file
    fname=`basename $f`
    
    # Apply modification scripts to the file and save to current directory. 
    ./genAdapt.ksh $f > ${fname}AD
    ./genBin.ksh $f > ${fname}BN
    ./genDFI.ksh $f > ${fname}DF
    ./genGrib1.ksh $f > ${fname}GR
    ./genQuilt.ksh $f > ${fname}QT
    ./genNest.ksh $f > ${fname}NE


done



