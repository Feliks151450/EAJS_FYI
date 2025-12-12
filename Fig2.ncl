;加载必要代码
load "../global.ncl"
load "../ncl_lib/fixBarColor.ncl"

begin
folder = localpath(3)+"SIC/figs/" ;"EAJ_plot"
fig = "pdf"
  fig@wkPaperWidthF = 20
  fig@wkPaperHeightF = 20
png = "png"
  png@wkHeight = 2000
  png@wkWidth = 2000
; year := ispan(1979, 2020, 1)
year := ispan(1977, 2020, 1)
year0 := ispan(1977, 1998, 1)
; year1 := ispan(2001, 2020, 1)
year1 := ispan(1999, 2020, 1)

; itemType = "research"
itemType = "nature"

  ; f = addfile("uzm.nc", "r")
  ; ; year = ispan(2001, 2020, 1)
  ; uzm = f->uzm(:,59:180)
  ; uzm = runave_n_Wrap(uzm, 5, 0, 1)
  ; year = uzm&year
  ; clim = dim_avg_n_Wrap(uzm, 0)
  ; abs_uzm = abs(uzm)
  ; copy_VarCoords(uzm, abs_uzm)
  ; ; abs_uzm := 
  ; ; print(abs_uzm(15,:))
  ; ; print(uzm(15,:))
  ; SFW_date = dim_minind(abs_uzm({day|:},{year|:}),0)*1.0
  ; setDim(SFW_date,0,"year",ispan(1979,2020,1))
  ; SFW_date = dim_standardize_Wrap(SFW_date, 0)

;# 全时段的EOF
type = "u"
  type@level = 200
  ; type@year := ispan(1999,2018,1)
  type@year := year
  ; type@year := ispan(1999,2018,1)
  type@month := (/7,8/)
  type@source = "ERA5"
  type@range = (/20,60,80,120/)
  ; type@range = (/20,60,30,130/)
  ; range = (/20,55,80,130/)
; range = (/20,60,80,130/)
detrend = False
method = "anom"
  method@detrend = detrend
opt = True
X := process(type,method)
    opt@neof = 2
    opt@jopt = 0
    opt@weight = True
    opt@reof = False
    opt@rev := (/-1, -1,1/)
    opt@name = "EAJ"
    opt@lbOrientation = "Vertical"
    opt@xcnLevels = (/-4,-3,-2,-1,1,2,3,4/)
    opt@minmax = (/-3,3/)
EAJ := EOF(X,opt)
    EAJ@units = ""
    pcvar = EAJ@pcvar
EOF1 := EAJ(0,:)
EOF2 := EAJ(1,:) 
print(EOF1)
  type@range = (/29,39, 95, 130/)
EAJSI_C1 = areavg_dev(type,method)
  type@range = (/45,55, 95, 125/)
EAJSI_C2 = areavg_dev(type,method)
EAJSI = dim_standardize_Wrap(EAJSI_C1 - EAJSI_C2, 0)
copy_VarCoords(EAJSI_C1, EAJSI)
EAJSI0 := dim_standardize_Wrap(EAJSI({year0}), 0)
EAJSI1 := dim_standardize_Wrap(EAJSI({year1}), 0)

;# 计算新生冰
year_eof := year
type := "sic"
  type@year = year_eof
  ; type@source = "hadisst2"
  type@source = "era5"
  ; type@source = "cobe2"
  ; type@source = "cobe2_oisst2"
  type@month = (/-12,1/);5或1或-12
  type@range = (/40,90,-180,180/)
method := "mean"
  method@detrend = detrend
sic_March := process(type,method)
printVarSummary(sic_March)
  type@year = year_eof
  type@month := (/-6,-7/)
sic_Pre_Sep := process(type,method)
printVarSummary(sic_Pre_Sep)
new_sic := sic_March-sic_Pre_Sep
copy_VarCoords(sic_March, new_sic)
if(detrend)then
  new_sic_dt := dtrend_n(new_sic, True, 0)
  copy_VarCoords(sic_March, new_sic_dt)
else
  new_sic_dt := new_sic
end if

new_sic&year = year_eof
new_sic_dt&year = year_eof
printVarSummary(new_sic)


  ; type@range = (/76,83, -10, 75/)
