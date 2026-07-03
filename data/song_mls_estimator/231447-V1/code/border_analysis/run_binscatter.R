
source("code/fn_binscatter.R")

deed_dt1 = deed_dt[!is.na(LOG_MLA)]
hmda_dt1 = hmda_dt[!is.na(LOG_MLA)]
mls_dt1 = mls_dt[!is.na(LOG_MLA)]

print(paste0("Run binscatter regressions --------------- "))
mla_bins = deed_dt1[, quantile(LOG_MLA, seq(0,1,0.05))] %>% unique

out_i = "LOG_PRICE"
x_i = "LOG_MLA"
fe_i1 = c("id_bord","fips_yr")
cov_bldg = c("LOG_land_sqft", "LOG_univ_bldg_sqft", "eff_age","bed_n", "calc_bath_n")

bins_temp = binscatter_feols(deed_dt1, y_var=out_i, x_var=x_i, x_cuts=mla_bins, include.lowest = F,
                             fe_vars = fe_i1, covs=cov_neigh0)
bins_temp[, spec:="sales11"]
fwrite(bins_temp, result_path, append=T)

bins_temp = binscatter_feols(deed_dt1, y_var=out_i, x_var=x_i, x_cuts=mla_bins, include.lowest = F,
                             fe_vars = fe_i1, covs=c(cov_neigh0,cov_bldg))
bins_temp[, spec:="sales12"]
fwrite(bins_temp, result_path, append=T)

bins_temp = binscatter_feols(deed_dt1, y_var=out_i, x_var=x_i, x_cuts=mla_bins, include.lowest = F,
                             fe_vars = c(fe_i1,"MUNI_SDLEA"), covs=cov_neigh0)
bins_temp[, spec:="sales21"]
fwrite(bins_temp, result_path, append=T)

bins_temp = binscatter_feols(deed_dt1, y_var=out_i, x_var=x_i, x_cuts=mla_bins, include.lowest = F,
                             fe_vars = c(fe_i1,"MUNI_SDLEA"), covs=c(cov_neigh0,cov_bldg))
bins_temp[, spec:="sales22"]
fwrite(bins_temp, result_path, append=T)

bins_temp = binscatter_feols(mls_dt1, y_var=out_i, x_var=x_i, x_cuts=mla_bins, include.lowest = F,
                             fe_vars = fe_i1, covs=cov_neigh0)
bins_temp[, spec:="rent11"]
fwrite(bins_temp, result_path, append=T)

bins_temp = binscatter_feols(mls_dt1, y_var=out_i, x_var=x_i, x_cuts=mla_bins, include.lowest = F,
                             fe_vars = fe_i1, covs=c(cov_neigh0,cov_bldg))
bins_temp[, spec:="rent12"]
fwrite(bins_temp, result_path, append=T)

bins_temp = binscatter_feols(mls_dt1, y_var=out_i, x_var=x_i, x_cuts=mla_bins, include.lowest = F,
                             fe_vars = c(fe_i1,"MUNI_SDLEA"), covs=cov_neigh0)
bins_temp[, spec:="rent21"]
fwrite(bins_temp, result_path, append=T)

bins_temp = binscatter_feols(mls_dt1, y_var=out_i, x_var=x_i, x_cuts=mla_bins, include.lowest = F,
                             fe_vars = c(fe_i1,"MUNI_SDLEA"), covs=c(cov_neigh0,cov_bldg))
bins_temp[, spec:="rent22"]
fwrite(bins_temp, result_path, append=T)

out_i = "i_white"
bins_temp = binscatter_feols(hmda_dt1, y_var=out_i, x_var=x_i, x_cuts=mla_bins, include.lowest = F,
                             fe_vars = fe_i1, covs=cov_neigh0)
bins_temp[, spec:="white11"]
fwrite(bins_temp, result_path, append=T)

bins_temp = binscatter_feols(hmda_dt1, y_var=out_i, x_var=x_i, x_cuts=mla_bins, include.lowest = F,
                             fe_vars = fe_i1, covs=c(cov_neigh0,cov_bldg))
bins_temp[, spec:="white12"]
fwrite(bins_temp, result_path, append=T)

bins_temp = binscatter_feols(hmda_dt1, y_var=out_i, x_var=x_i, x_cuts=mla_bins, include.lowest = F,
                             fe_vars = c(fe_i1,"MUNI_SDLEA"), covs=cov_neigh0)
bins_temp[, spec:="white21"]
fwrite(bins_temp, result_path, append=T)

bins_temp = binscatter_feols(hmda_dt1, y_var=out_i, x_var=x_i, x_cuts=mla_bins, include.lowest = F,
                             fe_vars = c(fe_i1,"MUNI_SDLEA"), covs=c(cov_neigh0,cov_bldg))
bins_temp[, spec:="white22"]
fwrite(bins_temp, result_path, append=T)

out_i = "LOG_inc_clean"
bins_temp = binscatter_feols(hmda_dt1, y_var=out_i, x_var=x_i, x_cuts=mla_bins, include.lowest = F,
                             fe_vars = fe_i1, covs=cov_neigh0)
bins_temp[, spec:="log_income11"]
fwrite(bins_temp, result_path, append=T)

bins_temp = binscatter_feols(hmda_dt1, y_var=out_i, x_var=x_i, x_cuts=mla_bins, include.lowest = F,
                             fe_vars = fe_i1, covs=c(cov_neigh0,cov_bldg))
bins_temp[, spec:="log_income12"]
fwrite(bins_temp, result_path, append=T)

bins_temp = binscatter_feols(hmda_dt1, y_var=out_i, x_var=x_i, x_cuts=mla_bins, include.lowest = F,
                             fe_vars = c(fe_i1,"MUNI_SDLEA"), covs=cov_neigh0)
bins_temp[, spec:="log_income21"]
fwrite(bins_temp, result_path, append=T)

bins_temp = binscatter_feols(hmda_dt1, y_var=out_i, x_var=x_i, x_cuts=mla_bins, include.lowest = F,
                             fe_vars = c(fe_i1,"MUNI_SDLEA"), covs=c(cov_neigh0,cov_bldg))
bins_temp[, spec:="log_income22"]
fwrite(bins_temp, result_path, append=T)

