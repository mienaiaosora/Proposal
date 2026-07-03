# ==============================================================================
# Prepare Input
# ==============================================================================
# read parcel data -------------------------------------------------------------
# tax records
file_vec1 = list.files(tax_path)
# geography
file_vec2 = list.files(paste0(int_path, "st_geo/"))
file_vec = intersect(file_vec1, file_vec2)

# job_i = 1,...length(file_vec)
job_i = commandArgs(trailingOnly=T) %>% as.integer
file_i = file_vec[[job_i]]
fips_i = str_sub(file_i, 6, 10)

dt = fread(paste0(tax_path, file_i), colClasses="character",
           select = c(id_vars,"prop_type", "year_built","eff_year_built",
                      "tax_year","assd_year","land_sqft","univ_bldg_sqft"))
to_merge = fread(paste0(int_path, "st_geo/", file_i), colClasses="character")
dt = merge(dt, to_merge, by=id_vars)

# define year
dt[, year:=ifelse(assd_year!="", assd_year, tax_year)]

# split by municipality*zoning_clean ------------------------------------------------
muni_vec = dt[muni_AFFGEOID!="", unique(muni_AFFGEOID)]
if(dt[muni_AFFGEOID!="",.N]>0){
  for(muni_i in muni_vec){
    dt_i = dt[muni_AFFGEOID==muni_i,.SD[1],
              by=c(id_vars,"muni_AFFGEOID","zoning_clean","cbg_geoid","year_built","land_sqft","univ_bldg_sqft","year")]
    fwrite(dt_i, paste0(int_path, "mla_sample/by_muni/fips_",fips_i,"_",muni_i,".csv"))
  }
}

# split by CBG -----------------------------------------------------------------
if(dt[,.N]>0){
  # by CBG
  cbg_vec = dt[,unique(cbg_geoid)]
  for(cbg_i in cbg_vec){
    dt_i = dt[cbg_geoid==cbg_i,.SD[1],by=c(id_vars,"cbg_geoid","year_built","land_sqft","univ_bldg_sqft","year")]
    fwrite(dt_i, paste0(int_path, "mla_sample/by_cbg/cbg_",cbg_i,".csv"))
  }
}

# ==============================================================================
# Detect structural break
# ==============================================================================

# function for structural break detection
source("code/mla_estimation/fn_struc_break.R")

# choice of degree of polynomial
p_degree_i = 7

# parameters to save
var1_i1 = paste0("p", p_degree_i, "_break1")
var1_i2 = paste0("p", p_degree_i, "_break2")
var1_i3 = paste0("p", p_degree_i, "_break3")
var2_i1 = paste0("p", p_degree_i, "_rss1")
var2_i2 = paste0("p", p_degree_i, "_rss2")
var2_i3 = paste0("p", p_degree_i, "_rss3")
vars_all = c(var1_i1, var1_i2, var1_i3, var2_i1, var2_i2, var2_i3)

# Detect structural break - municipality*zoning level ==========================
# County FIPS to run
file_vec = list.files(paste0(int_path, "mla_sample/by_muni/"))
fips_vec = unique(str_sub(file_vec,6,10))

# Terminal input (job_i = 1,...,length(fips_vec))
job_i = commandArgs(trailingOnly=T) %>% as.integer
fips_i = fips_vec[[job_i]]
file_vec_i = str_subset(file_vec, paste0("fips_",fips_i))

