load "../global.ncl"

begin
fig = "pdf"
  fig@wkPaperWidthF = 20
  fig@wkPaperHeightF = 20
png = "png"
  png@wkHeight = 2000
  png@wkWidth = 2000
; month = (/7,8/)
month = (/7,8/)
year = ispan(1979,2020,1)
year0 := ispan(1979, 1998, 1)
year1 := ispan(2001, 2020, 1)
; year = ispan(1958,2022,1)
EAJ_range = (/20,60,85,123/);EAJ
WPJ_range = (/20,60,123,160/);WPJ

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
detrend = True
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


; exit()
; print(EOF1)
; 补充图1 回归U200
; ts0 := dim_standardize_Wrap(designal(EAJ_EOF1,WPJ_EOF1), 0)
ts0 := BSFYI1
ts1 := BSFYI1
; ts2 := dim_standardize_Wrap(designal(WPJ_EOF1,EAJ_EOF1), 0)
ts2 := dim_standardize_Wrap(BKSST_ns({year0}), 0)
ts3 := dim_standardize_Wrap(BKSST_ns({year1}), 0)
; exit()
fileName = "fig3"
; itemType = "research"
itemType = "nature"
wks = gsn_open_wks(png,fileName)
notDrawAndFrame(opt)
type := "h"
  type@level = 200
  ; type@month := (/7,8/)
  type@month := month
  type@source = "era5"
  ; type@source = "gpcp"
  type@range = (/5,90,-180,180/)
  range := (/5,90,-180,180/)
  ranges = (/31,53,80,135/)

size = 2
  ; size@gsnLeftString = (/bold("a")+"  WPJ PC1 (EAJ PC1 removed)",bold("b")+"  WPJ PC2",bold("c")+"  EAJ PC1 (WPJ PC1 removed)",bold("d")+"  EAJ PC2"/)
  size@gsnCenterString = (/genItem("a",itemType)+"  H200 & WAF ",genItem("b",itemType)+"  LWA"/)
  size@gsnCenterStringFontHeightF = 0.04
  size@gsnCenterStringOrthogonalPosF = (/0.01,0.01/)+0.03
  size@tmXBLabelsOn = (/False,False,True,True/)
  size@tmYLLabelsOn = (/True,False,True,False/)
  size@vpHeightF = 0.6
  size@tmYLTickStartF = 10
  size@tmYLTickSpacingF = 20
  size@tmYLMode = "Explicit"
  size@tmYLValues = (/15,35,55/)
  size@tmYLLabels = (/"15N","35N","55N"/)
  size@mpProjection      = "Satellite"
  size@mpCenterLatF      = 35.
  size@mpLandFillColor = "#e9e9e9"
  size@mpCenterLonF = 100
  size@mpLimitMode = "LatLon"
  size@mpMaxLatF = 90
  size@mpMinLatF = 10
  size@mpMaxLonF = 360
  size@mpMinLonF = 0
  size@mpPerimOn = False
  size@gsnAddCyclic = True
plot = plot_bases(wks,range,size)

opt = True
notDrawAndFrame(opt)
  opt@Scale = 5.
  opt@lbLabelBarOn = True
  opt@reverseColors = False
  opt@stipplingLevel = 95
  opt@gsnAddCyclic = True
  opt@cnFillDotSizeF = 0.004
  opt@lbLabelFormat = "%0.0f"
  opt@lbTitleString = "Geopotential Height (gpm)"
  opt@lbTitleFontHeightF = 0.022
  ; opt@lbTitleOffsetF = 0.5
  opt@lbTitleDirection = "Across"
  opt@lbTitleAngleF = -90
  opt@lbTitlePosition = "Right"
  opt@lbBoxSeparatorLinesOn = False
  opt@pmLabelBarOrthogonalPosF = 0.04
  ; print(type)
add_reg(plot(0),ts0,type,range,opt)
type = "tcc"
  type@source = "era5"
  opt@Scale = 0.01
; add_reg(plot(1),ts1,type,range,opt)

  res_waf = True
    res_waf@vcRefMagnitudeF = 1
    res_waf@vcRefLengthF = 0.06
    res_waf@vcRefAnnoPerimOn = False
    res_waf@vcRefAnnoString1 = "1 m~S~2~N~ s~S~-2~N~"
    res_waf@vcRefAnnoFontHeightF = 0.025
    res_waf@vcMinMagnitudeF = 0.25
  range(1) = 75
  type@range = range
  add_waf_dev(plot(0),ts0,type,range,res_waf)
  ; add_waf_dev(plot(1),BSFYI1,type,range,res_waf)


  ; add_clim(plot(1),clim,range,True)
