# ==============================================================================
# Additional setup
# ==============================================================================

# border region bandwidth: 1km, ..., 10km
border_vec = c(paste0(0,1:9), "10")

# border sample path
sample_path = paste0(int_path, "sample_by_dist/")

# intermediate files for sample building
sample_int = paste0(int_path, "border_sample/")

# input data: border parcels and MLA estimates
seg_path = paste0(int_path, "border_seg_parcels/")
mla_path = paste0(int_path, "mla_est/by_parcel/")

# ==============================================================================
# Deed (transaction) sample
# ==============================================================================

file_vec = list.files(deed_path)
for(file_i in file_vec){
  print(paste0("Working on: ", file_i))
  print(Sys.time())
  
  dt_i = fread(paste0(deed_path, file_i), colClasses= c(apn_unformatted = "character", fips="character", apn_num="character"),
                select = c(id_vars, "sale_price_adj", "sale_dt","sale_year"))
  setnames(dt_i, "sale_year", "sale_yr")
  dt_i[nchar(fips)==4, fips:=paste0(0,fips)]
  
  # border parcels
  fips_vec0 = dt_i[,unique(fips)]
  fips_vec1 = list.files(seg_path, "fips") %>% str_sub(6,10)
  fips_vec2 = list.files(mla_path) %>% str_sub(6,10)
  fips_vec3 = list.files(tax_path) %>% str_sub(6,10)
  fips_vec = intersect(fips_vec0, fips_vec1) %>% intersect(fips_vec2) %>% intersect(fips_vec3)
  
  print(paste0("----- ", length(fips_vec), " counties"))
  for(fips_j in fips_vec){
    
    # selectborder parcels
    bord_j = fread(paste0(seg_path, "fips_", fips_j, ".csv"), colClasses= c(apn_unformatted = "character", fips="character", apn_num="character"))
    bord_j[nchar(fips)==4, fips:=paste0(0,fips)]
    out_dt = merge(bord_j, dt_i[fips==fips_j], by=id_vars)
    
    # merge characteristics from Parcel Data
    chars_j = fread(paste0(tax_path, "fips_", fips_j, ".csv"), colClasses= c(apn_unformatted = "character", fips="character", apn_num="character"),
                     select=c(id_vars, "prop_type","land_use","year_built","eff_year_built","land_sqft","univ_bldg_sqft","bed_n","rooms_n","calc_bath_n"))
    
    chars_j = chars_j[,.SD[1],by=id_vars]
    out_dt = merge(out_dt, chars_j, by=id_vars)
    
    # merge MLA estimates
    mla_j = fread(paste0(mla_path, "fips_", fips_j, ".csv"), colClasses= c(apn_unformatted = "character", fips="character", apn_num="character"),
                   select=c(id_vars,"id_muni","zoning_clean",
                            "mla_zoning_all","mla_zoning_post40","mla_zoning_post70","mla_cbg_all","mla_cbg_post40","mla_cbg_post70"))
    mla_j[, `:=`(mla_est_all=ifelse(id_muni!=""&zoning_clean!=""&mla_zoning_all,mla_zoning_all,mla_cbg_all),
                 mla_est_post40=ifelse(id_muni!=""&zoning_clean!=""&mla_zoning_post40,mla_zoning_post40,mla_cbg_post40),
                 mla_est_post70=ifelse(id_muni!=""&zoning_clean!=""&mla_zoning_post70,mla_zoning_post70,mla_cbg_post70))]
    mla_j = mla_j[,.SD,.SDcols=c(id_vars,"mla_est_all","mla_est_post40","mla_est_post70")]
    out_dt = merge(out_dt, mla_j, by=id_vars)
    
    fwrite(out_dt, paste0(sample_int, "deed/fips_",fips_j,".csv"))
  }
}

# ==============================================================================
# Deed+HMDA (Demographics) sample
# ==============================================================================

