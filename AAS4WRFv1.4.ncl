;************************************************************************************************************************************
; NCL script used to interpolate emission rates to a given user-defined WRF-Chem domain
; Copyleft: Observatorio Latinoamericano de Eventos Extraordinarios (OLE2)
; Contact: angel.vela@iag.usp.br - www.cmc.org.ve/mediawiki/index.php?title=Calidad_de_Aire
;************************************************************************************************************************************
; List of input files
; - namelist.emiss
; - wrfinput_d01: WRF grid used for interpolation
; - emissions.txt: emission file with 39 columns: ID, longitude, latitude, and 36 chemical species (CBMZ-MOSAIC). Complete with 
; columns of "0" if data is not available.
; List of output files
; - wrfchemi_00z_d01 and wrfchemi_12z_d01 if n_tim = 24 (set io_style_emissions to 1)
; Or
; - wrfchemi_d01_<date> if n_tim > 24 (set io_style_emissions to 2)
; Run sintaxis: ncl AAS4WRF.ncl
; In both cases, the processing time should not take more than 12 min (nt = 168; time for 7 days of data). Please be patient.
;------------------------------------------------------------------------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
;------------------------------------------------------------------------------------------------------------------------------------
begin
;------------------------------------------------------------------------------------------------------------------------------------
 fil                          = "namelist4D.emiss"
 n_lon                        = stringtoint(systemfunc("grep -w nx "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))
 n_lat                        = stringtoint(systemfunc("grep -w ny "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))
 n_lev                        = stringtoint(systemfunc("grep -w nz "+fil+" | cut -f2 -d'=' | cut -f1 -d','")) 
 n_tim                        = stringtoint(systemfunc("grep -w nt "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))
 n_cbmz                       = 36      ; number of chemical species in CBMZ-MOSAIC (emiss_opt = 4)
 nom_spe                      = (/"E_SO2",  "E_NO",  "E_ALD", "E_HCHO", "E_ORA2",  "E_NH3",   "E_HC3",  "E_HC5"   \ 
                                 ,"E_HC8",  "E_ETH", "E_CO",  "E_OL2",  "E_OLT",   "E_OLI",   "E_TOL",  "E_XYL"   \
				 ,"E_KET",  "E_CSL", "E_ISO", "E_NO2",  "E_CH3OH", "E_C2H5OH","E_PM25I","E_PM25J" \
				 ,"E_SO4I", "E_SO4J","E_NO3I","E_NO3J", "E_ORGI",  "E_ORGJ",  "E_ECI",  "E_ECJ"   \
				 ,"E_SO4C", "E_NO3C","E_ORGC","E_ECC"/)
;------------------------------------------------------------------------------------------------------------------------------------
 wrf_dir                      = systemfunc("grep wrf_dir "+fil+" | cut -f2 -d'=' | cut -f2 -d' '") 
 wrf_inp                      = addfile(wrf_dir,"r") 
 emiss_dir                    = systemfunc("grep emiss_dir "+fil+" | cut -f2 -d'=' | cut -f2 -d' '")
 emiss_txt                    = asciiread(emiss_dir,(/n_lat*n_lon*n_tim*n_lev,(n_cbmz+3)/),"float")
;------------------------------------------------------------------------------------------------------------------------------------
 lon1d                        = emiss_txt(0:n_lon-1,1)
 lat1d                        = new((/n_lat/),"float")
 do i = 0, n_lat-1
  lat1d(i)                    = emiss_txt(n_lat*n_lon-n_lon*i-1,2)
 end do
;------------------------------------------------------------------------------------------------------------------------------------
 e_so2                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_no                         = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_ald                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_hcho                       = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_ora2                       = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_nh3                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_hc3                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_hc5                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_hc8                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_eth                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_co                         = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_ol2                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_olt                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_oli                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_tol                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_xyl                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_ket                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_csl                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_iso                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_no2                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_ch3oh                      = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_c2h5oh                     = new((/n_lon,n_lat,n_lev,n_tim/),"float") 
 e_pm_10                      = new((/n_lon,n_lat,n_lev,n_tim/),"float") 
 e_pm25i                      = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_pm25j                      = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_so4i                       = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_so4j                       = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_no3i                       = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_no3j                       = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_orgi                       = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_orgj                       = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_eci                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_ecj                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_so4c                       = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_no3c                       = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_orgc                       = new((/n_lon,n_lat,n_lev,n_tim/),"float")
 e_ecc                        = new((/n_lon,n_lat,n_lev,n_tim/),"float")
