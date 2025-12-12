load "../global.ncl"

begin
folder = localpath(3)+"SIC/figs/" ;"EAJ_plot"
fig = "pdf"
  fig@wkPaperWidthF = 20
  fig@wkPaperHeightF = 20
png = "png"
  png@wkHeight = 2000
  png@wkWidth = 2000
; year := ispan(1979, 2020, 1)
year := ispan(1979, 2020, 1)
year0 := ispan(1979, 1998, 1)
; year1 := ispan(2001, 2020, 1)
year1 := ispan(1999, 2020, 1)

; f = addfile("hgtzm.nc", "r")
; hgtzm = f->hgtzm
f = addfile("PCH.nc", "r")
hgtzm = f->PCH({year1},:,:)
hgtzm = (/hgtzm/9.8/)

hgtzm_2003 = hgtzm({2003},:,:)
hgtzm_anom = dim_rmvmean_n_Wrap(hgtzm_2003, 0)
; tzm_2003 = tzm({2003},:,:)
; tzm_anom = dim_rmvmean_n_Wrap(tzm_2003, 0)
print(dim_avg_n_Wrap(hgtzm(2,{30:60},{700:200}), (/1/)))
print(dim_avg_n_Wrap(hgtzm(2,{60:90},{700:200}), (/1/)))
hgtzm_2003(44,:) = hgtzm_2003(43,:)
hgtzm_2003(45,:) = hgtzm_2003(46,:)
print(hgtzm_2003(:,{1000}))
hgtzm({2003},:,:) = hgtzm_2003
; exit()
printVarSummary(hgtzm)
; exit()
f = addfile("tzm.nc", "r")
tzm = f->tzm({year1},:,:)

f = addfile("VTEddyZM.nc", "r")
VTEddyZM = f->VTEddyZM
VTEddyZM := VTEddyZM({year1},:)

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
method = "anom"
  method@detrend = True
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
new_sic_dt := dtrend_n(new_sic, True, 0)
copy_VarCoords(sic_March, new_sic_dt)
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

ts := BSFYI1
printVarSummary(hgtzm)
printVarSummary(ts)
;pos:1,2,10,13,18,19
;neg:5,12,15,16,17
print(ts)
; exit()
; hgtzm = (/smth9_Wrap(hgtzm, 0.25, 0.5, False)/)
; tzm = (/smth9_Wrap(tzm, 0.25, 0.5, False)/)
slidingWindow = 5
hgtzm = runave_n_Wrap(hgtzm, slidingWindow, 0, 1)
tzm = runave_n_Wrap(tzm, slidingWindow, 0, 1)
VTEddyZM = runave_n_Wrap(VTEddyZM, slidingWindow, 0, 1)
; VTEddyZM = runave_n_Wrap(VTEddyZM, 40, 0, 1)
; printVarSummary(tem)
; exit()
; cor_hgtzm = (/smth9_Wrap(cor_hgtzm, 0.25, 0.5, False)/)
rec_hgtzm = regCoef_n(ts,hgtzm, 0, 0)

cor_hgtzm = escorc_n(ts,hgtzm, 0, 0)
rec_tzm = regCoef_n(ts,tzm, 0, 0)
cor_tzm = escorc_n(ts,tzm, 0, 0)
rec_VTEddyZM = regCoef_n(ts,VTEddyZM, 0, 0)
cor_VTEddyZM = escorc_n(ts,VTEddyZM, 0, 0)
; rec_hgtzm = (/smth9_Wrap(rec_hgtzm, 0.25, 0.5, False)/)
; cor_hgtzm = (/smth9_Wrap(cor_hgtzm, 0.25, 0.5, False)/)

copy_VarCoords(hgtzm(0,:,:), rec_hgtzm)
copy_VarCoords(hgtzm(0,:,:), cor_hgtzm)
copy_VarCoords(tzm(0,:,:), rec_tzm)
copy_VarCoords(tzm(0,:,:), cor_tzm)
copy_VarCoords(VTEddyZM(0,:), rec_VTEddyZM)
copy_VarCoords(VTEddyZM(0,:), cor_VTEddyZM)
; print(rec_VTEddyZM)
; print(cor_VTEddyZM)
; exit()

