#!/bin/bash

#suffix="_6hrPlevPt_MPI-ESM1-2-HR_ssp126_r1i1p1f1_gn_201501010600-202001010000.nc"
startdate=$1
enddate=$2
#date1=$1
hlist=("00" "06" "12" "18")
varlist=("ta" "ua" "va" "zg" "tas" "uas" "vas" "ts" "tsl" "snw" "hus" "huss" "psl")
var2d=("tas" "uas" "vas" "ts" "tsl" "snw" "huss" "psl")
var3d=("ta" "ua" "va" "zg" "hus")

#echo ${date1}
while [[ ${startdate} -lt ${enddate} ]]
do
date1=`date -d "${startdate}" +%Y-%m-%d`
echo ${date1}
  for var in ${var3d[@]}
  do
  echo ${var}
   for hour in ${hlist[@]}
   do
   echo ${hour}
   out_filename=${var}_${date1}_${hour}.nc
   #input_filename=${var}${suffix}
   input_filename=`ls ${var}_*ssp*`
   echo ${out_filename}
   echo ${input_filename}
   cdo -seldate,${date1} -selhour,${hour} -selname,${var} -sellevel,92500,85000,70000,60000,50000,25000,5000 ${input_filename} ${out_filename}
   echo "cdo done"
   done
 done
startdate=`date -d "+1 day ${startdate}" +%Y%m%d`
done
#cdo -seldate,2019-05-15 -selhour,0 -selname,zg zg_6hrPlevPt_MPI-ESM1-2-HR_ssp126_r1i1p1f1_gn_201501010600-202001010000.nc zg_2019-05-15_00:00:00.nc