BKSST_ns_region := new_sic_dt(:,{76:83},{0:75})
BSFYI_region1 := new_sic_dt(:,{77:79},{25:65})
BSFYI_region2 := new_sic_dt(:,{80.5:82.5},{0:35})


; BKSST_ns := dim_avg_n_Wrap(new_sic_dt(:,{76:83},{-10:75}), (/1,2/))
d2r = get_d2r("float")
lat_wgt = cos(BKSST_ns_region&lat*d2r)
lat_wgt1 = cos(BSFYI_region1&lat*d2r)
lat_wgt2 = cos(BSFYI_region2&lat*d2r)
BKSST_ns := wgt_areaave(BKSST_ns_region, lat_wgt,1, 0)
BSFYI_C1 := wgt_areaave(BSFYI_region1, lat_wgt1,1, 0)
BSFYI_C2 := wgt_areaave(BSFYI_region2, lat_wgt2,1, 0)
; BSFYI_C1 = dim_standardize_Wrap(BSFYI_C1, 0)
; BSFYI_C2 = dim_standardize_Wrap(BSFYI_C2, 0)
BSFYI = dim_standardize(BSFYI_C1+BSFYI_C2, 0)
copy_VarCoords(BSFYI_C1, BSFYI)
setDim(BSFYI,0,"year",year)
BSFYI0 = dim_standardize_Wrap(BSFYI({year0}), 0)
BSFYI1 = dim_standardize_Wrap(BSFYI({year1}), 0)
printVarSummary(BSFYI)

setDim(BKSST_ns,0,"year",year)
printVarSummary(BKSST_ns)
tem = dim_standardize_Wrap(BKSST_ns,0)
BKSST_ns0 := dim_standardize_Wrap(BKSST_ns({year0}), 0)
BKSST_ns1 := dim_standardize_Wrap(BKSST_ns({year1}), 0)

; f = addfile("SVD.nc", "r")
; MCA1_FYI = f->ts_FYI
; MCA1_U200 = f->ts_U200
; EAJSI0 := dim_standardize_Wrap(EOF1({year0}), 0)
; EAJSI1 := dim_standardize_Wrap(EOF1({year1}), 0)

; print(f->ts_FYI)
; print(escorc(BKSST_ns1, MCA1_FYI))
; print(escorc(MCA1_U200, EAJSI1))
; print(escorc(x, y))

;# Nino3b
type = "sst"
  type@year := year
  ; type@source = "era5"
  ; type@month := (/1,2,3/)
  ; type@range = (/-5,5, 240, 280/)
  type@source = "ersstv5"
  type@month := (/1,2,3/)
  type@range = (/-12,5,215,280/)
NINO3 := areavg_dev(type,opt)

;# TPUW
  TPUW_S_range := (/25,35,80,105/)
  TPUW_N_range := (/44,52,85,105/)
    type = "u"
    type@source = "era5"
    type@level = 200
    type@month := (/7,8/)
    type@range = TPUW_S_range
    type@year = year
  opt = True
    opt@std = False
    opt@weight = True
    opt@detrend = False
  TPUW_S := areavg_dev(type,opt)
    type@range = TPUW_N_range
  TPUW_N := areavg_dev(type,opt)
  TPUW := TPUW_S - TPUW_N
  TPUW = dim_standardize_Wrap(TPUW, 0)
    TPUW@name = "TPUW"
  copy_VarCoords(TPUW_S, TPUW)
  TPUW0 := dim_standardize_Wrap(TPUW({year0}), 0)
  TPUW1 := dim_standardize_Wrap(TPUW({year1}), 0)

;# 计算滑动相关
window = 21
t = t_value(window-2)
; print(EAJSI0)
; print(escorc(EOF1_p1({year0}), NINO3({year0})))
; print(escorc(EOF1_p1({year1}), BKSST({year1})))
; print(run_cor(EAJSI, NINO3, 21))
; print(run_cor(EAJSI, BKSST, 21))
rc_EOF1_NINO3 := run_cor(EOF1, NINO3, window)
print(rc_EOF1_NINO3)

rc_TPUW_NINO3 := run_cor(TPUW, NINO3, window)
; print(rc_TPUW_NINO3)