;------------------------------------------------------------------------------------------------------------------------------------
 c_so2                        = stringtoint(systemfunc("grep -w so2 "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_no                         = stringtoint(systemfunc("grep -w no "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_ald                        = stringtoint(systemfunc("grep -w ald "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_hcho                       = stringtoint(systemfunc("grep -w hcho "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_ora2                       = stringtoint(systemfunc("grep -w ora2 "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_nh3                        = stringtoint(systemfunc("grep -w nh3 "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_hc3                        = stringtoint(systemfunc("grep -w hc3 "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_hc5                        = stringtoint(systemfunc("grep -w hc5 "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_hc8                        = stringtoint(systemfunc("grep -w hc8 "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_eth                        = stringtoint(systemfunc("grep -w eth "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_co                         = stringtoint(systemfunc("grep -w co "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_ol2                        = stringtoint(systemfunc("grep -w ol2 "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_olt                        = stringtoint(systemfunc("grep -w olt "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_oli                        = stringtoint(systemfunc("grep -w oli "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_tol                        = stringtoint(systemfunc("grep -w tol "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_xyl                        = stringtoint(systemfunc("grep -w xyl "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_ket                        = stringtoint(systemfunc("grep -w ket "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_csl                        = stringtoint(systemfunc("grep -w csl "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_iso                        = stringtoint(systemfunc("grep -w iso "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_no2                        = stringtoint(systemfunc("grep -w no2 "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_ch3oh                      = stringtoint(systemfunc("grep -w ch3oh "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_c2h5oh                     = stringtoint(systemfunc("grep -w c2h5oh "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_pm25i                      = stringtoint(systemfunc("grep -w pm25i "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_pm25j                      = stringtoint(systemfunc("grep -w pm25j "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_so4i                       = stringtoint(systemfunc("grep -w so4i "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_so4j                       = stringtoint(systemfunc("grep -w so4j "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_no3i                       = stringtoint(systemfunc("grep -w no3i "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_no3j                       = stringtoint(systemfunc("grep -w no3j "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_orgi                       = stringtoint(systemfunc("grep -w orgi "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_orgj                       = stringtoint(systemfunc("grep -w orgj "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_eci                        = stringtoint(systemfunc("grep -w eci "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_ecj                        = stringtoint(systemfunc("grep -w ecj "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_so4c                       = stringtoint(systemfunc("grep -w so4c "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_no3c                       = stringtoint(systemfunc("grep -w no3c "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_orgc                       = stringtoint(systemfunc("grep -w orgc "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
 c_ecc                        = stringtoint(systemfunc("grep -w ecc "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))   
;------------------------------------------------------------------------------------------------------------------------------------
 do z = 0, n_lev-1
  do ihr = 0, n_tim-1
   do j = 1, n_lat-2
    do i = 1, n_lon-2
     e_so2(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_so2)
     e_no(i,j,z,ihr)          = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_no)
     e_ald(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_ald)
     e_hcho(i,j,z,ihr)        = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_hcho)
     e_ora2(i,j,z,ihr)        = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_ora2)
     e_nh3(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_nh3) 
     e_hc3(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_hc3)
     e_hc5(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_hc5)
     e_hc8(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_hc8)
     e_eth(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_eth)
     e_co(i,j,z,ihr)          = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_co)
     e_ol2(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_ol2)
     e_olt(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_olt)
     e_oli(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_oli)
     e_tol(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_tol)
     e_xyl(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_xyl)
     e_ket(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_ket)
     e_csl(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_csl)
     e_iso(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_iso)
     e_no2(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_no2)
     e_ch3oh(i,j,z,ihr)       = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_ch3oh)
     e_c2h5oh(i,j,z,ihr)      = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_c2h5oh)        
;------------------------------------------------------------------------------------------------------------------------------------
     e_pm25i(i,j,z,ihr)       = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_pm25i)
     e_pm25j(i,j,z,ihr)       = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_pm25j)  
     e_so4i(i,j,z,ihr)        = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_so4i)   
     e_so4j(i,j,z,ihr)        = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_so4j)
     e_no3i(i,j,z,ihr)        = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_no3i)
     e_no3j(i,j,z,ihr)        = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_no3j)
     e_orgi(i,j,z,ihr)        = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_orgi)
     e_orgj(i,j,z,ihr)        = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_orgj)
     e_eci(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_eci)
     e_ecj(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_ecj)
     e_so4c(i,j,z,ihr)        = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_so4c)
     e_no3c(i,j,z,ihr)        = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_no3c)
     e_orgc(i,j,z,ihr)        = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_orgc)
     e_ecc(i,j,z,ihr)         = emiss_txt(i+n_lon*j+n_lat*n_lon*ihr+n_lat*n_lon*n_tim*z,c_ecc)
    end do
   end do
  end do
 end do 
;------------------------------------------------------------------------------------------------------------------------------------
 spec                         = (/e_so2,  e_no,   e_ald,  e_hcho, e_ora2, e_nh3,  e_hc3,  e_hc5,  e_hc8,  e_eth,  e_co     \ 
                                 ,e_ol2,  e_olt,  e_oli,  e_tol,  e_xyl,  e_ket,  e_csl,  e_iso,  e_no2,  e_ch3oh,e_c2h5oh \
                                 ,e_pm25i,e_pm25j,e_so4i, e_so4j, e_no3i, e_no3j, e_orgi, e_orgj, e_eci,  e_ecj,  e_so4c   \
                                 ,e_no3c, e_orgc, e_ecc/)
;------------------------------------------------------------------------------------------------------------------------------------
 XLAT                         = wrf_user_getvar(wrf_inp,"XLAT",-1)
 XLONG                        = wrf_user_getvar(wrf_inp,"XLONG",-1)
;------------------------------------------------------------------------------------------------------------------------------------
 sy                           = stringtoint(systemfunc("grep -w sy "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))
 sm                           = stringtoint(systemfunc("grep -w sm "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))
 sd                           = stringtoint(systemfunc("grep -w sd "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))
 ey                           = stringtoint(systemfunc("grep -w ey "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))
 em                           = stringtoint(systemfunc("grep -w em "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))
 ed                           = stringtoint(systemfunc("grep -w ed "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))     
 Time                         = -1                  
 DateStrLen                   = 19
 dSizes                       = getfiledimsizes(wrf_inp)
 west_east                    = dSizes(2)
 south_north                  = dSizes(3)
 emissions_zdim               = n_lev
;------------------------------------------------------------------------------------------------------------------------------------
 s_jd                         = greg2jul(sy,sm,sd,-1)
 e_jd                         = greg2jul(ey,em,ed,-1)
 do chemi = 0, 1
  if(n_tim.ne.24)
   wrfchemi                   = "wrfchemi_d01_temp.nc" 
   tt                         = n_tim
   Times_string               = new((/n_tim/),"string")   
   t                          = 0
   do jd = s_jd, e_jd
    gc                        = jul2greg(jd)
    if(gc(1).lt.10)
     m                        = "0"+gc(1)
    else
     m                        = sprinti("%0.2i",gc(1))
    end if 
    if(gc(2).lt.10)
     d                        = "0"+gc(2)
    else
     d                        = sprinti("%0.2i",gc(2)) 
    end if     
    do h = 0, 23
     if(h.lt.10)then
      Times_string(t)         = gc(0)+"-"+m+"-"+d+"_0"+h+":00:00"
     else
      Times_string(t)         = gc(0)+"-"+m+"-"+d+"_"+h+":00:00"
     end if
     t                        = t+1
    end do 
   end do 
   Times_character            = stringtocharacter(Times_string)
   Times                      = new((/n_tim,DateStrLen/),typeof(Times_character))
   emiss                      = new((/n_tim,n_lev,n_lat,n_lon/),"float")   
;------------------------------------------------------------------------------------------------------------------------------------
  else
   if(chemi.eq.0)
    wrfchemi                  = "wrfchemi_00z_d01_temp.nc"
   else
    wrfchemi                  = "wrfchemi_12z_d01_temp.nc"
   end if  
   tt                         = n_tim/2
   Times_string               = new((/n_tim/2/),"string")   
   t                          = 0 
   gc                         = jul2greg(s_jd)   
   if(gc(1).lt.10)
    m                         = "0"+gc(1)
   else
    m                         = sprinti("%0.2i",gc(1))
   end if 
   if(gc(2).lt.10)
    d                         = "0"+gc(2)
   else
    d                         = sprinti("%0.2i",gc(2)) 
   end if         
   do h = chemi*12, (chemi+1)*12-1
    if(h.lt.10)then
     Times_string(t)          = gc(0)+"-"+m+"-"+d+"_0"+h+":00:00"
    else
     Times_string(t)          = gc(0)+"-"+m+"-"+d+"_"+h+":00:00"
    end if
    t                         = t+1
   end do 
   Times_character            = stringtocharacter(Times_string)
   Times                      = new((/n_tim/2,DateStrLen/),typeof(Times_character))
   emiss                      = new((/n_tim/2,n_lev,n_lat,n_lon/),"float")
  end if 
;------------------------------------------------------------------------------------------------------------------------------------  
  Times                       = Times_character(:,0:DateStrLen-1)
  delete(Times@_FillValue)                                           
  system("/bin/rm -f "+wrfchemi)                
  f                           = addfile(wrfchemi,"c")
  setfileoption(f,"DefineMode",True)               
  fAtt                        = True
  att_wrfinput                = getvaratts(wrf_inp)
  if(.not.all(ismissing(att_wrfinput)))then    
   do att = 0, dimsizes(att_wrfinput)-1             
    if(att_wrfinput(att).ne."TITLE")then           
     fAtt@$att_wrfinput(att)$ = wrf_inp@$att_wrfinput(att)$
    else                            
     fAtt@$att_wrfinput(att)$ = "OUTPUT FROM AAS4WRF EMISSIONS PREPROCESSOR"
    end if                                         
   end do                                          
  end if        
;------------------------------------------------------------------------------------------------------------------------------------
  fileattdef(f,fAtt)                                     
  dimNames                    = (/"Time","DateStrLen","west_east","south_north","emissions_zdim"/)
  dimSizes                    = (/Time,DateStrLen,west_east,south_north,emissions_zdim/)
  dimUnlim                    = (/True,False,False,False,False/)
  filedimdef(f,dimNames,dimSizes,dimUnlim)    
  filevardef(f,"Times","character",(/"Time","DateStrLen"/))
;------------------------------------------------------------------------------------------------------------------------------------
  esmf                        = True
  esmf@InterpMethod           = "neareststod"
  esmf@SrcGridLat             = lat1d
  esmf@SrcGridLon             = lon1d
  esmf@DstGridLat             = XLAT(0,:,:)
  esmf@DstGridLon             = XLONG(0,:,:)
  esmf@ForceOverwrite         = True
  hemi                        = stringtoint(systemfunc("grep -w hemi "+fil+" | cut -f2 -d'=' | cut -f1 -d','"))
  do spe = 0, n_cbmz-1
   do z = 0, n_lev-1
    t                         = 0   
    do tim = chemi*tt, (chemi+1)*tt-1
     do i = 0, n_lon-1                        
      do j = 0, n_lat-1
       if(hemi.eq.1)then                        
        emiss(t,z,j,i)        = spec(spe,i,j,z,tim)
       else
        emiss(t,z,j,i)        = spec(spe,i,n_lat-1-j,z,tim)
       end if   
      end do                                      
     end do
     t                        = t+1                                         
    end do 
   end do                                        
   emiss_wrf                  = (/ESMF_regrid(emiss,esmf)/)
   emiss_wrf!0                = "Time"
   emiss_wrf!1                = "emissions_zdim"
   emiss_wrf!2                = "south_north"
   emiss_wrf!3                = "west_east"
   emiss_wrf@_FillValue       = 0
   delete(emiss_wrf@_FillValue)                  
   emiss_wrf@coordinates      = "XLONG XLAT"
   emiss_wrf@stagger          = ""
   if(spe.lt.22)then                              
    emiss_wrf@units           = "mol km^-2 hr^-1"
   else                                         
    emiss_wrf@units           = "ug/m3 m/s"
   end if                                             
   emiss_wrf@description      = "EMISSIONS"
   emiss_wrf@MemoryOrder      = "XYZ"
   emiss_wrf@FieldType        = 104
;------------------------------------------------------------------------------------------------------------------------------------
   filevardef(f,nom_spe(spe),typeof(emiss_wrf),getvardims(emiss_wrf))
   f->$nom_spe(spe)$          = emiss_wrf
;------------------------------------------------------------------------------------------------------------------------------------
  end do                                      
  f->Times                    = Times
  if(n_tim.ne.24)
   break
  end if 
 end do
 if(n_tim.ne.24) 
  system("/bin/mv -f wrfchemi_d01_temp.nc wrfchemi_d01_"+Times_string(0))
 else 
  system("/bin/mv -f wrfchemi_00z_d01_temp.nc wrfchemi_00z_d01")
  system("/bin/mv -f wrfchemi_12z_d01_temp.nc wrfchemi_12z_d01")
 end if 
 print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
 print("!           Successful completion of AAS4WRF.ncl         !")
 print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
end
