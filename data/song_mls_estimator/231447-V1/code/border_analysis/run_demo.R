
# baseline demographic regressions ---------------------------------------------

sink(paste0(result_path, "tex_demo.txt"))
print(paste0("Run baseline demographic regressions"))

x_i = "LOG_MLA"
fe_i1 = c("id_bord","fips_yr")

out_i = "i_white"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste("fips_yr", collapse="+"))
reg_race0 = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste(fe_i1, collapse="+"))
reg_race1 = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0,cov_bldg), collapse="+"),
                       "|", paste(fe_i1, collapse="+"))
reg_race2 = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))

out_i = "LOG_inc_clean"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste("fips_yr", collapse="+"))
reg_inc0 = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste(fe_i1, collapse="+"))
reg_inc1 = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0,cov_bldg), collapse="+"),
                       "|", paste(fe_i1, collapse="+"))
reg_inc2 = feols(as.formula(formula_temp), data=hmda_dt, cluster = c("AFFGEOID"))

print(etable(reg_race0, reg_race1, reg_race2,
             reg_inc0, reg_inc1, reg_inc2, tex=T))

print(paste0("Racial sorting by income decile"))

# racial sorting by income decile
inc_bins = hmda_dt[!is.na(LOG_inc_clean), quantile(LOG_inc_clean, seq(0,1,0.2), na.rm=T)]
hmda_dt[, inc_quartile:=ifelse(LOG_inc_clean<=inc_bins[[2]],"q1",
                               ifelse(LOG_inc_clean<=inc_bins[[3]],"q2",
                                      ifelse(LOG_inc_clean<=inc_bins[[4]],"q3",
                                             ifelse(LOG_inc_clean<=inc_bins[[5]],"q4","q5"))))]
out_i = "i_white"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste(fe_i1, collapse="+"))
reg_by_inc = list()
for(bin_i in paste0("q",1:5)){
  reg_by_inc[[bin_i]] <- feols(as.formula(formula_temp), data=hmda_dt[inc_quartile==bin_i], cluster = c("AFFGEOID"))
}
print(etable(reg_by_inc, tex=T))

print(paste0("Income sorting by race"))
out_i = "LOG_inc_clean"
formula_temp <- paste0(out_i, "~", x_i, "+",
                       paste(c(cov_neigh0), collapse="+"),
                       "|", paste(c(fe_i1), collapse="+"))
reg_by_race = list()
for(race_i in hmda_dt[,unique(race_ethnicity)]){
  reg_by_race[[race_i]] <- feols(as.formula(formula_temp),
                                 data=hmda_dt[race_ethnicity==race_i], cluster = c("AFFGEOID"))
}

print(etable(reg_by_race, tex=T))

print("Counts:")
print(hmda_dt[,.N,inc_quartile][order(inc_quartile)])
print(hmda_dt[,.N,race_ethnicity][order(race_ethnicity)])

sink()