for(i in 1:length(file_vec_i)){
  
  # read MLA estimation sample (each file include SFRs in a municipality)
  dt_i0 = fread(paste0(int_path, "mla_sample/by_muni/", file_vec_i[i]),
                colClasses=c(fips="character", apn_unformatted="character", apn_num="character",zoning_clean="character",
                             muni_AFFGEOID="character",
                             year_built="integer",land_sqft="numeric",univ_bldg_sqft="numeric"))
  dt_i0[, muni:=muni_AFFGEOID]
  
  # run only if zoning_clean field is filled
  if(dt_i0[zoning_clean!="",.N]==0) next
  
  zoning_vec = dt_i0[, unique(zoning_clean)]
  for(zoning_i in zoning_vec){
    dt_i = dt_i0[zoning_clean==zoning_i]
    
    # take counts
    out_i = dt_i[,.(fips=fips_i, zoning_clean=zoning_i,
                    N_all=.SD[,.N], N_year_built=.SD[!is.na(year_built),.N],
                    N_land_sqft=.SD[!is.na(land_sqft),.N],N_univ_bldg_sqft=.SD[!is.na(univ_bldg_sqft),.N],
                    N_apn=.SD[,uniqueN(.SD),.SDcols=id_vars]), by=muni]
    
    # deduplicate by ID
    dt_i = dt_i[!is.na(land_sqft)]
    setorder(dt_i, -year, na.last=T)
    
    # Restriction on sample: note that this steps may be skipped
    # (i) if univ_bldg_sqft exists, take it
    dt_i1 = dt_i[!is.na(univ_bldg_sqft), .SD[1], by=id_vars]
    
    # (ii) if construction year exists, take it
    dt_i = merge(dt_i, dt_i1[,..id_vars][,i_exist:=1], by=id_vars, all.x=T)
    dt_i = dt_i[is.na(i_exist)][, i_exist:=NULL]
    dt_i2 = dt_i[!is.na(year_built), SD[1], by=id_vars]
    
    sample_i = rbindlist(list(dt_i1, dt_i2))
    rm(dt_i1, dt_i2, dt_i)
    # take counts
    out_i[, `:=`(sample_apn = sample_i[,.N], sample_univ_bldg_sqft = sample_i[!is.na(univ_bldg_sqft),.N], sample_year_built = sample_i[!is.na(year_built),.N],
                 sample_post40 = sample_i[year_built>=1940,.N], sample_post70 = sample_i[year_built>=1970,.N], sample_post00 = sample_i[year_built>=2000,.N])]
    
    ###### run structural detection
    # use all observations
    if(out_i[1,sample_apn]>=50){
      sample_temp = sample_i
      pcum_temp = sample_temp[,.N,land_sqft][order(land_sqft)]
      pcum_temp[, cumN:=cumsum(N)][, cump:=cumN/sum(N)][, p:=N/sum(N)]
      
      x_cands = unique(c(quantile(sample_temp$land_sqft, c(0,1,0.005)),
                         pcum_temp[order(-N)][1:100, land_sqft]))
      x_cands = x_cands[order(x_cands)]
      x_cands = x_cands[!is.na(x_cands)]
      
      i_error <- 0
      tryCatch(break_stats <- sapply(x_cands,
                                     function(x) fit_break_1(pcum_temp,
                                                             y_var = "cump", x_var="land_sqft", p_var="p", x,
                                                             x_log = T, y_log = F, p_order = p_degree_i)[[1]]),
               error = function(e) i_error <<- 1)
      
      if(i_error==0){
        break_dt <- data.table(x_var = x_cands,
                               y_var = break_stats)
        setorder(break_dt, y_var)
        
        out_i[, (var1_i1):=break_dt[1, x_var]]
        out_i[, (var2_i1):=break_dt[1, y_var]]
        
        out_i[, (var1_i2):=break_dt[2, x_var]]
        out_i[, (var2_i2):=break_dt[2, y_var]]
        
        out_i[, (var1_i3):=break_dt[3, x_var]]
        out_i[, (var2_i3):=break_dt[3, y_var]]
        
        rm(break_stats)
      } else{
        out_i[, (vars_all):=NA]
      }
    } else{
      out_i[, (vars_all):=NA]
    }
    setnames(out_i, c(var1_i1,var1_i2,var1_i3,var2_i1,var2_i2,var2_i3), paste0(c(var1_i1,var1_i2,var1_i3,var2_i1,var2_i2,var2_i3),"_all"))
    
    # use post 1940 observations
    if(out_i[1,sample_post40]>=50){
      sample_temp = sample_i[year_built>=1940]
      pcum_temp = sample_temp[,.N,land_sqft][order(land_sqft)]
      pcum_temp[, cumN:=cumsum(N)][, cump:=cumN/sum(N)][, p:=N/sum(N)]
      
      x_cands = unique(c(quantile(sample_temp$land_sqft, c(0,1,0.005)),
                         pcum_temp[order(-N)][1:100, land_sqft]))
      x_cands = x_cands[order(x_cands)]
      x_cands = x_cands[!is.na(x_cands)]
      
      i_error <- 0
      tryCatch(break_stats <- sapply(x_cands,
                                     function(x) fit_break_1(pcum_temp,
                                                             y_var = "cump", x_var="land_sqft", p_var="p", x,
                                                             x_log = T, y_log = F, p_order = p_degree_i)[[1]]),
               error = function(e) i_error <<- 1)
      
      if(i_error==0){
        break_dt <- data.table(x_var = x_cands,
                               y_var = break_stats)
        setorder(break_dt, y_var)
        
        out_i[, (var1_i1):=break_dt[1, x_var]]
        out_i[, (var2_i1):=break_dt[1, y_var]]
        
        out_i[, (var1_i2):=break_dt[2, x_var]]
        out_i[, (var2_i2):=break_dt[2, y_var]]
        
        out_i[, (var1_i3):=break_dt[3, x_var]]
        out_i[, (var2_i3):=break_dt[3, y_var]]
        
        rm(break_stats)
      } else{
        out_i[, (vars_all):=NA]
      }
    } else{
      out_i[, (vars_all):=NA]
    }
    setnames(out_i, c(var1_i1,var1_i2,var1_i3,var2_i1,var2_i2,var2_i3), paste0(c(var1_i1,var1_i2,var1_i3,var2_i1,var2_i2,var2_i3),"_post40"))
    
    # use post 1970 observations
    if(out_i[1,sample_post70]>=50){
      sample_temp = sample_i[year_built>=1970]
      pcum_temp = sample_temp[,.N,land_sqft][order(land_sqft)]
      pcum_temp[, cumN:=cumsum(N)][, cump:=cumN/sum(N)][, p:=N/sum(N)]
      
      x_cands = unique(c(quantile(sample_temp$land_sqft, c(0,1,0.005)),
                         pcum_temp[order(-N)][1:100, land_sqft]))
      x_cands = x_cands[order(x_cands)]
      x_cands = x_cands[!is.na(x_cands)]
      
      i_error <- 0
      tryCatch(break_stats <- sapply(x_cands,
                                     function(x) fit_break_1(pcum_temp,
                                                             y_var = "cump", x_var="land_sqft", p_var="p", x,
                                                             x_log = T, y_log = F, p_order = p_degree_i)[[1]]),
               error = function(e) i_error <<- 1)
      
      if(i_error==0){
        break_dt <- data.table(x_var = x_cands,
                               y_var = break_stats)
        setorder(break_dt, y_var)
        
        out_i[, (var1_i1):=break_dt[1, x_var]]
        out_i[, (var2_i1):=break_dt[1, y_var]]
        
        out_i[, (var1_i2):=break_dt[2, x_var]]
        out_i[, (var2_i2):=break_dt[2, y_var]]
        
        out_i[, (var1_i3):=break_dt[3, x_var]]
        out_i[, (var2_i3):=break_dt[3, y_var]]
        
        rm(break_stats)
      } else{
        out_i[, (vars_all):=NA]
      }
    } else{
      out_i[, (vars_all):=NA]
    }
    setnames(out_i, c(var1_i1,var1_i2,var1_i3,var2_i1,var2_i2,var2_i3), paste0(c(var1_i1,var1_i2,var1_i3,var2_i1,var2_i2,var2_i3),"_post70"))
    
    # use post 2000 observations
    if(out_i[1,sample_post00]>=50){
      sample_temp = sample_i[year_built>=2000]
      pcum_temp = sample_temp[,.N,land_sqft][order(land_sqft)]
      pcum_temp[, cumN:=cumsum(N)][, cump:=cumN/sum(N)][, p:=N/sum(N)]
      
      x_cands = unique(c(quantile(sample_temp$land_sqft, c(0,1,0.005)),
                         pcum_temp[order(-N)][1:100, land_sqft]))
      x_cands = x_cands[order(x_cands)]
      x_cands = x_cands[!is.na(x_cands)]
      
      i_error <- 0
      tryCatch(break_stats <- sapply(x_cands,
                                     function(x) fit_break_1(pcum_temp,
                                                             y_var = "cump", x_var="land_sqft", p_var="p", x,
                                                             x_log = T, y_log = F, p_order = p_degree_i)[[1]]),
               error = function(e) i_error <<- 1)
      
      if(i_error==0){
        break_dt <- data.table(x_var = x_cands,
                               y_var = break_stats)
        setorder(break_dt, y_var)
        
        out_i[, (var1_i1):=break_dt[1, x_var]]
        out_i[, (var2_i1):=break_dt[1, y_var]]
        
        out_i[, (var1_i2):=break_dt[2, x_var]]
        out_i[, (var2_i2):=break_dt[2, y_var]]
        
        out_i[, (var1_i3):=break_dt[3, x_var]]
        out_i[, (var2_i3):=break_dt[3, y_var]]
        
        rm(break_stats)
      } else{
        out_i[, (vars_all):=NA]
      }
    } else{
      out_i[, (vars_all):=NA]
    }
    setnames(out_i, c(var1_i1,var1_i2,var1_i3,var2_i1,var2_i2,var2_i3), paste0(c(var1_i1,var1_i2,var1_i3,var2_i1,var2_i2,var2_i3),"_post00"))
    
    fwrite(out_i, paste0(int_path, "mla_est/by_muni_zoning_p7.csv"), append=T)
  }
}