file_vec = list.files(hmda_path)
for(file_i in file_vec){
  print(paste0("Working on: ", file_i))
  print(Sys.time())
  
  dt_i = fread(paste0(hmda_path, file_i), colClasses= c(apn_unformatted = "character", fips="character", apn_num="character"),
                select = c(id_vars, "sale_price_adj","sale_yr","inc_clean","race_ethnicity"))
  
  # border parcels
  fips_vec0 = dt_i[,unique(fips)]
  fips_vec1 = list.files(seg_path, "fips") %>% str_sub(6,10)
  fips_vec2 = list.files(mla_path) %>% str_sub(6,10)
  fips_vec3 = list.files(tax_path) %>% str_sub(6,10)
  fips_vec = intersect(fips_vec0, fips_vec1) %>% intersect(fips_vec2) %>% intersect(fips_vec3)
  
  print(paste0("----- ", length(fips_vec), " counties"))
  for(fips_j in fips_vec){
    # select border parcels
    bord_j = fread(paste0(seg_path, "fips_", fips_j, ".csv"), colClasses= c(apn_unformatted = "character", fips="character", apn_num="character"))
    bord_j[nchar(fips)==4, fips:=paste0(0,fips)]
    out_dt = merge(bord_j, dt_i[fips==fips_j], by=id_vars)
    
    # merge characteristics from Parcel Data
    chars_j = fread(paste0(tax_path, "fips_", fips_j, ".csv"), colClasses= c(apn_unformatted = "character", fips="character", apn_num="character"),
                     select=c(id_vars, "prop_type","land_use","year_built","eff_year_built","land_sqft","univ_bldg_sqft","bed_n","rooms_n","calc_bath_n"))
    
    chars_j = chars_j[,.SD[1],by=id_vars]
    out_dt = merge(out_dt, chars_j, by=id_vars)
    
    # merge MLA estimates
    mla_j = fread(paste0(mla_path, "fips_", fips_j, ".csv"), colClasses= c(apn_unformatted = "character", fips="character", apn_num="character"),
                   select=c(id_vars,"id_muni","zoning_clean",
                            "mla_zoning_all","mla_zoning_post40","mla_zoning_post70","mla_cbg_all","mla_cbg_post40","mla_cbg_post70"))
    mla_j[, `:=`(mla_est_all=ifelse(id_muni!=""&zoning_clean!=""&mla_zoning_all,mla_zoning_all,mla_cbg_all),
                 mla_est_post40=ifelse(id_muni!=""&zoning_clean!=""&mla_zoning_post40,mla_zoning_post40,mla_cbg_post40),
                 mla_est_post70=ifelse(id_muni!=""&zoning_clean!=""&mla_zoning_post70,mla_zoning_post70,mla_cbg_post70))]
    mla_j = mla_j[,.SD,.SDcols=c(id_vars,"mla_est_all","mla_est_post40","mla_est_post70")]
    out_dt = merge(out_dt, mla_j, by=id_vars)
    
    fwrite(out_dt, paste0(sample_int, "hmda/fips_",fips_j,".csv"))
  }
}

# ==============================================================================
# MLS (rentals) sample
# ==============================================================================