rc_EOF1_NINO3 = (/rc_EOF1_NINO3*3.5/)
rc_EOF1_NINO3_sig := where(abs(rc_EOF1_NINO3) .ge. t@r95*3.5, rc_EOF1_NINO3, rc_EOF1_NINO3@_FillValue)
copy_VarCoords(rc_EOF1_NINO3, rc_EOF1_NINO3_sig)

rc_TPUW_NINO3 = (/rc_TPUW_NINO3*3.5/)
rc_TPUW_NINO3_sig := where(abs(rc_TPUW_NINO3) .ge. t@r95*3.5, rc_TPUW_NINO3, rc_TPUW_NINO3@_FillValue)
copy_VarCoords(rc_TPUW_NINO3, rc_TPUW_NINO3_sig)

rc_EOF1_BKSST_ns := run_cor(EOF1, BKSST_ns, window)
rc_EAJSI_BSFYI := run_cor(EAJSI, BSFYI, window)
print(rc_EOF1_BKSST_ns)

rc_TPUW_BKSST_ns := run_cor(TPUW, BKSST_ns, window)
; print(rc_TPUW_BKSST_ns)

rc_EOF1_BKSST_ns = (/rc_EOF1_BKSST_ns*3.5/)
rc_EOF1_BKSST_ns_sig := where(abs(rc_EOF1_BKSST_ns) .ge. t@r95*3.5, rc_EOF1_BKSST_ns, rc_EOF1_BKSST_ns@_FillValue)
copy_VarCoords(rc_EOF1_BKSST_ns, rc_EOF1_BKSST_ns_sig)

rc_EAJSI_BSFYI = (/rc_EAJSI_BSFYI*3.5/)
rc_EAJSI_BSFYI_sig := where(abs(rc_EAJSI_BSFYI) .ge. t@r95*3.5, rc_EAJSI_BSFYI, rc_EAJSI_BSFYI@_FillValue)
copy_VarCoords(rc_EAJSI_BSFYI, rc_EAJSI_BSFYI_sig)


;新生冰和PC1的关系
new_sic_dt_reg_PC1 := regCoef_n(dim_standardize_Wrap(EOF1({year1}), 0), new_sic_dt({year1},:,:), 0, 0)
copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_reg_PC1)

new_sic_dt_cor_PC1 := escorc_n(dim_standardize_Wrap(EOF1({year}), 0), new_sic_dt({year},:,:), 0, 0)
copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_cor_PC1)

new_sic_dt_cor_PC1_P1 := escorc_n(dim_standardize_Wrap(EOF1({year0}), 0), new_sic_dt({year0},:,:), 0, 0)
copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_cor_PC1_P1)

new_sic_dt_cor_PC1_P2 := escorc_n(dim_standardize_Wrap(EOF1({year1}), 0), new_sic_dt({year1},:,:), 0, 0)
copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_cor_PC1_P2)

new_sic_dt_cor_EAJSI_P1 := escorc_n(EAJSI0, new_sic_dt({year0},:,:), 0, 0)
copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_cor_EAJSI_P1)

new_sic_dt_cor_EAJSI_P2 := escorc_n(EAJSI1, new_sic_dt({year1},:,:), 0, 0)
copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_cor_EAJSI_P2)
; new_sic_dt_cor_SFW_P1 := escorc_n(dim_standardize_Wrap(SFW_date({year0}), 0), new_sic_dt({year0},:,:), 0, 0)
; copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_cor_SFW_P1)

; new_sic_dt_cor_SFW_P2 := escorc_n(dim_standardize_Wrap(SFW_date({year1}), 0), new_sic_dt({year1},:,:), 0, 0)
; copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_cor_SFW_P2)

new_sic_dt_reg_BKSST := regCoef_n(dim_standardize_Wrap(BKSST_ns({year1}), 0), new_sic_dt({year1},:,:), 0, 0)
copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_reg_BKSST)
new_sic_dt_cor_BKSST := escorc_n(dim_standardize_Wrap(BKSST_ns({year1}), 0), new_sic_dt({year1},:,:), 0, 0)
copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_cor_BKSST)

;新生冰和TPUW的关系
new_sic_dt_reg_TPUW := regCoef_n(dim_standardize_Wrap(TPUW({year1}), 0), new_sic_dt({year1},:,:), 0, 0)
copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_reg_TPUW)

