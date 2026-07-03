# No IPUMS both side -----------------------------------------------------------

bord_dt = deed_dt[IPUMS_NA==1, .(N_NA=uniqueN(AFFGEOID)), by=id_bord]
deed_dt = deed_dt[id_bord%in%bord_dt[N_NA==2,id_bord]]
bord_dt = hmda_dt[IPUMS_NA==1, .(N_NA=uniqueN(AFFGEOID)), by=id_bord]
hmda_dt = hmda_dt[id_bord%in%bord_dt[N_NA==2,id_bord]]
bord_dt = mls_dt[IPUMS_NA==1, .(N_NA=uniqueN(AFFGEOID)), by=id_bord]
mls_dt = mls_dt[id_bord%in%bord_dt[N_NA==2,id_bord]]

sink(paste0(result_path, "robust_sample_size.txt"))
print(paste0("No IPUMS ------------------------"))
print(paste0("sales"))
print(deed_dt[,.N])
print(paste0("rental"))
print(mls_dt[,.N])
print(paste0("demo"))
print(hmda_dt[,.N])
sink()

x_i = "LOG_MLA"
fe_i1 = c("id_bord","fips_yr")

# run regression
spec_index = 11
out_i = "LOG_PRICE"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste(c(fe_i1), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=deed_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "deed",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_NoIPUMS.csv"), append=T)
reg_temp = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "mls",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_NoIPUMS.csv"), append=T)

out_i = "i_white"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste(c(fe_i1), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "hmda",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_NoIPUMS.csv"), append=T)
out_i = "LOG_inc_clean"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste(c(fe_i1), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "hmda",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_NoIPUMS.csv"), append=T)

# including bldg chars
spec_index = 12
out_i = "LOG_PRICE"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0,cov_bldg), collapse="+"),
                       "|", paste(c(fe_i1), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=deed_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "deed",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_NoIPUMS.csv"), append=T)
reg_temp = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "mls",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_NoIPUMS.csv"), append=T)

out_i = "i_white"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0,cov_bldg), collapse="+"),
                       "|", paste(c(fe_i1), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "hmda",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_NoIPUMS.csv"), append=T)
out_i = "LOG_inc_clean"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0,cov_bldg), collapse="+"),
                       "|", paste(c(fe_i1), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "hmda",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_NoIPUMS.csv"), append=T)

# with muni*SD FE included
spec_index = 21
out_i = "LOG_PRICE"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=deed_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "deed",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_NoIPUMS.csv"), append=T)
reg_temp = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "mls",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_NoIPUMS.csv"), append=T)

out_i = "i_white"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "hmda",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_NoIPUMS.csv"), append=T)
out_i = "LOG_inc_clean"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "hmda",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_NoIPUMS.csv"), append=T)

# with muni*SD FE included + bldg chars
spec_index = 22
out_i = "LOG_PRICE"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0,cov_bldg), collapse="+"),
                       "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=deed_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "deed",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_NoIPUMS.csv"), append=T)
reg_temp = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "mls",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_NoIPUMS.csv"), append=T)

out_i = "i_white"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0,cov_bldg), collapse="+"),
                       "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "hmda",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_NoIPUMS.csv"), append=T)
out_i = "LOG_inc_clean"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0,cov_bldg), collapse="+"),
                       "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "hmda",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_NoIPUMS.csv"), append=T)
