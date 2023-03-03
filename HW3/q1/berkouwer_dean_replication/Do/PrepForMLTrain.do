include "${main}/Do/0. Master.do"
clear all 

*Preliminaries
cap log close
set more off

*Load data
use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear


********** Select outcome variable  *************
	gen y=asinh(sms_amount_weekly_post_USD)	
	gen y_obs=sms_obs
	
********** Select treatment variable *************
	gen d=jikokoa

********** Generate WTP indicators to condition on **********
	xtile z=finwtp_USD, n(5)
	

********** Estimate propensity score for each individual **********
	reg d i.z
	predict pd
	replace pd=pd
	label var pd "Propensity Score"
	
	
	*Check to make sure it gives similar estimates to the IV
	gen weights=1/pd if jikokoa==1
	replace weights=1/(1-pd) if d==0
	reg y d [pweight=weights]

	

	
********** Create and Collect training variables *********


	***** Energy variables
	
		*For unused energy sources replace with zero
		foreach var of varlist d_*buy d_*free{
			replace `var'=0 if missing(`var')
		}

		
		*Reduce data for non-charcoal energy spending
		pca d_candlesbuy d_elecbuy d_firewoodbuy d_kerosenebuy d_lpgbuy d_solarbuy d_candlesfree d_firewoodfree d_kerosenefree d_lpgfree, mine(1)
		predict pca_non_charcoal_engergy*
		
		*Get charcoal prices after controlling for units
		reg c_charcoalkes i.c_charcoalunits 
		predict r_charprice, r
		 
	unab train : `train'  jiko_months pca_non_charcoal_engergy* d_charcoalfree d_charcoaluse d_charcoalbuy_USD c_cookstoveprice_USD r_charprice
	
	***** New Stove attributes
		replace f_health_work=0 if f_health_work==-99
		
	unab train : `train'   d_beanmax d_beanmin v1_beliefs_annual_mean-v1_beliefs_annual_median
	
	***** Preferences
	
	
	unab train : `train' g_invest_USD PB
	
	***** Demographics
	
		*Assume if they didn't respond savings/borrowing or rent questions number is zero
		foreach var of varlist g1g1 g2a g2b g2b2 g2c g2e g2f b_rent  {
			replace `var'=0 if missing(`var')
			replace `var'=0 if `var'<0	
		}
		
		*Deal with "others"
		foreach var of varlist g1a2 {
			replace `var'=0 if `var'==98
		
		}
		
		*Recode ROSCA use to be either yes or no
		replace g1b="0" if g1b=="96"
		replace g1b="1" if g1b!="0"
		destring g1b, replace
		
		*Code borrowing sources  
		gen borrow_formal=regex(g1d,"1")
		gen borrow_family=regex(g1d,"3")
		gen borrow_rosca=regex(g1d,"[56]") & g1d!="96"
		gen borrow_other=regex(g1d,"[42]")
		gen borrow_none=regex(g1d,"96")
		
		
		*Code borrowing denials  
		gen denied_formal=regex(g1e,"1")
		gen denied_family=regex(g1e,"3")
		gen denied_rosca=regex(g1e,"[56]") & g1d!="96"
		gen denied_other=regex(g1e,"[42]")
		gen denied_none=regex(g1e,"96")
		
		*If no children set child health variables to zero 
		foreach var of varlist d2_*child{
			replace `var'=0 if missing(`var')
		}
		
		cap drop purpose_*
		*Generate dummies for loan purpose
		foreach var of varlist g2d g2h g2i {
			forvalues i=1/10 {
				gen purpose_`var'_`i' = regex(g2d,"`i'") & g2d!="97"
			}
			gen purpose_`var'_oth=(g2d=="97")
		}
			
		*Reason no loans
		gen noloans_noneed=regex(g2g,"[34]")
		gen noloans_cant=regex(g2g,"1")
		gen noloans_repayment=regex(g2g,"2")
		gen noloans_other=(g2g=="97")
		
	
		 
	unab train : `train' b_residents b_children hhincome b_rent 
		
	
	
	su `train'
	

******** Prepare to outsheet ***********

	keep respondent_id `train' y y_obs d pd z
	
	drop if missing(y) | missing(d) | missing(z)
		
	
	** Make splines
	
	foreach var of local train {
	
		mkspline _`var' 3 = `var'
		drop `var'
	
	
	}
	
	foreach var of varlist _* {
		
		** For still missing values replace with zero and generate dummies for missing variables
		gen mi_`var'=missing(`var')
		qui su mi_`var'
		if `r(min)'!=`r(max)' {
			replace `var'=0 if missing(`var')
		} 
		else { 
			drop mi_`var'
		}
		

	}
	
	
	
	** Drop missings for all variables  (most common reason is no variation so SD is zero)
	missings dropvars, force
	
	* Drop any perfectly colinear
	local drop " "
	unab all: _all
	local core "respondent_id y y_obs d pd z"
	local  all : list all - core
	local K: word count `all'
	forv i=1(1)`=`K'-1' {
		forv j=`=`i'+1'(1)`K' {
			local y: word `i' of `all'
			local x: word `j' of `all'
			qui: isvar `y' `x'
			if wordcount("`r(varlist)'")==2 {
				qui: reg `y' `x'
				if e(r2)==1 {		
					local drop "`drop' `x'" 
					qui: drop `x' 
				}
			}
		}
	}

	di "`drop'"
	
	order respondent_id y y_obs d pd z 
	
	outsheet using "`datamed'/MLTrain_replication_noPII.csv", replace c

	