new_sic_dt_cor_TPUW := escorc_n(dim_standardize_Wrap(TPUW({year1}), 0), new_sic_dt({year1},:,:), 0, 0)
copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_cor_TPUW)

new_sic_dt_cor_TPUW_P1 := escorc_n(dim_standardize_Wrap(TPUW({year0}), 0), new_sic_dt({year0},:,:), 0, 0)
copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_cor_TPUW_P1)

new_sic_dt_cor_TPUW_P2 := escorc_n(dim_standardize_Wrap(TPUW({year1}), 0), new_sic_dt({year1},:,:), 0, 0)
copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_cor_TPUW_P2)

; new_sic_dt_reg_BKSST := regCoef_n(dim_standardize_Wrap(BKSST_ns({year1}), 0), new_sic_dt({year1},:,:), 0, 0)
; copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_reg_BKSST)
; new_sic_dt_cor_BKSST := escorc_n(dim_standardize_Wrap(BKSST_ns({year1}), 0), new_sic_dt({year1},:,:), 0, 0)
; copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_cor_BKSST)

  ;只画和海冰的滑动相关+新生冰分段
plot := newPlots(8)
fileName = "fig2"
wks = gsn_open_wks(png,fileName)
rts := True
notDrawAndFrame(rts)
  rts@vpHeightF = 0.4
  rts@vpWidthF = 1.5
  rts@gsnLeftString = genItem("a",itemType)+"   EAJSI";"(b) EAJII & PC1"
  rts@gsnLeftStringFontHeightF = 0.035
  rts@gsnLeftStringParallelPosF = -0.042
  rts@gsnLeftStringOrthogonalPosF = 0.01
  rts@gsnRightString = window+"-yr run cor (EAJSI & BSFYI)"
  rts@gsnRightStringFontColor = "Firebrick1"
  rts@gsnRightStringOrthogonalPosF = 0.00
  rts@gsnRightStringFontHeightF = 0.03
  rts@tmXBLabelFontHeightF = 0.028
  rts@tmYLLabelFontHeightF = 0.028
  rts@tmYRLabelFontHeightF = 0.028
  rts@tmXBTickStartF = 1979
  ; rts@tmYLValues = ispan(-9,9,3)
  rts@tmYLValues = fspan(-3,3,5)
  rts@minmax = (/-2.5,3.5/)
  rts@tiYAxisString = "std. dev."
  rts@tiYAxisOffsetXF = 0.0
  ; rts@tiXAxisString = "Year"
  ; rts@tiXAxisOffsetYF = -0.01
  rts@xyCurveDrawOrder = "PostDraw"

  rts@tmBorderThicknessF = 3.
  rts@tmYROn = True
  rts@tmYRLabelsOn = True
  rts@tmYRMode = "Explicit"
  rts@tmYRValues = fspan(-3.5,3.5,5)
  rts@tmYRLabels = rts@tmYRValues/3.5
  rts@tmYRLabelDeltaF = -0.5
  rts@tmYRMajorLineColor = "Firebrick1"
  rts@tmYRLabelFontColor = "Firebrick1"
  rts@gsnYRefLine = 0
plot(0) = plot_ts(wks,EAJSI,rts)
pgres := (/-10,10,min(year1)-0.5,max(year1)+1/)
  pgres@gsFillOpacityF = 0.05
  pgres@gsFillColor = "#ff8747"
add_fillBox(plot(0),pgres)
  ; rts@xyDashPattern = 1
  rts@xyLineColor = "DodgerBlue"
  rts@xyMarkLineMode = "MarkLines"
  ; rts@xyMarkers = 4
  ; rts@xyMarkerThicknessF = 5
  rts@xyMarkerSizeF = 0.015
;# 新生冰指数
add_ts(plot(0),BSFYI,rts)
  rts@xyDashPattern = 0
  rts@xyLineThicknessF = 20
  rts@xyMarkLineMode = "MarkLines"
  rts@xyMarkers = 4
; add_ts(plot(0),rc_EOF1_NINO3_sig,rts)
  rts@xyLineThicknessF = 10
  rts@xyMarkerThicknessF = 10
  rts@xyMarkerSizeF = 0.02
  rts@xyDashPattern = 1
  rts@xyLineColor = "Firebrick1"
