# ==============================================================================
# Additional Setup
# ==============================================================================

# state to run (in parallel)
state_vec <- fips_dt[!state_abbr %in% c("AK","HI"), state_abbr]
job_i = commandArgs(trailingOnly=T) %>% as.integer
state_i = state_vec[[job_i]]

# path to save border parcels
border_path = paste0(int_path, "muni_border/")
seg_path = paste0(int_path, "/border_seg_parcels/")

# path to parcel-level MLA estimates
mla_path = paste0(int_path, "mla_est/by_parcel/")

# ==============================================================================
# Map Input
# ==============================================================================
# state map
states_map <- st_read(paste0(map_path,"/cb_2019_us_state_500k/cb_2019_us_state_500k.shp"))
state_map <- subset(states_map, STATEFP==state_fips_str_i)

# state plane zones
spz <- st_read(paste0(map_path,"/USA_State_Plane_Zones_NAD83/spz_nad83.shp")) %>% st_transform(4269)
# fips matching
spz_dt <- fread(paste0(map_path,"/USA_State_Plane_Zones_NAD83/county-epsg.csv"))
setnames(spz_dt,c("countyfips","name","stateplanefips","epsg"))
spz_dt[,epsg:=as.integer(str_sub(epsg,1,-2))]
spz_dt[,statefips:=as.integer(str_sub(countyfips,1,-4))]
spz <- merge(spz, spz_dt[statefips==state_fips_i,unique(.SD),.SDcols=c("stateplanefips","epsg")],
             by.x="FIPSZONE",by.y="stateplanefips")

# county map
cty_map <- st_read(paste0(map_path,"/cb_2019_us_county_500k/cb_2019_us_county_500k.shp"))
cty_map <- filter(cty_map, as.integer(STATEFP)==as.integer(state_fips_i))

# ==============================================================================
# Function to define border around municipality boundaries
# ==============================================================================

get_borders_muni <- function(data_shp, dist_km=1){
  epsg_vec <- unique(data_shp$epsg)
  
  # construct buffer
  for(i in 1:length(epsg_vec)){
    epsg_i <- epsg_vec[[i]]
    data_temp <- subset(data_shp,epsg==epsg_i) %>% select(muni_id)
    data_temp <- st_transform(data_temp, crs=epsg_i)
    data_temp <- st_buffer(data_temp,set_units(dist_km,km))
    data_temp <- st_transform(data_temp, crs=4269)
    
    if(i==1){
      data_buff <- data_temp
    }else{
      data_buff <- rbind(data_buff,data_temp)
    }
  }
  
  # clean buffer by muni_id
  muni_vec <- unique(data_buff$muni_id)
  for(j in 1:length(muni_vec)){
    id_j <- muni_vec[j]
    data_temp <- subset(data_buff, muni_id==id_j)
    data_temp <- st_sf(st_union(st_make_valid(data_temp)))
    data_temp$muni_id <- id_j
    
    if(j==1){
      data_buff_clean <- data_temp
    } else{
      data_buff_clean <- rbind(data_buff_clean,data_temp)
    }
  }
  
  # intersect and get borders
  data_bord <- st_intersection(data_buff_clean, data_buff_clean)
  data_bord <- filter(data_bord, muni_id<muni_id.1) %>%
    select(muni_id,muni_id.1) %>%
    rename(muni_id.a=muni_id,muni_id.b=muni_id.1) %>%
    mutate(buff=dist_km) %>% st_make_valid
  
  return(data_bord)
}

# ==============================================================================
# Merge borders to parcel data
# ==============================================================================

# calculate 0.1,...,1km buffers
buff_vec <- c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0)

# SFR parcel data with geocodes
st_path = paste0(int_path, "st_geo/")
input_files = list.files(st_path)

# counties to run
county_vec <- str_sub(list.files(st_path, paste0("fips_", state_fips_str_i)), 6, 10) %>% as.integer
print(paste0("There are ", length(county_vec), " counties within CBSAs to run."))

# read state municipality map
if(state_i!="OH"){
  muni_map <- st_read(paste0(processed_path, "muni_boundaries/", state_i, ".shp"))
  muni_incorp <- muni_map %>% filter(type=="incorp")
  muni_mcd <- muni_map %>% filter(type=="mcd")
}else{
  muni_incorp <- st_read(paste0(processed_path, "muni_boundaries/", state_i, "_plc.shp"))
  muni_incorp <- muni_incorp %>% select(AFFGEOID=AFF_p1, type)
  muni_mcd <- st_read(paste0(processed_path, "muni_boundaries/", state_i, "_ctysub.shp"))
}

