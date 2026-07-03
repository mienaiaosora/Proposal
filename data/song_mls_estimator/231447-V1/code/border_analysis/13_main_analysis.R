# =======================================================
# Specifications
# =======================================================

# border sample path
sample_path = paste0(int_path, "sample_by_dist/")

# covariates --------------------------------------------------
cov_bldg = c("LOG_land_sqft","LOG_univ_bldg_sqft","eff_age","bed_n","calc_bath_n")
cov_neigh0 = c("IPUMS_NA","IPUMS_NA_mean_valueh","IPUMS_NA_mean_rent","IPUMS_NA_p_ownership",
               "IPUMS_log_n_obs","IPUMS_mean_pernum","IPUMS_log_mean_inc","IPUMS_mean_i_white",
               "IPUMS_p_ownership","IPUMS_log_mean_valueh","IPUMS_log_mean_rent",
               "dist2bord")
x_i = "LOG_MLA"
fe_i1 = c("id_bord","fips_yr")

# read sample -------------------------------------------------
deed_dt = paste0("deed_0",1:5,".csv") %>% lapply(function(x) fread(paste0(sample_path, x))[,dist2bord:=str_sub(x,-5,-5) %>% as.integer]) %>% rbindlist
hmda_dt = paste0("hmda_0",1:5,".csv") %>% lapply(function(x) fread(paste0(sample_path, x))[,dist2bord:=str_sub(x,-5,-5) %>% as.integer]) %>% rbindlist
mls_dt = paste0("mls_0",1:5,".csv") %>% lapply(function(x) fread(paste0(sample_path, x))[,dist2bord:=str_sub(x,-5,-5) %>% as.integer]) %>% rbindlist

# =======================================================
# Border segment illustration
# =======================================================

muni_map = st_read(paste0(int_path,"muni_boundaries/CT.shp"))
to_plot = fread(paste0(int_path, "border_seg_parcels/fips_09003.csv"))
muni_i = to_plot[str_detect(AFFGEOID,"0600000US0900337070"),unique(AFFGEOID)]
muni_j = to_plot[str_detect(AFFGEOID,"0600000US0900382590"),unique(AFFGEOID)]

to_plot = to_plot[AFFGEOID.a%in%c(muni_i,muni_j)&AFFGEOID.b%in%c(muni_i,muni_j)]
to_plot = st_as_sf(to_plot, coords=c("long","lat"), crs=4269)

ggplot()+
  geom_sf(data=to_plot %>% filter(grp_bordseg4!=""&grp_border==34), mapping=aes(color=str_sub(grp_bordseg4,-1,-1)))+
  geom_sf(data=muni_map %>% filter(AFFGEOID%in%c(muni_i,muni_j)),fill=NA)+
  scale_color_viridis_d()+
  theme_bw()+
  annotate("text", x=-72.775, y=41.78, label = "Municipality A", size=6)+
  annotate("text", x=-72.675, y=41.78, label = "Municipality B", size=6)+
  theme(text = element_text(size=15),
        legend.text = element_text(size=20),
        strip.text=element_text(size=15),
        legend.position="bottom")+
  labs(color="Border segment",x=element_blank(),y=element_blank())
ggsave(paste0(output_path, "fig_eg_seg_design.pdf"),
       dpi = "print", width= 9, height = 7)

# =======================================================
# Baseline Sample Descriptives
# =======================================================

# Descriptive Statistics -------------------------------------------------------

sink(paste0(output_path, "summary_stats.txt"))
dt = deed_dt[!is.na(LOG_MLA)]
dt[,.(.N,.SD[,uniqueN(.SD),.SDcols=c("fips","apn_unformatted","apn_num")],.SD[,uniqueN(.SD),.SDcols=c("fips","id_bord")])]
var_vec = c("PRICE","MLA","land_sqft","univ_bldg_sqft","eff_year_built","bed_n","calc_bath_n")
print("Baseline sales sample statistics --------------------")
for(var_i in var_vec){
  print(var_i)
  print(dt[,.(quantile(get(var_i),0.25,na.rm=T),quantile(get(var_i),0.5,na.rm=T),quantile(get(var_i),0.75,na.rm=T),mean(get(var_i),na.rm=T),sd(get(var_i),na.rm=T))])
}

print("Baseline rental sample statistics --------------------")
dt = hmda_dt[!is.na(LOG_MLA)]
dt[,.(.N,.SD[,uniqueN(.SD),.SDcols=c("fips","apn_unformatted","apn_num")],.SD[,uniqueN(.SD),.SDcols=c("fips","id_bord")])]
var_vec = c("sale_price_adj","mla_est_post40","i_white","i_black","i_asian","i_hispanic","inc_clean")
for(var_i in var_vec){
  print(var_i)
  print(dt[,.(quantile(get(var_i),0.25,na.rm=T),quantile(get(var_i),0.5,na.rm=T),quantile(get(var_i),0.75,na.rm=T),mean(get(var_i),na.rm=T),sd(get(var_i),na.rm=T))])
}

