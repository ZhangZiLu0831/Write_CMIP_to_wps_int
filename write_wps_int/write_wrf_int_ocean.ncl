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
lat=inputf->latitude
lon=inputf->longitude

Opt                = True
Opt@SrcRegional    = True
Opt@ForceOverwrite = True
Opt@PrintTimings   = True
Opt@Title          = "MPI-ESM1"
Opt@CopyVarAtts    = True
;Opt@GridMask       = where(.not.ismissing(zg),1,0) 
Opt@CopyVarCoords  = False
srcGridName    = "SCRIP_MPI-ESM1_grid"+".nc"
curvilinear_to_SCRIP(srcGridName, lat,lon, Opt)
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
;data_filename="/public/home/dcdq/zhangzl/CMIP6/ssp126/2050-2055/siconc_2050-01-03_00.nc"
print(data_filename) 
f=addfile(data_filename,"r")
;tos=f->tos(0,:,:)
;tos=tofloat(tos)+273.3
sic =f->siconc(0,:,:)
lat2d=f->latitude
lon2d=f->longitude
lat2d@units="degrees_N"
lon2d@units="degrees_E"
sic=tofloat(sic)/100.0

print(max(lon2d)+" " +min(lon2d)) 
print(max(lat2d)+" " +min(lat2d))
;printVarSummary(sic)

;ddate       = "2050-01-03"
;hh=(/"00","06","12","18"/)

ddate = getenv("basedate")
hh    = getenv("hours")

DATE        = ddate+"_"+hh(0)
DATE1=DATE+":00:00"
WPS_IM_root_name = "SEAICE_"
;WPS_IM_root_name = "SST"
output_file_name = WPS_IM_root_name + DATE1
lonn=0+1*ispan(0,360,1)
latt=90.0-1*ispan(0,180,1)
earth_radius     = 6367.470
;system(" /rm " + output_file_name)
; for 2d variable
 
 FIELD_ICE          = "SEAICE"
 UNITS_ICE          = "1"
 DESC_ICE           = "ocean seaice"

FIELD_ST          = "SST"
UNITS_ST          = "K"
DESC_ST           = "sea surface temperature"


re_sic=regrid_MPI(data_filename,sic)
; re_tos=regrid_MPI(data_filename,tos)
 

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

wrf_wps_write_int(WPS_IM_root_name,FIELD_ICE,UNITS_ICE,\
                      DESC_ICE,re_sic,opt)

end