# run through counties
for(county_i in county_vec){
  
  print(paste0("Working on : ", county_i))
  print(Sys.time())
  
  county_map_i <- cty_map %>% filter(COUNTYFP==str_sub(county_i,3,-1))
  
  # clean municipality map by county -------------------------------------------
  muni_incorp_i <- st_intersection(muni_incorp, county_map_i) %>% st_make_valid
  
  # prioritize incorporated places over MCDs (in case of overlapping)
  muni_mcd_i <- st_intersection(muni_mcd, county_map_i) %>% st_make_valid
  muni_mcd_i <- muni_mcd_i %>% filter(str_sub(AFFGEOID,nchar("0600000US3"),nchar("0600000US3")+4)==county_i)
  if(dim(muni_incorp_i)[1]>0){
    muni_mcd_i <- st_difference(muni_mcd_i, st_union(muni_incorp_i))
  }
  
  muni_i <- rbind(muni_incorp_i %>% select(AFFGEOID,type),
                  muni_mcd_i %>% select(AFFGEOID,type))
  muni_i <- mutate(muni_i, muni_area=st_area(muni_i))
  muni_i <- muni_i %>% filter(as.numeric(muni_area)>0)
  
  if(dim(muni_mcd_i)[1]==0){
    
    muni_cty_i <- county_map_i %>% mutate(AFFGEOID=paste0("0500000US",county_i), type="balance")
    muni_i <- muni_cty_i %>% select(AFFGEOID,type)
    
  } else{
    muni_cty_i <- st_difference(county_map_i, st_union(muni_i))
    muni_cty_i <- mutate(muni_cty_i, AFFGEOID=paste0("0500000US",county_i), type="balance")
    muni_i <- rbind(muni_i %>% select(AFFGEOID,type), muni_cty_i %>% select(AFFGEOID,type))
  }
  
  # read parcel data -----------------------------------------------------------
  dt <- fread(paste0(st_path, "fips_", county_i, ".csv"),
              colClasses="character")
  dt[, i_row:=.I]
  
  # coordinates
  st.sf <- st_as_sf(dt[st_long!="", .(i_row, st_lat, st_long)],
                    coords = c("st_long","st_lat"), crs = 4269)
  if(dim(st.sf)[1]==0) next
  
  # merge with municipality
  st_w_muni <- st_join(st.sf, select(muni_i, AFFGEOID, type))
  st_w_muni.dt <- as.data.table(st_w_muni)
  st_w_muni.dt <- st_w_muni.dt[AFFGEOID!="",.SD[1],by=i_row,.SDcols=c("AFFGEOID","type")]
  w_muni.dt <- st_w_muni.dt[!is.na(AFFGEOID)][, coord_type:="st"]
  
  # create indexes for municipality for deduplication
  muni_def <- w_muni.dt[,.N,AFFGEOID][order(-N)][,muni_id:=.I][,-"N"]
  st_w_muni.dt <- merge(st_w_muni.dt, muni_def, by="AFFGEOID")
  
  # restrict to municipalities with parcels
  muni.spz <- st_intersection(muni_i, spz)
  muni.spz <- merge(muni.spz, muni_def,
                    by="AFFGEOID")
  
  borders_st <- copy(st_w_muni.dt)
  
  # run through bandwidths
  for(buff_dist in buff_vec){
    
    # define buffer area
    muni.bord <- get_borders_muni(muni.spz, buff_dist)
    
    # join with parcel data
    w_bord <- st_join(st.sf, muni.bord)
    
    # clean parcel-border merge
    w_bord.dt <- as.data.table(w_bord)[!is.na(buff),.SD,.SDcols=-"geometry"]
    w_bord.dt <- merge(st_w_muni.dt, w_bord.dt, by="i_row")
    
    # select one observation per a pair of municipalities
    w_bord.dt <- w_bord.dt[(muni_id.a<muni_id.b)&(muni_id==muni_id.a|muni_id==muni_id.b)]
    w_bord.dt[,n_dup:=.N,by=i_row]
    
    # save n_dup=1
    temp <- w_bord.dt[n_dup==1, .SD,
                      .SDcols=c("i_row","n_dup","muni_id.a","muni_id.b")]
    print(paste0("Among ",dim(st.sf)[1],", ",temp[,.N]," parcels are within ",buff_dist,"km away from a single border."))
    
    # save n_dup>1
    temp2 <- w_bord.dt[n_dup>1, unique(.SD),
                       .SDcols=c("i_row","n_dup")]
    print(paste0("Among ",dim(st.sf)[1],", ",temp2[,.N]," parcels are within ",buff_dist,"km away from multiple borders."))
    
    temp <- rbindlist(list(temp,temp2),use.names=T,fill=T)
    temp <- merge(temp, muni_def, by.x="muni_id.a",by.y="muni_id",all.x=T)
    temp <- merge(temp, muni_def, by.x="muni_id.b",by.y="muni_id",suffixes=c(".a",".b"),
                  all.x=T)
    
    vars <- c("n_dup","AFFGEOID.a","AFFGEOID.b")
    temp <- temp[,.SD,.SDcols=c("i_row",vars)]
    
    # variable name setting
    buff_dist_str = as.integer(buff_dist*10)
    buff_dist_str = ifelse(nchar(buff_dist_str)==2,paste0(buff_dist_str),paste0(0,buff_dist_str))
    setnames(temp,vars,paste0(vars,"_",buff_dist_str))
    
    borders_st <- merge(borders_st, temp, by="i_row", all.x=T)
    borders_out <- merge(dt[,.SD,.SDcols=c("i_row",id_vars)],
                         borders_st, by="i_row",
                         all.x=T)
    
  }
  
  # save the intermediate file
  fwrite(borders_out[,-"i_row"],
         paste0(border_path, "fips_", county_i, ".csv"))
  
}

