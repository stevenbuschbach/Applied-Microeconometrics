		
local TREATMENTS = "bdmlo treata a1 a2 treatc c1 c2"
local CONTROLS   = "d_charcoalbuy_KSH spend50 savings_KSH b_incomeself_KSH RiskAverse CreditConstrained b_residents b_children d_jikokoalast_years v1_beliefs_annual_mean v1_beliefs_annual_sd" 


*******************************************************************************
************* IV OF BDM PRICE ON STOVE OWNERSHIP ON SPENDING ******************
	
******************** 1 MONTH SMSES ****************

use "../Data/Clean/SMS_clean_sms_replication.dta", clear

* POST Adoption data only:
drop if missing(SMS_date) | missing(midline_date)
keep if (midline_date < SMS_date)

* Import V2 datA 
preserve
	use "../Data/Clean/Visit123_analysis_replication_noPII.dta", clear
	keep if Visit2==1
	tempfile V2
	save `V2'
restore

merge m:1 respondent_id using `V2'
	keep if _merge ==3
	drop _merge

* Import pre-adoption verage (replace with mean if missing, for treata==0)
merge m:1 respondent_id using "../Data/Clean/SMS_clean_resp_replication.dta", keepusing(sms_amount_weekly_pre)
assert _merge != 1
keep if _merge == 3
su sms_amount_weekly_pre
replace sms_amount_weekly_pre=`r(mean)' if missing(sms_amount_weekly_pre)

* Convert KSH to USD
replace amount_weekly = amount_weekly/100 

* Winsorize at 99th percentile:
assert !missing(amount_weekly)
su amount_weekly,d
replace amount_weekly = `r(p99)' if amount_weekly > `r(p99)'
	
su CsinceV2	
local m = 1
forv k = `r(min)'/`r(max)' {  
	g TsinceV2_`m' = (TsinceV2==`k')
	local m = `m'+1
}	
				
*** REGRESSIONS WITH SMS DATA ***

bys respondent_id: gen n = _n

* OLS1
eststo ols1: reg amount_weekly price_USD finwtp_USD jikokoa `CONTROLS', ///
	cluster(respondent_id)
su amount_weekly if jikokoa==0
		
		
* IV2
eststo iv2: xi: ivreg2 amount_weekly finwtp_USD i.treata i.treatc `CONTROLS' ///
	i.SMS_date sms_amount_weekly_pre TsinceV2_* (jikokoa=price_USD), ///
	cluster(respondent_id)
su amount_weekly if bdmlo==0


*** Import Endline Data ***
use "../Data/Clean/Visit123_analysis_replication_noPII.dta", clear
keep if Visit3==1
	
* FS2
eststo fs2: reg jikokoa price_USD finwtp_USD i.treata i.treatc `CONTROLS', ///
	cluster(respondent_id)
