load "../global.ncl"
undef("addShading")
procedure addShading(plotid,upper,lower,opt)
local tem_wks,xArray,yArray,rpoly,str
begin
  tem_wks = NhlGetParentWorkstation(plotid)
  xArray = array_append_record(upper&day, lower&day(::-1), 0)
  yArray = array_append_record(upper, lower(::-1), 0)
  rpoly := True
    rpoly@gsFillColor = get_res_value_keep(opt, "gsFillColor", "Tomato")
    rpoly@gsFillOpacityF = get_res_value_keep(opt, "gsFillOpacityF", 0.1)
    rpoly@tfPolyDrawOrder = "PreDraw"
  str = unique_string("shading")
  plotid@$str$ = gsn_add_polygon(tem_wks, plotid, xArray, yArray, rpoly)
end

undef("addSpreading")
procedure addSpreading(plotid,data,opt)
local tem_wks,data_mean,data_std,upper,lower
begin
  data_mean = dim_avg_n_Wrap(data, 0)
  data_std = dim_stddev_n_Wrap(data, 0)
  upper = data_mean+0.5*data_std
  lower = data_mean-0.5*data_std
  copy_VarCoords(data_mean, upper)
  copy_VarCoords(data_mean, lower)
  addShading(plotid,upper,lower,opt)
end

undef("calcBootstrap")
function calcBootstrap(data)
local tem,std,mean
begin
  tem := bootstrap_stat(data, 0, 10000, 0, False)
  std = tem[2]
  mean = dim_avg_Wrap(data)
  mean@upper = mean+0.5*std
  mean@lower = mean-0.5*std
  mean@std = std
  print("Mean: "+mean)
  print("Std: "+std)
  print("Lower: "+(mean-0.5*std))
  print("Upper: "+(mean+0.5*std))
  return mean
end
undef("addBootstrapSpreading")
procedure addBootstrapSpreading(plotid,data,opt)
local tem_wks,data_mean,data_std,upper,lower
begin
  print("addBootstrapSpreading")
  data_mean = dim_avg_n_Wrap(data, 0)
  dim = dimsizes(data)
  data_std = new(dim(1),float)
  do i = 0, dim(1)-1
    tem := bootstrap_stat(data(:,i), 0, 10000, 0, False)
    data_std(i) = tem[2]
  end do
  copy_VarCoords(data_mean, data_std)
  upper = data_mean+0.5*data_std
  lower = data_mean-0.5*data_std
  copy_VarCoords(data_mean, upper)
  copy_VarCoords(data_mean, lower)
  addShading(plotid,upper,lower,opt)
end
begin
; itemType = "research"
itemType = "nature"
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

fileName = "figS9b_SFW"
  ; plot = newPlots(2)
  png = "png"
    png@wkHeight = 2000
    png@wkWidth = 2000
  wks = gsn_open_wks(png,fileName)




;# 计算新生冰
year_eof := year
type := "sic"
  type@year = year_eof
  ; type@source = "hadisst2"
  type@source = "era5"
  ; type@source = "cobe2"
  ; type@source = "cobe2_oisst2"
  type@month = (/1/);5或1或-12
  type@range = (/40,90,0,360/)
