#!/bin/bash

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
suffix=${date1}_${hour}
echo ${suffix}
inputfile=3D_MPI_HR_${date1}_${hour}_00:00.nc
#inputfile=2D_MPI_HR_${date1}_${hour}_00:00.nc
#inputfile=siconc_${date1}_${hour}.nc
#inputfile=ps_${date1}_${hour}.nc
echo ${inputfile}
export filename=${inputfile}
export hours=${hour}
export basedate=${date1}
echo ${basedate}
echo ${hours}
echo ${filename}
ncl write_wrf_int3d.ncl
#ncl write_wrf_int2d.ncl
#ncl write_ps.ncl
#ncl  write_wrf_int_ocean.ncl
done
startdate=`date -d "+1 day ${startdate}" +%Y%m%d`
echo ${startdate}
done
                                 



