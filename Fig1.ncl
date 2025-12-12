;加载必要代码
load "../global.ncl"
load "../ncl_lib/fixBarColor.ncl"

undef("r2pStringDev")
function r2pStringDev(r,df)
local p
begin
  p = R2p(r,df)
  if(p .ge. 0.01)then
    return "p = "+sprintf("%.2f",p)
  end if
  if(p .eq. 0)then
    return "p = 0"
  end if
  multi_level = abs(toint(log10(p)))+1
  return "p = "+sprintf("%.1f",p*10^multi_level)+"~F34~4~F21~10~S~-"+multi_level+"~N~"
end

begin
folder = localpath(3)+"SIC/figs/" ;"EAJ_plot"
fig = "pdf"
  fig@wkPaperWidthF = 20
  fig@wkPaperHeightF = 20
png = "png"
  png@wkHeight = 2000
  png@wkWidth = 2000

year := ispan(1977, 2020, 1)
year0 := ispan(1977, 1998, 1)
year1 := ispan(1999, 2020, 1)

; year := ispan(1973, 2024, 1)
; year0 := ispan(1973, 1998, 1)
; year1 := ispan(1999, 2024, 1)


;# 全时段的EOF
type = "u_1x1"
  type@level = 200
  ; type@year := ispan(1999,2018,1)
  ; type@year := year1
  type@year := year
  ; type@year := ispan(1999,2018,1)
  type@month := (/7,8/)
  type@source = "era5"
  ; type@range = (/20,60,80,120/)
  type@range = (/20,60,85,123/)
  ; type@range = (/20,60,30,130/)
  ; range = (/20,55,80,130/)
; range = (/20,60,80,130/)
detrend = True
method = "anom"
  method@detrend = detrend
opt = True
U200 := process(type,method)
    opt@neof = 2
    opt@jopt = 0
    opt@weight = True
    opt@reof = False
    opt@rev := (/-1, -1,1/)
    opt@name = "EAJ"
    opt@lbOrientation = "Vertical"
    opt@xcnLevels = (/-4,-3,-2,-1,1,2,3,4/)
    opt@minmax = (/-3,3/)
EAJ := EOF(U200,opt)
    EAJ@units = ""
    pcvar = EAJ@pcvar
EOF1 := EAJ(0,:)
EOF2 := EAJ(1,:) 
print(EOF1)

type = "u"
  type@range = (/29,39, 95, 130/)
EAJSI_C1 = areavg_dev(type,method)
  type@range = (/45,55, 95, 125/)
EAJSI_C2 = areavg_dev(type,method)
EAJSI = dim_standardize_Wrap(EAJSI_C1 - EAJSI_C2, 0)
copy_VarCoords(EAJSI_C1, EAJSI)
EAJSI0 := dim_standardize_Wrap(EAJSI({year0}), 0)
EAJSI1 := dim_standardize_Wrap(EAJSI({year1}), 0)


;# 计算新生冰
; year_eof := year1
year_eof := year
type := "sic_1x1"
  type@year = year_eof
  ; type@source = "hadisst2"
  type@source = "era5"
  ; type@source = "cobe2_oisst2"
  type@month = (/-12,1/);5或1或-12
  type@range = (/70,87,-20,90/)
method := "mean"
sic_March := process(type,method)
printVarSummary(sic_March)
  type@year = year_eof
  type@month := (/-7,-6/)
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

year_eof := year
type := "sic"
  type@year = year_eof
  type@source = "era5"
  type@month = (/1/);5或1或-12
  type@range = (/70,87,-20,90/)
method := "mean"
sic_Jan_025 := process(type,method)
  type@year = year_eof
  type@month := (/-7/)
sic_Pre_Jul_025 := process(type,method)
new_sic_025 := sic_Jan_025 - sic_Pre_Jul_025
copy_VarCoords(sic_Jan_025, new_sic_025)
if(detrend)then
new_sic_dt_025 := dtrend_n(new_sic_025, True, 0)
copy_VarCoords(sic_Jan_025, new_sic_dt_025)
else
  new_sic_dt_025 := new_sic_025
end if
new_sic_025&year = year_eof
new_sic_dt_025&year = year_eof
  ; type@range = (/76,83, -10, 75/)
; BKSST_ns_region := new_sic_dt(:,{76:83},{0:75})
  ; range := (/70,87,-20,90/)

; BKSST_ns_region := new_sic_dt(:,{70:87},{-20:90})
; BKSST_ns := dim_avg_n_Wrap(new_sic_dt(:,{76:83},{-10:75}), (/1,2/))
d2r = get_d2r("float")
lat_wgt = cos(new_sic_dt&lat*d2r)
; BKSST_ns := wgt_areaave(BKSST_ns_region, lat_wgt,1, 0)
; setDim(BKSST_ns,0,"year",year)
; printVarSummary(BKSST_ns)
; print(EOF1)
if(detrend)then
  svdCacheName = "SVD_full.nc"