; add_ts(plot(0),rc_EOF1_BKSST,rts)
;# 滑动相关
add_ts(plot(0),rc_EAJSI_BSFYI,rts)
  rts@xyDashPattern = 0
  rts@xyLineThicknessF = 20
  rts@xyMarkLineMode = "Markers"
  rts@xyMarkerSizeF = 0.02
  rts@xyMarker = 4
  rts@xyMarkers = 4
; add_ts(plot(0),rc_EOF1_BKSST_sig,rts)
; add_ts(plot(0),rc_EOF1_BKSST_ns_sig,rts)
; add_ts(plot(0),rc_EAJSI_BSFYI,rts)
  rts@xyMarkers = 16
  rts@xyMarker = 16
  rts@xyMarkLineMode = "MarkLines"
add_ts(plot(0),rc_EAJSI_BSFYI_sig,rts)
text := "BSFYI"
  text@txFontColor = "DodgerBlue"
  text@txFontHeightF = 0.035
  text@txJust = "CenterLeft"
add_text(plot(0),text,1977,2.7)
opt := True
notDrawAndFrame(opt)
  opt@tmBorderThicknessF = 2
  opt@mpGeophysicalLineThicknessF = 0.5
  opt@lbLabelFontHeightF = 0.026
  ; EOF
  opt@lbOrientation = "Vertical"
  opt@xcnLevels = (/-4,-3,-2,-1,1,2,3,4/)
  opt@minmax = (/-3,3/)
  opt@vpHeightF = 0.6
  ; range=(/10,65,70,160/)
  type := "sst"
    type@source = "cobe2_oisst2"
  type@level = 200
  opt@data = 1
  opt@lbLabelBarOn = False  
  opt@vpWidthF = 0.75
  opt@vpHeightF = 0.6
  opt@Scale = 0.1
  ; opt@gsnStringFontHeightF = 0.042
  ; opt@tmLabelFontHeightF = 0.033
  opt@tmYLTickSpacingF = 15
  opt@tmYLLabelFontHeightF = 0.025
  opt@tmXBTickSpacingF = 50
  opt@tmXBTickStartF = 90
  opt@tmXBLabelStride = 1
  opt@tmXBLabelFontHeightF = 0.025
  delete(opt@lbStyle)
  ; opt@tmYLLabelFontHeightF = 0.03
  opt@tmYLLabelStride = 1
  opt@gsnLeftString = genItem("b",itemType)+"  SST (JFM)"
  opt@gsnLeftStringParallelPosF = -0.01
  opt@gsnLeftStringOrthogonalPosF = 0.02
  opt@gsnLeftStringFontHeightF = 0.03
  opt@gsnRightString = "P1"; "1979-1998"
  opt@gsnRightStringFontHeightF = 0.03
  ; opt@addRightString = "1979-1998";"P1 "
      ; rts@gsnRightString = sprintf("%5.1f", pcvar1(0)) +"%"
  opt@tmYLLabelsOn = True
  ; opt@tmXBLabelsOn = False
  ; opt@tiYAxisString = "Latitude"
  ; opt@tiYAxisOffsetXF = 0.02
  ; opt@tiXAxisString = "Longitude"
  ; opt@tiXAxisOffsetYF = -0.035
  opt@cnLineThicknessF = 3.
  opt@dots = False
  opt@dotslat = (/38.5,44.5,44,38.5,38.5/)
  opt@dotslon = (/90.,90,120,120,90/)
  opt@dotsLineThicknessF = 5.
  opt@tmXBLabelsOn = False
  range := (/-20,20,120,290/)
  opt@vpHeightF = 0.3
  opt@cnFillDotSizeF = 0.003
  type@month := (/1,2,3/)
  type@range = range

box = (/76,83, -10, 75/)
  box@gsLineColor = "Tomato"
  box@gsLineDashPattern = 0
  box@gsLineThicknessF = 5
; add_lineBox(plot(3),box)
box = (/-5,5, 210, 270/)
; add_lineBox(plot(2),box)
resp := True
  resp@gsnFrame = False
  resp@gsnPanelScalePlotIndex = 2
  resp@gsnPanelRight = 1.0
  resp@gsnPanelLeft = 0.0
  resp@gsnPanelXF = (/0.09,0.09/)
  resp@gsnPanelYF = (/0.965,0.965/)