# Detect structural break - CBG level ==========================================

# input files to run
file_vec = list.files(paste0(int_path, "mla_sample/by_cbg/"))
cbg_dt = data.table(file = file_vec,
                    cbg = str_sub(file_vec, 5, -5),
                    ct = str_sub(file_vec, 5, -6))

# # Terminal input (for parallel computing)
# job_i = commandArgs(trailingOnly=T) %>% as.integer
# fips_i = fips_vec[[job_i]]

for(i in 1:cbg_to_run[,.N]){
  cbg_i = cbg_to_run[i, cbg]
  ct_i = cbg_to_run[i, ct]
  dt_i = fread(paste0(int_path, "mla_sample/by_cbg/", cbg_to_run[i, file]),
               colClasses=c(fips="character", apn_unformatted="character", apn_num="character",
                            cbg_geoid="character",year_built="integer",land_sqft="numeric",univ_bldg_sqft="numeric",year="integer"))
  
  # take counts
  out_i = cbg_to_run[i][, `:=`(N_all=dt_i[,.N], N_year_built=dt_i[!is.na(year_built),.N],
                               N_land_sqft=dt_i[!is.na(land_sqft),.N],N_univ_bldg_sqft=dt_i[!is.na(univ_bldg_sqft),.N],
                               N_apn=dt_i[,uniqueN(.SD),.SDcols=id_vars])]
  
  # deduplicate by ID
  dt_i = dt_i[!is.na(land_sqft)]
  setorder(dt_i, -year, na.last=T)
  
  # (i) if univ_bldg_sqft exists, take it
  dt_i1 = dt_i[!is.na(univ_bldg_sqft), .SD[1], by=id_vars]
  
  # (ii) otherwise, if construction year exists, take it
  dt_i = merge(dt_i, dt_i1[,..id_vars][,i_exist:=1], by=id_vars, all.x=T)
  dt_i = dt_i[is.na(i_exist)][, i_exist:=NULL]
  dt_i2 = dt_i[!is.na(year_built), SD[1], by=id_vars]
  
  sample_i = rbindlist(list(dt_i1, dt_i2))
  rm(dt_i1, dt_i2, dt_i)
  # take counts
  out_i[, `:=`(sample_apn = sample_i[,.N], sample_univ_bldg_sqft = sample_i[!is.na(univ_bldg_sqft),.N], sample_year_built = sample_i[!is.na(year_built),.N],
               sample_post40 = sample_i[year_built>=1940,.N], sample_post70 = sample_i[year_built>=1970,.N], sample_post00 = sample_i[year_built>=2000,.N])]
  
  ###### run structural detection
  # use all observations
  if(out_i[1,sample_apn]>=50){
    sample_temp = sample_i
    pcum_temp = sample_temp[,.N,land_sqft][order(land_sqft)]
    pcum_temp[, cumN:=cumsum(N)][, cump:=cumN/sum(N)][, p:=N/sum(N)]
    
    x_cands = unique(c(quantile(sample_temp$land_sqft, c(0,1,0.005)),
                       pcum_temp[order(-N)][1:100, land_sqft]))
    x_cands = x_cands[order(x_cands)]
    x_cands = x_cands[!is.na(x_cands)]
    
    i_error <- 0
    tryCatch(break_stats <- sapply(x_cands,
                                   function(x) fit_break_1(pcum_temp,
                                                           y_var = "cump", x_var="land_sqft", p_var="p", x,
                                                           x_log = T, y_log = F, p_order = p_degree_i)[[1]]),
             error = function(e) i_error <<- 1)
    
    if(i_error==0){
      break_dt <- data.table(x_var = x_cands,
                             y_var = break_stats)
      setorder(break_dt, y_var)
      
      out_i[, (var1_i1):=break_dt[1, x_var]]
      out_i[, (var2_i1):=break_dt[1, y_var]]
      
      out_i[, (var1_i2):=break_dt[2, x_var]]
      out_i[, (var2_i2):=break_dt[2, y_var]]
      
      out_i[, (var1_i3):=break_dt[3, x_var]]
      out_i[, (var2_i3):=break_dt[3, y_var]]
      
      rm(break_stats)
    } else{
      out_i[, (vars_all):=NA]
    }
  } else{
    out_i[, (vars_all):=NA]
  }
  setnames(out_i, c(var1_i1,var1_i2,var1_i3,var2_i1,var2_i2,var2_i3), paste0(c(var1_i1,var1_i2,var1_i3,var2_i1,var2_i2,var2_i3),"_all"))
  
  # use post 1940 observations
  if(out_i[1,sample_post40]>=50){
    sample_temp = sample_i[year_built>=1940]
    pcum_temp = sample_temp[,.N,land_sqft][order(land_sqft)]
    pcum_temp[, cumN:=cumsum(N)][, cump:=cumN/sum(N)][, p:=N/sum(N)]
    
    x_cands = unique(c(quantile(sample_temp$land_sqft, c(0,1,0.005)),
                       pcum_temp[order(-N)][1:100, land_sqft]))
    x_cands = x_cands[order(x_cands)]
    x_cands = x_cands[!is.na(x_cands)]
    
    i_error <- 0
    tryCatch(break_stats <- sapply(x_cands,
                                   function(x) fit_break_1(pcum_temp,
                                                           y_var = "cump", x_var="land_sqft", p_var="p", x,
                                                           x_log = T, y_log = F, p_order = p_degree_i)[[1]]),
             error = function(e) i_error <<- 1)
    
    if(i_error==0){
      break_dt <- data.table(x_var = x_cands,
                             y_var = break_stats)
      setorder(break_dt, y_var)
      
      out_i[, (var1_i1):=break_dt[1, x_var]]
      out_i[, (var2_i1):=break_dt[1, y_var]]
      
      out_i[, (var1_i2):=break_dt[2, x_var]]
      out_i[, (var2_i2):=break_dt[2, y_var]]
      
      out_i[, (var1_i3):=break_dt[3, x_var]]
      out_i[, (var2_i3):=break_dt[3, y_var]]
      
      rm(break_stats)
    } else{
      out_i[, (vars_all):=NA]
    }
  } else{
    out_i[, (vars_all):=NA]
  }
  setnames(out_i, c(var1_i1,var1_i2,var1_i3,var2_i1,var2_i2,var2_i3), paste0(c(var1_i1,var1_i2,var1_i3,var2_i1,var2_i2,var2_i3),"_post40"))
  
  # use post 1970 observations
  if(out_i[1,sample_post70]>=50){
    sample_temp = sample_i[year_built>=1970]
    pcum_temp = sample_temp[,.N,land_sqft][order(land_sqft)]
    pcum_temp[, cumN:=cumsum(N)][, cump:=cumN/sum(N)][, p:=N/sum(N)]
    
    x_cands = unique(c(quantile(sample_temp$land_sqft, c(0,1,0.005)),
                       pcum_temp[order(-N)][1:100, land_sqft]))
    x_cands = x_cands[order(x_cands)]
    x_cands = x_cands[!is.na(x_cands)]
    
    i_error <- 0
    tryCatch(break_stats <- sapply(x_cands,
                                   function(x) fit_break_1(pcum_temp,
                                                           y_var = "cump", x_var="land_sqft", p_var="p", x,
                                                           x_log = T, y_log = F, p_order = p_degree_i)[[1]]),
             error = function(e) i_error <<- 1)
    
    if(i_error==0){
      break_dt <- data.table(x_var = x_cands,
                             y_var = break_stats)
      setorder(break_dt, y_var)
      
      out_i[, (var1_i1):=break_dt[1, x_var]]
      out_i[, (var2_i1):=break_dt[1, y_var]]
      
      out_i[, (var1_i2):=break_dt[2, x_var]]
      out_i[, (var2_i2):=break_dt[2, y_var]]
      
      out_i[, (var1_i3):=break_dt[3, x_var]]
      out_i[, (var2_i3):=break_dt[3, y_var]]
      
      rm(break_stats)
    } else{
      out_i[, (vars_all):=NA]
    }
  } else{
    out_i[, (vars_all):=NA]
  }
  setnames(out_i, c(var1_i1,var1_i2,var1_i3,var2_i1,var2_i2,var2_i3), paste0(c(var1_i1,var1_i2,var1_i3,var2_i1,var2_i2,var2_i3),"_post70"))
  
  # use post 2000 observations
  if(out_i[1,sample_post00]>=50){
    sample_temp = sample_i[year_built>=2000]
    pcum_temp = sample_temp[,.N,land_sqft][order(land_sqft)]
    pcum_temp[, cumN:=cumsum(N)][, cump:=cumN/sum(N)][, p:=N/sum(N)]
    
    x_cands = unique(c(quantile(sample_temp$land_sqft, c(0,1,0.005)),
                       pcum_temp[order(-N)][1:100, land_sqft]))
    x_cands = x_cands[order(x_cands)]
    x_cands = x_cands[!is.na(x_cands)]
    
    i_error <- 0
    tryCatch(break_stats <- sapply(x_cands,
                                   function(x) fit_break_1(pcum_temp,
                                                           y_var = "cump", x_var="land_sqft", p_var="p", x,
                                                           x_log = T, y_log = F, p_order = p_degree_i)[[1]]),
             error = function(e) i_error <<- 1)
    
    if(i_error==0){
      break_dt <- data.table(x_var = x_cands,
                             y_var = break_stats)
      setorder(break_dt, y_var)
      
      out_i[, (var1_i1):=break_dt[1, x_var]]
      out_i[, (var2_i1):=break_dt[1, y_var]]
      
      out_i[, (var1_i2):=break_dt[2, x_var]]
      out_i[, (var2_i2):=break_dt[2, y_var]]
      
      out_i[, (var1_i3):=break_dt[3, x_var]]
      out_i[, (var2_i3):=break_dt[3, y_var]]
      
      rm(break_stats)
    } else{
      out_i[, (vars_all):=NA]
    }
  } else{
    out_i[, (vars_all):=NA]
  }
  setnames(out_i, c(var1_i1,var1_i2,var1_i3,var2_i1,var2_i2,var2_i3), paste0(c(var1_i1,var1_i2,var1_i3,var2_i1,var2_i2,var2_i3),"_post00"))
  
  fwrite(out_i, paste0(int_path, "mla_est/by_cbg_p7.csv"), append=T)
}

