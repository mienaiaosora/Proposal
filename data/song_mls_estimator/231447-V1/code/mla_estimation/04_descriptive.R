###############################################################################
# State level variations
###############################################################################

dt_state = fread(paste0(int_path, "mla_est/by_geo/mla_stats_state_muni_cbsa.csv"))
dt_state = merge(dt_state, fips_dt[,.(state_fips,state_abbr)], by="state_fips")
dt_state = merge(dt_state, region_dt, by="state_fips")

# state plot
ggplot(dt_state[N_apn>=1000], aes(x=med_mla_post40,
                                  y=p_bind05_post40.built40*100,
                                  label=state_abbr))+
  # geom_text_repel(max.overlaps = 25, size=6)+
  geom_text(size=6)+
  scale_x_continuous(breaks=c(10000,20000,30000,40000))+
  ylim(10,25)+
  labs(x = "Median min lot size (in SF)",
       y= "% Bunching rate")
ggsave(paste0(output_path, "fig_by_state.pdf"),
       dpi = "print", width= 11, height = 8)

# national level bunching: 0.1845228
dt_state[,sum(p_bind05_post40.built40*N_mla_post40.built40)/sum(N_mla_post40.built40)]
# > dt_state[order(p_bind05_post40.built40)][1:5,.(state_abbr,p_bind05_post40.built40)]
# state_abbr p_bind05_post40.built40
# 1:         VT               0.1139709
# 2:         NC               0.1154222
# 3:         ME               0.1197141
# 4:         NH               0.1262461
# 5:         DC               0.1298358
# > dt_state[order(-p_bind05_post40.built40)][1:5,.(state_abbr,p_bind05_post40.built40)]
# state_abbr p_bind05_post40.built40
# 1:         NJ               0.2378251
# 2:         CA               0.2358332
# 3:         FL               0.2280358
# 4:         IL               0.2224149
# 5:         TX               0.2202110

dt_state[, summary(med_mla_post40)]

###############################################################################
# CBG/CT level variations
###############################################################################

dt_cbg = fread(paste0(int_path, "mla_est/by_geo/mla_stats_cbg_muni.csv"),
               colClasses=c(cbg_geoid="character"))
# add CBSA
dt_cbg[, fips:=str_sub(cbg_geoid,1,5)]
dt_cbg = merge(dt_cbg, cbsa_dt[,.(fips=ifelse(nchar(fips)==4,paste0(0,fips),paste0(fips)),cbsa)],
               by="fips")
# select MLA statistics
dt_cbg = dt_cbg[,.(cbsa,fips,cbg_geoid,
                   N_apn,N_apn.built40,
                   mla_est=med_mla_post40,
                   mla_bunching=N_mla_post40.built40)]
# remove outliers (1st and 99th percentiles)
dt_cbg = dt_cbg[N_apn.built40>=100]
dt_cbg = dt_cbg[mla_est<=5*43560&mla_est>=2500]

# > dt_cbg[, mean(mla_est, na.rm=T)]
# [1] 17825.91
# > dt_cbg[, median(mla_est, na.rm=T)]
# [1] 10001

# CBG distributions ------------------------------------------------------------
ggplot(dt_cbg, aes(x=mla_est))+
  geom_density()+
  scale_x_continuous(trans="log",breaks=c(3000,9000,3*9000,9*9000,3*9*9000))+
  geom_vline(xintercept=7500, linetype="dashed")+
  geom_vline(xintercept=10000, linetype="dashed")+
  geom_vline(xintercept=15000, linetype="dashed")+
  geom_vline(xintercept=20000, linetype="dashed")+
  geom_vline(xintercept=43560, linetype="dashed")+
  geom_vline(xintercept=43560*2, linetype="dashed")+
  annotate("text", x=9500, y=0.975, label = "7500 SF", size=5)+
  annotate("text", x=13000, y=0.775, label = "10000 SF", size=5)+
  annotate("text", x=19000, y=0.475, label = "15000 SF", size=5)+
  annotate("text", x=27000, y=0.37, label = "20000 SF", size=5)+
  annotate("text", x=60000, y=0.45, label = "43,560 SF\n(1 acre)", size=5)+
  annotate("text", x=120000, y=0.15, label = "87,120 SF\n(2 acres)", size=5)+
  labs(x="Min lot size (in SF)", y="density")
ggsave(paste0(output_path, "fig_dist_cbg.pdf"),
       dpi = "print", width= 10, height = 6)