gsn_panel(wks,plot,(/2,1/),resp)

;# 画PC1与新生冰的相关场
ts := dim_standardize_Wrap(EOF1({year1}), 0)

plot := newPlots(2)
opt := True
notDrawAndFrame(opt)
  opt@gsnLeftString = genItem("b",itemType)
  opt@gsnLeftStringOrthogonalPosF = -0.2
  opt@gsnLeftStringParallelPosF = 0.1
  opt@gsnLeftStringFontHeightF = 0.04
  opt@gsnCenterString = "P1"
  opt@gsnCenterStringFontHeightF = 0.038
  opt@tmXBTickSpacingF = 30
  opt@tmYLTickSpacingF = 20
  opt@tmXBLabelsOn = False
  opt@lbLabelBarOn = False
  range := (/72,85,-20,90/)
type = "sic"
  type@month := (/1/)
  ; type@month := (/1,2,3/)
  ; type@month := (/-9/)
  type@range = range
    type@source = "era5"
  ; type@source = "era5"
  ; opt@mpMinLatF = 60
  ; ; opt@mpCenterLonF = 20
  ; opt@mpMinLonF = -50
  ; opt@mpMaxLonF = 70
  opt@mpProjection          = "LambertConformal"
  opt@gsnMaskLambertConformal = True
  opt@vpWidthF = 1.0
  opt@Scale = 0.02
  opt@gsnRightStringFontHeightF = 0.035
  opt@gsnRightStringOrthogonalPosF = -0.1
  opt@gsnRightStringParallelPosF = 0.9

; plot(3) = gsn_csm_map(wks, opt)
plot(0) = plot_base(wks,range,opt)
  ; opt@Scale = 0.05
; add_cor(plot(0),dim_standardize_Wrap(EOF1_p1({year1}), 0),type,range,opt)
t := t_value(dimsizes(ts)-2)
opt@Scale = 1.
opt@cnLevels = (/-t@r999,-t@r99,-t@r95,-t@r90,t@r90,t@r95,t@r99,t@r999/)
; BKSST_cor := escorc_n(ts, new_sic_dt({ts&year},:,:), 0, 0)
; copy_VarCoords(new_sic_dt(0,:,:), BKSST_cor)
; add_cn(plot(0),BKSST_cor,range,opt)
; opt@cnLevels = (/-4,-3,-2,-1,1,2,3,4/)
add_cn(plot(0),new_sic_dt_cor_EAJSI_P1,range,opt)

; add_reg(plot(0),dim_standardize_Wrap(EOF1({year1}), 0),type,range,opt)
rlable := True
  rlable@lat_spacing = 10
  rlable@lon_spacing = 20
  rlable@lat_labels_on = False
  rlable@txFontHeightF = 0.03
  ; rlable@txAngleF = 0
add_lc_labels(plot(0),range,rlable)
; plot(3) = reg_dev(wks,dim_standardize_Wrap(EOF1_p1({year1}), 0),type,range,opt)
  opt@gsnLeftString = genItem("c",itemType)
  opt@gsnCenterString = "P2"
  type@month := (/5/)
plot(1) = plot_base(wks,range,opt)
; add_reg(plot(1),dim_standardize_Wrap(EOF1({year1}), 0),type,range,opt)
add_cn(plot(1),new_sic_dt_cor_EAJSI_P2,range,opt)
; add_cor(plot(1),ts,type,range,opt)
add_lc_labels(plot(1),range,rlable)

;
box := (/76.,83, 0, 75/)
  box@gsLineColor = "DodgerBlue"
  box@gsLineDashPattern = 0
  box@gsLineThicknessF = 5
; add_lineBox(plot(0),box)
; add_lineBox(plot(1),box)
box = (/-5,5, 210, 270/)
add_lineBox(plot(1),box)

box = (/80.5,82.5, 0, 35/)
add_lineBox(plot(1),box)
box = (/77,79, 25, 60/)
add_lineBox(plot(1),box)

res_polygon := True
  res_polygon@lat = (/77,84,84,82.5,77/)
  res_polygon@lon = (/-15,-5,49,53,-15/)