file_vec = list.files(mls_path)
for(file_i in file_vec){
  print(paste0("Working on: ", file_i))
  print(Sys.time())
  
  dt_i = fread(paste0(mls_path, file_i), colClasses= c(CMAS_FIPS_CODE = "character", CMAS_PARCEL_ID="character", CMAS_PARCEL_SEQ_NBR="character"),
                select = c("CMAS_FIPS_CODE","CMAS_PARCEL_ID","CMAS_PARCEL_SEQ_NBR",
                           "FA_PropertyType","FA_PropertySubType","FA_LandUse","LotSizeAreaSqFeet","BuildingAreaTotal","LivingArea",
                           "close_year","list_year","year","ClosePrice_adj","ListPrice_adj","FA_PricePerSqFt_adj"))
  setnames(dt_i, c("CMAS_FIPS_CODE","CMAS_PARCEL_ID","CMAS_PARCEL_SEQ_NBR"), id_vars)
  dt_i[nchar(fips)==4, fips:=paste0(0,fips)]
  
  # select border parcels
  fips_vec0 = dt_i[,unique(fips)]
  fips_vec1 = list.files(seg_path, "fips") %>% str_sub(6,10)
  fips_vec2 = list.files(mla_path) %>% str_sub(6,10)
  fips_vec3 = list.files(tax_path) %>% str_sub(6,10)
  fips_vec = intersect(fips_vec0, fips_vec1) %>% intersect(fips_vec2) %>% intersect(fips_vec3)
  
  print(paste0("----- ", length(fips_vec), " counties"))
  if(length(fips_vec)==0) next
  for(fips_j in fips_vec){
    
    # border parcels
    bord_j = fread(paste0(seg_path, "fips_", fips_j, ".csv"), colClasses= c(apn_unformatted = "character", fips="character", apn_num="character"))
    bord_j[nchar(fips)==4, fips:=paste0(0,fips)]
    out_dt = merge(bord_j, dt_i[fips==fips_j], by=id_vars)
    
    # merge characteristics from Parcel Data
    chars_j = fread(paste0(tax_path, "fips_", fips_j, ".csv"), colClasses= c(apn_unformatted = "character", fips="character", apn_num="character"),
                     select=c(id_vars, "prop_type","land_use","year_built","eff_year_built","land_sqft","univ_bldg_sqft","bed_n","rooms_n","calc_bath_n"))
    
    chars_j = chars_j[,.SD[1],by=id_vars]
    out_dt = merge(out_dt, chars_j, by=id_vars)
    
    # merge MLA estimates
    mla_j = fread(paste0(mla_path, "fips_", fips_j, ".csv"), colClasses= c(apn_unformatted = "character", fips="character", apn_num="character"),
                   select=c(id_vars,"id_muni","zoning_clean",
                            "mla_zoning_all","mla_zoning_post40","mla_zoning_post70","mla_cbg_all","mla_cbg_post40","mla_cbg_post70"))
    mla_j[, `:=`(mla_est_all=ifelse(id_muni!=""&zoning_clean!=""&mla_zoning_all,mla_zoning_all,mla_cbg_all),
                 mla_est_post40=ifelse(id_muni!=""&zoning_clean!=""&mla_zoning_post40,mla_zoning_post40,mla_cbg_post40),
                 mla_est_post70=ifelse(id_muni!=""&zoning_clean!=""&mla_zoning_post70,mla_zoning_post70,mla_cbg_post70))]
    mla_j = mla_j[,.SD,.SDcols=c(id_vars,"mla_est_all","mla_est_post40","mla_est_post70")]
    out_dt = merge(out_dt, mla_j, by=id_vars)
    
    fwrite(out_dt, paste0(sample_int, "mls/fips_",fips_j,".csv"))
  }
}

# =======================================================
# Save sample by bandwidth
# =======================================================

# select border regions or segments with variation in MLA estimates ------------
border_chars = fread(paste0(seg_path, "border_chars.csv"), colClasses="character")
border_chars[nchar(fips)==4, fips:=paste0(0,fips)]
border_chars = border_chars[SD_mla_est_post40>0,.(fips,grp_border,i_border=1,N_ipums.a,N_ipums.b,N_ipums.bord)]

bordseg_chars = fread(paste0(seg_path, "bordseg_chars.csv"), colClasses="character")[grp_bordseg!=""]
bordseg_chars[nchar(fips)==4, fips:=paste0(0,fips)]
bordseg_chars[, type_bordseg:=str_sub(grp_bordseg,1,-3)]
bordseg_chars[, i_variation:=ifelse(SD_mla_est_post40>0,1,0)]
temp = bordseg_chars[,.(i_variation=min(i_variation)),by=.(fips,type_bordseg)]
bordseg_chars = merge(bordseg_chars, temp[i_variation==1,.(fips,type_bordseg)],
                       by=c("fips","type_bordseg"))[,.(fips,grp_bordseg,i_bordseg=1)]

