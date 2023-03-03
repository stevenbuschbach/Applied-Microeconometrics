include "${main}/Do/0. Master.do"

**************************************************************
******************* Prepare for Data Analysis ****************
************************************************************** 

use "`dataclean'/Visit123_clean_replication_noPII.dta", clear


merge 1:1 respondent_id using "`dataclean'/SMS_clean_resp_replication.dta"
assert _merge != 2 // Never SMSes from someone we did not survey
drop _merge 
	
merge 1:1 respondent_id using "`raw'/Visit1_clean_original.dta", keepusing(bdmprice) update // do NOT replace
replace price = bdmprice if missing(price)

cou if price != bdmprice
assert `r(N)' == 1 /* One time an FO entered the wrong respondent ID for 
respondent 68cd33f, re-assigning them to different treatment assignments from
 what was assigned in V1 */
drop bdmprice 

cou if _merge != 3 & _merge != 4
drop _merge 

********** Demographic Variables *********

replace a_area = "Dandora" if a_area == "Kayole"

tab b_educ
replace b_educ = 0 if b_educ == 96 // No Schooling
replace b_educ = . if b_educ == 97
replace b_educ = 39 if b_educ == 3 // Finished primary school
foreach n in 6 7 8 9 10 11 12 13 14 {
	replace b_educ = b_educ * 10 if b_educ == `n'
}
tab b_educ
g educ_prim = b_educ >= 39 if !missing(b_educ)

********** Economic Variables *********


*** Savings
foreach var of varlist g2a* g2b* g2b2* g2c* g1g1* { 
	destring `var', replace
	foreach n in -88 88 -99 99 999 {
		replace `var' = . if `var' == `n'
	}
	su `var', d
	replace `var' = `r(p99)' if `var' > `r(p99)' & !missing(`var')
	tab `var'
	* pause
}

egen savings = rowtotal(g2a g2b2 g2c)
lab var savings "Savings in bank, mobile, ROSCA (Ksh)"
lab var g1g1 	"Borrowing limit today"
su savings, d

*** Credit Constrained


* 1 = credit constrainted 
g CC_loanaccess = (g1a2==0)
g CC_refloan = (g1e=="96")
g CC_refmoneylender = (g1e_2==1)
g CC_wantsmore = (g1f==2 | g1f==3)
g CC_mpesalo = (g1g1 <= 1000) | missing(g1g1)
g CC_paybackloan = (g2i_9==1 |  g2h_9==1)
g CC_noborrowsource = (g2g_1==1)

lab var CC_loanaccess		"Has not used mobile banking loan"
lab var CC_refloan 			"Was refused a loan"
lab var CC_refmoneylender	"Refused by a moneylender"
lab var CC_wantsmore		"Would borrow more if could/cheaper"
lab var CC_mpesalo			"Has low Mpesa borrowing limit"
lab var CC_paybackloan 		"Would use money to pay back loan"
lab var CC_noborrowsource	"Has no source to borrow from" 

egen CreditConstrained = rowmean(CC_*)


egen payability=rowmean(g1g g1h g1i)
replace jikokoa_guessprice = 3990 if jikokoa_guessprice==39990
replace jikokoa_guessprice = 2000 if jikokoa_guessprice==20000




********** Treatment Variables *********

* Binary BDM treatment variable: <=1500 vs >1500 price allocation
g bdmlo = (price <= 1500)
lab var bdmlo "BDM Treatment (Price <= 1500)"	

* Interactions:
g treat_any = (treata_pooled==1 | treatc_pooled==1)
lab var treat_any "Any treatment (A or C)"

g treat_both = (treata_pooled==1 & treatc_pooled==1)
lab var treat_both "Attention Treatment X Credit Treatment"

g a0 = (treata==0) if !missing(treata)
g a1 = (treata==1) if !missing(treata)
g a2 = (treata==2) if !missing(treata)
g c0 = (treatc==0) if !missing(treatc)
g c1 = (treatc==1) if !missing(treatc)
g c2 = (treatc==2) if !missing(treatc)
g t_benefits 	= (treata==1 | treata==2)
g t_costs	 	= (treata==2)

g t_benefits_C 	= t_benefits * treatc_pooled
g t_costs_C		= t_costs * treatc_pooled

g t_benefits_WC 	= t_benefits 	* c1
g t_costs_WC		= t_costs 		* c1
g t_benefits_MC 	= t_benefits 	* c2
g t_costs_MC		= t_costs 		* c2

lab var a1 "Treatment A1 Only"
lab var a2 "Treatment A2 Only"
lab var c1 "Treatment C1 Only"
lab var c2 "Treatment C2 Only"

lab var t_benefits 		"Attention to benefits"
lab var t_costs 		"Attention to costs"
lab var t_benefits_C 	"Attention to benefits X Credit"
lab var t_costs_C 		"Attention to costs X Credit"

lab var t_benefits_WC 	"Attention to benefits X Weekly Credit"
lab var t_costs_WC 		"Attention to costs X Weekly Credit"
lab var t_benefits_MC 	"Attention to benefits X Monthly Credit"
lab var t_costs_MC 		"Attention to costs X Monthly Credit"

g any_any 		= (treata_pooled==1 | treatc_pooled==1 | bdmlo==1)
lab var any_any "Any treatment (Attention, Control, or Subsidy)"



********* Converting bean bins to mean, median, sd per respondent *********

foreach var of varlist d_beans* {
	rename `var' v2_`var'
}