# merge CBG-level neighborhood chars
# Source: 2020 ACS 5-year estimates and Fee_and_Hartley (distance to CBD)
to_merge = fread(paste0(data_path,"CBG_chars.csv"))
to_merge[, cbg_geoid:=str_sub(GEO_ID,-12,-1)]
dt_cbg = merge(dt_cbg, to_merge, by="cbg_geoid")

# add CBG land area
to_merge = st_read(paste0(map_path, "cb_2019_us_bg_500k/cb_2019_us_bg_500k.shp")) %>% setDT
to_merge = to_merge[,.(cbg_geoid=GEOID,cbg_land=ALAND)]
dt_cbg = merge(dt_cbg, to_merge ,by="cbg_geoid")

# clean variable
dt_cbg[, p_educ_bplus:=(educ_bachelor+educ_master+educ_prof+educ_doctor)/educ_all]
dt_cbg[, med_home_value:=as.numeric(med_home_value)]
dt_cbg[, med_gross_rent:=as.numeric(med_gross_rent)]
dt_cbg[, pop_dens:=pop_tot/cbg_land]
dt_cbg[, p_hispan:=tot1_hispan/tot1_pop]
dt_cbg[, med_hh_inc:=as.numeric(med_hh_inc)]

# Within CBSA variations ----------------------------------------
by_cbsa = dt_cbg[, .(n_cbg=.N,
                     q1=quantile(mla_est, 0.1,na.rm=T),
                     q9=quantile(mla_est, 0.9, na.rm=T)), by=cbsa]
# > by_cbsa[,summary(n_cbg)]
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.0    12.0    26.0   101.8    67.5  4162.0 
# > by_cbsa[n_cbg>=10, summary(q9/q1)]
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.000   2.155   3.587   5.400   6.474  35.449 

# binscatter plot (dist to CBD) ---------------------------------
# function for binscatter plot
source("code/fn_binscatter.R")
options(scipen=10000)
dt_cbg[, dist0:=dist_to_cbg, by=cbsa]
dt_cbg[, dist1:=dist_to_cbg/max(dist_to_cbg, na.rm=T), by=cbsa]

# binscatter with raw distance (dist0)
dist0_bins = dt_cbg[, quantile(dist0, seq(0,1,0.05), na.rm=T)]
dist0_binsreg = binscatter_feols(dt_cbg, y_var="mla_est",
                                 x_var="dist0", x_cuts=dist0_bins, include.lowest = F,
                                 fe_vars = "cbsa")
ggplot(dist0_binsreg, aes(x=mean_x*3.28084/1000, y=10000/y_coeff_scale))+
  geom_point()+
  scale_x_continuous(labels = scales::comma)+
  labs(x="Distance to CBD (in 1,000ft)",
       y="Allowed density")
ggsave(paste0(output_path, "binscatter_CBD0.pdf"),
       dpi = "print", width= 9, height = 7)

# binscatter with normalized dist (dist1)
dist1_bins = dt_cbg[, quantile(dist1, seq(0,1,0.05), na.rm=T)]
dist1_binsreg = binscatter_feols(dt_cbg, y_var="mla_est",
                                 x_var="dist1", x_cuts=dist1_bins, include.lowest = F,
                                 fe_vars = "cbsa")
ggplot(dist1_binsreg, aes(x=mean_x, y=10000/y_coeff_scale))+
  geom_point()+
  labs(x="Distance to CBD (relative to the furthest)",
       y="Allowed density")
ggsave(paste0(output_path, "binscatter_CBD1.pdf"),
       dpi = "print", width= 9, height = 7)

# single regression ---------------------------------------------
dt_cbg[, `:=`(log_density=log(pop_dens),
              log_inc=log(med_hh_inc),
              log_hval=log(med_home_value),
              log_rent=log(med_gross_rent),
              log_dist0=log(dist0),
              log_dist1=log(dist1))]
dt_cbg[log_density==-Inf, log_density:=NA]

reg_dt = data.table(y_var=c("log_density",
                            "p_white",
                            "p_black",
                            "p_asian",
                            "p_hispan",
                            "log_inc",
                            "p_educ_bplus",
                            "log_hval",
                            "log_rent",
                            "log_dist0",
                            "dist1"),
                    clean_name = c("log density",
                                   "% white",
                                   "% Black",
                                   "% Asian",
                                   "% Hispanic",
                                   "log income",
                                   "% Bachelor+",
                                   "log home value",
                                   "log gross rent",
                                   "dist to CBD (absolute)",
                                   "dist to CBD (relative)"))