# compile all sample data ------------------------------------------------------
# run in batch script (job_i = 1,2,3)
dataset_vec = list("hmda","mls","deed")
job_i = commandArgs(trailingOnly=T) %>% as.integer
dataset_i = dataset_vec[[job_i]]

print(paste0("==========",dataset_i))

input_path = paste0(sample_int, dataset_i, "/")
input_vec = list.files(input_path)

for(input_i in input_vec){

  if(which(input_vec==input_i)%%10==1){
    print(paste0("Working on ",which(input_vec==input_i)," among ",length(input_vec)))
  }

  dt = fread(paste0(input_path, input_i), colClasses="character")

  # merge border region, seg2, seg3, seg4, within school districts
  dt = merge(dt, border_chars, by=c("fips","grp_border"), all.x=T)
  dt[kmeans_2!="", grp_bordseg2:=paste0(grp_border,"_C2_",kmeans_2)]
  dt[kmeans_3!="", grp_bordseg3:=paste0(grp_border,"_C3_",kmeans_3)]
  dt[kmeans_4!="", grp_bordseg4:=paste0(grp_border,"_C4_",kmeans_4)]
  dt[, `:=`(i_cluster=NULL,kmeans_2=NULL,kmeans_3=NULL,kmeans_4=NULL,kmeans_5=NULL,kmeans_6=NULL,kmeans_7=NULL,kmeans_8=NULL)]
  dt = merge(dt, bordseg_chars, by.x=c("fips","grp_bordseg2"), by.y=c("fips","grp_bordseg"), all.x=T)
  dt = merge(dt, bordseg_chars, by.x=c("fips","grp_bordseg3"), by.y=c("fips","grp_bordseg"), suffixes=c("",".C3"), all.x=T)
  dt = merge(dt, bordseg_chars, by.x=c("fips","grp_bordseg4"), by.y=c("fips","grp_bordseg"), suffixes=c(".C2",".C4"), all.x=T)

  dt[, `:=`(type_bordseg2 = str_sub(grp_bordseg2, 1, -3),
            type_bordseg3 = str_sub(grp_bordseg3, 1, -3),
            type_bordseg4 = str_sub(grp_bordseg4, 1, -3))]

  dt = dt[i_border==1]
  if(dt[i_border==1,.N]>0){
    for(bord_i in bord_vec){
      bord_var = paste0("n_dup_", bord_i)
      dt_i = dt[get(bord_var)==1]
      dt = dt[get(bord_var)==""]

      if(dt_i[,.N]>0){
        # select smallest border regions with at least 20 observations on each side
        by_bord4 = dt_i[!is.na(i_bordseg.C4),.(N.a = .SD[AFFGEOID==AFFGEOID.a,.N],
                                               N.b = .SD[AFFGEOID==AFFGEOID.b,.N]),
                        by = .(type_bordseg4,grp_bordseg4)]
        by_bord4 = by_bord4[N.a>=20&N.b>=20,.N,by=type_bordseg4][N==4,.(type_bordseg4)]
        by_bord3 = dt_i[!is.na(i_bordseg.C3),.(N.a = .SD[AFFGEOID==AFFGEOID.a,.N],
                                               N.b = .SD[AFFGEOID==AFFGEOID.b,.N]),
                        by = .(type_bordseg3,grp_bordseg3)]
        by_bord3 = by_bord3[N.a>=20&N.b>=20,.N,by=type_bordseg3][N==3,.(type_bordseg3)]
        by_bord2 = dt_i[!is.na(i_bordseg.C2),.(N.a = .SD[AFFGEOID==AFFGEOID.a,.N],
                                               N.b = .SD[AFFGEOID==AFFGEOID.b,.N]),
                        by = .(type_bordseg2,grp_bordseg2)]
        by_bord2 = by_bord2[N.a>=20&N.b>=20,.N,by=type_bordseg2][N==2,.(type_bordseg2)]
        by_bord1 = dt_i[!is.na(i_border),.(N.a = .SD[AFFGEOID==AFFGEOID.a,.N],
                                           N.b = .SD[AFFGEOID==AFFGEOID.b,.N]),
                        by = .(grp_border)]
        by_bord1 = by_bord1[N.a>=20&N.b>=20,grp_border]

        dt_i[type_bordseg4%in%by_bord4, clean_bord:=paste0(fips,"_",grp_bordseg4)]
        dt_i[type_bordseg3%in%by_bord3&is.na(clean_bord), clean_bord:=paste0(fips,"_",grp_bordseg3)]
        dt_i[type_bordseg2%in%by_bord2&is.na(clean_bord), clean_bord:=paste0(fips,"_",grp_bordseg2)]
        dt_i[grp_border%in%by_bord1&is.na(clean_bord), clean_bord:=paste0(fips,"_",grp_border)]

        dt_i = dt_i[!is.na(clean_bord),.SD,.SDcols=-c(paste0("n_dup_",bord_vec),"i_border","i_bordseg.C2","i_bordseg.C3","i_bordseg.C4",
                                                      "grp_bordseg2","grp_bordseg3","grp_bordseg4","grp_border",
                                                      "type_bordseg2","type_bordseg3","type_bordseg4")]
        setcolorder(dt_i, "clean_bord")

        if(dt_i[,.N]>0){
          fwrite(dt_i, paste0(sample_path, dataset_i, "_", bord_i, ".csv"), append=T)
        }
      }
    }
  }
}

