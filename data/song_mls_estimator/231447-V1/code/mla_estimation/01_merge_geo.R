# ==============================================================================
# Create municipality shape files
# ==============================================================================

# raw data cleaning ============================================================
# Municipal incorporation data (Version downloaded in March 2023)
plc_xw = read_excel(paste0(data_path,"muni_incorporation/fips_crosswalk.xlsx")) %>% setDT
plc_incorp = read_excel(paste0(data_path,"muni_incorporation/muni-incorporation.xlsx")) %>% setDT

# Census shapefiles
plc_all = st_read(paste0(map_path,"/cb_2019_us_place_500k/cb_2019_us_place_500k.shp"))
ctysub_all = st_read(paste0(map_path,"/cb_2019_us_cousub_500k/cb_2019_us_cousub_500k.shp"))
cty_map = st_read(paste0(map_path,"/cb_2019_us_county_500k/cb_2019_us_county_500k.shp"))
state_map = st_read(paste0(map_path,"/cb_2019_us_state_500k/cb_2019_us_state_500k.shp"))

# Data on types of county subdivisions: https://public.opendatasoft.com/explore/dataset/georef-united-states-of-america-county-subdivision/table/?disjunctive.ste_code&disjunctive.ste_name&disjunctive.coty_code&disjunctive.coty_name&disjunctive.cousub_code&disjunctive.cousub_name&sort=year
ctysub_type = fread(paste0(data_path, "georef-county-subdivision.csv"))

# incorporated places
plc.dt = as.data.table(plc_all)[,.(STATEFP,PLACEFP,AFFGEOID,GEOID,NAME)]
plc.dt = merge(plc.dt[,STATEFP:=as.integer(STATEFP)],
               fips_dt[,.(state_fips=as.integer(state_fips),state_abbr)],
               by.x="STATEFP",by.y="state_fips")

# county subdivisions that are not statistical
ctysub.dt = ctysub_type[,.(state_fips = as.numeric(as.character(`Official Code State`)),
                           ctysub_fips = as.numeric(as.character(`Official Code County Subdivision`)),
                           type = `Type`,
                           muni_name = `Name with legal/statistical area description`)]
to_merge = as.data.table(ctysub_all)[,.(AFFGEOID,
                                        ctysub_fips = as.numeric(as.character(GEOID)),
                                        state_fips = as.numeric(as.character(STATEFP)),
                                        muni_name = NAME)]
ctysub.dt = merge(ctysub.dt, to_merge,
                  by=c("state_fips","ctysub_fips"), all=T, suffixes = c(".type",""))
ctysub.dt = merge(ctysub.dt, fips_dt[,.(state_fips=as.numeric(state_fips), state_abbr)],
                  by="state_fips")
ctysub.dt = ctysub.dt[,.(AFFGEOID,state_abbr,state_fips,ctysub_fips,type,muni_name,muni_name.type)]

# municipality definition by states ============================================
# Main reference: https://www.census.gov/geographies/reference-files/2010/geo/state-local-geo-guides-2010.html

# state type 1: MCD are non-governmental ---------------------------------------
# take independent incorporated places and then countes if relevant
state_vec1 = c("AL","AR","AZ","CA","CO","DC","DE","FL","GA","ID","KY","LA","MD","MS","MT","NC","NM","NV","OK","OR","SC","TN","TX","UT","VA","WA","WV","WY")

for(abbr_i in state_vec1){
  
  print(paste0("Working on: ", abbr_i, " ---------------------------"))
  
  fips_i = fips_dt[state_abbr==abbr_i, state_fips]
  fips_i = ifelse(nchar(fips_i)==1, paste0(0,fips_i), paste0(fips_i))
  state_i = fips_dt[state_abbr==abbr_i, toupper(state_name)]
  
  # list of incorporated places
  inc_temp = plc_xw[`State Name`==state_i]
  plc_temp = plc_all %>% filter(STATEFP==fips_i)
  plc_temp = plc_temp %>% filter(PLACEFP %in% inc_temp[, `FIPS Place Numeric Code`])
  
  # treat exceptions
  # (i) remove some non functioning or dependent incorporated places
  if(abbr_i=="MD"){
    # only Baltimore City is independent
    plc_temp = plc_temp %>% filter(str_detect(NAME, "Baltimore"))
  }
  if(abbr_i=="VA"){
    # Note: only detecting 38/39 incorporated cities (removing towns)
    plc_temp = plc_temp %>% filter(PLACEFP %in% inc_temp[str_detect(Name, "CITY OF"), `FIPS Place Numeric Code`])
  }
  
  # (ii) save
  muni_temp = plc_temp %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
  
  print(paste0("# incorp: ",dim(muni_temp)[1]))
  st_write(muni_temp, paste0(int_path, "muni_boundaries/", abbr_i, ".shp"))
  
  rm(inc_temp, plc_temp, muni_temp)
}