else
  svdCacheName = "SVD_full_withTrend.nc"
end if
cache = True
if(cache .and. fileexists(svdCacheName))
  f = addfile(svdCacheName, "r")
  ts_U200 = f->ts_U200
  ts_FYI = f->ts_FYI
else
  result = SVD(U200,new_sic_dt,opt)
  ts_U200 = result[0](0,:)
  ts_FYI = result[1](0,:)
  remove(svdCacheName)
  fout = addfile(svdCacheName, "c")
  fout->ts_U200 = ts_U200
  fout->ts_FYI = ts_FYI
end if
printVarSummary(ts_U200)


print(calcCor(ts_U200,EAJSI))
print(calcCor(EOF1,EAJSI))
new_sic_dt_cor_U200 := escorc_n(dim_standardize_Wrap(ts_U200, 0), new_sic_dt, 0, 0)
new_sic_dt_025_cor_U200 := escorc_n(dim_standardize_Wrap(ts_U200, 0), new_sic_dt_025, 0, 0)
U200_cor_U200 := escorc_n(dim_standardize_Wrap(ts_U200, 0), U200, 0, 0)
U200_cor_FYI := escorc_n(dim_standardize_Wrap(ts_FYI, 0), U200, 0, 0)
new_sic_dt_cor_FYI := escorc_n(dim_standardize_Wrap(ts_FYI, 0), new_sic_dt, 0, 0)
copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_cor_U200)
copy_VarCoords(new_sic_dt_025(0,:,:), new_sic_dt_025_cor_U200)
copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_cor_FYI)
copy_VarCoords(U200(0,:,:), U200_cor_U200)

; new_sic_dt_cor_PC1_P2 := escorc_n(dim_standardize_Wrap(ts_U200({year1}), 0), new_sic_dt({year1},:,:), 0, 0)
; copy_VarCoords(new_sic_dt(0,:,:), new_sic_dt_cor_PC1_P2)
R1 = escorc(ts_U200({year0}), ts_FYI({year0}))
R2 = escorc(ts_U200({year1}), ts_FYI({year1}))

  ;只画和海冰的滑动相关+新生冰分段
plot := newPlots(1)
fileName = "fig1"
; itemType = "research"
itemType = "nature"
wks = gsn_open_wks(png,fileName)
rts := True
notDrawAndFrame(rts)
  rts@vpHeightF = 0.35
  rts@vpWidthF = 1.5
  rts@gsnLeftString = genItem("c",itemType)+"  Time series of                   &";"(b) EAJII & PC1"
  rts@gsnLeftStringFontHeightF = 0.035
  rts@gsnLeftStringParallelPosF = -0.0345
  rts@gsnLeftStringOrthogonalPosF = 0.04
  rts@gsnRightString = "R = "+sprintf("%0.2f", escorc(ts_U200, ts_FYI))
  rts@gsnRightStringFontColor = "Black"
  rts@gsnRightStringOrthogonalPosF = 0.035
  rts@gsnRightStringFontHeightF = 0.035
  rts@tmXBLabelFontHeightF = 0.028
  rts@tmYLLabelFontHeightF = 0.028
  rts@tmYLLabelDeltaF = -0.8
  rts@tmYRLabelFontHeightF = 0.028
  rts@tmXBTickStartF = 1979
  ; rts@tmYLValues = ispan(-9,9,3)
  rts@tmYLValues = fspan(-3,3,5)
  rts@minmax = (/-2.5,3.4/)
  rts@tiYAxisString = "std. dev."
  rts@tiYAxisOffsetXF = 0.01
  ; rts@tiXAxisString = "Year"
  ; rts@tiXAxisOffsetYF = -0.01
  rts@xyCurveDrawOrder = "PostDraw"
  rts@tmBorderThicknessF = 3.
  rts@gsnYRefLine = 0
  rts@gsnXYBarChart = True
plot(0) = plot_ts(wks,dim_standardize_Wrap(ts_U200, 0),rts)
pgres := (/-10,10,min(year1)-0.5,max(year1)+1/)
  pgres@gsFillOpacityF = 0.05
  pgres@gsFillColor = "#ff8747"
; add_fillBox(plot(0),pgres)
  ; rts@xyDashPattern = 1
  rts@xyLineColor = "DodgerBlue"
  rts@xyMarkLineMode = "MarkLines"
  ; rts@xyMarkers = 4
  ; rts@xyMarkerThicknessF = 5
  rts@xyMarkerSizeF = 0.015
  rts@gsnXYBarChart = False
