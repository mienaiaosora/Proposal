# fit linear regression with one break and calculate RSS
fit_break_1 <- function(dt, y_var="cump", x_var="x", p_var="p", x_break, 
                        x_log = T, y_log=F, p_order){
  
  # split data table by below/above the break point
  dt_l <- dt[get(x_var) < x_break, .SD, .SDcols = c(y_var, x_var, p_var)]
  dt_r <- dt[get(x_var) >= x_break, .SD, .SDcols = c(y_var, x_var, p_var)]
  
  setnames(dt_l, c("y_temp","x_temp","p_temp"))
  setnames(dt_r, c("y_temp","x_temp","p_temp"))
  
  # set polynomial order
  fit_r <- 1
  fit_l <- 1
  if(p_order>=dt_l[,.N]-1){
    warning(paste0("The data table does not have enough below the break point. Fitting it perfectly."))
    fit_l <- 0
  }
  if(p_order>=dt_r[,.N]-1){
    warning(paste0("The data table does not have enough above the break point. Fitting it perfectly."))
    fit_r <- 0
  }
  
  if(x_log==T){
    if(dt[get(x_var)<=0,.N]>0){
      stop("Some of x entries are smaller than or equal to 0. Consider setting x_log = F instead.")
    }
    dt_l[, x_temp:=log(x_temp)]
    dt_r[, x_temp:=log(x_temp)]
  }
  
  # regression formula
  if(y_log == T){
    reg_form <- paste0("log(y_temp)~poly(x_temp,",p_order,", raw=T)")
  } else{
    reg_form <- paste0("y_temp~poly(x_temp,",p_order,", raw=T)")
  }
  
  # run regression (if has enough unique points)
  if(fit_l==1){
    
    reg1 <- felm(as.formula(reg_form), data=dt_l, weights = dt_l$p_temp)
    # add fitted values
    if(y_log == T){
      dt_l[, `:=`(log_y_fit=reg1$fitted.values)]
      dt_l[, `:=`(y_fit=exp(log_y_fit))]
    } else{
      dt_l[, `:=`(y_fit=reg1$fitted.values)]
    }
    
  }else{
    dt_l[, `:=`(y_fit=y_temp)]
  }
  
  if(fit_r==1){
    
    reg1 <- felm(as.formula(reg_form), data=dt_r, weights = dt_r$p_temp)
    # add fitted values
    if(y_log == T){
      dt_r[, `:=`(log_y_fit=reg1$fitted.values)]
      dt_r[, `:=`(y_fit=exp(log_y_fit))]
    } else{
      dt_r[, `:=`(y_fit=reg1$fitted.values)]
    }
    
  }else{
    dt_r[, `:=`(y_fit=y_temp)]
  }
  
  dt_all <- rbindlist(list(dt_l[,.(y_temp,x_temp,p_temp,y_fit)],dt_r[,.(y_temp,x_temp,p_temp,y_fit)]))
  dt_all[, `:=`(residual=y_temp-y_fit)]
  
  setnames(dt_all, c("y_temp","p_temp","y_fit"), c(y_var,p_var,paste0(y_var,".fitted")))
  
  if(x_log==T){
    setnames(dt_all, "x_temp", paste0(x_var,".log"))
  }else{
    setnames(dt_all, "x_temp", x_var)
  }
  
  rss_all <- dt_all[, sum(residual^2*p)]
  return(list(rss=rss_all,
              fit_dt=dt_all))
}