# state type 2: MCDs are governmental units ------------------------------------
# take independent incorporated places and then take MCDs, and then counties if relevant
state_vec2 = c("CT","IA","IL","IN","KS","MA","ME","MI","MN","MO","ND","NE","NH","NJ","NY","OH","PA","RI","SD","VT","WI")

for(abbr_i in state_vec2){
  
  print(paste0("Working on: ", abbr_i, " ---------------------------"))
  
  if(file.exists(paste0(int_path, "muni_boundaries/", abbr_i, ".shp"))){
    file.remove(paste0(int_path, "muni_boundaries/", abbr_i, ".shp"))
  }
  
  fips_i = fips_dt[state_abbr==abbr_i, state_fips]
  fips_i = ifelse(nchar(fips_i)==1, paste0(0,fips_i), paste0(fips_i))
  state_i = fips_dt[state_abbr==abbr_i, toupper(state_name)]
  
  # list of incorporated places
  inc_temp = plc_xw[`State Name`==state_i]
  plc_temp = plc_all %>% filter(STATEFP==fips_i)
  plc_temp = plc_temp %>% filter(PLACEFP %in% inc_temp[, `FIPS Place Numeric Code`])
  
  # list of MCDs
  ctysub_temp = ctysub_all %>% filter(STATEFP==fips_i)
  ctysub_type_temp = ctysub_type[toupper(`Official Name State`)==state_i,.(fips = `Official Code County`, 
                                                                           GEOID = `Official Code County Subdivision`,
                                                                           type = `Type`)]
  
  # restrict to city, town, township, village, municipality, county (removing, UT, district, borough, precinct, reservation, charter, gore, plantation)
  # exception: for PA, include boroughs
  if(abbr_i=="PA"){
    ctysub_type_temp = ctysub_type_temp[type!=""]
  } else{
    ctysub_type_temp = ctysub_type_temp[type%in%c("township","town","city","village","municipality","county")]
  }
  
  # treat exceptions
  if(abbr_i=="CT"){
    plc_muni = plc_temp %>% filter(NA)
    ctysub_muni = ctysub_temp %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  } else if(abbr_i=="IA"){
    # 59 independent places and 1 partially independent (Tabor)
    ctysub_indp = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="city",as.numeric(GEOID)]) %>% as.data.table %>% .$NAME %>% unique
    indp_incorp = data.table()
    for(indp_i in ctysub_indp){
      temp = filter(plc_temp, NAME==indp_i)
      indp_incorp = rbindlist(list(indp_incorp, as.data.table(temp) %>% .[,.(STATEFP,AFFGEOID,NAME)]))
    }
    plc_muni = plc_temp %>% filter(AFFGEOID%in%indp_incorp$AFFGEOID) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="township",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  } else if(abbr_i=="IL"){
    plc_muni = plc_temp %>% filter(NAME=="Chicago") %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = ctysub_temp %>% filter(NAME!="Chicago") %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  } else if(abbr_i=="IN"){
    plc_muni = plc_temp %>% filter(NAME%in%c("Indianapolis","Terre Haute")|str_detect(NAME, "Indianapolis")) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = ctysub_temp %>% filter(!NAME%in%c("Indianapolis","Terre Haute")&!str_detect(NAME, "Indianapolis")) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  } else if(abbr_i=="KS"){
    ctysub_indp = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="city",as.numeric(GEOID)]) %>% as.data.table %>% .$NAME %>% unique
    indp_incorp = data.table()
    for(indp_i in ctysub_indp){
      temp = filter(plc_temp, NAME==indp_i)
      indp_incorp = rbindlist(list(indp_incorp, as.data.table(temp) %>% .[,.(STATEFP,AFFGEOID,NAME)]))
    }
    plc_muni = plc_temp %>% filter(AFFGEOID%in%indp_incorp$AFFGEOID) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    # 1401 MCDs while 1274 active and 129 inactive
    ctysub_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="township",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  } else if(abbr_i=="MA"){
    plc_muni = plc_temp %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="town",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  } else if(abbr_i=="ME"){
    plc_muni = plc_temp %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="town",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  } else if(abbr_i=="MI"){
    plc_muni = plc_temp %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="township",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  } else if(abbr_i=="MN"){
    plc_muni = plc_temp %>% filter(!NAME%in%c("Aurora","Beardsley","Calumet","Johnson","Kinney","Marble","Nashwauk","Ortonville","Taconite")) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="township",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  } else if(abbr_i=="MO"){
    plc_muni = plc_temp %>% filter(NAME%in%c("St. Louis","Springfield")) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = ctysub_temp %>% filter(!NAME%in%c("St. Louis","Springfield")) 
    
    # restrict to 22 counties where MCDs are functioning
    county_indp = cty_map %>% filter(STATEFP==fips_i) %>% as.data.table %>% .[,.(NAME,GEOID)]
    county_indp = county_indp[NAME%in%c("Barton","Bates","Caldwell","Carroll","Chariton","Dade","Daviess","DeKalb","Dunklin","Gentry","Grundy","Harrison","Henry","Linn","Livingston","Mercer","Nodaway","Putnam","Stoddard","Sullivan","Texas","Vernon")]
    
    ctysub_muni = ctysub_muni %>% filter(COUNTYFP%in%county_indp[,str_sub(GEOID,3,-1)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
    
  } else if(abbr_i=="ND"){
    plc_muni = plc_temp %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="township",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  } else if(abbr_i=="NE"){
    # 76 cities and 425 townships (some are missing)
    plc_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="city",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="township",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  } else if(abbr_i=="NH"){
    # keep inactive but nongov
    plc_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="city",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="town",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  } else if(abbr_i=="NJ"){
    plc_muni = plc_temp %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="township",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  } else if(abbr_i=="NY"){
    plc_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="city",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="town",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  } else if(abbr_i=="OH"){
    # (i) first take incorp places (cities and villages), which are either independent or partially independent
    # take all incorp places and ctysub with the same name (will assume they are the zoning authority)
    
    indp_incorp = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type%in%c("city","village"),as.numeric(GEOID)]) %>% as.data.table %>% .[,.(n_ctysub=.N),NAME]
    for(i in 1:indp_incorp[,.N]){
      NAME_i = indp_incorp[i,NAME]
      ctysub_list_i = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type%in%c("city","village"),as.numeric(GEOID)]) %>% as.data.table %>% .[order(-ALAND)] %>% .[NAME==NAME_i,AFFGEOID]
      plc_list_i = plc_temp %>% as.data.table %>% .[order(-ALAND)] %>% .[NAME==NAME_i,AFFGEOID]
      plc_i = st_union(st_union(ctysub_temp %>% filter(AFFGEOID %in% ctysub_list_i)), st_union(plc_temp %>% filter(AFFGEOID %in% plc_list_i)))
      
      indp_incorp[, n_plc:=length(plc_list_i)]
      if(length(ctysub_list_i)>0){
        indp_incorp[i, `:=`(AFF_c1=ctysub_list_i[1])]
      }
      if(length(ctysub_list_i)>1){
        indp_incorp[i, `:=`(AFF_c2=ctysub_list_i[2])]
      }
      if(length(ctysub_list_i)>2){
        indp_incorp[i, `:=`(AFF_c3=ctysub_list_i[3])]
      }
      
      if(length(plc_list_i)>0){
        indp_incorp[i, `:=`(AFF_p1=plc_list_i[1])]
      }
      if(length(plc_list_i)>1){
        indp_incorp[i, `:=`(AFF_p2=plc_list_i[2])]
      }
      if(length(plc_list_i)>2){
        indp_incorp[i, `:=`(AFF_p3=plc_list_i[3])]
      }
      
      plc_i = st_make_valid(plc_i)
      
      if(i==1){
        plc_muni = plc_i
      } else{
        plc_muni = rbind(plc_muni, plc_i)
      }
    }
    plc_muni = st_sf(indp_incorp %>% mutate(STATEFP=39, state_abbr=abbr_i, type = "incorp", geometry=st_sfc(plc_muni)), crs = 4269)
    rm(plc_list_i, ctysub_list_i, plc_i)
    
    # (ii) take townships (ctysub divisions) that are not part of (i) - dropping 4 ctysubs
    ctysub_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="township",as.numeric(GEOID)])
    ctysub_muni = st_difference(ctysub_muni, st_union(plc_muni)) %>% st_make_valid
    ctysub_muni = ctysub_muni %>% mutate(area = st_area(ctysub_muni)) %>% filter(as.numeric(area)>0) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
    ctysub_muni = ctysub_muni %>% st_collection_extract
    
  } else if(abbr_i=="PA"){
    # take incorporated places and the rest ctysubdivisions
    plc_muni = plc_temp %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = st_difference(ctysub_temp, st_union(plc_muni)) %>% st_make_valid
    ctysub_muni = ctysub_muni %>% mutate(area = st_area(ctysub_muni)) %>% filter(as.numeric(area)>0) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  } else if(abbr_i=="RI"){
    plc_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="city",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="town",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  } else if(abbr_i=="SD"){
    plc_muni = plc_temp %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="township",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  } else if(abbr_i=="VT"){
    plc_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="city",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="town",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
    # 9 towns are inactive but keeping them: filter(ctysub_muni, NAME%in%c("Averill","Ferdinand","Glastenbury","Lewis","Somerset"))
  } else if(abbr_i=="WI"){
    plc_muni = plc_temp %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "incorp")
    ctysub_muni = ctysub_temp %>% filter(as.numeric(GEOID)%in%ctysub_type_temp[type=="town",as.numeric(GEOID)]) %>% select(STATEFP, AFFGEOID, NAME) %>% mutate(state_abbr = abbr_i, type = "mcd")
  }
  
  print(paste0("# incorp: ",dim(plc_muni)[1], ", # MCD: ",dim(ctysub_muni)[1]))
  
  # save - Note that for Ohio, saving two separate files
  if(abbr_i=="OH"){
    st_write(plc_muni, paste0(int_path, "muni_boundaries/", abbr_i, "_plc.shp"))
    st_write(ctysub_muni, paste0(int_path, "muni_boundaries/", abbr_i, "_ctysub.shp"))
  } else{
    muni_temp = rbind(plc_muni, ctysub_muni)
    if(dim(muni_temp)[2]!=6){
      break
    }
    st_write(muni_temp, paste0(int_path, "muni_boundaries/", abbr_i, ".shp"))
  }
  
  rm(inc_temp, plc_temp, ctysub_temp, plc_muni, ctysub_muni, muni_temp, indp_incorp, plc_union)
}