;# 新生冰指数
add_ts(plot(0),ts_FYI,rts)
  rts@xyDashPattern = 0
  rts@xyLineThicknessF = 20
  rts@xyMarkLineMode = "Lines"
; add_ts(plot(0),rc_EOF1_NINO3_sig,rts)
  rts@xyLineThicknessF = 10
  rts@xyDashPattern = 1
  rts@xyLineColor = "Firebrick1"
; add_ts(plot(0),rc_EOF1_BKSST,rts)
;# 滑动相关
; add_ts(plot(0),rc_EOF1_BKSST_ns,rts)
  rts@xyDashPattern = 0
  rts@xyLineThicknessF = 20
; add_ts(plot(0),rc_EOF1_BKSST_sig,rts)
; add_ts(plot(0),rc_EOF1_BKSST_ns_sig,rts)
text := "MCA1-FYI"
  text@txFontColor = "DodgerBlue"
  text@txFontHeightF = 0.035
  text@txJust = "CenterLeft"
; add_text(plot(0),text,1979,2.6)
add_string(plot(0),text,0.215,1.305)
text = "MCA1-U200"
  text@txFontColor = "Black"
; add_text(plot(0),text,1986.5,2.6)
add_string(plot(0),text,0.4,1.305)
; text = "R1 = "+sprintf("%0.2f", R1)+", "+r2pStringDev(R1,dimsizes(year0)-2)
text = "R1 = "+R1+", "+r2pStringDev(R1,dimsizes(year0)-2)
  text@txFontColor = "Black"
add_text(plot(0),text,1981,2.6)
  text@txFontColor = "Firebrick1"
text = "R2 = "+R2+", "+r2pStringDev(R2,dimsizes(year1)-2)
add_text(plot(0),text,2003,2.67)

pgres := (/-10,10,min(year1)-0.5,max(year1)+1/)
  pgres@gsFillOpacityF = 0.05
  pgres@gsFillColor = "#ff8747"
add_fillBox(plot(0),pgres)

resp := True
  resp@gsnFrame = False
  resp@gsnPanelScalePlotIndex = 2
  resp@gsnPanelRight = 1.0
  resp@gsnPanelLeft = 0.0
  resp@gsnPanelTop = 0.75
  resp@gsnPanelXF = 0.08
  ; resp@gsnPanelXF = (/0.09,0.09/)
  ; resp@gsnPanelYF = (/0.965,0.965/)
gsn_panel(wks,plot,(/1,1/),resp)

;# 画PC1与新生冰的相关场
ts := dim_standardize_Wrap(EOF1({year}), 0)

plot := newPlots(2)
opt := True
notDrawAndFrame(opt)
  opt@gsnLeftString = genItem("a",itemType)+"   FYI";"(b) EAJII & PC1"
  opt@gsnLeftStringOrthogonalPosF = -0.1
  opt@gsnLeftStringParallelPosF = 0.06
  opt@gsnLeftStringFontHeightF = 0.045
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
  opt@vpHeightF = 0.52
  opt@Scale = 0.02
  opt@gsnRightStringFontHeightF = 0.035
  opt@gsnRightStringOrthogonalPosF = -0.1
  opt@gsnRightStringParallelPosF = 0.9
  ; opt@mpLambertParallel1F = 70.
  opt@mpLambertParallel2F = 85
; plot(3) = gsn_csm_map(wks, opt)
plot(0) = plot_base(wks,range,opt)
  delete(opt@mpLambertParallel2F)
  delete(opt@mpLambertParallel1F)
  ; opt@Scale = 0.05
; add_cor(plot(0),dim_standardize_Wrap(EOF1_p1({year1}), 0),type,range,opt)
t := t_value(dimsizes(ts)-2)
opt@Scale = 1.
opt@cnLevels = (/-t@r999,-t@r99,-t@r95,-t@r90,t@r90,t@r95,t@r99,t@r999/)
opt@cnFillDrawOrder = "PreDraw"
; BKSST_cor := escorc_n(ts, new_sic_dt({ts&year},:,:), 0, 0)
; copy_VarCoords(new_sic_dt(0,:,:), BKSST_cor)
; add_cn(plot(0),BKSST_cor,range,opt)
; opt@cnLevels = (/-4,-3,-2,-1,1,2,3,4/)
; add_cn(plot(0),new_sic_dt_cor_FYI,range,opt)
; add_cn(plot(0),new_sic_dt_cor_U200,range,opt)
add_cn(plot(0),new_sic_dt_025_cor_U200,range,opt)
; add_reg(plot(0),dim_standardize_Wrap(EOF1({year1}), 0),type,range,opt)
rlable := True
  rlable@lat_spacing = 10
  rlable@lon_spacing = 20
  rlable@lat_labels_on = False
  rlable@txFontHeightF = 0.03
  ; rlable@txAngleF = 0