# ==============================================================================
# Cluster border parcels to define border segments
# ==============================================================================

# number of clusters
n_cluster_vec = 2:8

# county to run
county_vec = list.files(border_path) %>% str_sub(6,10)

job_i = commandArgs(trailingOnly=T) %>% as.integer
county_i = county_vec[[job_i]]

if(which(county_vec==county_i)%%25==1){
  print(paste0("# ",which(county_vec==county_i)))
  print(Sys.time())
}

# read border parcels -----------------------------------------------------------
dt = fread(paste0(border_path, "fips_", county_i, ".csv"), colClasses="character")
dt = dt[n_dup_01==1|n_dup_02==1|n_dup_03==1|n_dup_04==1|n_dup_05==1|n_dup_06==1|n_dup_07==1|n_dup_08==1|n_dup_09==1|n_dup_10==1]
dt[n_dup_01==1, `:=`(AFFGEOID.a=AFFGEOID.a_01, AFFGEOID.b=AFFGEOID.b_01)]
dt[n_dup_02==1, `:=`(AFFGEOID.a=AFFGEOID.a_02, AFFGEOID.b=AFFGEOID.b_02)]
dt[n_dup_03==1, `:=`(AFFGEOID.a=AFFGEOID.a_03, AFFGEOID.b=AFFGEOID.b_03)]
dt[n_dup_04==1, `:=`(AFFGEOID.a=AFFGEOID.a_04, AFFGEOID.b=AFFGEOID.b_04)]
dt[n_dup_05==1, `:=`(AFFGEOID.a=AFFGEOID.a_05, AFFGEOID.b=AFFGEOID.b_05)]
dt[n_dup_06==1, `:=`(AFFGEOID.a=AFFGEOID.a_06, AFFGEOID.b=AFFGEOID.b_06)]
dt[n_dup_07==1, `:=`(AFFGEOID.a=AFFGEOID.a_07, AFFGEOID.b=AFFGEOID.b_07)]
dt[n_dup_08==1, `:=`(AFFGEOID.a=AFFGEOID.a_08, AFFGEOID.b=AFFGEOID.b_08)]
dt[n_dup_09==1, `:=`(AFFGEOID.a=AFFGEOID.a_09, AFFGEOID.b=AFFGEOID.b_09)]
dt[n_dup_10==1, `:=`(AFFGEOID.a=AFFGEOID.a_10, AFFGEOID.b=AFFGEOID.b_10)]
dt = dt[,.SD,.SDcols=c(id_vars, "AFFGEOID", "AFFGEOID.a", "AFFGEOID.b", paste0("n_dup_0",1:9), "n_dup_10")]

# add coordinates
dt_st = fread(paste0(st_path, "fips_", county_i, ".csv"), colClasses="character")
dt <- merge(dt, dt_st, by=id_vars)
dt[, `:=`(long=as.numeric(st_long), lat=as.numeric(st_lat))]

# kmeans clustering ------------------------------------------------------------
dt[, grp_border:=.GRP, by=.(AFFGEOID.a, AFFGEOID.b)]
by_border = dt[,.(N_parcel=.N), by=.(AFFGEOID.a, AFFGEOID.b, grp_border)]
by_border[, fips:=county_i]
by_border[, i_cluster:=ifelse(N_parcel>=50,1,0)]
setcolorder(by_border, "fips")
fwrite(by_border, paste0(int_path, "border_info.csv"), append=T)

dt <- merge(dt, by_border[,.(grp_border, i_cluster)], by="grp_border")