method := "mean"
sic_March := process(type,method)
printVarSummary(sic_March)
  type@year = year_eof
  type@month := (/-7/)
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
; BKSST_ns := dim_avg_n_Wrap(new_sic_dt(:,{76:83},{-10:75}), (/1,2/))
d2r = get_d2r("float")
lat_wgt = cos(BKSST_ns_region&lat*d2r)
BSFYI := wgt_areaave(BKSST_ns_region, lat_wgt,1, 0)
BSFYI = dim_standardize_Wrap(BSFYI, 0)
setDim(BSFYI,0,"year",year)
BSFYI0 = dim_standardize_Wrap(BSFYI({year0}), 0)
BSFYI1 = dim_standardize_Wrap(BSFYI({year1}), 0)
; posInd = ind(dim_standardize_Wrap(BSFYI({year1}), 0) .ge. 0.75)
; print(posInd)
; exit()
; f = addfile("SVD.nc", "r")
; print(f->ts_FYI)
;   negInd = (/5,7,11,12,15,16,17/)+22;2006,2012,2013,2016,2017,2018
;   posInd = (/2,3,10,13,14,18,19/)+22;2002,2003,2011,2014,2019,2020
; ; exit()
; BSFYI := f->ts_FYI

  f = addfile("uzm.nc", "r")
  ; year = ispan(2001, 2020, 1)
  uzm = f->uzm(:,59:180)
  uzm = runave_n_Wrap(uzm, 5, 0, 1)
  year = uzm&year
  clim = dim_avg_n_Wrap(uzm, 0)
  abs_uzm = abs(uzm)
  copy_VarCoords(uzm, abs_uzm)
  ; abs_uzm := 
  ; print(abs_uzm(15,:))
  ; print(uzm(15,:))
  SFW_date = dim_minind(abs_uzm({day|:},{year|:}),0)
  setDim(SFW_date,0,"year",ispan(1979,2020,1))
  SFW_date0 = dim_standardize_Wrap(SFW_date({year0})*1.0, 0)
  SFW_date1 = dim_standardize_Wrap(SFW_date({year1})*1.0, 0)

;根据MCA_FYI挑选的年份
  posInd = (/4,5,12,15,16,20,21/)+20;2003,2004,2011,2014,2015,2019,2020
  negInd = (/0,1,7,9,11,13,14,17,18,19/)+20;1999,2000,2006,2008,2012,2013,2016,2017,2018
  ; yearPos = year1(posInd)
  ; yearNeg = year1(negInd)
  ; print(yearPos)
  ; print(yearNeg)

  ; negInd = (/5,7,11,12,15,16,17/)+22;2006,2008,2012,2013,2016,2017,2018
  ; posInd = (/2,3,10,13,14,18,19/)+22;2003,2004,2011,2014,2015,2019,2020
  ; posInd = (/1,2,10,13,18,19/)+22;2002,2003,2011,2014,2019,2020
  ; negInd = (/5,12,15,16,17/)+22;2006,2013,2016,2017,2018
  uzm365 = f->uzm
  uzm365 = runave_n_Wrap(uzm365, 5, 0, 1)
  printVarSummary(uzm365)
  printVarSummary(SFW_date)
  uzmAll = new((/dimsizes(year),121/),float)
  do i = 0, dimsizes(year)-1
    uzmAll(i,:) = uzm365(i,SFW_date(i)-60+59:SFW_date(i)+60+59)
  end do

  uzmPos = new((/dimsizes(posInd),121/),float)
  uzmNeg = new((/dimsizes(negInd),121/),float)
  do i = 0, dimsizes(posInd)-1
    uzmPos(i,:) = uzm365(posInd(i),SFW_date(posInd(i))-60+59:SFW_date(posInd(i))+60+59)
  end do
  do i = 0, dimsizes(negInd)-1
    uzmNeg(i,:) = uzm365(negInd(i),SFW_date(negInd(i))-60+59:SFW_date(negInd(i))+60+59)
  end do
  uzmTrend = dim_trend_n(uzmAll(:,40:80),1)
  uzmTrend0 = dim_standardize_Wrap(uzmTrend({year0}), 0)
  uzmTrend1 = dim_standardize_Wrap(uzmTrend({year1}), 0)
  print(escorc(SFW_date0, uzmTrend0))
  print(escorc(SFW_date1, uzmTrend1))
  print(escorc(BSFYI0, uzmTrend0))
  print(escorc(BSFYI1, uzmTrend1))
  print(escorc(BSFYI0, SFW_date0))
  print(escorc(BSFYI1, SFW_date1))
  ; exit()
  uzmPosTrend = dim_trend_n(uzmPos(:,40:80),1)
  print(uzmPosTrend)
  print(avg(uzmPosTrend))
  uzmNegTrend = dim_trend_n(uzmNeg(:,40:80),1)
  print(uzmNegTrend)
  print(avg(uzmNegTrend))
  ; exit()
  earlyFW_date = SFW_date(posInd)
  lateFW_date = SFW_date(negInd)
  resEarly = calcBootstrap(uzmPosTrend)
  resLate = calcBootstrap(uzmNegTrend)
