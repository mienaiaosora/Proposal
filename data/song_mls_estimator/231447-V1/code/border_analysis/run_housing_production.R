for(var_bldg in cov_bldg){
  
  print(paste0("Working on: ", var_bldg))
  
  formula_temp = paste0(var_bldg, "~", x_i, "+",
                         paste(c(cov_neigh0), collapse="+"),
                         "|", paste(c(fe_i1), collapse="+"))
  reg_temp = feols(as.formula(formula_temp), data=deed_dt, cluster = c("AFFGEOID"))
  reg_temp = data.table(var = var_bldg,
                        data = "sales",
                        spec = 1,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_bldg_chars.csv"), append=T)
  reg_temp = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))
  reg_temp = data.table(var = var_bldg,
                        data = "rental",
                        spec = 1,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_bldg_chars.csv"), append=T)
  
  formula_temp = paste0(var_bldg, "~", x_i, "+",
                         paste(c(cov_neigh0), collapse="+"),
                         "|", paste(c(fe_i1,"MUNI_SDLEA"), collapse="+"))
  reg_temp = feols(as.formula(formula_temp), data=deed_dt, cluster = c("AFFGEOID"))
  reg_temp = data.table(var = var_bldg,
                        data = "sales",
                        spec = 2,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_bldg_chars.csv"), append=T)
  reg_temp = feols(as.formula(formula_temp), data=mls_dt, cluster = c("AFFGEOID"))
  reg_temp = data.table(var = var_bldg,
                        data = "rental",
                        spec = 2,
                        coef = coefficients(reg_temp)[["LOG_MLA"]],
                        se = se(reg_temp)[["LOG_MLA"]])
  fwrite(reg_temp, paste0(result_path, "reg_bldg_chars.csv"), append=T)
}

# Figure with the coefficients
reg_bldg = fread(paste0(result_path, "reg_bldg_chars.csv"))
reg_bldg = reg_bldg[spec==1]
reg_bldg[, spec_name:="Coefficient estimates of log MLS"]
reg_bldg[str_detect(var, "eff"), `:=`(coef=coef/10,se=se/10)]
reg_bldg[, `:=`(coef_low=coef-1.96*se,
                coef_high=coef+1.96*se)]
reg_bldg[str_detect(var, "land"), var_name:="log lot size"]
reg_bldg[str_detect(var, "univ"), var_name:="log bldg sqft"]
reg_bldg[str_detect(var, "eff"), var_name:="eff. age (in 10s)"]
reg_bldg[str_detect(var, "bed"), var_name:="# bed"]
reg_bldg[str_detect(var, "bath"), var_name:="# bath"]
reg_bldg[, var_name:=factor(var_name, c("# bath","# bed","eff. age (in 10s)","log bldg sqft","log lot size"))]
reg_bldg[, `:=`(data=factor(data, c("sales","rental")))]

ggplot(reg_bldg, aes(x=coef, y=var_name, xmin=coef_low, xmax=coef_high, color=data))+
  geom_vline(xintercept=0, linetype="dashed")+
  geom_point(size = 4, position=position_dodge2(0.3))+
  geom_linerange(size = 1.25, position=position_dodge2(0.3))+
  # facet_wrap(~spec_name)+
  scale_color_viridis_d()+
  labs(y="Outcome", color="Data", x = "Estimate and 95% Confidence Interval")
ggsave(paste0(result_path, "fig_bldg_chars.pdf"), dpi = "print", width = 12, height = 8)

# housing production distortion by whether constrained under regulation
p_list = list(c(0,0.05),c(0,0.01),c(0,0.1),
              c(0.05,0.05),c(0.01,0.01),c(0.1,0.1))
for(p_vec in p_list){
  
  p_left = p_vec[1]
  p_right = p_vec[2]
  
  ##### sales
  deed_dt[, group_temp:=ifelse(land_sqft>=(1-p_left)*mla_est_post40&land_sqft<=(1+p_right)*mla_est_post40,"constrained",
                               ifelse(land_sqft<(1-p_left)*mla_est_post40, "smaller","larger"))]
  
  # by lot size group
  formula_temp = paste0("LOG_univ_bldg_sqft~LOG_land_sqft:group_temp",
                         "|", paste(c(fe_i1), collapse="+"))
  reg1_sales1 = feols(as.formula(formula_temp),
                     data=deed_dt, cluster = c("AFFGEOID"))
  
  formula_temp = paste0("LOG_univ_bldg_sqft~LOG_land_sqft:group_temp","+",
                         paste(c(cov_neigh0), collapse="+"),
                         "|", paste(c(fe_i1), collapse="+"))
  reg1_sales2 = feols(as.formula(formula_temp),
                     data=deed_dt, cluster = c("AFFGEOID"))
  
  formula_temp = paste0("LOG_univ_bldg_sqft~LOG_land_sqft:group_temp","+",
                         paste(c(cov_neigh0, "eff_age"), collapse="+"),
                         "|", paste(c(fe_i1), collapse="+"))
  reg1_sales3 = feols(as.formula(formula_temp),
                     data=deed_dt, cluster = c("AFFGEOID"))
  
  ##### rental
  mls_dt[, group_temp:=ifelse(land_sqft>=(1-p_left)*mla_est_post40&land_sqft<=(1+p_right)*mla_est_post40,"constrained",
                              ifelse(land_sqft<(1-p_left)*mla_est_post40, "smaller","larger"))]
  
  # by lot size group
  formula_temp = paste0("LOG_univ_bldg_sqft~LOG_land_sqft:group_temp",
                         "|", paste(c(fe_i1), collapse="+"))
  reg_rent1 = feols(as.formula(formula_temp),
                    data=mls_dt, cluster = c("AFFGEOID"))
  
  formula_temp = paste0("LOG_univ_bldg_sqft~LOG_land_sqft:group_temp","+",
                         paste(c(cov_neigh0), collapse="+"),
                         "|", paste(c(fe_i1), collapse="+"))
  reg_rent2 = feols(as.formula(formula_temp),
                    data=mls_dt, cluster = c("AFFGEOID"))
  
  formula_temp = paste0("LOG_univ_bldg_sqft~LOG_land_sqft:group_temp","+",
                         paste(c(cov_neigh0, "eff_age"), collapse="+"),
                         "|", paste(c(fe_i1), collapse="+"))
  reg_rent3 = feols(as.formula(formula_temp),
                    data=mls_dt, cluster = c("AFFGEOID"))
  
  sink(paste0(result_path, "table_sqft_on_lot_group.txt"), append=T)
  print(paste0("Threshold left: ", p_left,", ", "right: ", p_right))
  print(etable(reg_sales1,reg_sales2,reg_sales3,
               reg_rent1,reg_rent2,reg_rent3))
  sink()
}
deed_dt[, group_temp:=NULL]
mls_dt[, group_temp:=NULL]