# Alternative MLS estimates ----------------------------------------------------

print(paste0("Run with ", mla_i))

deed_dt[, MLA_i:=get(mla_i)]
deed_dt[, LOG_MLA_i:=log(MLA_i)]

hmda_dt[, MLA_i:=get(mla_i)]
hmda_dt[, LOG_MLA_i:=log(MLA_i)]

mls_dt[, MLA_i:=get(mla_i)]
mls_dt[, LOG_MLA_i:=log(MLA_i)]

x_i = "LOG_MLA_i"
fe_i1 = c("id_bord","fips_yr")

# run baseline regression
spec_index = 11
out_i = "LOG_PRICE"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste(c(fe_i1), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=deed_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      x_var = mla_i,
                      data = "deed",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_by_mla.csv"), append=T)
reg_temp = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      x_var = mla_i,
                      data = "mls",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_by_mla.csv"), append=T)

out_i = "i_white"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste(c(fe_i1), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      x_var = mla_i,
                      data = "hmda",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_by_mla.csv"), append=T)
out_i = "LOG_inc_clean"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste(c(fe_i1), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      x_var = mla_i,
                      data = "hmda",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_by_mla.csv"), append=T)

# with building chars
spec_index = 12
out_i = "LOG_PRICE"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0,cov_bldg), collapse="+"),
                       "|", paste(c(fe_i1), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=deed_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      x_var = mla_i,
                      data = "deed",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_by_mla.csv"), append=T)
reg_temp = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      x_var = mla_i,
                      data = "mls",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_by_mla.csv"), append=T)

out_i = "i_white"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0,cov_bldg), collapse="+"),
                       "|", paste(c(fe_i1), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      x_var = mla_i,
                      data = "hmda",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_by_mla.csv"), append=T)
out_i = "LOG_inc_clean"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0,cov_bldg), collapse="+"),
                       "|", paste(c(fe_i1), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      x_var = mla_i,
                      data = "hmda",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_by_mla.csv"), append=T)

# with muni*SD FE included
spec_index = 21
out_i = "LOG_PRICE"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=deed_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      x_var = mla_i,
                      data = "deed",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_by_mla.csv"), append=T)
reg_temp = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      x_var = mla_i,
                      data = "mls",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_by_mla.csv"), append=T)

out_i = "i_white"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      x_var = mla_i,
                      data = "hmda",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_by_mla.csv"), append=T)
out_i = "LOG_inc_clean"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      x_var = mla_i,
                      data = "hmda",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_by_mla.csv"), append=T)

# with muni*SD FE included & building chars included
spec_index = 22
out_i = "LOG_PRICE"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0,cov_bldg), collapse="+"),
                       "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=deed_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      x_var = mla_i,
                      data = "deed",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_by_mla.csv"), append=T)
reg_temp = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      x_var = mla_i,
                      data = "mls",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_by_mla.csv"), append=T)

out_i = "i_white"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0,cov_bldg), collapse="+"),
                       "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      x_var = mla_i,
                      data = "hmda",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_by_mla.csv"), append=T)
out_i = "LOG_inc_clean"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0,cov_bldg), collapse="+"),
                       "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
reg_temp = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      x_var = mla_i,
                      data = "hmda",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, paste0(result_path, "reg_by_mla.csv"), append=T)
