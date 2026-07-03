binscatter_regs <- function(dt, aux_form="", y_var, covs=NULL, others=NULL, x_var, x_cuts, include.lowest = F){
  to_est <- dt[,.SD,.SDcols=c(y_var,x_var,covs,others)]
  setnames(to_est,c(y_var,x_var),c("y_var","x_var"))
  
  if(any(duplicated(x_cuts))){
    print("Bin cutoffs have duplicates -- take unique.")
    x_cuts <- unique(x_cuts)
  }
  
  to_est[,x_bin:=cut(as.numeric(x_var),breaks=x_cuts,labels=1:(length(x_cuts)-1),include.lowest=include.lowest)]
  to_est <- to_est[!is.na(x_bin)]
  
  # exclude any covs NA
  to_est <- to_est[!is.na(y_var)]
  if(is.null(c(covs,others))){
    for(var in c(covs,others)){
      to_est <- to_est[!is.na(get(var))]
    }
  }
  
  # first bin as reference
  to_est[,x_bin:=relevel(x_bin,ref=1)]
  
  # regression formula
  if(is.null(covs)){
    reg_form <- paste0("y_var~x_bin",aux_form)
  } else{
    reg_form <- paste0("y_var~x_bin+",paste0(covs,collapse="+"),aux_form)
  }
  reg <- felm(as.formula(reg_form),data=to_est)
  
  # to plot
  to_plot <- to_est[,.(mean_x=mean(x_var),n_x=.N),by=x_bin][order(x_bin)]
  to_plot[2:(length(x_cuts)-1),`:=`(y_coeff=reg$coefficients[str_detect(rownames(reg$coefficients),"x_bin")],
                                    y_se=summary(reg)[["coefficients"]][str_detect(rownames(summary(reg)[["coefficients"]]),"x_bin"),"Std. Error"],
                                    y_tval=summary(reg)[["coefficients"]][str_detect(rownames(summary(reg)[["coefficients"]]),"x_bin"),"t value"])]
  # scale up by bin 1 mean
  mean_y_bin1 <- to_est[x_bin==1,mean(y_var)]
  to_plot[1,y_coeff_scale:=mean_y_bin1]
  to_plot[2:(length(x_cuts)-1),y_coeff_scale:=y_coeff+mean_y_bin1]
  print(paste0("Scale up by the reference group mean,",mean_y_bin1))
  # scale up to match unconditional mean
  mean_y_org <- to_est[,mean(y_var,na.rm=T)]
  mean_y_bins <- to_plot[,sum(y_coeff_scale*n_x)]/to_plot[,sum(n_x)]
  # to_plot[,y_coeff_scale2:=y_coeff_scale*mean_y_org/mean_y_bins]
  # print(paste0("Multiply by ",mean_y_org/mean_y_bins," to match the overall mean"))
  to_plot[,y_coeff_scale2:=y_coeff_scale+mean_y_org-mean_y_bins]
  print(paste0("Add ",mean_y_org-mean_y_bins," to match the overall mean"))
  
  return(to_plot)
}

binscatter_feols <- function(dt, y_var, x_var, x_cuts, include.lowest = F,
                             fe_vars = NULL, covs=NULL, others=NULL){
  to_est <- dt[,.SD,.SDcols=unique(c(y_var,x_var,covs,fe_vars,others))]
  setnames(to_est,c(y_var,x_var),c("y_var","x_var"))
  
  if(any(duplicated(x_cuts))){
    print("Bin cutoffs have duplicates -- take unique.")
    x_cuts <- unique(x_cuts)
  }
  
  to_est[,x_bin:=cut(as.numeric(x_var),breaks=x_cuts,labels=1:(length(x_cuts)-1),include.lowest=include.lowest)]
  to_est <- to_est[!is.na(x_bin)]
  
  # exclude any covs NA
  to_est <- to_est[!is.na(y_var)]
  if(is.null(c(covs,others))){
    for(var in c(covs,others)){
      to_est <- to_est[!is.na(get(var))]
    }
  }
  
  # first bin as reference
  to_est[,x_bin:=relevel(x_bin,ref=1)]
  
  # regression formula
  if(is.null(covs)){
    reg_form <- paste0("y_var~x_bin")
  } else{
    reg_form <- paste0("y_var~x_bin+",paste0(covs,collapse="+"))
  }
  
  if(is.null(fe_vars)){
    reg_form <- reg_form
  } else{
    reg_form <- paste0(reg_form, "|", paste0(fe_vars, collapse = "+"))
  }
  
  reg <- feols(as.formula(reg_form),data=to_est)
  
  # to plot
  to_plot <- to_est[,.(mean_x=mean(x_var),n_x=.N),by=x_bin][order(x_bin)]
  to_plot[2:(length(x_cuts)-1),`:=`(y_coeff=reg$coefficients[str_detect(names(reg$coefficients),"x_bin")],
                                    y_se=reg$se[str_detect(names(reg$coefficients),"x_bin")])]
  # scale up by bin 1 mean
  mean_y_bin1 <- to_est[x_bin==1,mean(y_var)]
  to_plot[1,y_coeff_scale:=mean_y_bin1]
  to_plot[2:(length(x_cuts)-1),y_coeff_scale:=y_coeff+mean_y_bin1]
  print(paste0("Scale up by the reference group mean, ",mean_y_bin1))
  # scale up to match unconditional mean
  mean_y_org <- to_est[,mean(y_var,na.rm=T)]
  mean_y_bins <- to_plot[,sum(y_coeff_scale*n_x)]/to_plot[,sum(n_x)]
  # to_plot[,y_coeff_scale2:=y_coeff_scale*mean_y_org/mean_y_bins]
  # print(paste0("Multiply by ",mean_y_org/mean_y_bins," to match the overall mean"))
  to_plot[,y_coeff_scale2:=y_coeff_scale+mean_y_org-mean_y_bins]
  print(paste0("Add ",mean_y_org-mean_y_bins," to match the overall mean"))
  
  return(to_plot)
}