reg_dt0=copy(reg_dt)
reg_dt1=copy(reg_dt)

x_var ="log(mla_est)"
for(j in 1:reg_dt[,.N]){
  reg_formula = paste0(reg_dt[j,y_var],"~",x_var,"|cbsa")
  reg_j = feols(as.formula(reg_formula), dt_cbg)
  reg_dt[j, `:=`(nobs = reg_j$nobs,
                 coef = reg_j$coeftable[1,1],
                 se = reg_j$coeftable[1,2],
                 tval = reg_j$coeftable[1,3],
                 y_sd = dt_cbg[!is.na(mla_est), sd(get(reg_dt[j,y_var]),na.rm=T)])]
  
  reg_formula = paste0(reg_dt[j,y_var],"~",x_var)
  reg_j = feols(as.formula(reg_formula), dt_cbg, cluster="cbsa")
  reg_dt0[j, `:=`(nobs = reg_j$nobs,
                  coef = reg_j$coeftable[1,1],
                  se = reg_j$coeftable[1,2],
                  tval = reg_j$coeftable[1,3],
                  y_sd = dt_cbg[!is.na(mla_est), sd(get(reg_dt[j,y_var]),na.rm=T)])]
  
  reg_formula = paste0(reg_dt[j,y_var],"~",x_var,"+dist1|cbsa")
  reg_j = feols(as.formula(reg_formula), dt_cbg, cluster="cbsa")
  reg_dt1[j, `:=`(nobs = reg_j$nobs,
                  coef = reg_j$coeftable[1,1],
                  se = reg_j$coeftable[1,2],
                  tval = reg_j$coeftable[1,3],
                  y_sd = dt_cbg[!is.na(mla_est), sd(get(reg_dt[j,y_var]),na.rm=T)])]
}

reg_dt[, `:=`(coef_norm = coef/y_sd,
              se_norm = se/y_sd)]
reg_dt[, `:=`(coef_min = coef_norm-1.96*se_norm,
              coef_max = coef_norm+1.96*se_norm)]
reg_dt[, clean_name:=factor(clean_name, reg_dt[.N:1,clean_name])]

reg_dt0[, `:=`(coef_norm = coef/y_sd,
               se_norm = se/y_sd)]
reg_dt0[, `:=`(coef_min = coef_norm-1.96*se_norm,
               coef_max = coef_norm+1.96*se_norm)]
reg_dt0[, clean_name:=factor(clean_name, reg_dt0[.N:1,clean_name])]

reg_dt1[, `:=`(coef_norm = coef/y_sd,
               se_norm = se/y_sd)]
reg_dt1[, `:=`(coef_min = coef_norm-1.96*se_norm,
               coef_max = coef_norm+1.96*se_norm)]
reg_dt1[, clean_name:=factor(clean_name, reg_dt0[.N:1,clean_name])]

ggplot(rbindlist(list(reg_dt[, i_spec:="CBSA FE"],
                      reg_dt1[, i_spec:="CBSA FE + dist to CBD"]))[!str_detect(clean_name, "dist")], 
       aes(x=coef_norm,xmin=coef_min,xmax=coef_max,y=clean_name,
           group=as.factor(i_spec),color=as.factor(i_spec)))+
  geom_vline(xintercept=0, linetype="dashed", alpha=0.5)+
  geom_point(position=position_dodge2(width=0.5), size=3)+
  geom_linerange(position=position_dodge2(width=0.5), size=1.5)+
  scale_color_viridis_d()+
  labs(x="Coef. and 95% CI",
       y=element_blank(),
       color = "Controls")+
  xlim(-1,1)
ggsave(paste0(output_path, "withincbsa_regs.pdf"),
       dpi = "print", width= 10, height = 6)

# value with dist to CBD controlled
sink(paste0(output_path, "tex_descriptive.txt"))
reg_formula = paste0("log_hval~",x_var,"|cbsa")
reg_hval0 = feols(as.formula(reg_formula), dt_cbg)
reg_formula = paste0("log_hval~",x_var,"+dist1|cbsa")
reg_hval1 = feols(as.formula(reg_formula), dt_cbg)
print(etable(reg_hval0,reg_hval1, tex=T))

reg_formula = paste0("log_rent~",x_var,"|cbsa")
reg_rent0 = feols(as.formula(reg_formula), dt_cbg)
reg_formula = paste0("log_rent~",x_var,"+dist1|cbsa")
reg_rent1 = feols(as.formula(reg_formula), dt_cbg)
print(etable(reg_rent0,reg_rent1, tex=T))
sink()
