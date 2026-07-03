# within SD borders ------------------------------------------------------------
# clean border char's
border_chars <- fread(paste0(int_path, "border_seg_parcels/border_chars.csv"), colClasses="character")
border_chars[nchar(fips)==4, fips:=paste0(0,fips)]
border_chars[, id_bord:=paste0(fips,"_",grp_border)]

bordseg_chars <- fread(paste0(int_path, "border_seg_parcels/bordseg_chars.csv"), colClasses="character")[grp_bordseg!=""]
bordseg_chars[nchar(fips)==4, fips:=paste0(0,fips)]
bordseg_chars[, type_bordseg:=str_sub(grp_bordseg,1,-3)]
bordseg_chars[, id_bord:=paste0(fips,"_",grp_bordseg)]

bord_sd = rbindlist(list(border_chars[N_sd==1, .(fips=as.integer(fips), id_bord)],
                         bordseg_chars[N_sd==1, .(fips=as.integer(fips), id_bord)]),
                    use.names=F)

deed_dt = merge(deed_dt, bord_sd[,.(id_bord)], by=c("id_bord"))
hmda_dt = merge(hmda_dt, bord_sd[,.(id_bord)], by=c("id_bord"))
mls_dt = merge(mls_dt, bord_sd[,.(id_bord)], by=c("id_bord"))

sink(paste0(result_path, "robust_sample_size.txt"))
print(paste0("Within SD ------------------------"))
print(paste0("sales"))
print(deed_dt[,.N])
print(paste0("rental"))
print(mls_dt[,.N])
print(paste0("demo"))
print(hmda_dt[,.N])
sink()

result_path = paste0(result_path, "reg_withinSD.csv")
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
fwrite(reg_temp, result_path, append=T)
reg_temp = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "mls",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, result_path, append=T)

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
fwrite(reg_temp, result_path, append=T)
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
fwrite(reg_temp, result_path, append=T)

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
fwrite(reg_temp, result_path, append=T)
reg_temp = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "mls",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, result_path, append=T)

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
fwrite(reg_temp, result_path, append=T)
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
fwrite(reg_temp, result_path, append=T)

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
fwrite(reg_temp, result_path, append=T)
reg_temp = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "mls",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, result_path, append=T)

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
fwrite(reg_temp, result_path, append=T)
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
fwrite(reg_temp, result_path, append=T)

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
fwrite(reg_temp, result_path, append=T)
reg_temp = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))
reg_temp = data.table(y_var = out_i,
                      data = "mls",
                      spec = spec_index,
                      coef = coefficients(reg_temp)[[x_i]],
                      se = se(reg_temp)[[x_i]])
fwrite(reg_temp, result_path, append=T)

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
fwrite(reg_temp, result_path, append=T)
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
fwrite(reg_temp, result_path, append=T)