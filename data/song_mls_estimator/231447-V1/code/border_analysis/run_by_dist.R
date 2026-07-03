
# regressions by distance -------------------------------------
bord_vec = c(paste0("0",1:9),"10")
x_i = "LOG_MLA"
fe_i1 = c("id_bord","fips_yr")
cov_neigh = setdiff(cov_neigh0, "dist2bord")

for(bord_i in bord_vec){
  
  deed_i = fread(paste0(sample_path, "deed_", bord_i,".csv"))
  hmda_i = fread(paste0(sample_path, "hmda_", bord_i,".csv"))
  mls_i = fread(paste0(sample_path, "mls_", bord_i,".csv"))
  
  print(paste0("Working on: ", bord_i))
  
  out_i = "LOG_PRICE"
  formula_temp <- paste0(out_i, "~", x_i, "+",
                         paste(c(cov_neigh), collapse="+"),
                         "|", paste(c(fe_i1), collapse="+"))
  reg_temp = feols(as.formula(formula_temp), data=deed_i, cluster = c("AFFGEOID"))
  reg_temp = data.table(bord = bord_i,
                        var = out_i,
                        data = "deed",
                        spec = 11,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_by_dist.csv"), append=T)
  reg_temp = feols(as.formula(formula_temp), data=mls_i, cluster = c("AFFGEOID"))
  reg_temp = data.table(bord = bord_i,
                        var = out_i,
                        data = "mls",
                        spec = 11,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_by_dist.csv"), append=T)
  
  out_i = "i_white"
  formula_temp <- paste0(out_i, "~", x_i, "+",
                         paste(c(cov_neigh), collapse="+"),
                         "|", paste(c(fe_i1), collapse="+"))
  reg_temp = feols(as.formula(formula_temp), data=hmda_i, cluster = c("AFFGEOID"))
  reg_temp = data.table(bord = bord_i,
                        var = out_i,
                        data = "hmda",
                        spec = 11,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_by_dist.csv"), append=T)
  out_i = "LOG_inc_clean"
  formula_temp <- paste0(out_i, "~", x_i, "+",
                         paste(c(cov_neigh), collapse="+"),
                         "|", paste(c(fe_i1), collapse="+"))
  reg_temp = feols(as.formula(formula_temp), data=hmda_i, cluster = c("AFFGEOID"))
  reg_temp = data.table(bord = bord_i,
                        var = out_i,
                        data = "hmda",
                        spec = 11,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_by_dist.csv"), append=T)
  
  # with FE and building control included ------------------------------------
  out_i = "LOG_PRICE"
  formula_temp <- paste0(out_i, "~", x_i, "+",
                         paste(c(cov_neigh,cov_bldg), collapse="+"),
                         "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
  reg_temp = feols(as.formula(formula_temp), data=deed_i, cluster = c("AFFGEOID"))
  reg_temp = data.table(bord = bord_i,
                        var = out_i,
                        data = "deed",
                        spec = 12,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_by_dist.csv"), append=T)
  reg_temp = feols(as.formula(formula_temp), data=mls_i, cluster = c("AFFGEOID"))
  reg_temp = data.table(bord = bord_i,
                        var = out_i,
                        data = "mls",
                        spec = 12,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_by_dist.csv"), append=T)
  
  out_i = "i_white"
  formula_temp <- paste0(out_i, "~", x_i, "+",
                         paste(c(cov_neigh,cov_bldg), collapse="+"),
                         "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
  reg_temp = feols(as.formula(formula_temp), data=hmda_i, cluster = c("AFFGEOID"))
  reg_temp = data.table(bord = bord_i,
                        var = out_i,
                        data = "hmda",
                        spec = 12,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_by_dist.csv"), append=T)
  out_i = "LOG_inc_clean"
  formula_temp <- paste0(out_i, "~", x_i, "+",
                         paste(c(cov_neigh,cov_bldg), collapse="+"),
                         "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
  reg_temp = feols(as.formula(formula_temp), data=hmda_i, cluster = c("AFFGEOID"))
  reg_temp = data.table(bord = bord_i,
                        var = out_i,
                        data = "hmda",
                        spec = 12,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_by_dist.csv"), append=T)
  
  # with muni*SD FE included ------------------------------------
  out_i = "LOG_PRICE"
  formula_temp <- paste0(out_i, "~", x_i, "+",
                         paste(c(cov_neigh), collapse="+"),
                         "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
  reg_temp = feols(as.formula(formula_temp), data=deed_i, cluster = c("AFFGEOID"))
  reg_temp = data.table(bord = bord_i,
                        var = out_i,
                        data = "deed",
                        spec = 21,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_by_dist.csv"), append=T)
  reg_temp = feols(as.formula(formula_temp), data=mls_i, cluster = c("AFFGEOID"))
  reg_temp = data.table(bord = bord_i,
                        var = out_i,
                        data = "mls",
                        spec = 21,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_by_dist.csv"), append=T)
  
  out_i = "i_white"
  formula_temp <- paste0(out_i, "~", x_i, "+",
                         paste(c(cov_neigh), collapse="+"),
                         "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
  reg_temp = feols(as.formula(formula_temp), data=hmda_i, cluster = c("AFFGEOID"))
  reg_temp = data.table(bord = bord_i,
                        var = out_i,
                        data = "hmda",
                        spec = 21,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_by_dist.csv"), append=T)
  out_i = "LOG_inc_clean"
  formula_temp <- paste0(out_i, "~", x_i, "+",
                         paste(c(cov_neigh), collapse="+"),
                         "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
  reg_temp = feols(as.formula(formula_temp), data=hmda_i, cluster = c("AFFGEOID"))
  reg_temp = data.table(bord = bord_i,
                        var = out_i,
                        data = "hmda",
                        spec = 21,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_by_dist.csv"), append=T)
  
  # with muni*SD FE and building control included ------------------------------------
  out_i = "LOG_PRICE"
  formula_temp <- paste0(out_i, "~", x_i, "+",
                         paste(c(cov_neigh,cov_bldg), collapse="+"),
                         "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
  reg_temp = feols(as.formula(formula_temp), data=deed_i, cluster = c("AFFGEOID"))
  reg_temp = data.table(bord = bord_i,
                        var = out_i,
                        data = "deed",
                        spec = 22,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_by_dist.csv"), append=T)
  reg_temp = feols(as.formula(formula_temp), data=mls_i, cluster = c("AFFGEOID"))
  reg_temp = data.table(bord = bord_i,
                        var = out_i,
                        data = "mls",
                        spec = 22,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_by_dist.csv"), append=T)
  
  out_i = "i_white"
  formula_temp <- paste0(out_i, "~", x_i, "+",
                         paste(c(cov_neigh,cov_bldg), collapse="+"),
                         "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
  reg_temp = feols(as.formula(formula_temp), data=hmda_i, cluster = c("AFFGEOID"))
  reg_temp = data.table(bord = bord_i,
                        var = out_i,
                        data = "hmda",
                        spec = 22,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_by_dist.csv"), append=T)
  out_i = "LOG_inc_clean"
  formula_temp <- paste0(out_i, "~", x_i, "+",
                         paste(c(cov_neigh,cov_bldg), collapse="+"),
                         "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
  reg_temp = feols(as.formula(formula_temp), data=hmda_i, cluster = c("AFFGEOID"))
  reg_temp = data.table(bord = bord_i,
                        var = out_i,
                        data = "hmda",
                        spec = 22,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_by_dist.csv"), append=T)
}