# add IPUMS covariates ------------------------------------------------------
# municipality characteristics from geocoded 1940 full-count data
ipums_muni = fread(paste0(data_path, "ipums40_chars_muni.csv"), colClasses="character")
ipums_vars = names(ipums_muni)[6:31]
ipums_muni = ipums_muni[,.SD,.SDcols=c("AFFGEOID",ipums_vars)]
setnames(ipums_muni, ipums_vars, paste0("IPUMSM_",ipums_vars))

# run in batch script (job_i = 1,...10)
job_i = commandArgs(trailingOnly=T) %>% as.integer
bord_i = bord_vec[[job_i]]
sample_vec = list.files(sample_path, paste0(bord_i,".csv"))

# merge variables
for(sample_i in sample_vec){
  print(paste0("Working on: ", sample_i))

  dt_i = fread(paste0(sample_path, sample_i), colClasses="character")
  dt_i = merge(dt_i, ipums_muni, by=c("AFFGEOID"), all.x=T)
  dt_i = merge(dt_i, ipums_bord, by=c("AFFGEOID","AFFGEOID.a","AFFGEOID.b"), all.x=T)

  # remove duplicate vars
  var1 = str_subset(names(dt_i),"\\.y")
  dt_i[, (var1):=NULL]
  var2 = str_subset(names(dt_i),"\\.x")
  setnames(dt_i, var2, str_replace(var2, "\\.x",""))

  fwrite(dt_i, paste0(sample_path, sample_i))
}

# ==============================================================================
# Additional cleaning (incld. variable cleaning, outlier removal, missing data)
# ==============================================================================

# run in batch script (job_i = 1,...10)
job_i = commandArgs(trailingOnly=T) %>% as.integer
bord_i = bord_vec[[job_i]]