# ==============================================================================
# Compile results
# ==============================================================================

# parcel level =================================================================
# MLA estimate by muni*zoning
dt1 <- fread(paste0(int_path, "mla_est/by_muni_zoning_p7.csv"), colClasses=c(fips="character",zoning_clean="character"))
dt1 <- dt1[muni!="",.(fips,muni_AFFGEOID=muni,zoning_clean,
                      mla_zoning_all=p7_break1_all,mla_zoning_post40=p7_break1_post40,mla_zoning_post70=p7_break1_post70)]

# MLA estimate by CBG
dt2 <- fread(paste0(int_path, "mla_est/by_cbg_p7.csv"), colClasses=c(cbg="character"))
dt2 <- dt2[,.(cbg_geoid=cbg,mla_cbg_all=p7_break1_all,mla_cbg_post40=p7_break1_post40,mla_cbg_post70=p7_break1_post70)]
dt2[, fips:=str_sub(cbg_geoid,1,5)]

# counties to clean
fips_vec = unique(c(dt1[,fips], dt2[,fips]))

for(fips_i in fips_vec){
  
  dt = fread(paste0(tax_path, file_i), colClasses="character",
             select = c(id_vars,"prop_type", "year_built","eff_year_built",
                        "tax_year","assd_year","land_sqft","univ_bldg_sqft"))
  to_merge = fread(paste0(int_path, "st_geo/", file_i), colClasses="character")
  dt = merge(dt, to_merge, by=id_vars)
  
  # pick one recent records per parcel
  dt[, `:=`(tax_year=as.integer(tax_year), assd_year=as.integer(assd_year))]
  setorder(dt, -tax_year, -assd_year, na.last=T)
  dt = dt[,.SD[1],by=id_vars]
  
  # merge MLA estimates
  dt <- merge(dt, dt1, by=c("fips","muni_AFFGEOID","zoning_clean"), all.x=T)
  dt <- merge(dt, dt2, by=c("fips","cbg_geoid"), all.x=T)
  
  # save parcel level MLA estimates
  fwrite(dt, paste0(int_path, "mla_est/by_parcel/fips_", fips_i, ".csv"))
}