foreach v in v1 v2 {

	preserve 
		keep respondent_id `v'_d_beans* 
		reshape long `v'_d_beans, ///
			i(respondent_id) j(binID)
		g binVal=(1250*binID)-625
		drop if `v'_d_beans==0
		forv n=0/20 {
			expand `n' if `v'_d_beans==`n'
		}
		collapse (mean) 	`v'_beliefs_annual_mean=	binVal ///
				 (sd) 		`v'_beliefs_annual_sd=		binVal ///
				 (median)	`v'_beliefs_annual_median=	binVal, ///
				by(respondent_id)
		tempfile beliefs
		save `beliefs'	
	restore
	
	merge 1:1 respondent_id using `beliefs'
	assert _merge == 3
	drop _merge 
}

g beliefs_annual_increase = v2_beliefs_annual_mean - v1_beliefs_annual_mean
lab var beliefs_annual_increase "Increase in beliefs about annual savings (KSH)"

*/

********** Attention Calculations **********

* Attention calculations should be missing for all attention control group: 
foreach var of varlist attw* {
	cap replace `var' = . if treata==0
	cap replace `var' = "" if treata==0
} 

g finwtp_weekly= finwtp*0.08499

egen attw_TOTAL_12  	= rowtotal(attw1-attw12), missing
egen attw_TOTAL_52 		= rowtotal(attw1-attw52), missing

replace attw_TOTAL_12 	= spend50*12 if treata_pooled==0
replace attw_TOTAL_52 	= spend50*52 if treata_pooled==0

g finwtp_relto_benefits    = finwtp - attw_TOTAL_12
g weeklywtp_relto_benefits = finwtp_weekly - spend50
		
lab var finwtp_weekly 				"WTP (in Weekly terms)" 
lab var attw_TOTAL_12 				"Total expected savings (12 weeks)"
lab var attw_TOTAL_52 				"Total expected savings (52 weeks)"
lab var finwtp_relto_benefits		"WTP relative to Savings (12 weeks)"
lab var weeklywtp_relto_benefits	"Weekly WTP relative to Savings (12 weeks)"
	
* Measure of SD of savings that is independent of mean savings:
egen newmean = rowmean(attw1-attw12)
forv n = 1/12 {
	g new`n' = attw`n' / newmean
}
egen attw_sheet_SD_12 = rowsd(new1-new12)
corr newmean attw_sheet_SD_12
drop newmean new1-new12

g attw_sheet_SDhi = (attw_sheet_SD_12>0) if !missing(attw_sheet_SD_12)
lab var attw_sheet_SD_12	"SD of savings (12 weeks)"
lab var attw_sheet_SDhi		"SD of savings is high (12 weeks)"
		


********** Effort Tasks *********

* Decisions1-5 is V1, Decision1-5 is V2
* Higher number is more in FUTURE
* if INCREASE, then choosing more in FUTURE, hence PB
forv n = 1/5 { 
	g tasks_change_`n' = decision`n'-decisions`n'
	lab var tasks_change_`n' "Tasks V2 - Tasks V1 (Set `n')"
	g tasks_pcchange_`n' = tasks_change_`n' / (24-decisions`n')
	lab var tasks_pcchange_`n' "Percentage change tasks today (Set `n')"
}
egen tasks_average_change = rowmean(tasks_change_*)
egen tasks_average_pcchange = rowmean(tasks_pcchange_*)
lab var tasks_average_change	"Average change in tasks postponed"
lab var tasks_average_pcchange	"Average percentage change in tasks postponed"
		

		
********** Income Variability: *********

* Converting belief bins to mean, median, sd per respondent *********

egen income_variability_cap_self = rowmax(d_ivself*)
egen income_variability_cap_others = rowmax(d_ivothers*)
egen income_variability_cap_total = rowmax(d_ivself* d_ivothers*)

br income_variability_cap_self d_ivself*