; box := EAJ_range
; box := WPJ_range
;   box@gsLineColor = "Magenta"
;   box@gsLineThicknessF = 7.
;   box@gsLineDashPattern = 1
; add_lineBox(plot(1),box)
; add_lineBox(plot(3),box)
; box = EAJ_range
; add_lineBox(plot(0),box)
; add_lineBox(plot(2),box)
; box = (/45, 51, 100, 130/)
;   box@gsLineColor = "Tomato"
;   box@gsLineDashPattern = 0
; add_lineBox(plot,box)
; box = (/31, 37, 100, 130/)
; add_lineBox(plot,box)


;# LWA
;LWA只能从1979开始
type := "lwa"
  ; type@source = "ersstv5"
  type@source = "era5"
  type@month = (/7,8/)
  type@range := (/0,90,-80,260/)
  type@level = 200
opt := True
notDrawAndFrame(opt)
  opt@cnFillDotSizeF = 0.0045
  opt@cnFillDotOpacityF = 0.9
  opt@cnFillScaleF = 1.2
  opt@stipplingColor = "white"
  opt@lbLabelBarOn = True
  opt@lbLabelStride = 1
  opt@smoothing = True
  opt@lbTitleString = "LWA (m s~S~-1~N~)"
  ; opt@lbTitleJust = "CenterLeft"
  opt@lbTitlePosition = "Right"
  opt@lbTitleAngleF = -90
  ; opt@cnFillColors := (/"#407933","#72BF4F","#9BCE7F","#C1E0B8","#FFFFFF","#F6E9BC","#F1CD5C","#F0BF2A","#bd932a","#A57E1E"/)
  ; opt@cnFillColors := (/"#51538e","#7572a3","#b3aec8","#eae7ed","#FFFFFF","#f6d9d6","#eb9998","#f48176","#ff4134","#d70e00"/)
  opt@lbLabelFormat = "%0.1f"
  opt@lbBoxSeparatorLinesOn = False

  opt@cnLevels := (/-4,-3,-2,-1,1,2,3,4/)
  opt@cnFillColors = (/"#407933","#72BF4F","#9BCE7F","#C1E0B8","#FFFFFF","#F6E9BC","#F1CD5C","#F0BF2A","#A57E1E"/)
  ; opt@cnFillColors = (/"#3AA142","#68B75D","#9BCB94","#CCE6C7","#FFFFFF","#FEF5C7","#FEC554","#FEA52C","#F4602A","#C42A1D"/)
  ; opt@cnLevels = (/-3,-2,-1.5,-1,-0.5,0.5,1,1.5,2,3/)*2
  opt@lbLabelFontHeightF = 0.022
  opt@lbTitleFontHeightF = 0.022
  opt@lbLabelStrings = (/"-4","-3","-2","-1","1","2","3","4"/)
  ; opt@lbLabelConstantSpacingF = 0.6
  ; opt@lbLabelAngleF = -45
  ; opt@lbLabelFontHeightF = 0.025
  opt@Scale = 1
  ; opt@multi = 2.0
; plot@isShaded(1) = True
type@year = ts1&year
method := "anom"
lwa := process(type,method)
lwa_reg := regCoef_n(ts1, lwa, 0, 0)
copy_VarCoords(lwa(0,:,:), lwa_reg)
tem := lwa_reg({0:45},{0:180})
; lwa_reg({0:45},{0:180}) = where(tem > 0, 0, tem)
; lwa_reg({0:40},{50:120}) = 0
lwa_reg({0:15},{0:180}) = 0
  opt@cnFillOn = True
  opt@cnLinesOn = False
  opt@lbTitleDirection = "Across"
  opt@lbOrientation = "Vertical"
  ; opt@lbTitleOffsetF = 1.0
  ; opt@pmLabelBarWidthF = 0.09
  ; opt@pmLabelBarHeightF = 0.45
  opt@pmLabelBarOrthogonalPosF = 0.04
add_cn(plot(1),lwa_reg,ranges,opt)



