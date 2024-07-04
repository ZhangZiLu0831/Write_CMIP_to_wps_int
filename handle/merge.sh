#!/bin/bash

var3d=("ta" "ua" "va" "zg" "hus")
var2d=("tas" "uas" "vas" "ts" "tsl" "snw" "huss" "psl")

#date1=$1
startdate=$1
enddate=$2
hlist=("00" "06" "12" "18")
while [[ ${startdate} -lt ${enddate} ]]
do
for hour in ${hlist[@]}
do
date1=`date -d "${startdate}" +%Y-%m-%d`

echo ${date1}
echo ${hour}
suffix=${date1}_${hour}.nc
echo ${suffix}
outputfile=MPI_HR_${date1}_${hour}_00:00.nc
echo ${outputfile}
cdo merge ta_${suffix} ua_${suffix} va_${suffix} zg_${suffix} hus_${suffix} 3D_${outputfile}
cdo merge tas_${suffix} uas_${suffix} vas_${suffix} ts_${suffix} huss_${suffix} tsl_${suffix} psl_${suffix} snw_${suffix} 2D_${outputfile}
done
startdate=`date -d "+1 day ${startdate}" +%Y%m%d`
echo ${startdate}
done
                                 