# Compile results - CBG level ==================================================
summarize_dt <- function(dt, group_vars) {
  dt[, .(
    N_apn = .N,
    N_in_muni = sum(muni_AFFGEOID != "", na.rm = TRUE),
    N_muni = uniqueN(muni_AFFGEOID[muni_AFFGEOID != ""]),
    N_mla_all = sum(!is.na(mla_est_all)),
    med_mla_all = median(mla_est_all, na.rm = TRUE),
    mean_mla_all = mean(mla_est_all, na.rm = TRUE),
    p_bind05_all = mean(i_bind05_all, na.rm = TRUE),
    p_bind05u_all = mean(i_bind05u_all, na.rm = TRUE),
    N_mla_post40 = sum(!is.na(mla_est_post40)),
    med_mla_post40 = median(mla_est_post40, na.rm = TRUE),
    mean_mla_post40 = mean(mla_est_post40, na.rm = TRUE),
    p_bind05_post40 = mean(i_bind05_post40, na.rm = TRUE),
    p_bind05u_post40 = mean(i_bind05u_post40, na.rm = TRUE),
    N_mla_post70 = sum(!is.na(mla_est_post70)),
    med_mla_post70 = median(mla_est_post70, na.rm = TRUE),
    mean_mla_post70 = mean(mla_est_post70, na.rm = TRUE),
    p_bind05_post70 = mean(i_bind05_post70, na.rm = TRUE),
    p_bind05u_post70 = mean(i_bind05u_post70, na.rm = TRUE)
  ), by = group_vars]
}