# run only if N_parcel>=50
if(by_border[i_cluster==1,.N]==0){
  print("No border regions are big enough")
  for(n_cluster in n_cluster_vec){
    var_i = paste0("kmeans_",n_cluster)
    dt[, (var_i):=NA]
  }
} else{
  border_to_cluster = by_border[i_cluster==1, grp_border]
  for(n_cluster in n_cluster_vec){
    for(i in border_to_cluster){
      dt_i = dt[grp_border==i]
      
      # kmeans clustering
      out_i = kmeans(dt_i[,.(long,lat)],n_cluster)
      dt[grp_border==i, cluster_temp:=out_i$cluster]
    }
    setnames(dt, "cluster_temp",paste0("kmeans_",n_cluster))
  }
}

# save clustering output
fwrite(dt, paste0(seg_path, "fips_", county_i, ".csv"))

# =======================================================
# Add parcel-level MLA estimates and SD and CBG
# =======================================================
file_vec1 = list.files(seg_path, "fips")
file_vec2 = list.files(mla_path)
file_vec = intersect(file_vec1, file_vec2)

for(file_i in file_vec){
  
  # border segment parcels
  dt <- fread(paste0(seg_path,file_i), colClasses="character")
  
  # define border segment ID
  dt[, grp_border:=.GRP, by=.(AFFGEOID.a, AFFGEOID.b)]
  
  # MLA estimates
  zoning_dt <- fread(paste0(mla_path, file_i), colClasses="character")
  zoning_dt[,`:=`(mla_est_all = ifelse(muni_AFFGEOID!=""&zoning_clean!=""&mla_zoning_all!="",mla_zoning_all,mla_cbg_all),
                  mla_est_post40 = ifelse(muni_AFFGEOID!=""&zoning_clean!=""&mla_zoning_post40!="",mla_zoning_post40,mla_cbg_post40),
                  mla_est_post70 = ifelse(muni_AFFGEOID!=""&zoning_clean!=""&mla_zoning_post70!="",mla_zoning_post70,mla_cbg_post70))]
  zoning_dt <- zoning_dt[,.SD[1],by=id_vars,.SDcols=c("muni_AFFGEOID","zoning_clean","st_long","st_lat",
                                                      "prop_type","land_sqft","univ_bldg_sqft","year_built","eff_year_built",
                                                      "mla_est_all","mla_est_post40","mla_est_post70")]
  dt <- merge(dt, zoning_dt, by=id_vars, all.x=T)
  
  # School districts and CBG
  st_dt <- fread(paste0(st_path, file_i), colClasses="character")
  st_dt <- st_dt[coord_type!="",.SD[1],by=id_vars,.SDcols=c("ELSDLEA","SCSDLEA","UNSDLEA","cbg_geoid")]
  dt <- merge(dt, st_dt, by=id_vars, all.x=T)
  
  fwrite(dt, paste0(seg_path, file_i))
  
  # Save border region/segment characteristics ---------------------------------
  # School district and CBG and MLS variation within border segment
  out_dt1 = dt[,.(N_apn = .N,
                  N_sd = .SD[,uniqueN(.SD),.SDcols=c("ELSDLEA","SCSDLEA","UNSDLEA")],
                  N_sd.a = .SD[AFFGEOID==AFFGEOID.a,uniqueN(.SD),.SDcols=c("ELSDLEA","SCSDLEA","UNSDLEA")],
                  N_sd.b = .SD[AFFGEOID==AFFGEOID.b,uniqueN(.SD),.SDcols=c("ELSDLEA","SCSDLEA","UNSDLEA")],
                  N_cbg = .SD[cbg_geoid!="",uniqueN(cbg_geoid)],
                  N_cbg.a = .SD[AFFGEOID==AFFGEOID.a&cbg_geoid!="",uniqueN(cbg_geoid)],
                  N_cbg.b = .SD[AFFGEOID==AFFGEOID.b&cbg_geoid!="",uniqueN(cbg_geoid)],
                  N_builtNA = .SD[is.na(year_built),.N],
                  N_built40 = .SD[year_built>=1940,.N],
                  N_built70 = .SD[year_built>=1970,.N],
                  MEAN_mla_est_all = .SD[, mean(mla_est_all, na.rm=T)],
                  MEAN_mla_est_all.a = .SD[AFFGEOID==AFFGEOID.a, mean(mla_est_all, na.rm=T)],
                  MEAN_mla_est_all.b = .SD[AFFGEOID==AFFGEOID.b, mean(mla_est_all, na.rm=T)],
                  MED_mla_est_all = .SD[, median(mla_est_all, na.rm=T)],
                  MED_mla_est_all.a = .SD[AFFGEOID==AFFGEOID.a, median(mla_est_all, na.rm=T)],
                  MED_mla_est_all.b = .SD[AFFGEOID==AFFGEOID.b, median(mla_est_all, na.rm=T)],
                  SD_mla_est_all = .SD[, sd(mla_est_all, na.rm=T)],
                  SD_mla_est_all.a = .SD[AFFGEOID==AFFGEOID.a, sd(mla_est_all, na.rm=T)],
                  SD_mla_est_all.b = .SD[AFFGEOID==AFFGEOID.b, sd(mla_est_all, na.rm=T)],
                  SD_logmla_est_all = .SD[, sd(log(mla_est_all), na.rm=T)],
                  SD_logmla_est_all.a = .SD[AFFGEOID==AFFGEOID.a, sd(log(mla_est_all), na.rm=T)],
                  SD_logmla_est_all.b = .SD[AFFGEOID==AFFGEOID.b, sd(log(mla_est_all), na.rm=T)],
                  PBIND40_mla_est_all = .SD[year_built>=1940, mean(i_bind_all, na.rm=T)],
                  PBIND40_mla_est_all.a = .SD[AFFGEOID==AFFGEOID.a&year_built>=1940, mean(i_bind_all, na.rm=T)],
                  PBIND40_mla_est_all.b = .SD[AFFGEOID==AFFGEOID.b&year_built>=1940, mean(i_bind_all, na.rm=T)],
                  PBIND70_mla_est_all = .SD[year_built>=1970, mean(i_bind_all, na.rm=T)],
                  PBIND70_mla_est_all.a = .SD[AFFGEOID==AFFGEOID.a&year_built>=1970, mean(i_bind_all, na.rm=T)],
                  PBIND70_mla_est_all.b = .SD[AFFGEOID==AFFGEOID.b&year_built>=1970, mean(i_bind_all, na.rm=T)],
                  MEAN_mla_est_post40 = .SD[, mean(mla_est_post40, na.rm=T)],
                  MEAN_mla_est_post40.a = .SD[AFFGEOID==AFFGEOID.a, mean(mla_est_post40, na.rm=T)],
                  MEAN_mla_est_post40.b = .SD[AFFGEOID==AFFGEOID.b, mean(mla_est_post40, na.rm=T)],
                  MED_mla_est_post40 = .SD[, median(mla_est_post40, na.rm=T)],
                  MED_mla_est_post40.a = .SD[AFFGEOID==AFFGEOID.a, median(mla_est_post40, na.rm=T)],
                  MED_mla_est_post40.b = .SD[AFFGEOID==AFFGEOID.b, median(mla_est_post40, na.rm=T)],
                  SD_mla_est_post40 = .SD[, sd(mla_est_post40, na.rm=T)],
                  SD_mla_est_post40.a = .SD[AFFGEOID==AFFGEOID.a, sd(mla_est_post40, na.rm=T)],
                  SD_mla_est_post40.b = .SD[AFFGEOID==AFFGEOID.b, sd(mla_est_post40, na.rm=T)],
                  SD_logmla_est_post40 = .SD[, sd(log(mla_est_post40), na.rm=T)],
                  SD_logmla_est_post40.a = .SD[AFFGEOID==AFFGEOID.a, sd(log(mla_est_post40), na.rm=T)],
                  SD_logmla_est_post40.b = .SD[AFFGEOID==AFFGEOID.b, sd(log(mla_est_post40), na.rm=T)],
                  PBIND40_mla_est_post40 = .SD[year_built>=1940, mean(i_bind_post40, na.rm=T)],
                  PBIND40_mla_est_post40.a = .SD[AFFGEOID==AFFGEOID.a&year_built>=1940, mean(i_bind_post40, na.rm=T)],
                  PBIND40_mla_est_post40.b = .SD[AFFGEOID==AFFGEOID.b&year_built>=1940, mean(i_bind_post40, na.rm=T)],
                  PBIND70_mla_est_post40 = .SD[year_built>=1970, mean(i_bind_post40, na.rm=T)],
                  PBIND70_mla_est_post40.a = .SD[AFFGEOID==AFFGEOID.a&year_built>=1970, mean(i_bind_post40, na.rm=T)],
                  PBIND70_mla_est_post40.b = .SD[AFFGEOID==AFFGEOID.b&year_built>=1970, mean(i_bind_post40, na.rm=T)],
                  MEAN_mla_est_post70 = .SD[, mean(mla_est_post70, na.rm=T)],
                  MEAN_mla_est_post70.a = .SD[AFFGEOID==AFFGEOID.a, mean(mla_est_post70, na.rm=T)],
                  MEAN_mla_est_post70.b = .SD[AFFGEOID==AFFGEOID.b, mean(mla_est_post70, na.rm=T)],
                  MED_mla_est_post70 = .SD[, median(mla_est_post70, na.rm=T)],
                  MED_mla_est_post70.a = .SD[AFFGEOID==AFFGEOID.a, median(mla_est_post70, na.rm=T)],
                  MED_mla_est_post70.b = .SD[AFFGEOID==AFFGEOID.b, median(mla_est_post70, na.rm=T)],
                  SD_mla_est_post70 = .SD[, sd(mla_est_post70, na.rm=T)],
                  SD_mla_est_post70.a = .SD[AFFGEOID==AFFGEOID.a, sd(mla_est_post70, na.rm=T)],
                  SD_mla_est_post70.b = .SD[AFFGEOID==AFFGEOID.b, sd(mla_est_post70, na.rm=T)],
                  SD_logmla_est_post70 = .SD[, sd(log(mla_est_post70), na.rm=T)],
                  SD_logmla_est_post70.a = .SD[AFFGEOID==AFFGEOID.a, sd(log(mla_est_post70), na.rm=T)],
                  SD_logmla_est_post70.b = .SD[AFFGEOID==AFFGEOID.b, sd(log(mla_est_post70), na.rm=T)],
                  PBIND40_mla_est_post70 = .SD[year_built>=1940, mean(i_bind_post70, na.rm=T)],
                  PBIND40_mla_est_post70.a = .SD[AFFGEOID==AFFGEOID.a&year_built>=1940, mean(i_bind_post70, na.rm=T)],
                  PBIND40_mla_est_post70.b = .SD[AFFGEOID==AFFGEOID.b&year_built>=1940, mean(i_bind_post70, na.rm=T)],
                  PBIND70_mla_est_post70 = .SD[year_built>=1970, mean(i_bind_post70, na.rm=T)],
                  PBIND70_mla_est_post70.a = .SD[AFFGEOID==AFFGEOID.a&year_built>=1970, mean(i_bind_post70, na.rm=T)],
                  PBIND70_mla_est_post70.b = .SD[AFFGEOID==AFFGEOID.b&year_built>=1970, mean(i_bind_post70, na.rm=T)]),
               by=.(fips,grp_border,AFFGEOID.a,AFFGEOID.b)]
  fwrite(out_dt1, paste0(seg_path, "border_chars.csv"), append=T)
  
  if("kmeans_2"%in%names(dt)){
    # border segment definition
    dt[kmeans_2!="", grp_bordseg2:=paste0(grp_border,"_C2_",kmeans_2)]
    dt[kmeans_3!="", grp_bordseg3:=paste0(grp_border,"_C3_",kmeans_3)]
    dt[kmeans_4!="", grp_bordseg4:=paste0(grp_border,"_C4_",kmeans_4)]
    dt[kmeans_5!="", grp_bordseg5:=paste0(grp_border,"_C5_",kmeans_2)]
    dt[kmeans_6!="", grp_bordseg6:=paste0(grp_border,"_C6_",kmeans_3)]
    dt[kmeans_7!="", grp_bordseg7:=paste0(grp_border,"_C7_",kmeans_4)]
    dt[kmeans_8!="", grp_bordseg8:=paste0(grp_border,"_C8_",kmeans_4)]
    
    for(n_clusters_i in 2:8){
      var_i = paste0("grp_bordseg",n_clusters_i)
      
      out_dt2 = dt[!is.na(get(var_i)),.(N_apn = .N,
                                        N_sd = .SD[,uniqueN(.SD),.SDcols=c("ELSDLEA","SCSDLEA","UNSDLEA")],
                                        N_sd.a = .SD[AFFGEOID==AFFGEOID.a,uniqueN(.SD),.SDcols=c("ELSDLEA","SCSDLEA","UNSDLEA")],
                                        N_sd.b = .SD[AFFGEOID==AFFGEOID.b,uniqueN(.SD),.SDcols=c("ELSDLEA","SCSDLEA","UNSDLEA")],
                                        N_cbg = .SD[cbg_geoid!="",uniqueN(cbg_geoid)],
                                        N_cbg.a = .SD[AFFGEOID==AFFGEOID.a&cbg_geoid!="",uniqueN(cbg_geoid)],
                                        N_cbg.b = .SD[AFFGEOID==AFFGEOID.b&cbg_geoid!="",uniqueN(cbg_geoid)],
                                        N_builtNA = .SD[is.na(year_built),.N],
                                        N_built40 = .SD[year_built>=1940,.N],
                                        N_built70 = .SD[year_built>=1970,.N],
                                        MEAN_mla_est_all = .SD[, mean(mla_est_all, na.rm=T)],
                                        MEAN_mla_est_all.a = .SD[AFFGEOID==AFFGEOID.a, mean(mla_est_all, na.rm=T)],
                                        MEAN_mla_est_all.b = .SD[AFFGEOID==AFFGEOID.b, mean(mla_est_all, na.rm=T)],
                                        MED_mla_est_all = .SD[, median(mla_est_all, na.rm=T)],
                                        MED_mla_est_all.a = .SD[AFFGEOID==AFFGEOID.a, median(mla_est_all, na.rm=T)],
                                        MED_mla_est_all.b = .SD[AFFGEOID==AFFGEOID.b, median(mla_est_all, na.rm=T)],
                                        SD_mla_est_all = .SD[, sd(mla_est_all, na.rm=T)],
                                        SD_mla_est_all.a = .SD[AFFGEOID==AFFGEOID.a, sd(mla_est_all, na.rm=T)],
                                        SD_mla_est_all.b = .SD[AFFGEOID==AFFGEOID.b, sd(mla_est_all, na.rm=T)],
                                        SD_logmla_est_all = .SD[, sd(log(mla_est_all), na.rm=T)],
                                        SD_logmla_est_all.a = .SD[AFFGEOID==AFFGEOID.a, sd(log(mla_est_all), na.rm=T)],
                                        SD_logmla_est_all.b = .SD[AFFGEOID==AFFGEOID.b, sd(log(mla_est_all), na.rm=T)],
                                        PBIND40_mla_est_all = .SD[year_built>=1940, mean(i_bind_all, na.rm=T)],
                                        PBIND40_mla_est_all.a = .SD[AFFGEOID==AFFGEOID.a&year_built>=1940, mean(i_bind_all, na.rm=T)],
                                        PBIND40_mla_est_all.b = .SD[AFFGEOID==AFFGEOID.b&year_built>=1940, mean(i_bind_all, na.rm=T)],
                                        PBIND70_mla_est_all = .SD[year_built>=1970, mean(i_bind_all, na.rm=T)],
                                        PBIND70_mla_est_all.a = .SD[AFFGEOID==AFFGEOID.a&year_built>=1970, mean(i_bind_all, na.rm=T)],
                                        PBIND70_mla_est_all.b = .SD[AFFGEOID==AFFGEOID.b&year_built>=1970, mean(i_bind_all, na.rm=T)],
                                        MEAN_mla_est_post40 = .SD[, mean(mla_est_post40, na.rm=T)],
                                        MEAN_mla_est_post40.a = .SD[AFFGEOID==AFFGEOID.a, mean(mla_est_post40, na.rm=T)],
                                        MEAN_mla_est_post40.b = .SD[AFFGEOID==AFFGEOID.b, mean(mla_est_post40, na.rm=T)],
                                        MED_mla_est_post40 = .SD[, median(mla_est_post40, na.rm=T)],
                                        MED_mla_est_post40.a = .SD[AFFGEOID==AFFGEOID.a, median(mla_est_post40, na.rm=T)],
                                        MED_mla_est_post40.b = .SD[AFFGEOID==AFFGEOID.b, median(mla_est_post40, na.rm=T)],
                                        SD_mla_est_post40 = .SD[, sd(mla_est_post40, na.rm=T)],
                                        SD_mla_est_post40.a = .SD[AFFGEOID==AFFGEOID.a, sd(mla_est_post40, na.rm=T)],
                                        SD_mla_est_post40.b = .SD[AFFGEOID==AFFGEOID.b, sd(mla_est_post40, na.rm=T)],
                                        SD_logmla_est_post40 = .SD[, sd(log(mla_est_post40), na.rm=T)],
                                        SD_logmla_est_post40.a = .SD[AFFGEOID==AFFGEOID.a, sd(log(mla_est_post40), na.rm=T)],
                                        SD_logmla_est_post40.b = .SD[AFFGEOID==AFFGEOID.b, sd(log(mla_est_post40), na.rm=T)],
                                        PBIND40_mla_est_post40 = .SD[year_built>=1940, mean(i_bind_post40, na.rm=T)],
                                        PBIND40_mla_est_post40.a = .SD[AFFGEOID==AFFGEOID.a&year_built>=1940, mean(i_bind_post40, na.rm=T)],
                                        PBIND40_mla_est_post40.b = .SD[AFFGEOID==AFFGEOID.b&year_built>=1940, mean(i_bind_post40, na.rm=T)],
                                        PBIND70_mla_est_post40 = .SD[year_built>=1970, mean(i_bind_post40, na.rm=T)],
                                        PBIND70_mla_est_post40.a = .SD[AFFGEOID==AFFGEOID.a&year_built>=1970, mean(i_bind_post40, na.rm=T)],
                                        PBIND70_mla_est_post40.b = .SD[AFFGEOID==AFFGEOID.b&year_built>=1970, mean(i_bind_post40, na.rm=T)],
                                        MEAN_mla_est_post70 = .SD[, mean(mla_est_post70, na.rm=T)],
                                        MEAN_mla_est_post70.a = .SD[AFFGEOID==AFFGEOID.a, mean(mla_est_post70, na.rm=T)],
                                        MEAN_mla_est_post70.b = .SD[AFFGEOID==AFFGEOID.b, mean(mla_est_post70, na.rm=T)],
                                        MED_mla_est_post70 = .SD[, median(mla_est_post70, na.rm=T)],
                                        MED_mla_est_post70.a = .SD[AFFGEOID==AFFGEOID.a, median(mla_est_post70, na.rm=T)],
                                        MED_mla_est_post70.b = .SD[AFFGEOID==AFFGEOID.b, median(mla_est_post70, na.rm=T)],
                                        SD_mla_est_post70 = .SD[, sd(mla_est_post70, na.rm=T)],
                                        SD_mla_est_post70.a = .SD[AFFGEOID==AFFGEOID.a, sd(mla_est_post70, na.rm=T)],
                                        SD_mla_est_post70.b = .SD[AFFGEOID==AFFGEOID.b, sd(mla_est_post70, na.rm=T)],
                                        SD_logmla_est_post70 = .SD[, sd(log(mla_est_post70), na.rm=T)],
                                        SD_logmla_est_post70.a = .SD[AFFGEOID==AFFGEOID.a, sd(log(mla_est_post70), na.rm=T)],
                                        SD_logmla_est_post70.b = .SD[AFFGEOID==AFFGEOID.b, sd(log(mla_est_post70), na.rm=T)],
                                        PBIND40_mla_est_post70 = .SD[year_built>=1940, mean(i_bind_post70, na.rm=T)],
                                        PBIND40_mla_est_post70.a = .SD[AFFGEOID==AFFGEOID.a&year_built>=1940, mean(i_bind_post70, na.rm=T)],
                                        PBIND40_mla_est_post70.b = .SD[AFFGEOID==AFFGEOID.b&year_built>=1940, mean(i_bind_post70, na.rm=T)],
                                        PBIND70_mla_est_post70 = .SD[year_built>=1970, mean(i_bind_post70, na.rm=T)],
                                        PBIND70_mla_est_post70.a = .SD[AFFGEOID==AFFGEOID.a&year_built>=1970, mean(i_bind_post70, na.rm=T)],
                                        PBIND70_mla_est_post70.b = .SD[AFFGEOID==AFFGEOID.b&year_built>=1970, mean(i_bind_post70, na.rm=T)]),
                   by=c("fips",var_i,"AFFGEOID.a","AFFGEOID.b")]
      
      if(out_dt2[,.N]>0){
        out_dt2[, n_clusters:=n_clusters_i]
        setnames(out_dt2, paste0("grp_bordseg",n_clusters_i), "grp_bordseg")
        setcolorder(out_dt2, c("fips","grp_bordseg","n_clusters","AFFGEOID.a","AFFGEOID.b"))
        fwrite(out_dt2, paste0(seg_path, "bordseg_chars.csv"), append=T)
      }
    }
  }
}