add_lc_labels(plot(0),range,rlable)
box = (/76.,83, 0, 75/)
  box@gsLineColor = "DodgerBlue"
  box@gsLineDashPattern = 0
  box@gsLineThicknessF = 5
; add_lineBox(plot(0),box)
; box = (/77,79, 20, 75/)
; add_lineBox(plot(0),box)
; box = (/81,83, -2.5, 40/)
; add_lineBox(plot(0),box)
; box = (/77,80, -15, -2/)
; add_lineBox(plot(0),box)

res_polygon := True
  res_polygon@lat = (/77,84,84,82.5,77/)
  res_polygon@lon = (/-15,-5,49,53,-15/)
; add_polygon(plot(0),res_polygon)
; plot(3) = reg_dev(wks,dim_standardize_Wrap(EOF1_p1({year1}), 0),type,range,opt)
  ; range := (/70,87,-20,90/)
range=(/20,66,55,150/)
  opt@mpLambertParallel1F = 45.
  opt@mpLambertParallel2F = 50
  opt@vpHeightF = 0.5
  type@month := (/7,8/)
  type = "u"
    type@level = 200
    type@range = range
  opt@gsnLeftString = genItem("b",itemType)+"   U200";"(b) EAJII & PC1"
  opt@gsnLeftStringParallelPosF = 0.0
plot(1) = plot_base(wks,range,opt)
add_lc_labels(plot(1),range,rlable)
  opt@cnFillOn = True

; add_reg(plot(1),dim_standardize_Wrap(EOF1({year1}), 0),type,range,opt)
; add_cn(plot(1),new_sic_dt_cor_U200,range,opt)
; add_cor(plot(1),ts_U200,type,range,opt)
opt@cnFillDrawOrder = "Draw"
add_cor(plot(1),ts_FYI,type,range,opt)

res_topo := True
  res_topo@mode = "shading"
  res_topo@cnLineColor = "#686868"
  res_topo@cnLineThicknessF = 5.
  res_topo@cnFillOpacityF = 0.7
  ; res_topo@cnFillColor = "#575757"
  res_topo@cnFillColor = "Black"
  res_topo@cnFillOpacityF = 0.2
add_topo(plot(1),range,3000,res_topo)

box = (/29,39, 95, 130/)
  box@gsLineColor = "Firebrick1"
  box@gsLineDashPattern = 0
  box@gsLineThicknessF = 5
add_lineBox(plot(1),box)
box = (/45,55, 95, 125/)
add_lineBox(plot(1),box)

; add_lc_labels(plot(1),range,rlable)
  clim := "u"
    clim@source = "era5"
    clim@level = 200
    ; clim@year = year1
    clim@year = year
    clim@month = (/7,8/)
    clim@cnLevels = (/20,30/)
    clim@cnLineColor = "#0096FF"
    ; clim@plot_mode = "shading"
    ; clim@cnFillColor = "forestgreen"
    clim@cnLineThicknessF = 10
  ; plot@isShaded = (/True,True/)
  add_clim(plot(1),clim,range,True)

box = (/70,87, -20, 90/)
  box@gsLineColor = "DodgerBlue"
  box@gsLineDashPattern = 0
  box@gsLineThicknessF = 5
; add_lineBox(plot(0),box)
; add_lineBox(plot(1),box)
box = (/-5,5, 210, 270/)
; add_lineBox(plot(1),box)
;# 组图
resp := True
  resp@gsnFrame = False
  resp@gsnPanelLabelBar = True
  resp@pmLabelBarWidthF = 0.8
  resp@pmLabelBarHeightF = 0.05
  ; resp@gsnPanelScalePlotIndex = 2
  resp@gsnPanelRight = 1.0
  resp@gsnPanelLeft = 0.0
  resp@gsnPanelBottom = 0.5
  resp@pmLabelBarOrthogonalPosF = -0.0
  resp@lbTitleString = "Correlation"
  resp@lbTitlePosition = "Right"
  resp@lbTitleFontHeightF = 0.018
  resp@lbLabelFontHeightF = 0.018
  resp@lbTitleOffsetF = 0.02
  resp@lbTitleDirection = "Across"
  resp@gsnPanelYF = (/0.905,0.9/)
  resp@gsnPanelMainString = "MCA1 (FYI, U200)"
  resp@gsnPanelMainFont = 22
  resp@gsnPanelMainFontHeightF = 0.025
  resp@gsnPanelMainPosYF = 0.96
  ; resp@gsnPanelXF = (/0.09,0.09,0.09,0.562,0.09,0.562,0.09,0.562/)
  ; resp@gsnPanelYF = (/0.95,0.95,0.63,0.63,0.43,0.43,0.23,0.23/)
gsn_panel(wks,plot,(/1,2/),resp)
frame(wks)
show(fileName)
end