; add_polygon(plot(1),res_polygon)
;# 组图
resp := True
  resp@gsnFrame = False
  resp@gsnPanelLabelBar = False
  resp@pmLabelBarWidthF = 0.8
  resp@pmLabelBarHeightF = 0.05
  ; resp@gsnPanelScalePlotIndex = 2
  resp@gsnPanelRight = 1.0
  resp@gsnPanelLeft = 0.0
  ; resp@gsnPanelBottom = 0.05
  resp@pmLabelBarOrthogonalPosF = -0.05
  resp@lbTitleString = "Correlation"
  resp@lbTitlePosition = "Bottom"
  resp@lbTitleFontHeightF = 0.018
  resp@lbLabelFontHeightF = 0.018
  resp@lbTitleOffsetF = 0.4
  resp@gsnPanelMainString = "FYI linked to EAJSI"
  resp@gsnPanelMainFont = 22
  resp@gsnPanelMainPosYF = 0.665
  resp@gsnPanelYF = (/0.65,0.65/)
  ; resp@gsnPanelXF = (/0.09,0.09,0.09,0.562,0.09,0.562,0.09,0.562/)
  ; resp@gsnPanelYF = (/0.95,0.95,0.63,0.63,0.43,0.43,0.23,0.23/)
gsn_panel(wks,plot,(/1,2/),resp)

plot := newPlots(2)
opt := True
notDrawAndFrame(opt)
  opt@gsnLeftString = genItem("d",itemType)
  opt@gsnLeftStringOrthogonalPosF = -0.2
  opt@gsnLeftStringParallelPosF = 0.1
  opt@gsnLeftStringFontHeightF = 0.04
  opt@gsnCenterString = "P1"
  opt@gsnCenterStringFontHeightF = 0.038
  opt@tmXBTickSpacingF = 30
  opt@tmYLTickSpacingF = 20
  opt@tmXBLabelsOn = False
  opt@lbLabelBarOn = False
  range=(/20,66,55,150/)
type = "u"
  type@month := (/7,8/)
  type@level = 200
  ; type@month := (/1,2,3/)
  ; type@month := (/-9/)
  type@range = range
    type@source = "era5"
  ; type@source = "era5"
  ; opt@mpMinLatF = 60
  ; ; opt@mpCenterLonF = 20
  ; opt@mpMinLonF = -50
  ; opt@mpMaxLonF = 70
  opt@mpProjection          = "LambertConformal"
  opt@gsnMaskLambertConformal = True
  opt@vpWidthF = 1.0
  ; opt@Scale = 0.02
  opt@gsnRightStringFontHeightF = 0.035
  opt@gsnRightStringOrthogonalPosF = -0.1
  opt@gsnRightStringParallelPosF = 0.9

  opt@gsnMaskLambertConformal = True
  opt@vpWidthF = 1.0
  opt@vpHeightF = 0.5
  opt@gsnRightStringFontHeightF = 0.035
  opt@gsnRightStringParallelPosF = 0.9
  ; opt@mpLambertParallel1F = 70.
  opt@mpLambertParallel2F = 85

; plot(3) = gsn_csm_map(wks, opt)
plot(0) = plot_base(wks,range,opt)
  ; opt@Scale = 0.05
; add_cor(plot(0),dim_standardize_Wrap(EOF1_p1({year1}), 0),type,range,opt)
t := t_value(dimsizes(ts)-2)
opt@Scale = 1.
; opt@cnLevels = (/-t@r999,-t@r99,-t@r95,-t@r90,t@r90,t@r95,t@r99,t@r999/)
; BKSST_cor := escorc_n(ts, new_sic_dt({ts&year},:,:), 0, 0)
; copy_VarCoords(new_sic_dt(0,:,:), BKSST_cor)
; add_cn(plot(0),BKSST_cor,range,opt)
; opt@cnLevels = (/-4,-3,-2,-1,1,2,3,4/)
add_cor(plot(0),BSFYI0,type,range,opt)

; add_reg(plot(0),dim_standardize_Wrap(EOF1({year1}), 0),type,range,opt)
rlable := True
  rlable@lat_spacing = 10
  rlable@lon_spacing = 20
  rlable@lat_labels_on = False
  rlable@txFontHeightF = 0.03
  ; rlable@txAngleF = 0
add_lc_labels(plot(0),range,rlable)
; plot(3) = reg_dev(wks,dim_standardize_Wrap(EOF1_p1({year1}), 0),type,range,opt)
  opt@gsnLeftString = genItem("e",itemType)
  opt@gsnCenterString = "P2"
  type@month := (/7,8/)
