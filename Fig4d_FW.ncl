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

year1 = ispan(1999,2020,1)
; itemType = "research"
itemType = "nature"
f = addfile("SVD_P2.nc", "r")
print(f->ts_FYI)

;根据MCA_FYI挑选的年份
  posInd = (/4,5,12,15,16,20,21/);2003,2004,2011,2014,2015,2019,2020
  negInd = (/0,1,7,9,11,13,14,17,18,19/);1999,2000,2006,2008,2012,2013,2016,2017,2018
  yearPos = year1(posInd)
  yearNeg = year1(negInd)
  print(yearPos)
  print(yearNeg)

  ; posInd = (/2,3,10,13,14,18,19/)+22;2003,2004,2011,2014,2015,2019,2020
  ; negInd = (/5,7,11,12,15,16,17/)+22;2006,2008,2012,2013,2016,2017,2018
; exit()
BSFYI = f->ts_FYI
; BSFYI = (/-0.1906466,-0.2202076,0.3017961,-0.2642168,-1.766028,1.046185,0.9495315,0.8736283,0.1728881,-0.4203425,0.2987599,-1.31519,-0.05420229,-0.05854241,0.2416735,-0.735483,1.367486,1.551911,0.09805374,-0.003689864,-1.636702,-1.157498,-0.5761648,1.204698,1.309243,-0.2938702,-0.0008426936,-1.647578,0.7958208,-0.3194281,0.1309869,-0.42946,2.279365,-0.8538249,-0.5509521,1.319118,0.2055681,-1.566771,-0.6647437,-1.734879,1.38911,0.9254416/)
; BSFYI = dtrend(BSFYI, True)
; setDim(BSFYI,0,"year",ispan(1979,2020,1))
  f = addfile("uzm.nc", "r")
  ; year = ispan(2001, 2020, 1)
  uzm = f->uzm(:,59:180)
  uzm = runave_n_Wrap(uzm, 5, 0, 1)
  year = uzm&year
  clim = dim_avg_n_Wrap(uzm({year1},:), 0)
  abs_uzm = abs(uzm)
  copy_VarCoords(uzm, abs_uzm)
  ; abs_uzm := 
  ; print(abs_uzm(15,:))
  ; print(uzm(15,:))
  SFW_date = dim_minind(abs_uzm({day|:},{year|:}),0)*1.0
  setDim(SFW_date,0,"year",ispan(1979,2020,1))
  ; SFW_date = (/dtrend_n(SFW_date, True,0)/)
  ; posInd = (/1,2,10,13,18,19/)+22;2002,2003,2011,2014,2019,2020
  ; negInd = (/5,12,15,16,17/)+22;2006,2013,2016,2017,2018
  ; negInd = (/5,12,15,16,17/)+22;2006,2013,2016,2017,2018

  ; uzm := (uzm({year},:))
  ; print(SFW_date_dt)
  ; exit()
  ; print(clim)
  ;pos:1,2,10,13,18,19
;neg:5,12,15,16,17
  earlyFW = dim_avg_n_Wrap(uzm({yearPos},:), 0)
  print(earlyFW)
  lateFW = dim_avg_n_Wrap(uzm({yearNeg},:), 0)
  print(lateFW)
  dateEarly = SFW_date({yearPos})
  dateLate = SFW_date({yearNeg})
  print(avg(dateEarly))
  print(avg(dateLate))
  ; exit()

  nEarly = dimsizes(yearPos)
  nLate = dimsizes(yearNeg)
  nCLim = dimsizes(year)
  temEarly = ((nEarly-1)*variance(dateEarly)+(nCLim-1)*variance(SFW_date))/(nEarly+nCLim-2)
  tvalEarly = (avg(dateEarly)-avg(SFW_date))/(sqrt(variance(dateEarly))*sqrt(1./nEarly+1./nCLim))
  print(tvalEarly)
  t = t_value(nCLim+nEarly-2)
  print(t)

  ; tem = ttest(avg(dateEarly), variance(dateEarly), dimsizes(dateEarly), avg(SFW_date), variance(SFW_date), dimsizes(SFW_date), False, False)
  ; tem = ttest(avg(dateLate), variance(dateLate), dimsizes(dateLate), avg(SFW_date), variance(SFW_date), dimsizes(SFW_date), False, False)
