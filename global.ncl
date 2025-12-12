begin ;记录全局参数
  ; start_time = get_cpu_time()
  pwd = systemfunc("pwd")
  if(isStrSubset(pwd,"/Users/linlifei/code/"))
    localpath = (/"/Volumes/Libra/","/Users/linlifei/","/Volumes/Libra/","/Users/linlifei/code/ncl/"/)
    loadPath = "/Users/linlifei/code/ncl/ncl_lib/"
  elseif(isStrSubset(pwd,"/home/ys17-23/LLF/code/"))
    localpath := (/"/home/ys17-23/Extension2/llf/","/home/ys17-23/Extension2/llf/","/home/ys17-23/Extension2/llf/","/home/ys17-23/LLF/code/ncl/"/)
    loadPath = "/home/ys17-23/LLF/code/ncl/ncl_lib/"
  elseif(isStrSubset(pwd,"/home/llf/code/"))
    localpath := (/"/SSD1/","/data/","/SSD1/","/home/llf/code/ncl/"/)
    ; localpath := (/"/data/","/data/","/data/","/home/llf/code/ncl/"/)
    loadPath = "/home/llf/code/ncl/ncl_lib/"
  end if
  call_stream = NewList("fifo")
  bufferPath = localpath(1)+"buffer/"
  bufferMode = "disabled"
  bufferIdList = NewList("fifo")
  bufferFileList = NewList("fifo")
  bufferCount = 0
  ; localpath = (/"/mnt/c/data/","/mnt/c/data/","/mnt/c/data/"/)
  clr = (/"#407933","#6CB650","#9BCE7F","#C1E0B8","#FFFFFF","#F6E9BC","#F1CD5C","#F0BF2A","#A57E1E"/)
  script = get_script_prefix_name()
  except = (/"_FillValue","mode","time","tval","nptxy","rstd","yintercept","forecast_time","initial_time","average_op_ncl","sub_center","level_indicator","gds_grid_type","parameter_table_version","parameter_number","forecast_time_units","statistical_process_descriptor","statistical_process_duration"/)
  res_plot = (/"am","cn","gs","gsn","lb","lg","mp","pm","pr","sf","tf","ti","tm","tr","tx","vc","vf","vp","wk","ws","xy","Scale"/)
  global = (/-90,90,0,360/)
  NH = (/0,90,0,360/)
  NH_ex = (/20,90,0,360/)
  SH = (/-90,0,0,360/)
  levels       := (/1000,975,950,925,900,875,850,825,800,775,750,700,650,600,550,500,450,400,350,300,250,225,200,175,150,125,100/)
end
loadscript(loadPath+"sub_toolbox.ncl")
loadscript(loadPath+"sub_read.ncl")
loadscript(loadPath+"sub_calc.ncl")
loadscript(loadPath+"sub_plot.ncl")