print("Baseline demo sample statistics --------------------")
dt = mls_dt[!is.na(LOG_MLA)]
dt[,.(.N,.SD[,uniqueN(.SD),.SDcols=c("fips","apn_unformatted","apn_num")],.SD[,uniqueN(.SD),.SDcols=c("fips","id_bord")])]
var_vec = c("ClosePrice_adj","mla_est_post40","land_sqft","univ_bldg_sqft","eff_year_built","bed_n","calc_bath_n")
for(var_i in var_vec){
  print(var_i)
  print(dt[,.(quantile(get(var_i),0.25,na.rm=T),quantile(get(var_i),0.5,na.rm=T),quantile(get(var_i),0.75,na.rm=T),mean(get(var_i),na.rm=T),sd(get(var_i),na.rm=T))])
}

# some border descriptions -----------------------------------------------------
print("Border statistics --------------------")
border_chars <- fread(paste0(int_path, "border_seg_parcels/border_chars.csv"), colClasses="character")
border_chars[nchar(fips)==4, fips:=paste0(0,fips)]
border_chars[, id_bord:=paste0(fips,"_",grp_border)]

bordseg_chars <- fread(paste0(int_path, "border_seg_parcels/bordseg_chars.csv"), colClasses="character")[grp_bordseg!=""]
bordseg_chars[nchar(fips)==4, fips:=paste0(0,fips)]
bordseg_chars[, type_bordseg:=str_sub(grp_bordseg,1,-3)]
bordseg_chars[, id_bord:=paste0(fips,"_",grp_bordseg)]

bord_dt = rbindlist(list(border_chars[, .(id_bord, MEAN_mla_est_post40.a, MED_mla_est_post40.a, MEAN_mla_est_post40.b, MED_mla_est_post40.b, SD_logmla_est_post40.a, SD_logmla_est_post40.b)],
                         bordseg_chars[, .(id_bord, MEAN_mla_est_post40.a, MED_mla_est_post40.a, MEAN_mla_est_post40.b, MED_mla_est_post40.b, SD_logmla_est_post40.a, SD_logmla_est_post40.b)]),
                    use.names=F)
bord_dt = merge(bord_dt, deed_dt[!is.na(LOG_MLA), .(n_deed=.N), by=id_bord], by="id_bord", all.x=T)
bord_dt = merge(bord_dt, hmda_dt[!is.na(LOG_MLA), .(n_hmda=.N), by=id_bord], by="id_bord", all.x=T)
bord_dt = merge(bord_dt, mls_dt[!is.na(LOG_MLA), .(n_mls=.N), by=id_bord], by="id_bord", all.x=T)
bord_dt = bord_dt[!is.na(n_deed)|!is.na(n_hmda)|!is.na(n_mls)]
print(bord_dt[, mean(n_deed,na.rm=T)])
print(bord_dt[, mean(n_hmda,na.rm=T)])
print(bord_dt[, mean(n_mls,na.rm=T)])
print(bord_dt[, exp(mean(abs(log(as.numeric(MED_mla_est_post40.a))-log(as.numeric(MED_mla_est_post40.b))),na.rm=T))])
print(bord_dt[, exp(median(abs(log(as.numeric(MED_mla_est_post40.a))-log(as.numeric(MED_mla_est_post40.b))),na.rm=T))])
mean(c(bord_dt[,as.numeric(SD_logmla_est_post40.a)],bord_dt[,as.numeric(SD_logmla_est_post40.b)]), na.rm=T)

sink()

# jump at the border -----------------------------------------------------------
bord_high = bord_dt[,.(id_bord, a.high = ifelse(MED_mla_est_post40.a>MED_mla_est_post40.b,1,0))]

# IPUMS characteristics
deed_dt1 = deed_dt[IPUMS_NA==0][!is.na(LOG_MLA)]
deed_dt1[, i.a := ifelse(AFFGEOID==AFFGEOID.a, 1,0)]
deed_dt1 = merge(deed_dt1, bord_high, by="id_bord")
deed_dt1[, i_high:= ifelse(i.a==1&a.high==1|i.a==0&a.high==0,1,0)]

test_ipums = c("IPUMS_log_n_obs","IPUMS_mean_pernum","IPUMS_log_mean_inc","IPUMS_mean_i_white",
               "IPUMS_p_ownership","IPUMS_log_mean_valueh","IPUMS_log_mean_rent")
