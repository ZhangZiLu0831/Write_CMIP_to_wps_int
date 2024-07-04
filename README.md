#  <center> Write CMIP data to WPS intermediate file to WRF

##  <center> Zilu Zhang
##  <center> zhangzilu21@mails.ucas.ac.cn
##  <center> The Institute of Atmospheric Physics， Chinese Academy of Sciences, Beijing, China

## Get data
This code is used to write the CMIP data to the WPS intermediate file. The data used in this programe is the MPI-HR_ECSM,  the required variables are as follows:

| **v_name** | **wrf_name** | **units** | **dim** | **desc**                | **notes** |
|------------|--------------|-----------|---------|-------------------------|-----------|
| ps         | PSFC         | Pa        | 2d      | surface pressure        |           |
| psl        | PMSL         | Pa        | 2d      | Mean sea-level pressure |           |
| zg         | GHT          | m         | 3d      | geopotential height     |           |
| ta         | TT           | K         | 3d      | air temperature         |           |
| tas        | TT           | K         | 2d      | 2-m temerature          |           |
| ua         | UU           | m s-1     | 3d      | u-component wind;       |           |
| uas        | UU           | m s-1     | 2d      | `10-m u-component wind  |           |
| va         | VV           | m s-1     | 3d      | v-component wind        |           |
| vas        | VV           | m s-1     | 2d      | 10-m v-component wind   |           |
| hus        | SPECHUMD     | kg kg-1   | 3d      | specific humidity       |           |
| huss       | SPECHUMD     | kg kg-1   | 2d      | 10-m specific humidity  |           |
| ts         | SKINTEMP     | K         | 2d      | Skin temperature        |           |
| tsl        | ST000010     | K         | 2d      | 0-10cm soil temperature |           |
| tos        | SST          | K         | 2d      | Sea temperature         | optional  |
| mrsos      | SM000010     | m3 m-3    | 2d      | 0-10cm soil moisture    |           |
| snw        | SNOW         | kg m-2    | 2d      | snow mass               | optional  |
| sic        | SEAICE       | 1         | 2d      | seaice                  | optional  |

The data in "expamle" folder have the data between 2050-2055 and you can directly run with the code.

## Data handel
The `MPI-ESCM-HR-handel* .sh` are the bash scripts used to handle the CMIP data to specific format. e.g, When you enter the command:
``
bash MPI-ESCM-HR-handle2d.sh 20501003 20500104
``
then you can get files named :varname_2050-01-03_hours.nc

the `merge.sh` is used to merge all 2d and 3d files for convenience.

## Regrid and write WPS intermediate file

After run the `merge.sh`,you can nc files :2D_MPI_HR* and 3D_MPI_HR*
move them to same foler and run the write_wrf_int*ncl files repectively. The CMIP data will converted to the WPS intermediate file successfully.
