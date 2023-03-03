## Load needed packages
# library(here)
# require(caret)
# require(ggplot2)
# require(plyr)
# require(dplyr)
# require(glmnet)
## Set Base File 

library(groundhog)

packages = c("here", "caret", "ggplot2","plyr", "dplyr","glmnet")
groundhog.library(packages, "2021-12-08", ignore.deps='generics')


for (iteration in 1:250){
  base<-here::here('Data', 'Med')
  tmp <- try(setwd(base))

  arraynum <- iteration
  
  
  print(arraynum)
  seed <- 399832+1000*arraynum
  print(seed)
  set.seed(seed)
  print(.Random.seed)
  
  

  
  ## Set Tuning Parameters
  NCV <- 2
  NRCV <- 10
  
  ## Set main/aux parameters
  sims <- 4
  TG <- expand.grid(alpha=1,lambda=seq(0.001,0.2,0.001))
  
  
  ## Read in Data
  datfile <- file.path(base,"MLTrain_replication_noPII.csv")
  data <- read.csv(datfile)
  
  ## Process data as needed (e.g. define factor variables)
  data$z <- factor(data$z)
  data$respondent_id <- NULL
  
  ## Create control function
  myControl <- trainControl(
    method="repeatedcv", number=NCV, repeats=NRCV,
    verboseIter = TRUE,
    allowParallel = FALSE,
  )
  
  ###### Run Estimation ########
  
  fit_y0 <- matrix(NA,1,3)
  fit_y1 <- matrix(NA,1,3)
  preds <- matrix(NA,sims,2)
  results <- matrix(NA,sims,5)
  results_het <- matrix(NA,sims,5)
  results_group <- matrix(NA,sims,9)
  
  for(j in 1:sims){
    #Split into aux (training) and main (estimating) samples
    ind <- createDataPartition(data[,"z"], p = 0.5, list = FALSE)
    
    A <- as.data.frame(data[ind,])
    M <- as.data.frame(data[-ind,])
    
    ## Drop variables with near zero variation
    nzv <- nearZeroVar(A)
    A <- A[,-nzv]
    M <- M[,-nzv]
    
    #Estimate ML Scores on Aux Data
    #First for the control
    y0mod <- train(
      y~.-d-pd-z-y_obs,
      data=subset(A,d==0),
      weights=y_obs,
      tuneGrid=TG,
      preProcess="range",
      method="glmnet",
      metric="RMSE",
      trControl = myControl
    )
    
    #Post-LASSO OLS to remove bias
    if (length(predictors(y0mod))>0){
      Y0lmmod <- lm(as.formula(paste("y~",paste(predictors(y0mod),collapse="+"))),weights=y_obs,data=subset(A,d==1))
    } else {
      Y0lmmod <- lm(y~1, weights=y_obs, data=subset(A,d==1))
    }
    
    my_Y0 <-predict(Y0lmmod,M)
    preds[j,1] <- paste(predictors(y0mod), collapse=";")
    
    cont_inds <- which(M$d==0)
    fit_y0 <- rbind(fit_y0,cbind(j=j,my_Y0=my_Y0[cont_inds],true_Y0=M$y[cont_inds]))
    
    #Then for treatment
    y1mod <- train(
      y~.-d-pd-z-y_obs,
      data=subset(A,d==1),
      tuneGrid=TG,
      weights=y_obs,
      preProcess="range",
      method="glmnet",
      metric="RMSE",
      trControl = myControl
    )
    
    #Post-LASSO OLS to remove bias
    if (length(predictors(y1mod))>0){
      Y1lmmod <- lm(as.formula(paste("y~",paste(predictors(y1mod),collapse="+"))),weights=y_obs,data=subset(A,d==1))
    } else {
      Y1lmmod <- lm(y~1, weights=y_obs, data=subset(A,d==1))
    }
    
    my_Y1 <-predict(Y1lmmod,M)
    preds[j,2] <- paste(predictors(y1mod), collapse=";")
    
    treat_inds <- which(M$d==1)
    fit_y1 <- rbind(fit_y1,cbind(j=j,my_Y1=my_Y1[treat_inds],true_Y1=M$y[treat_inds]))
    
    
    #Form B and S predictors
    B <- my_Y0
    S <- (my_Y1-my_Y0)
    
    
    #Break ties and cut into groups to look at Gates
    S2 <- S+runif(length(S), 0, 0.00001)
    breaks    <- quantile(S2, seq(0,1, 1/3),  include.lowest =T)
    breaks[1] <- breaks[1] - 0.001
    breaks[4] <- breaks[4] + 0.001
    SG        <- cut(S2, breaks = breaks, labels=c("G1","G2","G3"))
    SGX       <- model.matrix(~-1+SG)
    
    
    #Add noise if no variation in B and S
    if(var(B)==0){
      B <- B+rnorm(length(B),0, sd=0.1)
    }
    if(var(S)==0){
      S <- S+rnorm(length(S),0, sd=0.1)
    }
    
    #Combine in data for estimation
    M <- cbind(M,B,S,SG)
    M$Sd <- M$S-mean(M$S)
    M$S_ort <- (M$d-M$pd)*M$Sd
    M$d_ort <- (M$d-M$pd)
    M$weights <- 1/(M$pd*(1-M$pd))
    
    #Create interacted dummies for GATES
    DGX <- SGX*M$d_ort
    colnames(DGX) <- c("G1","G2","G3")
    M <- cbind(M,DGX)
    
    
    ## Look at Gates
    
    gates <- lm(y~B+S+SG+G1+G2+G3+z,weights=weights, data=M)
    
    #Get adjusted critical value
    crit <- qnorm(1-0.05/3)
    
    #Get gates amd SEs
    coef <- summary(gates)$coef[c('G1','G2','G3'),1]
    se <- summary(gates)$coef[c('G1','G2','G3'),2]
    
    #monotize and store
    results_group[j,1:3] <- sort(coef)
    results_group[j,4:6] <- sort(coef+crit*se)
    results_group[j,7:9] <- sort(coef-crit*se)
    
    ## Look at WTP by treatment group
    
    
    ## Look at BLP
    
    blp <- lm(y~B+S+d_ort+S_ort+z, weights=weights, data=M)
    
    
    coef <- (summary(blp)$coefficients['d_ort',1])
    pval <- (summary(blp)$coefficients['d_ort',4])
    results[j,]      <-c(coef, confint(blp, 'd_ort', level = 0.95)[1:2],  (as.numeric(coef<0)*(pval/2) + as.numeric(coef>0)*(1-pval/2)),(as.numeric(coef<0)*(1-pval/2) + as.numeric(coef>0)*(pval/2)))
    
    coef <- (summary(blp)$coefficients['S_ort',1])
    pval <- (summary(blp)$coefficients['S_ort',4])
    results_het[j,]      <-c(coef, confint(blp, 'S_ort', level = 0.95)[1:2],  (as.numeric(coef<0)*(pval/2) + as.numeric(coef>0)*(1-pval/2)),(as.numeric(coef<0)*(1-pval/2) + as.numeric(coef>0)*(pval/2)))
    
  }
  
  ### Output results to be combined
  colnames(preds) <-  c("Y)","Y1")
  colnames(results) <- c("B","CI_L","CI_U","P_L","P_U")
  colnames(results_het) <- c("S","CI_L","CI_U","P_L","P_U")
  colnames(results_group) <- c("G1","G2","G3","UL_G1","UL_G2","UL_G3","LL_G1","LL_G2","LL_G3")
  
  
  fit_y0 <- fit_y0[-1,]
  fit_y1 <- fit_y1[-1,]
  
  # write.csv(preds,paste(base,"/Predictors/Preds_",arraynum,".csv",sep=""))
  # write.csv(fit_y0,paste(base,"/Fits_Y0/FitsY0_",arraynum,".csv",sep=""))
  # write.csv(fit_y1,paste(base,"/Fits_Y1/FitsY1_",arraynum,".csv",sep=""))
  # write.csv(results,paste(base,"/B_Results/BRes_",arraynum,".csv",sep=""))
  # write.csv(results_het,paste(base,"/S_Results/SRes_",arraynum,".csv",sep=""))
  write.csv(results_group,paste(base,"/GATES/GATES_",arraynum,".csv",sep=""))

} 