# ==============================================================================
# Merge geography to parcel data
# ==============================================================================

# Parcel Data county files
file_vec = list.files(tax_path, full.names=T)

# Command line input for parallel computing (job_i = 1,...,# of county-level tax files)
job_i = as.integer(commandArgs(trailingOnly=T))
file_i <- file_vec[job_i]

# read parcel data
dt0 = fread(file_i, colClasses="character",
           select = c(id_vars,"prop_type","zoning","st_long","st_lat",
                      "year_built","eff_year_built",
                      "tax_year","assd_year","land_sqft"))

# choose one record in each parcel
dt0 = dt0[st_long!="",.SD[1],by=id_vars]

# define row index
dt0[, i_row:=.I]

# shapefile to merge
to_merge <- dt0[, .(i_row, st_lat=as.numeric(st_lat), st_long=as.numeric(st_long))]
to_merge <- to_merge[!is.na(st_lat)]
to_merge <- st_as_sf(to_merge, coords=c("st_long","st_lat"), crs=4269)

# merge Census Places ==========================================================
# read Places boundaries
plc_map <- st_read(paste0(map_path, "cb_2019_us_place_500k/cb_2019_us_place_500k.shp"))
plc_map <- st_transform(plc_map, 4269)

# merge Places
temp = st_join(to_merge, plc_map)
temp = as.data.table(temp)[,.(i_row, plc_geoid=GEOID)]
dt0 = merge(dt0, temp[,SD[1],by=i_row], all.x=T)