tval := get_tval(lwa_reg)
t := t_value(22)
res_test := True
notDrawAndFrame(res_test)
  if(isatt(opt,"stipplingColor"))
    res_test@stipplingColor = opt@stipplingColor
  end if
  ; if(isatt(opt, "cnFillDotOpacityF"))then
  ;   res_test@cnFillOpacityF = opt@cnFillDotOpacityF
  ; end if
  ; if(isatt(opt, "dotDrawOrder"))then
  ;   res_test@dotDrawOrder = opt@dotDrawOrder
  ;   ; print(opt@dotDrawOrder)
  ; end if
  level = 95
  res_test@cnLevel = t@$("t"+level)$
  res_test@hatchingPattern = 8
  res_test@hatchingColor = "White"
  res_test@cnFillDotSizeF = 0.0045
  res_test@cnFillScaleF = 1.2
  res_test@cnFillDotOpacityF = 0.8
  add_dots(plot(1),tval,ranges,res_test)


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
    clim@source = "jra55"
    clim@level = 200
    clim@year = year
    clim@month = month
    clim@cnLevels = (/20,30/)
    clim@cnLineColor = "#0096FF"
    ; clim@plot_mode = "shading"
    ; clim@cnFillColor = "forestgreen"
    clim@cnLineThicknessF = 10
  plot@isShaded = (/True,True/)
  add_clim(plot(0),clim,range,True)
  add_clim(plot(1),clim,range,True)

resp := True
  resp@gsnFrame = False
  resp@gsnPanelLabelBar = False 
  resp@pmLabelBarWidthF = 0.7
  resp@pmLabelBarHeightF = 0.06
  resp@lbLabelFormat = (/"%0.0f","%0.1f"/)
  ; resp@pmLabelBarOrthogonalPosF = 0.0
  resp@lbOrientation = "Horizontal"
  ; setLabelbar(resp)
  resp@lbLabelFontHeightF = 0.017
  resp@lbTitlePosition = "right"
  resp@lbTitleString = (/"gpm","days month~S~-1~N~"/)
  resp@lbTitleJust = "CenterLeft"
  resp@lbTitleDirection = "Across"
  resp@lbTitleFontHeightF = 0.017
  resp@lbTitleOffsetF = 0.03
  resp@gsnPanelLabelBarPlotIndex = (/0/)
  resp@pmLabelBarOrthogonalPosF = (/0.03/)
  resp@pmLabelBarParallelPosF = (/0.1,0.1/)-0.012
  ; setLabelbarTitle(resp,"Correlation")
  resp@gsnPanelXWhiteSpacePercent = 10.
  ; resp@gsnPanelXF = (/0.06,0.52,0.06,0.52,0.06/)
  resp@gsnPanelYF = (/0.95,0.95/)
  resp@gsnPanelXF = (/0.01,0.53/)
  resp@gsnPanelScaleF = (/0.45,0.45/)
  ; resp@gsnPanelRight = 0.985
  ; resp@gsnPanelLeft = 0.015
gsn_panel(wks,plot,(/1,2/),resp)

;# 剖面
opt := True
notDrawAndFrame(opt)
  opt@gsnCenterString = genItem("c",itemType)+" Meridional Section (H & T)"
  opt@gsnCenterStringFontHeightF = 0.05
  opt@gsnCenterStringOrthogonalPosF = 0.01
  opt@vpWidthF = 0.9
  opt@vpHeightF = 0.6
  opt@tmXBTickSpacingF = 20
  opt@tmYLTickSpacingF = 25
  opt@mpProjection      = "Satellite"
  opt@mpCenterLatF      = 35.
  opt@mpLandFillColor = "transparent"
  opt@mpCenterLonF = 85
  opt@mpLimitMode = "LatLon"
  opt@mpMaxLatF = 67
  opt@mpMinLatF = 7
  opt@mpMaxLonF = 150
  opt@mpMinLonF = 0
  opt@mpPerimOn         = False 
  opt@gsnMaximize = False
  opt@gsnFrame = False
  opt@gsnDraw = False
  opt@dim_to_mean = "lon"
  ; opt@mpGeophysicalLineThicknessF = 3
range := (/15,70,90,125,1000,20/)