; exit()
  earlyFW = dim_avg_n_Wrap(uzmPos, 0)
  lateFW = dim_avg_n_Wrap(uzmNeg, 0)
  daysRelative = ispan(-60, 60, 1)
  setDim(uzmPos,1,"day",daysRelative)
  setDim(uzmNeg,1,"day",daysRelative)
  setDim(earlyFW,0,"day",daysRelative)
  setDim(lateFW,0,"day",daysRelative)
  print(SFW_date(posInd))
  print(SFW_date(negInd))
  ; printVarSummary(uzmPos)
  ; uzmPos = uzm(posInd-22,:)

  rts := True
  notDrawAndFrame(rts)
    rts@gsnXYBarChart = False
    rts@gsnYRefLine = 0
    rts@tmYLMode = "Explicit"
    rts@tmYLValues = (/-10,0,10,20,30,40/)
    ; rts@tmYLLabels = (/"-10","0","10","20","30"/)
    rts@tmYLFormat = "%.0f"
    ; rts@tmXBMode = "Explicit"
    ; rts@tmXBValues = (/59,90,120,151,181,212,243/)+1
    ; rts@tmXBLabels = (/"1 Mar","1 Apr","1 May","1 Jun","1 Jul","1 Aug","1 Sep"/)
    rts@minmax = (/-16,40/)
    rts@tiYAxisString = "Zonal wind (m s~S~-1~N~)"
    rts@tiYAxisFontHeightF = 0.02
    rts@tiXAxisFontHeightF = 0.02
    rts@tiXAxisString = "Relative Days"
    rts@gsnLeftString = genItem("e",itemType)+"  SFW intensity"
    rts@gsnLeftStringFontHeightF = 0.025
    rts@gsnLeftStringOrthogonalPosF = 0.018
    rts@gsnLeftStringParallelPosF = -0.05
    rts@gsnRightString = "Zonal wind at 10 hPa, 60N"
    rts@gsnRightStringFontHeightF = 0.025
    rts@gsnRightStringOrthogonalPosF = 0.02
    rts@vpHeightF = 0.65
    rts@trXMaxF = 45
    rts@trXMinF = -45
    rts@xyLineColor = "Firebrick1"
    rts@xyLineThicknessF = 15
  plot := plot_ts(wks,earlyFW,rts)
  addBootstrapSpreading(plot,uzmPos,rts)
  ; addSpreading(plot,uzmPos,rts)
    rts@gsFillColor = "Firebrick1"
    rts@xyLineColor = "DodgerBlue"
  add_ts(plot,lateFW,rts)
    rts@gsFillColor = "DodgerBlue"
  addBootstrapSpreading(plot,uzmNeg,rts)
    rts@xyLineColor = "DimGray"
    rts@xyDashPattern = 1
    rts@xyLineThicknessF = 10
  ; add_ts(plot,clim,rts)
  text = "Tendency in FYI+: "+sprintf("%0.2f", resEarly)+" ~F34~1~F21~ "+sprintf("%0.2f", resEarly@std)+" m s~S~-1~N~ day~S~-1~N~"
    text@txFontColor = "Firebrick1"
    text@txFontHeightF = 0.025
    text@txJust = "CenterLeft"
  add_text(plot,text,-26,36)
  text = "Tendency in FYI-: "+sprintf("%0.2f", resLate)+" ~F34~1~F21~ "+sprintf("%0.2f", resLate@std)+" m s~S~-1~N~ day~S~-1~N~"
    text@txFontColor = "DodgerBlue"
  add_text(plot,text,-26,31)
  pgres := (/-20,40,-20,20/)
  pgres@gsFillOpacityF = 0.04
  pgres@gsFillColor = "Black"
  add_fillBox(plot(0),pgres)
  print(clim)
  draw(plot)
  frame(wks)
  show(fileName)
end