file_vec <- list.files(paste0(int_path, "mla_est/by_parcel/"))

for (file_i in file_vec) {
  dt0 <- fread(file.path(int_path, "mla_est/by_parcel", file_i),
               colClasses = c(fips = "character", apn_unformatted = "character",
                              apn_num = "character", cbg_geoid = "character",
                              zoning_clean = "character"))
  
  dt0[, ct_geoid := str_sub(cbg_geoid, 1, -2)]
  dt <- dt0[prop_type == 10 & cbg_geoid != ""]
  
  # Create MLA Estimates
  dt[, `:=`(
    mla_est_all = as.numeric(ifelse(!is.na(mla_zoning_all) & zoning_clean != "", mla_zoning_all, mla_cbg_all)),
    mla_est_post40 = as.numeric(ifelse(!is.na(mla_zoning_post40) & zoning_clean != "", mla_zoning_post40, mla_cbg_post40)),
    mla_est_post70 = as.numeric(ifelse(!is.na(mla_zoning_post70) & zoning_clean != "", mla_zoning_post70, mla_cbg_post70))
  )]
  
  # Define binding indicators
  dt[, `:=`(
    i_bind05_all = as.integer(abs(land_sqft - mla_est_all) / mla_est_all < 0.05),
    i_bind05u_all = as.integer(abs(land_sqft - mla_est_all) / mla_est_all < 0.05 & land_sqft >= mla_est_all),
    i_bind05_post40 = as.integer(abs(land_sqft - mla_est_post40) / mla_est_post40 < 0.05),
    i_bind05u_post40 = as.integer(abs(land_sqft - mla_est_post40) / mla_est_post40 < 0.05 & land_sqft >= mla_est_post40),
    i_bind05_post70 = as.integer(abs(land_sqft - mla_est_post70) / mla_est_post70 < 0.05),
    i_bind05u_post70 = as.integer(abs(land_sqft - mla_est_post70) / mla_est_post70 < 0.05 & land_sqft >= mla_est_post70)
  )]
  
  # Summarize by CBG and CT
  out_dt1 <- summarize_dt(dt, "cbg_geoid")
  out_dt2 <- summarize_dt(dt[muni_AFFGEOID!=""], "cbg_geoid")
  
  # Add sqft, built40, built70, built00
  filters <- list(
    ".sqft" = !is.na(land_sqft) & !is.na(univ_bldg_sqft),
    ".built40" = year_built >= 1940,
    ".built70" = year_built >= 1970,
    ".built00" = year_built >= 2000
  )
  
  for (suffix in names(filters)) {
    dt_f <- dt[filters[[suffix]]]
    if (nrow(dt_f) > 0) {
      out_temp1 <- summarize_dt(sub, "cbg_geoid")
      out_dt1 <- merge(out_dt1, out_temp1, by = "cbg_geoid", suffixes = c("", suffix))
      out_temp2 <- summarize_dt(sub[muni_AFFGEOID!=""], "cbg_geoid")
      out_dt2 <- merge(out_dt2, out_temp2, by = "cbg_geoid", suffixes = c("", suffix))
    }
  }
  
  # Export only parcels in municipalities
  fwrite(out_dt1, file.path(int_path, "temp/", paste0("TEMP_", file_i)))
  fwrite(out_dt2, file.path(int_path, "temp/", paste0("TEMP1_", file_i)))
}