;# 剖面
fileName = "fig4"
plot := newPlots(3)
wks = gsn_open_wks(png,fileName)
; itemType = "research"
itemType = "nature"
t = t_value(dimsizes(year1)-2)
; print(t)
; exit()
res := True
notDrawAndFrame(res)
  res@cnFillOn = True
  res@cnLinesOn = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = (/-30,-20,-10,-5,-4,-3,-1,1,3,4,5,7,10,15/)*10
  ; res@cnLevels = (/-t@r999,-t@r99,-t@r95,-t@r90,t@r90,t@r95,t@r99,t@r999/)
  res@cnFillColors = (/"#223868","#105797","#1B71B6","#2392C9","#28A0CE","#4EC0D9","#98D6E3","#FFFFFF","#F6B8AA","#F28D75","#EE6B54","#EA463B","#E82229","#BE252B","#871E20"/)

  ; res@cnFillColors = (/"#407933","#72BF4F","#9BCE7F","#C1E0B8","#FFFFFF","#F6E9BC","#F1CD5C","#F0BF2A","#A57E1E"/)
  ; res@lbLabelStrings = sprintf("%0.2f", res@cnLevels)
  res@tmYROn = False
  ; res@tiYAxisOn = False
  res@lbLabelFontHeightF = 0.02
  res@lbOrientation = "Vertical"
  res@lbTitleString = "Correlation"
  res@lbTitlePosition = "Right"
  res@lbTitleDirection = "Across"
  res@lbTitleAngleF = 90
  res@lbTitleFontHeightF = 0.02
  res@lbTitleOffsetF = 0.2
  res@lbLabelBarOn = False
  res@pmLabelBarOrthogonalPosF = 0.01
  res@pmLabelBarWidthF = 0.08
  res@vpWidthF = 0.9
  res@vpHeightF = 0.36
  res@cnFillDotSizeF = 0.03
  res@gsnMaximize = True
  res@tmXBMinorOn = False
  ; res@tmYLLabelStride = "3"
  res@tiYAxisString = "Pressure Level"
  res@tiYAxisFontHeightF = 0.023
  res@tiYAxisOffsetXF = 0.004
  res@tmYLMode = "Explicit"
  res@tmYLValues = (/1000.,  700., 400.,  200.,100.,   50., 20., 10.,5, 1./)
  res@tmYLLabels = (/"1000","700","400","200",\
                         "100", "50", "20", "10","5", "1"/)
  res@trYMaxF = 850
  res@tmXBTickSpacingF = 1
  res@tmXTOn = False
  res@tmXBMode = "Explicit"
  res@tmXBValues = (/0,31,59,90,120,151,181,212,243/)
  res@tmXBLabels = (/"1 Jan","1 Feb","1 Mar","1 Apr","1 May","1 Jun","1 July","1 Aug","1 Sep"/)
  res@tmXBLabelsOn = False
  res@gsnLeftString = genItem("a",itemType)+"  H Section"
  res@gsnLeftStringParallelPosF = 0
  res@gsnLeftStringOrthogonalPosF = 0.01
  res@gsnLeftStringFontHeightF = 0.025
  res@gsnRightString = "65N-90N"
  res@gsnRightStringFontHeightF = 0.025
  res@gsnRightStringOrthogonalPosF = 0.01
  res@tmYLMajorLengthF = 0.013
  res@tmYLMajorOutwardLengthF = 0.013
  res@tmYLLabelFontHeightF = 0.025
  res@tmYLLabelDeltaF = -0.5
  res@gsnPresHgtHeightLabelOn = False
  res@cnInfoLabelOn = False
  res@cnLineLabelsOn = False
  res@trXMaxF = 242
  res@trXMinF = 0
  res@cnLevels := (/-0.7,-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.1,0.2,0.3,0.4,0.5,0.6,0.7/)
  ; res@cnLevels := (/-0.7,-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.1,0.2,0.3,0.4,0.5,0.6,0.7/)*1000

; plot(0) = gsn_csm_pres_hgt(wks, rec_hgtzm({lev|:},{day|:}), res)
plot(0) = gsn_csm_pres_hgt(wks, cor_hgtzm({lev|:},{day|:}), res)
; plot(0) = gsn_csm_pres_hgt(wks, hgtzm_anom({lev|:},{day|:}), res)
t = t_value(dimsizes(year1)-2)
; print(t)
  ; res@cnLevels := (/-0.7,-0.6,-0.55,-0.5,-0.45,-0.4,-t@r90,t@r90,0.4,0.45,0.5,0.55,0.6,0.7/)
  res@cnLevels := (/-0.7,-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.1,0.2,0.3,0.4,0.5,0.6,0.7/)
  ; res@cnLevels := (/-0.7,-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.1,0.2,0.3,0.4,0.5,0.6,0.7/)*6
  ; res@cnLevels := (/-4,-3,-2,-1,1,2,3,4/)*0.1;*50
  res@gsnLeftString = genItem("b",itemType)+"  T Section"
  res@lbTitleString = "Correlation"
  res@lbLabelBarOn = True
  res@pmLabelBarHeightF = 0.08
  res@pmLabelBarWidthF = 0.9
  res@pmLabelBarOrthogonalPosF = 0.05
  res@lbTitleOffsetF = 0.03
  res@lbTitleAngleF = 0
  res@lbLabelAutoStride = False
  res@lbOrientation = "Horizontal"
  res@lbLabelStrings = (/"-.7","-.6","-.5","-.4","-.3","-.2","-.1",".1",".2",".3",".4",".5",".6",".7"/)
; plot(1) = gsn_csm_pres_hgt(wks, tzm_anom({lev|:},{day|:}), res)
plot(1) = gsn_csm_pres_hgt(wks, cor_tzm({lev|:},{day|:}), res)
res_dots = True
  res_dots@cnLevel = t@r90
  ; res_dots@gsFillDotSizeF = 0.001
  res_dots@cnFillScaleF = 1.5
  res_dots@cnFillDotSizeF = 0.004