# merge County Subdivisions ====================================================
# read Places boundaries
ctysub_map <- st_read(paste0(map_path, "cb_2019_us_cousub_500k/cb_2019_us_cousub_500k.shp"))
ctysub_map <- st_transform(ctysub_map, 4269)

# merge Places
temp = st_join(to_merge, ctysub_map)
temp = as.data.table(temp)[,.(i_row, ctysub_geoid=GEOID)]
dt0 = merge(dt0, temp[,SD[1],by=i_row], all.x=T)

# merge Census Block Group =====================================================
# read CBG boundaries
cbg_map <- st_read(paste0(map_path, "cb_2019_us_bg_500k/cb_2019_us_bg_500k.shp"))
cbg_map <- st_transform(cbg_map, 4269)

# merge CBG
temp = st_join(to_merge, cbg_map)
temp = as.data.table(temp)[,.(i_row, cbg_geoid=GEOID)]
dt0 = merge(dt0, temp[,SD[1],by=i_row], all.x=T)

# merge School District ========================================================
# read school district boundaries
sd_map <- st_read(paste0(map_path, "nces_map/schooldistrict_sy1819_tl19.shp"))
sd_map <- st_transform(sd_map, 4269)
sd_map <- st_make_valid(sd_map)

# merge School District
temp = st_join(to_merge, sd_map)
temp = as.data.table(temp)[,.(i_row, ELSDLEA, SCSDLEA, UNSDLEA)]
dt0 = merge(dt0, temp[,SD[1],by=i_row], all.x=T)