;   anomEarly = clim-earlyFW
;   anomLate = clim-lateFW
;   varEarly = dim_variance_n_Wrap(uzm(posInd,:), 0)
;   varLate = dim_variance_n_Wrap(uzm(negInd,:), 0)
;   varCLim = dim_variance_n_Wrap(uzm, 0)
;   nEarly = dimsizes(posInd)
;   nLate = dimsizes(negInd)
;   nCLim = dimsizes(year)
;   temEarly = ((nEarly-1)*varEarly+(nCLim-1)*varCLim)/(nEarly+nCLim-2)
;   temLate = ((nLate-1)*varLate+(nCLim-1)*varCLim)/(nLate+nCLim-2)
;   copy_VarCoords(earlyFW, temEarly)
;   copy_VarCoords(lateFW, temLate)
;   tvalEarly = anomEarly/sqrt(varEarly)*sqrt(nEarly)

;   ; tvalEarly = anomEarly/(sqrt(temEarly)*sqrt(1./nEarly+1./nCLim))
;   tvalLate = anomLate/sqrt(temLate)
;   t = t_value(nCLim+nEarly-2)
;   print(tvalEarly)
;   ; print(tvalLate)
;   print(t)




  fileName = "figS9a_SFW"
  png = "png"
    png@wkHeight = 2000
    png@wkWidth = 2000
  wks = gsn_open_wks(png,fileName)
  rts := True
  notDrawAndFrame(rts)

    rts@gsnXYBarChart = False
    rts@gsnYRefLine = 0
    rts@tmYLMode = "Explicit"
    rts@tmYLValues = (/-10,0,10,20,30,40/)
    ; rts@tmYLLabels = (/"-10","0","10","20","30"/)
    rts@tmYLFormat = "%.0f"
    rts@tmXBMode = "Explicit"
    rts@tmXBValues = (/59,     90,     104,    120,    134,     151,    181,    212,    243/)+0.55
    rts@tmXBLabels = (/"1 Mar","1 Apr","15 Apr","1 May","15 May","1 Jun","1 Jul","1 Aug","1 Sep"/)
    rts@minmax = (/-16,30/)
    rts@tiYAxisString = "Zonal wind (m s~S~-1~N~)"
    rts@tiYAxisFontHeightF = 0.02
    rts@tiXAxisFontHeightF = 0.02
    rts@tiXAxisString = "Days"
    rts@gsnLeftString = genItem("d",itemType)+"  SFW date"
    rts@gsnLeftStringFontHeightF = 0.025
    rts@gsnLeftStringOrthogonalPosF = 0.02
    rts@gsnLeftStringParallelPosF = -0.05
    rts@gsnRightString = "Zonal wind at 10 hPa, 60N"
    rts@gsnRightStringFontHeightF = 0.025
    rts@gsnRightStringOrthogonalPosF = 0.014
    rts@vpHeightF = 0.65
    rts@trXMaxF = 150
    rts@trXMinF = 75
    rts@xyLineColor = "Firebrick1"
    rts@xyLineThicknessF = 15
  plot := plot_ts(wks,earlyFW,rts)
  addBootstrapSpreading(plot,uzm({yearPos},:),rts)
    rts@gsFillColor = "Firebrick1"
    rts@xyLineColor = "DodgerBlue"
  add_ts(plot,lateFW,rts)
    rts@gsFillColor = "DodgerBlue"
  addBootstrapSpreading(plot,uzm({yearNeg},:),rts)
    rts@xyLineColor = "DimGray"
    ; rts@xyDashPattern = 1
    rts@xyLineThicknessF = 10
  add_ts(plot,clim,rts)
  text = "FYI+ (15 Apr)"
    text@txFontColor = "Firebrick1"
    text@txFontHeightF = 0.025
    text@txJust = "CenterLeft"
  add_text(plot,text,104,27)
  text = "FYI- (26 Apr)"
    text@txFontColor = "DodgerBlue"
  add_text(plot,text,115,11)
  text = "Clim (20 Apr)"
    text@txFontColor = "DimGray"
  add_text(plot,text,108.7,19)
  res_line := True
    res_line@gsLineColor = "Firebrick1"
    res_line@gsLineDashPattern = 1
    res_line@gsLineThicknessF = 5

  add_line(plot,(/80,80/)+24.55,(/-20,25/),res_line)
    res_line@gsLineColor = "DimGray"
  add_line(plot,(/80,80/)+29.6,(/-20,17/),res_line)
    res_line@gsLineColor = "DodgerBlue"
  add_line(plot,(/80,80/)+35.5,(/-20,9/),res_line)
  print(clim)
  draw(plot)
  frame(wks)
  show(fileName)
  ; print(dim_avg_n_Wrap(uzm(posInd,:), 0))
  ; print(dim_avg_n_Wrap(uzm(negInd,:), 0))
end