plot(1) = plot_base(wks,range,opt)
; add_reg(plot(1),dim_standardize_Wrap(EOF1({year1}), 0),type,range,opt)
add_cor(plot(1),BSFYI1,type,range,opt)
; add_cor(plot(1),ts,type,range,opt)
add_lc_labels(plot(1),range,rlable)

;
box = (/76,83, 0, 75/)
  box@gsLineColor = "DodgerBlue"
  box@gsLineDashPattern = 0
  box@gsLineThicknessF = 5
; add_lineBox(plot(0),box)
; add_lineBox(plot(1),box)
box = (/-5,5, 210, 270/)
add_lineBox(plot(1),box)

box = (/76,80, 20, 75/)
add_lineBox(plot(1),box)
box = (/81,84, -10, 50/)
add_lineBox(plot(1),box)
res_polygon := True
  res_polygon@lat = (/77,84,84,82.5,77/)
  res_polygon@lon = (/-15,-5,49,53,-15/)
; add_polygon(plot(1),res_polygon)

res_topo := True
  res_topo@mode = "shading"
  res_topo@cnLineColor = "#686868"
  res_topo@cnLineThicknessF = 5.
  res_topo@cnFillOpacityF = 0.7
  ; res_topo@cnFillColor = "#575757"
  res_topo@cnFillColor = "Black"
  res_topo@cnFillOpacityF = 0.2
add_topo(plot(0),range,3000,res_topo)
add_topo(plot(1),range,3000,res_topo)

  clim := "u"
    clim@source = "era5"
    clim@level = 200
    ; clim@year = year1
    clim@year = year0
    clim@month = (/7,8/)
    clim@cnLevels = (/20,30/)
    clim@cnLineColor = "#0096FF"
    ; clim@plot_mode = "shading"
    ; clim@cnFillColor = "forestgreen"
    clim@cnLineThicknessF = 10
  ; plot@isShaded = (/True,True/)
  add_clim(plot(0),clim,range,True)

    clim := "u"
    clim@source = "era5"
    clim@level = 200
    ; clim@year = year1
    clim@year = year1
    clim@month = (/7,8/)
    clim@cnLevels = (/20,30/)
    clim@cnLineColor = "#0096FF"
    ; clim@plot_mode = "shading"
    ; clim@cnFillColor = "forestgreen"
    clim@cnLineThicknessF = 10
  ; plot@isShaded = (/True,True/)
  add_clim(plot(1),clim,range,True)

box = (/29,39, 95, 130/)
  box@gsLineColor = "Firebrick1"
  box@gsLineDashPattern = 0
  box@gsLineThicknessF = 5
add_lineBox(plot(1),box)
box = (/45,55, 95, 125/)
add_lineBox(plot(1),box)
;# 组图
resp := True
  resp@gsnFrame = False
  resp@gsnPanelLabelBar = True
  resp@pmLabelBarWidthF = 0.8
  resp@pmLabelBarHeightF = 0.05
  ; resp@gsnPanelScalePlotIndex = 2
  resp@gsnPanelRight = 1.0
  resp@gsnPanelLeft = 0.0
  resp@gsnPanelTop = 0.4
  ; resp@gsnPanelBottom = 0.05
  resp@pmLabelBarOrthogonalPosF = -0.02
  resp@lbTitleString = "Correlation"
  resp@lbTitlePosition = "Right"
  resp@lbTitleDirection = "Across"
  resp@lbTitleFontHeightF = 0.018
  resp@lbLabelFontHeightF = 0.018
  resp@lbTitleOffsetF = 0.02
  resp@gsnPanelMainString = "U200 linked to BSFYI"
  resp@gsnPanelMainFont = 22
  resp@gsnPanelMainPosYF = 0.334
  resp@gsnPanelYF = (/0.32,0.32/)
  ; resp@gsnPanelXF = (/0.09,0.09,0.09,0.562,0.09,0.562,0.09,0.562/)
  ; resp@gsnPanelYF = (/0.95,0.95,0.63,0.63,0.43,0.43,0.23,0.23/)
gsn_panel(wks,plot,(/1,2/),resp)

frame(wks)
show(fileName)
end