# Consolidate TEMP Files -------------------------------------------------------
combine_temp_files <- function(prefix, out_file) {
  temp_vec <- list.files(file.path(int_path, "temp/"), prefix, full.names = TRUE)
  dt_list <- lapply(temp_vec, fread, colClasses = "character")
  dt_combined <- rbindlist(dt_list, fill = TRUE, use.names = TRUE)
  fwrite(dt_combined, file.path(int_path, "mla_est/by_geo/", out_file))
}

combine_temp_files("TEMP_", "mla_stats_cbg_all.csv")
combine_temp_files("TEMP1_", "mla_stats_cbg_muni.csv")

# Clean up TEMP files
temp_files <- list.files(file.path(int_path, "temp/"), "TEMP", full.names = TRUE)
file.remove(temp_files)

# Compile results - state level ================================================
summarize_dt_agg <- function(dt, group_vars) {
  dt[, .(
    N_apn = .N,
    N_in_muni = sum(muni_AFFGEOID != "", na.rm = TRUE),
    N_muni = uniqueN(muni_AFFGEOID[muni_AFFGEOID != ""]),
    N_mla_all = sum(!is.na(mla_est_all)),
    med_mla_all = median(mla_est_all, na.rm = TRUE),
    mean_mla_all = mean(mla_est_all, na.rm = TRUE),
    sd_mla_all = sd(mla_est_all, na.rm = TRUE),
    q1_mla_all = quantile(mla_est_all, 0.25, na.rm = TRUE),
    q3_mla_all = quantile(mla_est_all, 0.75, na.rm = TRUE),
    p_bind05_all = mean(i_bind05_all, na.rm = TRUE),
    p_bind05u_all = mean(i_bind05u_all, na.rm = TRUE),
    N_mla_post40 = sum(!is.na(mla_est_post40)),
    med_mla_post40 = median(mla_est_post40, na.rm = TRUE),
    mean_mla_post40 = mean(mla_est_post40, na.rm = TRUE),
    sd_mla_post40 = sd(mla_est_post40, na.rm = TRUE),
    q1_mla_post40 = quantile(mla_est_post40, 0.25, na.rm = TRUE),
    q3_mla_post40 = quantile(mla_est_post40, 0.75, na.rm = TRUE),
    p_bind05_post40 = mean(i_bind05_post40, na.rm = TRUE),
    p_bind05u_post40 = mean(i_bind05u_post40, na.rm = TRUE),
    N_mla_post70 = sum(!is.na(mla_est_post70)),
    med_mla_post70 = median(mla_est_post70, na.rm = TRUE),
    mean_mla_post70 = mean(mla_est_post70, na.rm = TRUE),
    sd_mla_post70 = sd(mla_est_post70, na.rm = TRUE),
    q1_mla_post70 = quantile(mla_est_post70, 0.25, na.rm = TRUE),
    q3_mla_post70 = quantile(mla_est_post70, 0.75, na.rm = TRUE),
    p_bind05_post70 = mean(i_bind05_post70, na.rm = TRUE),
    p_bind05u_post70 = mean(i_bind05u_post70, na.rm = TRUE)
  ), by = group_vars]
}