add_dots(plot(0),cor_hgtzm({lev|:},{day|:}),(/1/),res_dots)
add_dots(plot(1),cor_tzm({lev|:},{day|:}),(/1/),res_dots)
reso := True
notDrawAndFrame(reso)
  reso@cnFillOn = True
  reso@cnLinesOn = False
  reso@cnLevelSelectionMode = "ExplicitLevels"
  reso@lbLabelBarOn = False
  reso@cnLevels = (/-t@r90,t@r90/)
  reso@cnFillPatterns = (/17,-1,17/)
  reso@cnFillColors = (/"Grey","White","Grey"/)
  reso@cnFillDotSizeF = 0.004
  reso@cnMonoFillPattern = False
  reso@cnInfoLabelOn = False
  reso@cnLineLabelsOn = False
; plot_H = gsn_csm_contour(wks, polar_H_cor({level|:},{month|:}), reso)
; overlay(plot(0), plot_H)
; plot_T = gsn_csm_contour(wks, polar_T_cor({level|:},{month|:}), reso)
; overlay(plot(1), plot_T)

;# 热通量
rts = True
notDrawAndFrame(rts)
  rts@vpHeightF = 0.27
  rts@trXMaxF = 242
  rts@trXMinF = 0
  ; rts@gsnXYBarChart = False
  rts@gsnYRefLine = 0
  rts@gsnXYBarChartBarWidth = 1.0
  rts@gsnXYBarChartColors = "Grey"
  rts@xyLineColor = "transparent"
  rts@gsnLeftString = genItem("c",itemType)+"  Poleward heat flux"
  rts@gsnLeftStringFontHeightF = 0.022
  rts@gsnLeftStringParallelPosF = 0
  rts@gsnLeftStringOrthogonalPosF = 0.01
  rts@tmYLLabelFontHeightF = 0.018
  rts@tmXBLabelFontHeightF = 0.018
  rts@tmBorderThicknessF = 2
  rts@tmXBMode = "Explicit"
  rts@tmXBValues = (/0,31,59,90,120,151,181,212,243/)
  rts@tmXBLabels = (/"1 Jan","1 Feb","1 Mar","1 Apr","1 May","1 Jun","1 July","1 Aug","1 Sep"/)
  rts@tiXAxisString = "Time (day)"
  rts@tiXAxisFontHeightF = 0.018
  rts@tiYAxisString = "[v'T'] (K m s~S~-1~N~)"
  rts@tiYAxisFontHeightF = 0.018
  rts@gsnRightString = "45N-75N"
  rts@gsnRightStringFontHeightF = 0.022
  rts@vpWidthF = 0.795
  rts@minmax = (/-7.5,6.2/)
  rts@tmYLValues = (/-6,-3,0,3,6/)
  ; rts@gsnXRefLine = 111
plot(2) = plot_ts(wks,rec_VTEddyZM,rts)
rec_VTEddyZM_sig = where(abs(cor_VTEddyZM) .ge. t@r90,rec_VTEddyZM,rec_VTEddyZM@_FillValue)
copy_VarCoords(rec_VTEddyZM, rec_VTEddyZM_sig)
; cor_VTEddyZM = (/cor_VTEddyZM*6/)
  ; rts@xyLineColor = "DodgerBlue"
  ; rts@gsnXYBarChart = True
  ; rts@gsnxybafi
;   rts@xyLineColor = "Red"
;   rts@gsnBelowYRefLineColor = "Red"
;   rts@gsnAboveYRefLineColor = "Red"
;   rts@gsnabov
;   ; rts@gsnXYBelowFillColors = 
; add_ts(plot(2),rec_VTEddyZM_sig,rts)
rec_VTEddyZM_sig@gsnBelowYRefLineBarColors = "Tomato"
rec_VTEddyZM_sig@gsnAboveYRefLineBarColors = "DodgerBlue"
rec_VTEddyZM_sig@gsnXYBarChartBarWidth = 1.0
res_line := True
  res_line@gsLineThicknessF = 10
  res_line@gsLineColor = "Green3"
  res_line@tfPolyDrawOrder = "PostDraw"
; add_line(plot(0),(/109,109/),(/10,900/),res_line)
; add_line(plot(1),(/109,109/),(/10,900/),res_line)
text = "Clim. SFW (20th Apr)"
  text@txFontColor = "Green3"
  text@txFontHeightF = 0.02
add_text(plot(2),text,155,-6.5)
; add_line(plot(2),(/111,111/),(/-6,6/),res_line)
; rec_VTEddyZM_sig@polyBox = (/111,2,10,1/)
add_bar(plot(2),rec_VTEddyZM_sig)
resp := True
  resp@gsnFrame = False
  resp@gsnPanelYF = (/0.965,0.64,0.27/)
  resp@gsnPanelScaleF = (/0.7,0.7,0.755/)
  ; resp@gsnPanelBottom = 0.05
gsn_panel(wks,plot,(/3,1/),resp)
gsn_polyline_ndc(wks,(/0.461,0.461/)+0.025,(/0.062,0.964/),res_line)
frame(wks)
show(fileName+".png")
end