plot := plot_topo(wks,range,opt)
type = "h"
  type@range := range
  opt@add_dim_to_mean = "lon"
  opt@Scale = 3
  opt@lbLabelFormat = "%0.0f"
  opt@lbLabelFontHeightF = 0.035
  opt@pmLabelBarOrthogonalPosF = 0.125
  opt@lbTitleString = "Geopotential Height (gpm)"
  opt@lbTitleFontHeightF = 0.04
  opt@lbTitleOffsetF = 0.2
  opt@lbTitleDirection = "Across"
  opt@lbTitleAngleF = -90
  opt@lbTitlePosition = "Right"
  opt@lbBoxSeparatorLinesOn = False
  ; print(type)
  opt@cnFillDotSizeF = 0.004
  opt@cnFillScaleF = 1.5
  opt@stipplingColor = "#aeffae"
  opt@lbLabelsOn = True
  opt@lbOrientation = "Vertical"
  opt@pmLabelBarHeightF = 0.7
  opt@pmLabelBarWidthF = 0.22
add_reg(plot,ts1,type,range,opt)
;   opt@Scale := 0.1
; type = "rh"
; add_reg(plot(1),BSFYI1,type,range,opt)

type = "t"
  opt@Scale := 0.2
  opt@cnFillOn = False
  opt@cnLinesOn = True
  opt@cnLineColors = (/"DodgerBlue","DodgerBlue","DodgerBlue","DodgerBlue","#ff4929","#ff4929","#ff4929","#ff4929"/)
  opt@cnLineThicknessF = 15
  opt@mode = "hatching"
  opt@hatchingColor = "#ff4929"
  opt@hatchingNegativeColor = "DodgerBlue"
  opt@hatchingRepeat = 5
  opt@hatchingOpacity = 0.1
  ; opt@cnFillScaleF = 1.13
  opt@cnFillScaleF = 0.38
add_reg(plot,ts1,type,range,opt)


; plot(0) = plot_base(wks,range,opt)

resp := True
  resp@gsnFrame = False
  resp@gsnPanelScaleF = 0.34
  resp@gsnPanelXF = 0.05
  resp@gsnPanelYF = 0.6
gsn_panel(wks,plot,(/1,1/),resp)


  ; range=(/15,70,55,165/)
  range:=(/20,66,55,150/)
  type@range := range
size := 3
  ; size@gsnLeftString = (/bold("a")+"  WPJ PC1 (EAJ PC1 removed)",bold("b")+"  WPJ PC2",bold("c")+"  EAJ PC1 (WPJ PC1 removed)",bold("d")+"  EAJ PC2"/)
  size@gsnCenterString = (/genItem("d",itemType)+"  Q850",genItem("e",itemType)+"  Downward thermal radiation",genItem("f",itemType)+"  NET-Heatwave"/)
  size@gsnCenterStringFontHeightF = 0.045
  size@gsnCenterStringOrthogonalPosF = (/0.02,0.02,0.02/)
  size@tmXBLabelsOn = (/False,False,True,True/)
  size@tmYLLabelsOn = (/True,False,True,False/)
  size@tmYLTickStartF = 10
  size@tmYLTickSpacingF = 20
  size@tmYLMode = "Explicit"
  size@tmYLValues = (/15,35,55/)
  size@tmYLLabels = (/"15N","35N","55N"/)
  size@mpCenterLatF      = 35.
  size@mpLandFillColor = "#e9e9e9"
  size@mpCenterLonF = 100
  ; size@mpLimitMode = "LatLon"
  ; size@mpMaxLatF = 90
  ; size@mpMinLatF = 10
  ; size@mpMaxLonF = 360
  ; size@mpMinLonF = 0
  size@mpPerimOn = False
  size@mpProjection          = "LambertConformal"
  size@gsnMaskLambertConformal = True
  size@vpWidthF = 1.0
  size@vpHeightF = 0.55
  size@gsnRightStringFontHeightF = 0.035
  size@gsnRightStringParallelPosF = 0.9
  ; size@mpLambertParallel1F = 70.
  size@mpLambertParallel2F = 85
  size@mpLambertParallel1F = 45.
  size@mpLambertParallel2F = 50
plot := plot_bases(wks,range,size)