# merge municipality ===========================================================
# municipality map -------------------------------------------------------------
if(state_i!="OH"){
  muni_i = st_read(paste0(int_path, "muni_boundaries/", state_i, ".shp"))
  incorp_i = filter(muni_i, type=="incorp") %>% .$AFFGEOID %>% unique
  mcd_i = filter(muni_i, type=="mcd") %>% .$AFFGEOID %>% unique
} else{
  incorp_i = st_read(paste0(int_path, "muni_boundaries/", state_i, "_plc.shp")) %>% as.data.table
  mcd_i = st_read(paste0(int_path, "muni_boundaries/", state_i, "_ctysub.shp")) %>% .$AFFGEOID %>% unique
}

# clean municipality  ----------------------------------------------------------
dt0[ctysub_geoid!="", `:=`(ctysub_affgeoid = paste0("0600000US", ctysub_geoid))]
dt0[plc_geoid!="", `:=`(plc_affgeoid = paste0("1600000US",plc_geoid))]

if(state_i!="OH"){
  dt0[plc_affgeoid%in%incorp_i, `:=`(muni_AFFGEOID=plc_affgeoid)]
  dt0[ctysub_affgeoid%in%incorp_i, `:=`(muni_AFFGEOID=ctysub_affgeoid)]
} else{
  for(k in 1:dim(incorp_i)[1]){
    dt0[plc_affgeoid%in%incorp_i[k,.(AFF_p1,AFF_p2,AFF_p3)] %>% unlist %>% .[!is.na(.)], `:=`(muni_AFFGEOID=incorp_i[k,AFF_p1])]
    dt0[ctysub_affgeoid%in%incorp_i[k,.(AFF_c1,AFF_c2,AFF_c3)] %>% unlist %>% .[!is.na(.)], `:=`(muni_AFFGEOID=incorp_i[k,AFF_p1])]
  }
}
dt0[is.na(muni_AFFGEOID)&ctysub_affgeoid%in%mcd_i, `:=`(muni_AFFGEOID=ctysub_affgeoid)]

# whether county has power
if(!state_i %in% c("CT","DC","LA","RI")){
  dt0[is.na(muni_AFFGEOID), `:=`(muni_AFFGEOID=paste0("0500000US",
                                                      ifelse(nchar(fips)==4, paste0("0", fips), fips)))]
}

# save the intermediate parcel file with geographic info =======================
dt0[, zoning_clean:=str_replace_all(zoning, "[[:punct:]]", "")]
fwrite(dt0[,.SD,.SDcols=c(id_vars,"st_long","st_lat","cbg_geoid","plc_geoid","ctysub_geoid",
                          "ELSDLEA","SCSDLEA","UNSDLEA","muni_AFFGEOID","zoning_clean")],
       paste0(int_path, "st_geo/", file_i))
