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
vas =f->vas(0,:,:)
uas =f->uas(0,:,:)
psl =f->psl(0,:,:)
tas =f->tas(0,:,:)
huss =f->huss(0,:,:)
snw =f->snw(0,:,:)
ts =f->ts(0,:,:)
tsl =f->tsl(0,:,:)

;ddate       = "2050-01-03"
;hh=(/"00","06","12","18"/)

ddate = getenv("basedate")
hh    = getenv("hours")

DATE        = ddate+"_"+hh(0)
DATE1=DATE+":00:00"
WPS_IM_root_name = "MPI_HR_2d"
output_file_name = WPS_IM_root_name +":"+ DATE1
lonn=0+1*ispan(0,360,1)
latt=90.0-1*ispan(0,180,1)
earth_radius     = 6367.470
;system(" /rm " + output_file_name)
; for 2d variable
 
 FIELD_T          = "TT"
 UNITS_T          = "K"
 DESC_T           = "2-m Temperature"

 FIELD_U          = "UU"
 UNITS_U          = "m s-1"
 DESC_U           = "10-m wind u-component"

 FIELD_V          = "VV"
 UNITS_V          = "m s-1"
 DESC_V           = "10-m wind v-component"

 FIELD_R          = "SPECHUMD"
 UNITS_R          = "kg kg-1"
 DESC_R           = "2-m specific humidity"

 FIELD_P          = "PSFC"
 UNITS_P          = "Pa"
 DESC_P           = "surface pressure"
 
 FIELD_PS          = "PMSL"
 UNITS_PS          = "Pa"
 DESC_PS           = "Mean sea-level pressure"

 FIELD_ST          = "ST000010"
 UNITS_ST          = "K"
 DESC_ST          = "0-10 cm soil temp"

 FIELD_SM          = "SM000010"
 UNITS_SM          = "m3 m-3"
 DESC_SM          = "0-10 cm soil moisture"

 FIELD_TS         = "SKINTEMP"
 UNITS_TS          = "K"
 DESC_TS          = "Skin temperature"

 FIELD_SN         = "SNOW"
 UNITS_SN          = "kg m-2"
 DESC_SN         = "Snow mass"
 
 re_uas=regrid_MPI(data_filename,uas)
 re_vas=regrid_MPI(data_filename,vas)
 re_tas=regrid_MPI(data_filename,tas)
 re_huss=regrid_MPI(data_filename,huss)
 re_snw=regrid_MPI(data_filename,snw)
 re_ts=regrid_MPI(data_filename,ts)
 re_psl=regrid_MPI(data_filename,psl)
 re_tsl=regrid_MPI(data_filename,tsl)
 

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
opt@level             = 200100

wrf_wps_write_int(WPS_IM_root_name,FIELD_U,UNITS_U,\
                      DESC_U,re_uas,opt)

wrf_wps_write_int(WPS_IM_root_name,FIELD_V,UNITS_V,\
                      DESC_V,re_vas(:,:),opt)

wrf_wps_write_int(WPS_IM_root_name,FIELD_T,UNITS_T,\
                      DESC_T,re_tas(:,:),opt)

wrf_wps_write_int(WPS_IM_root_name,FIELD_R,UNITS_R,\
                      DESC_R,re_huss(:,:),opt)

wrf_wps_write_int(WPS_IM_root_name,FIELD_PS,UNITS_PS,\
                      DESC_PS,re_psl(:,:),opt)

wrf_wps_write_int(WPS_IM_root_name,FIELD_ST,UNITS_ST,\
                      DESC_ST,re_tsl(:,:),opt)

wrf_wps_write_int(WPS_IM_root_name,FIELD_TS,UNITS_TS,\
                     DESC_TS,re_ts(:,:),opt)

wrf_wps_write_int(WPS_IM_root_name,FIELD_SN,UNITS_SN,\
                     DESC_SN,re_snw(:,:),opt)




 
end