# =======================================================
# Add border characteristics #2 (1940 existence)
# =======================================================

dt1 = fread(paste0(seg_path, "border_chars.csv"), colClasses=c(fips="character"))
dt2 = fread(paste0(seg_path, "bordseg_chars.csv"), colClasses=c(fips="character"))

# geocoded 1940 full-count data merged to municipality map
ipums_dt = fread(paste0(int_path, "ipums40_muni_border.csv"))

# existence of the border area
by_border <- ipums_dt[AFFGEOID.a!=""&AFFGEOID.b!="",.(N_ipums.bord=.N,
                                                      N_ipums.bord_a=.SD[AFFGEOID==AFFGEOID.a,.N],
                                                      N_ipums.bord_b=.SD[AFFGEOID==AFFGEOID.b,.N]),
                      by=.(AFFGEOID.a=AFFGEOID.a,AFFGEOID.b=AFFGEOID.b)]

# existence of municipality
by_muni <- ipums_dt[AFFGEOID!="",.(N_ipums=.N),by=.(AFFGEOID)]

dt1 <- merge(dt1, by_muni, by.x=c("AFFGEOID.a"), by.y=c("AFFGEOID"), all.x=T)
dt1 <- merge(dt1, by_muni, by.x=c("AFFGEOID.b"), by.y=c("AFFGEOID"), all.x=T, suffixes=c(".a",".b"))
dt1 <- merge(dt1, by_border, by=c("AFFGEOID.a","AFFGEOID.b"), all.x=T)
fwrite(dt1, paste0(seg_path, "border_chars.csv"))

dt2 <- merge(dt2, by_muni, by.x=c("AFFGEOID.a"), by.y=c("AFFGEOID"), all.x=T)
dt2 <- merge(dt2, by_muni, by.x=c("AFFGEOID.b"), by.y=c("AFFGEOID"), all.x=T, suffixes=c(".a",".b"))
dt2 <- merge(dt2, by_border, by=c("AFFGEOID.a","AFFGEOID.b"), all.x=T)
fwrite(dt2, paste0(seg_path, "bordseg_chars.csv"))
