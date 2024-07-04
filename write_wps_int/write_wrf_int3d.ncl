load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
;write function
undef ("regrid_MPI")
function regrid_MPI(fname:string,inputv:numeric)
local regrid_var,MPI_var,lat,lon,inputf
begin
inputf=addfile(fname,"r")
lat=inputf->lat
lon=inputf->lon
Opt                = True
Opt@SrcRegional    = True
Opt@ForceOverwrite = True
Opt@PrintTimings   = True
Opt@Title          = "MPI-ESM1"
Opt@CopyVarAtts    = True
;Opt@GridMask       = where(.not.ismissing(zg),1,0) 
Opt@CopyVarCoords  = False
srcGridName    = "SCRIP_MPI-ESM1_grid"+".nc"
rectilinear_to_SCRIP(srcGridName, inputv&lat, inputv&lon, Opt)
delete(Opt)

;----------------------------------------------------------------------
; Convert destination grid to a SCRIP convention file.
;----------------------------------------------------------------------
dstGridName = "dst_SCRIP.nc"
Opt                = True
Opt@LLCorner       = (/ -90.d,   0.d/)
Opt@URCorner       = (/  90.d,360.d/)
Opt@ForceOverwrite = True
Opt@PrintTimings   = True

latlon_to_SCRIP(dstGridName,"1x1",Opt)
;---Clean up
delete(Opt)


;----------------------------------------------------------------------
; Generate the weights that take you from the NCEP grid to a
; 1x1 degree grid.
;----------------------------------------------------------------------
 
 wgtFileName = "MPI_2_Rect.nc"
 Opt                      = True
 Opt@InterpMethod         = "bilinear"     ; default
 Opt@ForceOverwrite       = True
 Opt@PrintTimings         = True
 ESMF_regrid_gen_weights(srcGridName,dstGridName,wgtFileName,Opt)
 delete(Opt)

;----------------------------------------------------------------------
; Apply the weights to a given variable 
;----------------------------------------------------------------------
  Opt                = True
  Opt@PrintTimings   = True

;---In V6.1.0, coordinates and attributes are copied automatically
regrid_var = ESMF_regrid_with_weights(inputv,wgtFileName,Opt)
;printVarSummary(regrid_var)
return(regrid_var)
end

begin
varlist=(/"ta","ua","va","zg","hus","tas","uas","vas","ps","huss","psl","snw","mrsos","tsl","tos","ts","sic"/)
data_filename=getenv("filename")
;data_filename="/public/home/dcdq/zhangzl/CMIP6/ssp126/2050-2055/3D_MPI_HR_2050-01-03_00_00:00.nc"
print(data_filename) 
f=addfile(data_filename,"r")
ua = f->ua(0,:,:,:)
va =f->va(0,:,:,:)
zg =f->zg(0,:,:,:)
ta =f->ta(0,:,:,:)
hus =f->hus(0,:,:,:)

;ddate       = "2050-01-03"
;hh=(/"00","06","12","18"/)

ddate = getenv("basedate")
hh    = getenv("hours")

DATE        = ddate+"_"+hh(0)
DATE1=DATE+":00:00"
WPS_IM_root_name = "MPI_HR_3d"
output_file_name = WPS_IM_root_name +":" + DATE1
lonn=0+1*ispan(0,360,1)
latt=90.0-1*ispan(0,180,1)
earth_radius     = 6367.470
;system(" /rm " + output_file_name)
 FIELD_T          = "TT"
 UNITS_T          = "K"
 DESC_T           = "Temperature"

  FIELD_U          = "UU"
  UNITS_U          = "m s-1"
  DESC_U           = "Zonal Wind Speed"

  FIELD_V          = "VV"
  UNITS_V          = "m s-1"
  DESC_V           = "Meridional Wind Speed"

  FIELD_R          = "SPECHUMD"
  UNITS_R          = "kg kg-1"
  DESC_R           = "Specific Humidity"

  FIELD_Z          = "GHT"
  UNITS_Z          = "m"
  DESC_Z           = "Geopotential Height"
 UonP=regrid_MPI(data_filename,ua)
 VonP=regrid_MPI(data_filename,va)
 TonP=regrid_MPI(data_filename,ta)
 RonP=regrid_MPI(data_filename,hus)
 ZonP=regrid_MPI(data_filename,zg)

opt                   = True
opt@projection        = 0                 ; "Equidistant_Lat_Lon"
opt@date              = DATE1
opt@map_source        = "1×1"
opt@startloc          = "SWCORNER"	    ; 8 chars exact
opt@startlon          = 0
opt@startlat          = -90
opt@deltalon          = 1
opt@deltalat          = 1
;opt@is_wind_earth_rel = False
opt@is_wind_earth_relative = False



pnew = (/ 1000, 975, 950, 925, 900, 875,850,825, 800, 775,750, 700, 650, 600, 550, 500, \
  450, 400, 350, 300, 250,225, 200,175, 150,125, 100,50 /)*100
pnew2=(/925,850,700,600,500,250,50/)*100
  
NLEV = dimsizes(pnew)
NLEV2 = dimsizes(pnew2)

; For 3D variables
do ilev=0,NLEV2-1
    opt@level = pnew2(ilev)
    wrf_wps_write_int(WPS_IM_root_name,FIELD_U,UNITS_U,\
                     DESC_U,UonP(ilev,:,:),opt)
    wrf_wps_write_int(WPS_IM_root_name,FIELD_V,UNITS_V,\
                      DESC_V,VonP(ilev,:,:),opt)
    wrf_wps_write_int(WPS_IM_root_name,FIELD_T,UNITS_T,\
                      DESC_T,TonP(ilev,:,:),opt)
    wrf_wps_write_int(WPS_IM_root_name,FIELD_R,UNITS_R,\
                      DESC_R,RonP(ilev,:,:),opt)
    wrf_wps_write_int(WPS_IM_root_name,FIELD_Z,UNITS_Z,\
                      DESC_Z,ZonP(ilev,:,:),opt)
end do

;do jlev=0,NLEV2-1
 ; opt@level = pnew2(jlev)
  ;wrf_wps_write_int(WPS_IM_root_name,FIELD_U,UNITS_U,\
   ;                  DESC_U,UonP(jlev,:,:),opt)
  ;wrf_wps_write_int(WPS_IM_root_name,FIELD_V,UNITS_V,\
   ;                   DESC_V,VonP(jlev,:,:),opt)
;end do
 
end