cbsa_dt = fread(paste0(map_path, "cbsa2fipsxw.csv"), colClasses="character")[2:.N]
cbsa_fips = cbsa_dt[, unique(paste0(fipsstatecode,fipscountycode))]

file_vec0 = list.files(paste0(int_path, "mla_est/by_parcel/"), full.names=T)
dt0 = lapply(file_vec0 ,function(x) fread(paste0(x), colClasses=c(fips="character",apn_unformatted="character",apn_num="character",
                                                                  cbg_geoid="character",zoning_clean="character"),
                                          select=c(id_vars,"cbg_geoid","muni_AFFGEOID","zoning_clean","prop_type","land_sqft","univ_bldg_sqft","year_built","eff_year_built",
                                                   "mla_zoning_all","mla_zoning_post40","mla_zoning_post70","mla_cbg_all","mla_cbg_post40","mla_cbg_post70")))
dt0 = rbindlist(dt0)
dt0[, state_fips:=str_sub(fips,1,2)]

# MLA estimate selection
dt0[, `:=`(mla_est_all = ifelse(!is.na(mla_zoning_all)&zoning_clean!="",mla_zoning_all,mla_cbg_all) %>% as.numeric,
           mla_est_post40 = ifelse(!is.na(mla_zoning_post40)&zoning_clean!="",mla_zoning_post40,mla_cbg_post40) %>% as.numeric,
           mla_est_post70 = ifelse(!is.na(mla_zoning_post70)&zoning_clean!="",mla_zoning_post70,mla_cbg_post70) %>% as.numeric)]

# binding ("within 5%")
dt0[, `:=`(i_bind05_all = ifelse(abs(land_sqft-mla_est_all)/mla_est_all<0.05,1,0),
           i_bind05u_all = ifelse(abs(land_sqft-mla_est_all)/mla_est_all<0.05&land_sqft>=mla_est_all,1,0),
           i_bind05_post40 = ifelse(abs(land_sqft-mla_est_post40)/mla_est_post40<0.05,1,0),
           i_bind05u_post40 = ifelse(abs(land_sqft-mla_est_post40)/mla_est_post40<0.05&land_sqft>=mla_est_post40,1,0),
           i_bind05_post70 = ifelse(abs(land_sqft-mla_est_post70)/mla_est_post70<0.05,1,0),
           i_bind05u_post70 = ifelse(abs(land_sqft-mla_est_post70)/mla_est_post70<0.05&land_sqft>=mla_est_post70,1,0))]

# loop through states
for (state_i in unique(dt0$state_fips)) {
  dt_state <- dt0[state_fips == state_i]
  if (nrow(dt_state) == 0) next
  
  for (j in 0:3) {
    dt <- switch(as.character(j),
                 '0' = dt_state,
                 '1' = dt_state[muni_AFFGEOID != ""],
                 '2' = dt_state[fips %in% cbsa_fips],
                 '3' = dt_state[muni_AFFGEOID != "" & fips %in% cbsa_fips]
    )
    
    if (nrow(dt) == 0) next
    
    out_dt1 <- summarize_dt_agg(dt, "state_fips")
    
    # Add sqft, built40, built70, built00
    filters <- list(
      ".sqft" = !is.na(land_sqft) & !is.na(univ_bldg_sqft),
      ".built40" = year_built >= 1940,
      ".built70" = year_built >= 1970,
      ".built00" = year_built >= 2000
    )
    
    for (suffix in names(filters)) {
      dt_f <- dt[filters[[suffix]]]
      if (nrow(dt_f) > 0) {
        out_temp <- summarize_dt_agg(dt_f, "state_fips")
        out_dt1 <- merge(out_dt1, out_temp, by = "state_fips", suffixes = c("", suffix))
      }
    }
    
    # Output by condition
    fname <- switch(as.character(j),
                    '0' = "mla_stats_state_all.csv",
                    '1' = "mla_stats_state_muni.csv",
                    '2' = "mla_stats_state_all_cbsa.csv",
                    '3' = "mla_stats_state_muni_cbsa.csv"
    )
    
    fwrite(out_dt1, file.path(int_path, "mla_est/by_geo/", fname), append = TRUE)
  }
}