for(dataset_i in c("deed","hmda","mls")){
  print(paste0("Working on ",dataset_i, bord_i))
  
  if(dataset_i == "deed"){
    dt = fread(paste0(sample_path, "deed_",bord_i,".csv"))
    dt = dt[,unique(.SD)]
    dt[, `:=`(eff_year_built=ifelse(!is.na(eff_year_built),eff_year_built,year_built))]
    dt = merge(dt, cbsa_dt[,.(fips=as.numeric(fips),cbsa)], by="fips", all.x=T)
  }
  
  if(dataset_i == "hmda"){
    dt = fread(paste0(sample_path, "hmda_",bord_i,".csv"))
    dt = dt[,unique(.SD)]
    dt[, `:=`(eff_year_built=ifelse(!is.na(eff_year_built),eff_year_built,year_built))][race_ethnicity!="", `:=`(i_white=ifelse(race_ethnicity=="White",1,0),i_black=ifelse(race_ethnicity=="Black",1,0),i_hispan=ifelse(race_ethnicity=="Hispanic",1,0),
                                                                                                                 i_asian=ifelse(race_ethnicity=="AsianPacific",1,0))]
    dt = merge(dt, cbsa_dt[,.(fips=as.numeric(fips),cbsa)], by="fips", all.x=T)
  }
  
  if(dataset_i == "mls"){
    dt = fread(paste0(sample_path, "mls_",bord_i,".csv"))
    dt = dt[,unique(.SD)]
    dt[, `:=`(eff_year_built=ifelse(!is.na(eff_year_built),eff_year_built,year_built))]
    dt = merge(dt, cbsa_dt[,.(fips=as.numeric(fips),cbsa)], by="fips", all.x=T)
  }
  
  # variable cleaning - numerical variables
  num_vars0 = c("sale_price_adj","sale_yr","inc_clean","ClosePrice_adj","close_year",
                "year_built","eff_year_built","land_sqft","univ_bldg_sqft",
                "bed_n","rooms_n","calc_bath_n","mla_est_all","mla_est_post40","mla_est_post70",
                names(dt) %>% str_subset("IPUMS|ipums"))
  num_vars = intersect(names(dt),num_vars0)
  dt[, (num_vars):=lapply(.SD, as.numeric), .SDcols=num_vars]
  
  # variable cleaning - take logs
  log_vars0 = c("sale_price_adj","inc_clean","ClosePrice_adj","land_sqft","univ_bldg_sqft",
                "mla_est_all","mla_est_post40","mla_est_post70")
  log_vars = intersect(names(dt), log_vars0)
  log_vars1 = paste0("LOG_",log_vars)
  dt[, (log_vars1):=lapply(.SD, function(x) ifelse(x>0,log(x),NA)), .SDcols=log_vars]
  
  # variable cleaning - missing IPUMS
  dt[, IPUMS_NA:=ifelse(is.na(IPUMSM_n_obs)|IPUMSM_n_obs==0,1,0)]
  dt[, IPUMS_NA_mean_valueh:=ifelse(is.na(IPUMSM_mean_valueh),1,0)]
  dt[, IPUMS_NA_mean_rent:=ifelse(is.na(IPUMSM_mean_rent),1,0)]
  dt[, IPUMS_NA_mean_inc:=ifelse(is.na(IPUMSM_mean_inc),1,0)]
  dt[, IPUMS_ZERO_inc:=ifelse(IPUMSM_mean_inc==0,1,0)]
  dt[is.na(IPUMS_ZERO_inc),IPUMS_ZERO_inc:=0]
  dt[, IPUMS_NA_p_ownership:=ifelse(is.na(IPUMSM_p_ownership),1,0)]
  
  # variable cleaning - log IPUMS
  cov_ipums = c("IPUMS_log_n_obs","IPUMS_mean_pernum","IPUMS_log_mean_inc","IPUMS_mean_i_white",
                "IPUMS_p_ownership","IPUMS_log_mean_valueh","IPUMS_log_mean_rent")
  dt[, `:=`(IPUMS_log_n_obs = log(IPUMSM_n_obs),
            IPUMS_mean_pernum = IPUMSM_mean_pernum,
            IPUMS_log_mean_inc = log(IPUMSM_mean_inc),
            IPUMS_mean_i_white = IPUMSM_mean_i_white,
            IPUMS_p_ownership = IPUMSM_p_ownership,
            IPUMS_mean_valueh = IPUMSM_mean_valueh,
            IPUMS_log_mean_valueh = log(IPUMSM_mean_valueh),
            IPUMS_mean_rent = IPUMSM_mean_rent,
            IPUMS_log_mean_rent = log(IPUMSM_mean_rent))]
  dt[IPUMS_NA==1, (cov_ipums):=-99]
  dt[IPUMS_NA_mean_valueh==1, `:=`(IPUMS_mean_valueh=-98,
                                   IPUMS_log_mean_valueh=-98)]
  dt[IPUMS_NA_mean_rent==1, `:=`(IPUMS_mean_rent=-97,
                                 IPUMS_log_mean_rent=-97)]
  dt[IPUMS_NA_mean_inc==1, `:=`(IPUMS_mean_inc=-96,
                                IPUMS_log_mean_inc=-96)]
  dt[IPUMS_ZERO_inc==1, `:=`(IPUMS_log_mean_inc=-96)]
  dt[IPUMS_NA_p_ownership==1, `:=`(IPUMS_p_ownership=-95)]
  
  # HMDA race cleaning
  if("race_ethnicity" %in% names(dt)){
    dt[, `:=`(i_white = ifelse(race_ethnicity=="",NA,ifelse(race_ethnicity=="White",1,0)),
              i_black = ifelse(race_ethnicity=="",NA,ifelse(race_ethnicity=="Black",1,0)),
              i_hispanic = ifelse(race_ethnicity=="",NA,ifelse(race_ethnicity=="Hispanic",1,0)),
              i_asian = ifelse(race_ethnicity=="",NA,ifelse(race_ethnicity=="AsianPacific",1,0)),
              i_other = ifelse(race_ethnicity=="",NA,ifelse(race_ethnicity%in%c("Other","Native"),1,0)))]
  }
  
  # MLA outlier removal
  dt[mla_est_all<100|mla_est_all>5*43560, mla_est_all:=NA]
  dt[mla_est_post40<100|mla_est_post40>5*43560, mla_est_post40:=NA]
  dt[mla_est_post70<100|mla_est_post70>5*43560, mla_est_post70:=NA]
  
  # select baseline MLA estimate
  dt[, MLA:=mla_est_post40]
  dt[, LOG_MLA:=log(MLA)]
  
  # price select
  if("sale_price_adj" %in% names(dt)){
    dt[, PRICE:=sale_price_adj]
    dt[, YEAR:=sale_yr]
  } else{
    dt[, PRICE:=ClosePrice_adj]
    dt[, YEAR:=close_year]
  }
  dt[, LOG_PRICE:=log(PRICE)]
  dt[, age:=YEAR-year_built]
  dt[, eff_year_built:=ifelse(is.na(eff_year_built),year_built,eff_year_built)]
  dt[, eff_age:=YEAR-eff_year_built]
  
  # define county-by-year fixed effects
  dt[, fips_yr:=paste0(fips,"_",YEAR)]
  
  # define border region fixed effects
  dt[, id_bord:=clean_bord]
  
  # define school district fixed effects (SDLEA) and interact with municipality (MUNI_SDLEA)
  dt[, SDLEA:=.GRP, , by=.(ELSDLEA, SCSDLEA, UNSDLEA)]
  dt[, MUNI_SDLEA:=.GRP, by=.(AFFGEOID, ELSDLEA, SCSDLEA, UNSDLEA)]
  
  # only those with MLA estimates
  dt = dt[!is.na(mla_est_all)|!is.na(mla_est_post40)|!is.na(mla_est_post70)]
  
  # only those with key building char's (lot size, bldg SF, # bed, # bath, age)
  dt = dt[!is.na(bed_n)&!is.na(age)&!is.na(univ_bldg_sqft)&!is.na(land_sqft)&!is.na(calc_bath_n)]
  dt = dt[univ_bldg_sqft>=10&age>=-5&bed_n<=10&calc_bath_n<=20]
  
  # price outliers
  if("sale_price_adj" %in% names(dt)){
    dt = dt[sale_price_adj>=1000&sale_price_adj<=2e6]
  } else{
    dt = dt[ClosePrice_adj>=100&ClosePrice_adj<=2e5]
  }
  
  # race ethnicity observed
  if("race_ethnicity" %in% names(dt)){
    dt = dt[race_ethnicity!=""|!is.na(LOG_inc_clean)]
  }
  
  # drop 1900s observations
  dt = dt[YEAR>=2000]
  print(dt[,.N])
  
  fwrite(dt, paste0(sample_path, dataset_i,"_", bord_i,".csv"))
}