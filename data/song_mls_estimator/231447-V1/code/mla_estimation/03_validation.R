# ==============================================================================
# Validation statistics
# ==============================================================================

# compiled validation data using the following two sources.
# 1. MAPC Zoning Atlas - https://zoningatlas.mapc.org/
# 2. manually collected zoning data
dt = fread(paste0(data_path, "validation_set.csv"))
dt[, group:=ifelse(region=="mapc","Northeast",region)]

# Validation figures -----------------------------------------------------------

to_plot = rbindlist(list(dt[,.(group,mla_act,mla_est=mla_est_post40,n_sample=sample_post40,period="Since 1940",n_all=sample_apn)],
                         dt[,.(group,mla_act,mla_est=mla_est_post70,n_sample=sample_post70,period="Since 1970",n_all=sample_apn)],
                         dt[,.(group,mla_act,mla_est=mla_est_post00,n_sample=sample_post00,period="Since 2000",n_all=sample_apn)],
                         dt[,.(group,mla_act,mla_est=mla_est_all,n_sample=sample_apn,period="All SFR",n_all=sample_apn)]))

ggplot(to_plot, aes(x=mla_act, y=mla_est, size=n_sample, color=group))+
  geom_abline(slope=1, intercept = 0, color="black", linetype="dashed")+
  facet_wrap(~period)+
  geom_point(alpha=0.75)+
  scale_size(range=c(1,15))+
  scale_color_viridis_d()+
  scale_x_continuous(trans="log", breaks=c(43560/8,43560/2,2*43560), limits = c(1000,220000)) + 
  scale_y_continuous(trans="log", breaks=c(43560/8,43560/2,2*43560), limits = c(1000,220000)) +
  labs(x = "Actual min lot size (in SF)", y = "Estimated min lot size (in SF)",
       size = "# SFR built during the period", color= "Region")+
  theme(legend.box="vertical")+
  guides(color = guide_legend(override.aes = list(size=5)))
ggsave(paste0(output_path, "validation_by_period.pdf"),
       dpi = "print", width= 14, height = 12)

# # Instead, produce separate figures
# ggplot(dt, aes(x=mla_act, y=mla_est_post40, size=sample_post40, color=group))+
#   geom_abline(slope=1, intercept = 0, color="black", linetype="dashed")+
#   geom_point(alpha=0.75)+
#   scale_size(range=c(1,15))+
#   scale_color_viridis_d()+
#   scale_x_continuous(trans="log", breaks=c(43560/16,43560/8,43560/4,43560/2,43560,2*43560,4*43560), limits = c(1000,220000)) + 
#   scale_y_continuous(trans="log", breaks=c(43560/16,43560/8,43560/4,43560/2,43560,2*43560,4*43560), limits = c(1000,220000)) +
#   labs(x = "Actual min lot size (in SF)", y = "Estimated min lot size (in SF)",
#        size = "# SFR built after 1940") +
#   guides(color="none")
# ggsave(paste0(output_path, "validation_post40.pdf"),
#        dpi = "print", width= 10, height = 10)
# 
# ggplot(dt, aes(x=mla_act, y=mla_est_post70, size=sample_post70, color=group))+
#   geom_abline(slope=1, intercept = 0, color="black", linetype="dashed")+
#   geom_point(alpha=0.75)+
#   scale_size(range=c(1,15))+
#   scale_color_viridis_d()+
#   scale_x_continuous(trans="log", breaks=c(43560/16,43560/8,43560/4,43560/2,43560,2*43560,4*43560), limits = c(1000,220000)) + 
#   scale_y_continuous(trans="log", breaks=c(43560/16,43560/8,43560/4,43560/2,43560,2*43560,4*43560), limits = c(1000,220000)) +
#   labs(x = "Actual min lot size (in SF)", y = "Estimated min lot size (in SF)",
#        size = "# SFR built after 1970") +
#   guides(color="none")
# ggsave(paste0(output_path, "validation_post70.pdf"),
#        dpi = "print", width= 10, height = 10)
# 
# ggplot(dt, aes(x=mla_act, y=mla_est_post00, size=sample_post00, color=group))+
#   geom_abline(slope=1, intercept = 0, color="black", linetype="dashed")+
#   geom_point(alpha=0.75)+
#   scale_size(range=c(1,15))+
#   scale_color_viridis_d()+
#   scale_x_continuous(trans="log", breaks=c(43560/16,43560/8,43560/4,43560/2,43560,2*43560,4*43560), limits = c(1000,220000)) + 
#   scale_y_continuous(trans="log", breaks=c(43560/16,43560/8,43560/4,43560/2,43560,2*43560,4*43560), limits = c(1000,220000)) +
#   labs(x = "Actual min lot size (in SF)", y = "Estimated min lot size (in SF)",
#        size = "# SFR built after 2000") +
#   guides(color="none")
# ggsave(paste0(output_path, "validation_post00.pdf"),
#        dpi = "print", width= 10, height = 10)
# 
# ggplot(dt, aes(x=mla_act, y=mla_est_all, size=sample_apn, color=group))+
#   geom_abline(slope=1, intercept = 0, color="black", linetype="dashed")+
#   geom_point(alpha=0.75)+
#   scale_size(range=c(1,15))+
#   scale_color_viridis_d()+
#   scale_x_continuous(trans="log", breaks=c(43560/16,43560/8,43560/4,43560/2,43560,2*43560,4*43560), limits = c(1000,220000)) + 
#   scale_y_continuous(trans="log", breaks=c(43560/16,43560/8,43560/4,43560/2,43560,2*43560,4*43560), limits = c(1000,220000)) +
#   labs(x = "Actual min lot size (in SF)", y = "Estimated min lot size (in SF)",
#        size = "# SFR built after 2000") +
#   guides(color="none")
# ggsave(paste0(output_path, "validation_postNA.pdf"),
#        dpi = "print", width= 10, height = 10)

# Validation statistics --------------------------------------------------------

to_plot[, `:=`(p_error = (mla_act-mla_est)/mla_act)]
to_plot[, p_abs_error:=abs(p_error)]
to_plot[, weight:=n_all/sum(n_all), by=period]
to_plot[, cum_weight:=cumsum(weight), by=period]
setorder(to_plot, p_abs_error)

to_plot[, .(n_district=.SD[!is.na(mla_est),.N],
            cor1=cor(mla_act,mla_est, use="complete.obs"),
            cor2=cor(log(mla_act),log(mla_est), use="complete.obs"),
            e1=quantile(p_abs_error*100, 0.1, na.rm=T),
            e2=quantile(p_abs_error*100, 0.2, na.rm=T),
            e3=quantile(p_abs_error*100, 0.3, na.rm=T),
            e4=quantile(p_abs_error*100, 0.4, na.rm=T),
            e5=quantile(p_abs_error*100, 0.5, na.rm=T),
            e6=quantile(p_abs_error*100, 0.6, na.rm=T),
            e7=quantile(p_abs_error*100, 0.7, na.rm=T),
            e8=quantile(p_abs_error*100, 0.8, na.rm=T),
            e9=quantile(p_abs_error*100, 0.9, na.rm=T)), by=period][order(period)]

# > dt[is.na(mla_est_post00), median(mla_act)]
# [1] 15000
# > dt[!is.na(mla_est_post00), median(mla_act)]
# [1] 10000
# > dt[is.na(mla_est_post00), mean(mla_act)]
# [1] 29846
# > dt[!is.na(mla_est_post00), mean(mla_act)]