opt := True
notDrawAndFrame(opt)
  opt@Scale = 5
  opt@lbLabelBarOn = True
  opt@lbOrientation = "Vertical"
  opt@reverseColors = False
  opt@stipplingLevel = 95
  opt@cnSmoothingOn = True
  opt@cnSmoothingTensionF = -0.5
  opt@cnSmoothingDistanceF = 0.005
  opt@smoothing = True
type = "q"
  type@level = 850
  ; opt@Scale := 200000000
  ; opt@Scale := 100000
  opt@Scale := 1
  opt@lbLabelFormat = "%0.0f"
  opt@lbTitleString = "Specific humidity (10~S~-4~N~ g/kg)"
  opt@lbTitleDirection = "Across"
  opt@lbTitleAngleF = -90
  opt@lbTitlePosition = "Right"
  opt@lbTitleFontHeightF = 0.02
  opt@lbLabelFontHeightF = 0.018
  opt@multi = 10000
  opt@gsnAddCyclic = False
  opt@pmLabelBarOrthogonalPosF = 0.005
  opt@pmLabelBarHeightF = 0.69
  type@source = "era5"
add_reg(plot(0),ts0,type,range,opt)
type = "strd"
  opt@Scale := 1
  opt@multi := 1./86400
  opt@lbTitleString = "Radiation (W m~S~-2~N~)"
  opt@lbLabelFontHeightF = 0.018
add_reg(plot(1),ts1,type,range,opt)
type = "net75p"
  type@source = "era5_land"
  opt@lbTitleString = "days month~S~-1~N~"
  opt@Scale := 1.5
  opt@multi := 1.
  opt@reverseColors = False
  opt@lbLabelFormat = "%0.1f"
add_cor(plot(2),ts1,type,range,opt)
  
; add_reg(plot(2),ts1,type,range,opt)
; add_reg(plot(2),ts1,type,range,opt)

rlable := True
  rlable@lat_spacing = 20
  rlable@lon_spacing = 25
  rlable@lat_labels_on = False
  rlable@txFontHeightF = 0.03
  ; rlable@txAngleF = 0
add_lc_labels(plot(0),range,rlable)
add_lc_labels(plot(1),range,rlable)
add_lc_labels(plot(2),range,rlable)

res_topo := True
  res_topo@mode = "shading"
  res_topo@cnLineColor = "#686868"
  res_topo@cnLineThicknessF = 5.
  res_topo@cnFillOpacityF = 0.7
  ; res_topo@cnFillColor = "#575757"
  res_topo@cnFillColor = "Black"
  res_topo@cnFillOpacityF = 0.2
add_topo(plot,range,3000,res_topo)
resp := True
  resp@gsnFrame = False
  resp@gsnPanelLabelBar = False 
  resp@pmLabelBarWidthF = 0.7
  resp@pmLabelBarHeightF = 0.06
  resp@lbLabelFormat = (/"%0.1f"/)
  ; resp@pmLabelBarOrthogonalPosF = 0.0
  resp@lbOrientation = "Horizontal"
  ; setLabelbar(resp)
  resp@lbLabelFontHeightF = 0.017
  resp@lbTitlePosition = "right"
  resp@lbTitleString = (/"days month~S~-1~N~"/)
  resp@lbTitleJust = "CenterLeft"
  resp@lbTitleDirection = "Across"
  resp@lbTitleFontHeightF = 0.017
  resp@lbTitleOffsetF = 0.03
  resp@gsnPanelLabelBarPlotIndex = (/0/)
  resp@pmLabelBarOrthogonalPosF = (/0.02/)
  resp@pmLabelBarParallelPosF = (/0.1/)-0.012
  ; setLabelbarTitle(resp,"Correlation")
  resp@gsnPanelYWhiteSpacePercent = 5.
  resp@gsnPanelXF = (/0.53,0.005,0.53/)
  resp@gsnPanelYF = (/0.6,0.3,0.3/)
  resp@gsnPanelScaleF = (/0.38,0.38,0.38/)
  ; resp@gsnPanelBottom = 0.5
  ; resp@gsnPanelRight = 0.985
  ; resp@gsnPanelLeft = 0.015
gsn_panel(wks,plot,(/2,2/),resp)

frame(wks)
; delete(wks)
; system("gs -q -sDEVICE=png16m -sBATCH -sOutputFile="+fileName+".png -dNOPAUSE -r200 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 "+fileName+".pdf")
show(fileName+".png")
end