reg_ipums = data.table()
for(var_i in test_ipums){
  out_i = var_i
  x_i = "i_high"
  formula_temp <- paste0(out_i, "~", x_i,
                         "|", paste(c(fe_i1), collapse="+"))
  reg_i = feols(as.formula(formula_temp), data=deed_dt1[get(out_i)>=0], cluster = c("AFFGEOID"))
  reg_temp = data.table(y_var = out_i,
                        data = "deed",
                        N = deed_dt1[get(out_i)>=0,.N],
                        spec = 1,
                        coef = coefficients(reg_i)[[x_i]],
                        se = se(reg_i)[[x_i]],
                        R2 = r2(reg_i)["ar2"])
  reg_ipums = rbindlist(list(reg_ipums, reg_temp))
  formula_temp <- paste0(out_i, "~", x_i,
                         "|", paste(c(fe_i1,"SDLEA"), collapse="+"))
  reg_i = feols(as.formula(formula_temp), data=deed_dt1, cluster = c("AFFGEOID"))
  reg_temp = data.table(y_var = out_i,
                        data = "deed",
                        N = deed_dt1[get(out_i)>=0,.N],
                        spec = 2,
                        coef = coefficients(reg_i)[[x_i]],
                        se = se(reg_i)[[x_i]],
                        R2 = r2(reg_i)["ar2"])
  reg_ipums = rbindlist(list(reg_ipums, reg_temp))
}
reg_ipums[, `:=`(coef_low = coef - 1.96*se,
                 coef_high = coef + 1.96*se)]
reg_ipums[, `:=`(t_stat = abs(coef/se))]
reg_ipums[, `:=`(stars = ifelse(t_stat>2.58,"***",ifelse(t_stat>1.96,"**",ifelse(t_stat>1.65,"*",""))))]
fwrite(reg_ipums, paste0(output_path, "reg_balance_ipums.csv"))

# =======================================================
# Run Regressions
# =======================================================

# Housing Production Regressions
source("run_housing_production.R")

# Price Regressions
source("run_price_and_rent.R")

# Demographic Regressions
source("run_demo.R")

# run with other MLA estimates (run for index 1 to 3)
mla_vars = c("mla_est_all","mla_est_post40","mla_est_post70")
job_i = commandArgs(trailingOnly=T) %>% as.integer
mla_i = mla_vars[[job_i]]
source("run_other_mla.R")

# run within school district borders
source("run_within_sd.R")

# run using borders after 1940
source("run_no_ipums.R")

# Robustness: distance to border
source("run_by_dist.R")

# Appendix binscatter plots
source("run_binscatter.R")

# visualization (robustness all) -----------------------------------------------

result_dt = rbindlist(list(fread(paste0(output_path, "reg_by_mla.csv")),
                           fread(paste0(output_path, "reg_NoIPUMS.csv"))[,`:=`(rob="New Borders")],
                           fread(paste0(output_path, "reg_withinSD.csv"))[,`:=`(rob="Within SD")]),
                      fill=T)

result_dt[!is.na(x_var), rob := paste0("MLS (",str_sub(x_var,9,-1),")")]
result_dt[y_var=="LOG_PRICE", reg_spec := ifelse(data=="deed", "price", "rent")]
result_dt[y_var=="i_white", reg_spec := "1(white)"]
result_dt[str_detect(y_var,"clean"), reg_spec := "log income"]
result_dt[, reg_spec:=factor(reg_spec, c("price","rent","1(white)","log income"))]

result_dt[, `:=`(coef_low=coef-1.96*se,coef_high=coef+1.96*se)]
result_dt[str_sub(spec,1,1)==1, spec_name:="Full controls"]
result_dt[str_sub(spec,1,1)==2, spec_name:="Full controls + muni x SD FEs"]
result_dt[str_sub(spec,2,2)==1, spec_grp:="No"]
result_dt[str_sub(spec,2,2)==2, spec_grp:="Yes"]

result_dt[rob=="MLS (post40)", rob:="Baseline"]
setorder(result_dt, rob)

ggplot(result_dt[spec%in%c(11,21)|reg_spec%in%c("price","rent")],
       aes(x=reg_spec,y=coef,color=rob,ymin=coef_low,ymax=coef_high,group=spec_grp,linetype=spec_grp))+
  geom_hline(yintercept=0, linetype="dashed")+
  geom_point(size = 3, position=position_dodge2(0.8))+
  geom_linerange(size = 1, position=position_dodge2(0.8))+
  scale_color_viridis_d()+
  facet_wrap(~spec_name)+
  scale_x_discrete(guide = guide_axis(angle = 30)) +
  guides(color = guide_legend(nrow = 1))+
  labs(x="Outcome", y="Estimate and 95% CI",
       color = "Robustness",
       linetype = "Building char's controlled")+
  theme(legend.box="vertical")