foreach type in self others {

	preserve 
	
		keep respondent_id d_iv`type'* 
		reshape long d_iv`type', ///
			i(respondent_id) j(binID)
		g binVal=(500*binID)-750
		replace binVal = 0 if binID==1
		replace binVal = 10000 if binID==22
		
		drop if d_iv`type'==0 | missing(d_iv`type')
		* Expand so that every bean is 1 row:
		forv n=1/20 {
			expand `n' if d_iv`type'==`n'
		}
		
		* Confirm that everyone has 20 beans:
		bys respondent_id: g N = _N
		assert N == 20
		drop N
		sort respondent_id binID
		set more off
		list in 1/1000
		list in 1/1
		*stop
		
		collapse (mean) 	income_variability_`type'_mean=		binVal ///
				 (sd) 		income_variability_`type'_sd=		binVal ///
				 (median)	income_variability_`type'_median=	binVal, ///
			by(respondent_id)
			
		tempfile variability
		save `variability'	
		
	restore
	
	drop d_iv`type'*
	
	merge 1:1 respondent_id using `variability'
	assert _merge != 2
	drop _merge 

}

foreach type in mean sd median {
	g income_variability_`type' = income_variability_self_`type' + income_variability_others_`type'
}

********** Top-code/Winsorize continuous variables: *********

foreach var of varlist ///
	hhincome_week b_incomeself b_incomeothers ///
	b_rent_week d_TOTALbuy d_charcoalbuy savings /// 
	c_cookstoveprice {
	su `var', detail
	replace `var'=`r(p99)' if `var'>`r(p99)' & !missing(`var')
	su `var', detail
}

********** Convert KSH to USD: *********

local FX = 100
foreach var of varlist ///
	hhincome_week b_incomeself b_incomeothers ///
	b_rent_week d_TOTALbuy d_charcoalbuy savings /// 
	c_cookstoveprice g_invest ///
	sms_amount_weekly* price finwtp finwtp_weekly  ///
	attw_TOTAL_12 attw_TOTAL_52  g_char_week ///
	g_c2_wtp {
	assert `var' >= 0 
	
	destring `var', replace
	
	foreach n in -88 88 -99 99 999 0.888 0.999 {
		replace `var' = . if `var' == `n'
	}
	replace `var' = . if `var'>0.8879 & `var'<0.8881
	replace `var' = . if `var'>0.9989 & `var'<0.9991
	tab `var', mi	
	
	rename `var' `var'_KSH
	g `var'_USD = `var'_KSH/`FX' 
	local label : var lab `var'_KSH
	local new = subinstr("`label'", "Ksh", "USD", .)
	lab var `var'_USD "`new'"

}

lab var g_invest_USD "Risky investment amount (0-4 USD)"

foreach var of varlist ///
	wtp_normalized finwtp_relto_benefits weeklywtp_relto_benefits {
	
	destring `var', replace

	rename `var' `var'_KSH
	g `var'_USD = `var'_KSH/`FX' 
	local label : var lab `var'_KSH
	local new = subinstr("`label'", "Ksh", "USD", .)
	lab var `var'_USD "`new'"

}


	
********* INTERACTIONS *********


***  Treatments

g CreditInt = CreditConstrained * treatc_pooled
g SavingsInt = savings_KSH * treatc_pooled

g CxA  = treatc_pooled * treata_pooled 
g CxA0 = treatc_pooled * a0
g CxA1 = treatc_pooled * a1
g CxA2 = treatc_pooled * a2

g C1xA1 = c1 * a1
g C1xA2 = c1 * a2
g C2xA1 = c2 * a1
g C2xA2 = c2 * a2

*** Risk Aversion

g RiskAverse = (g_invest_KSH<=150) if !missing(g_invest_KSH)

g RA_TAP = RiskAverse * treata_pooled 
g negativenetbenefits = finwtp_relto_benefits_USD<0

g RAxA0 = RiskAverse * a0 
g RAxA1 = RiskAverse * a1
g RAxA2 = RiskAverse * a2

g RAxC = RiskAverse * treatc_pooled

g RAxt_benefits = RiskAverse * t_benefits
g RAxt_costs = RiskAverse * t_costs

*** Present Bias

* Time between V1 and V2: 
g timeV12 = midline_date - baseline_date
g timeV23 = endline_date - midline_date
lab var timeV12 "Days between Visits 1-2"
lab var timeV23 "Days between Visits 2-3"


pause

*Alt PB measures

forvalues i=1/5{
	g PB_`i' = (tasks_change_`i'>0) if !missing(tasks_change_`i')
}
egen PB_votes=rowmean(PB_*)
egen PB_ever=rowmax(PB_*)
egen PB_always=rowmin(PB_*)
replace PB_votes=round(PB_votes)

g PB_avg = (tasks_average_change>0) if !missing(tasks_average_change)


g PB = (tasks_change_3>0) if !missing(tasks_change_3)

