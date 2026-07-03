
# baseline price regressions -------------------------------------------------

sink(paste0(result_path, "tex_price_and_rent.txt"))
print(paste0("Run baseline price and rent regressions"))

out_i = "LOG_PRICE"
x_i = "LOG_MLA"
fe_i1 = c("id_bord","fips_yr")

formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste("fips_yr", collapse="+"))
reg_deed0 = feols(as.formula(formula_temp), data=deed_dt, cluster = c("AFFGEOID"))
reg_mls0 = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))

formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste(fe_i1, collapse="+"))
reg_deed1 = feols(as.formula(formula_temp), data=deed_dt, cluster = c("AFFGEOID"))
reg_mls1 = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))

formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0,cov_bldg), collapse="+"),
                       "|", paste(fe_i1, collapse="+"))
reg_deed2 = feols(as.formula(formula_temp), data=deed_dt, cluster = c("AFFGEOID"))
reg_mls2 = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))

deed_dt[, `:=`(lot_group = ifelse(land_sqft>=mla_est_post40, "comply", "smaller"))]
mls_dt[, `:=`(lot_group = ifelse(land_sqft>=mla_est_post40, "comply", "smaller"))]
formula_temp <- paste0(out_i, "~", x_i, "+lot_group+", x_i, ":lot_group+",
                       paste(c(cov_neigh0,cov_bldg), collapse="+"),
                       "|", paste(fe_i1, collapse="+"))
reg_deed3 = feols(as.formula(formula_temp), data=deed_dt, cluster = c("AFFGEOID"))
reg_mls3 = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))
deed_dt[, lot_group:=NULL]
mls_dt[, lot_group:=NULL]

etable(reg_deed0, reg_deed1, reg_deed2, reg_deed3,
       reg_mls0, reg_mls1, reg_mls2, reg_mls3, tex=T)

sink()

# Appendix (only lot) -------------------------------------------------------

sink(paste0(result_path, "tex_only_lot.txt"))

out_i = "LOG_PRICE"
x_i = "LOG_MLA"
fe_i1 = c("id_bord","fips_yr")

formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0,"LOG_land_sqft"), collapse="+"),
                       "|", paste(fe_i1, collapse="+"))
reg_deed2 = feols(as.formula(formula_temp), data=deed_dt, cluster = c("AFFGEOID"))
reg_mls2 = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))

deed_dt[, `:=`(lot_group = ifelse(land_sqft>=mla_est_post40, "comply", "smaller"))]
mls_dt[, `:=`(lot_group = ifelse(land_sqft>=mla_est_post40, "comply", "smaller"))]
formula_temp <- paste0(out_i, "~", x_i, "+lot_group+", x_i, ":lot_group+",
                       paste(c(cov_neigh0,"LOG_land_sqft"), collapse="+"),
                       "|", paste(fe_i1, collapse="+"))
reg_deed3 = feols(as.formula(formula_temp), data=deed_dt, cluster = c("AFFGEOID"))
reg_mls3 = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))
deed_dt[, lot_group:=NULL]
mls_dt[, lot_group:=NULL]

etable(reg_deed2, reg_deed3,
       reg_mls2, reg_mls3, tex=T)

sink()