ggsave(paste0(output_path,"reg_robustness.pdf"),
       dpi = "print", width = 12, height = 6.5)

# visualization (distance) ---------------------------------------------------

result_dt = fread(paste0(output_path, "reg_by_dist.csv"))
result_dt[, rob := as.numeric(bord)/10]
result_dt[, rob := paste0("(",rob-0.1,",",rob,"]")]

result_dt[var=="LOG_PRICE", reg_spec := ifelse(data=="deed", "price", "rent")]
result_dt[var=="i_white", reg_spec := "1(white)"]
result_dt[str_detect(var,"clean"), reg_spec := "log income"]
result_dt[, reg_spec:=factor(reg_spec, c("price","rent","1(white)","log income"))]

result_dt[, `:=`(coef_low=coef-1.96*se,coef_high=coef+1.96*se)]
result_dt[str_sub(spec,1,1)==1, spec_name:="Full controls"]
result_dt[str_sub(spec,1,1)==2, spec_name:="Full controls + muni x SD FEs"]
result_dt[str_sub(spec,2,2)==1, spec_grp:="No"]
result_dt[str_sub(spec,2,2)==2, spec_grp:="Yes"]

ggplot(result_dt[spec%in%c(11,21)|reg_spec%in%c("price","rent")],
       aes(x=reg_spec,y=coef,color=rob,ymin=coef_low,ymax=coef_high,group=spec_grp,linetype=spec_grp))+
  geom_hline(yintercept=0, linetype="dashed")+
  geom_point(size = 3, position=position_dodge2(0.8))+
  geom_linerange(size = 1, position=position_dodge2(0.8))+
  scale_color_viridis_d()+
  facet_wrap(~spec_name)+
  scale_x_discrete(guide = guide_axis(angle = 30)) +
  guides()+
  labs(x="Outcome", y="Estimate and 95% CI",
       color = "Border distance (km)",
       linetype = "Building char's controlled")+
  theme(legend.box="vertical")
ggsave(paste0(output_path,"reg_by_dist.pdf"),
       dpi = "print", width = 12, height = 7)

# visualization (binscatter) ---------------------------------------------------

result_dt = fread(paste0(output_path, "reg_bins.csv"))
result_dt[, `:=`(spec_name = ifelse(str_detect(spec,"1$"),"No","Yes"))]

ggplot(result_dt[spec%in%c("sales11","sales12")], 
       aes(x=exp(mean_x), y=exp(y_coeff_scale)/1000, color=spec_name, shape=spec_name))+
  geom_point(size=2)+
  scale_x_continuous(trans="log", breaks = c(5000, 10000, 20000, 40000))+
  scale_y_continuous(trans="log")+
  scale_color_viridis_d()+
  labs(x = "min lot size (in SF)", y="price ($1000s)", 
       color="Building char's controlled", shape="Building char's controlled")
ggsave(paste0(output_path, "bins_price.pdf"), dpi = "print", width = 6, height = 5)

ggplot(result_dt[spec%in%c("rent11","rent12")], 
       aes(x=exp(mean_x), y=exp(y_coeff_scale), color=spec_name, shape=spec_name))+
  geom_point(size=2)+
  scale_x_continuous(trans="log", breaks = c(5000, 10000, 20000, 40000))+
  scale_color_viridis_d()+
  scale_y_continuous(trans="log")+
  labs(x = "min lot size (in SF)", y="monthly rent ($)", 
       color="Building char's controlled", shape="Building char's controlled")
ggsave(paste0(output_path, "bins_rent.pdf"), dpi = "print", width = 6, height = 5)

ggplot(result_dt[spec=="white11"], aes(x=exp(mean_x), y=y_coeff_scale, color=spec_name))+
  geom_point(size=2)+
  scale_x_continuous(trans="log", breaks = c(5000, 10000, 20000, 40000))+
  scale_color_viridis_d()+
  theme(legend.position = "none")+
  labs(x = "min lot size (in SF)", y="1(white)", color=element_blank())
ggsave(paste0(output_path, "bins_race.pdf"), dpi = "print", width = 6, height = 4)

ggplot(result_dt[spec=="log_income11"], aes(x=exp(mean_x), y=y_coeff_scale2, color=spec_name))+
  geom_point(size=2)+
  scale_x_continuous(trans="log", breaks = c(5000, 10000, 20000, 40000))+
  scale_color_viridis_d()+
  theme(legend.position = "none")+
  scale_y_continuous(trans="log")+
  labs(x = "min lot size (in SF)", y="income ($1000s)")
ggsave(paste0(output_path, "bins_income.pdf"), dpi = "print", width = 6, height = 4)