g CreditXPB = treatc_pooled * PB

g CostsInvisibleXPB = a1 * PB
g CreditXCostsInvisibleXPB = treatc_pooled * a1 * PB

g PBxa0 = a0 * PB
g PBxa1 = a1 * PB
g PBxa2 = a2 * PB

g CreditxPBxa0 = treatc_pooled * PBxa0 
g CreditxPBxa1 = treatc_pooled * PBxa1
g CreditxPBxa2 = treatc_pooled * PBxa2 

g CreditXPBXcosts	 = t_costs * treatc_pooled * PB



foreach i in 1 2 3 4 5 avg votes ever always {

	g CreditXPB_`i' = treatc_pooled * PB_`i'

	g CostsInvisibleXPB_`i' = a1 * PB_`i'
	g CreditXCostsInvisibleXPB_`i'= treatc_pooled * a1 * PB_`i'

	g PB_`i'xa0 = a0 * PB_`i'
	g PB_`i'xa1 = a1 * PB_`i'
	g PB_`i'xa2 = a2 * PB_`i'

	g CreditxPB_`i'xa0 = treatc_pooled * PB_`i'xa0 
	g CreditxPB_`i'xa1 = treatc_pooled * PB_`i'xa1
	g CreditxPB_`i'xa2 = treatc_pooled * PB_`i'xa2 

	g CreditXPB_`i'Xcosts	 = t_costs * treatc_pooled * PB_`i'


}


*** Beliefs

su v1_beliefs_annual_sd, d
g v1_beliefs_annual_sd_hi = (v1_beliefs_annual_sd>=`r(p50)') if !missing(v1_beliefs_annual_sd)
g spend50_USD = spend50/100
g v1_beliefs_annual_mean_USD = v1_beliefs_annual_mean/100	
g Optimism = (attw_TOTAL_12_KSH) / (spend50 * 12) 
g Optimistic = (Optimism >= 1) if !missing(Optimism)

*** Other

g d_jikokoalast_years = d_jikokoalast/52

*** Health

egen health_beliefs_v1 = rowmean(f_health_trad_adult f_health_trad_child f_health_longterm f_health_jikokoa)

*** Other non-financial stove attributes
replace d3_stop = lower(d3_stop)
foreach no in "none" "0" "n0" {
	replace d3_stop = "no" if d3_stop=="`no'"
}
replace d3_start = lower(d3_start)
foreach no in "none"  {
	replace d3_start = "no" if d3_start=="`no'"
}

replace d3_heating_mins = 0 if d3_heating_yn == 0 

replace d3_like = lower(d3_like)
g d3_likes = "" 
replace d3_likes = d3_likes + "smoke " if strpos(d3_like, "smoke")
replace d3_likes = d3_likes + "fast " if strpos(d3_like, "fast") | strpos(d3_like, "time") | strpos(d3_like, "haraka")  | strpos(d3_like, "quick")
replace d3_likes = d3_likes + "taste " if strpos(d3_like, "taste") | strpos(d3_like, "tasty")

foreach save in "economical" "saves charcoal" "less charcoal" "less consumption" "charcoal" "money" "makaa" {
	replace d3_likes = d3_likes + "cheap " if strpos(d3_like, "`save'")
	replace d3_likes = subinstr(d3_likes, "cheap cheap", "cheap", .)
}
list d3_like* if !missing(d3_like) & missing(d3_likes)
tab d3_likes, sort


replace d3_dur_shorter = . if d3_dur_shorter==-999
g change_cookingtime_mins = d3_dur_shorter
replace change_cookingtime_mins = (d3_dur_longer * (-1)) if !missing(d3_dur_longer)
replace change_cookingtime_mins = 0 if d3_duration == 2

g d1_use_minutes_daily = d1_use_morn + d1_use_aft + d1_use_eve

********* RETURN CASES ********

* The following respondents returned the stove
* Drop them from the sample
* The reasoning for why these are dropped is saved in Dropbox > Cookstoves> Main > Do > "Manual_Changes.txt"

drop if respondent_id == "zcz0a7f" | respondent_id == "66bcf38" | respondent_id == "4z63435" | respondent_id == "0f2fa7d" | respondent_id == "d97cz8c"

********* OTHER CASES *********

* The FO mentions that the respondent was surveyed twice.
* It is unclear which responses are correct and appear in the data.
* See Dropbox > Cookstoves> Main > Do > "Manual_Changes.txt" for more details

drop if respondent_id == "670bf58"


* FO filled in the wrong respondent's details.
* See Dropbox > Cookstoves> Main > Do > "Manual_Changes.txt" for more details

drop if respondent_id == "3d53c17"



********* EXPORT FILE *********

save "`dataclean'/Visit123_analysis_replication_noPII.dta", replace


