include "${main}/Do/0. Master.do"
clear all 
use "`dataclean'/SMS_clean_sms_replication.dta", clear


local CONTROLS = "d_charcoalbuy_KSH spend50 savings_KSH b_incomeself_KSH RiskAverse CreditConstrained b_residents b_children d_jikokoalast_years v1_beliefs_annual_mean v1_beliefs_annual_sd" 

* CONTROLS2 is the 2018 PILOT controls
local CONTROLS2 = "b_rent b_residents b_children b_incomehh g2_savings d_charcoalbuy"

* CONTROLS3 adds the Dizon-Ross & Jayachandran (2022) practice WTP control
local CONTROLS3 = "`CONTROLS' prac_finwtp item"
		
foreach var in `CONTROLS' {
	di "`var' : "
	cap cou if missing(`var')
}

include "`dofiles'/Balance_reg.do"
		
local TREATMENTS = "bdmlo treata a1 a2 treatc c1 c2"

* IN PAPER:
local 		SummaryStatistics		1
local 		IVPriceSpending			1
	*Takes a long time to run and is only relevant for Figure A12 so may want to set to zero. 
	local 		ivqte					1 
local 		IVotherOutcomes			1
local 		Mechanisms				1
local 		BalanceTables			1
local		AttritionTable			1
local 		IV1YRendlineOutcomes 	1
local 		TreatmentsWTPOLS		1
local 		AttentionBeliefs		1


***********************************************	
************* Balance tables ******************
if `SummaryStatistics' == 1 {
	include "${main}/Do/0. Master.do"
	
	use "`dataclean'/Visit123_clean_replication_noPII.dta", clear
	drop b_educ* 
	
	
 	merge 1:1 respondent_id  using "`dataclean'/Visit123_analysis_replication_noPII.dta", keepusing(savings* b_educ*)
	
	
	g educ_primcomplete = (b_educ >= 39) if !missing(b_educ) & b_educ!=96 & b_educ!=97
	g educ_somesec = (b_educ > 39) if !missing(b_educ) & b_educ!=96 & b_educ!=97
	g educ_seccomplete = (b_educ >= 44) if !missing(b_educ) & b_educ!=96 & b_educ!=97
	
	g incomeself_weekly = (b_incomeself/100) * 7
	g incomeself_monthly = (b_incomeself/100) * 30.5
	su incomeself_monthly ,d
	
	foreach var of varlist hhincome_week d_charcoalbuy d_TOTALbuy c_cookstoveprice {
		g `var'_USD = `var'/100
	}
	
	local balvars b_residents age b_female educ_primcomplete educ_seccomplete incomeself_weekly hhincome_week_USD d_TOTALbuy_USD d_charcoalbuy_USD savings_USD c_cookstoveprice_USD
	eststo sumstats: estpost tabstat `balvars', statistics(mean sd p25 p50 p75) columns(statistics)
	
	preserve
	
	label var b_residents 		"Household size" 
	label var age 				"Age" 
	label var b_female 			"Female respondent"
	label var educ_primcomplete	"Completed primary education"
	label var educ_seccomplete 	"Completed secondary education"
	label var incomeself_weekly "Respondent income (USD/week)"
	label var hhincome_week_USD "Household income (USD/week)" 
	label var d_TOTALbuy_USD	"Energy spending (USD/week)" 
	label var d_charcoalbuy_USD	"Charcoal spending (USD/week)" 
	label var savings_USD		"Savings (USD)" 
	label var c_cookstoveprice_USD 	"Current cookstove price (USD)"

	esttab sumstats using "`tables'/Table1_sumstats.tex", noobs nonum nomtitle label end( \\ ) replace booktabs f cells("mean(fmt(2) label(\multicolumn{1}{c}{Mean})) sd(fmt(2) label(\multicolumn{1}{c}{SD})) p25(fmt(0) label(25$^{th}$)) p50(fmt(0) label(50$^{th}$)) p75(fmt(0) label(75$^{th}$))")
	cou
	
	restore
}


if `BalanceTables' == 1	{
	
	use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear
		
		foreach var of varlist treata treatc treata_pooled treatc_pooled { 
			replace `var'=v1_`var' if missing(`var')
		}
		
		keep if !missing(treata_pooled) & !missing(treatc_pooled) & !missing(bdmlo)
		
		* Define variables that we want to check for balance: 
		local varlistKSH = 		"b_female age b_residents b_children savings_KSH hhincome_week_KSH d_TOTALbuy_KSH d_charcoalbuy_KSH c_cookstoveprice_KSH g_invest_KSH"
		local varlistUSD = 		"b_female age b_residents b_children savings_USD hhincome_week_USD d_TOTALbuy_USD d_charcoalbuy_USD c_cookstoveprice_USD g_invest_USD"
		
		keep treatc_pooled treata_pooled bdmlo `varlistKSH' `varlistUSD'
		
		* Attention Treatment and Credit Treatment - KSH
		g one = 0
		replace one = 1 if _n == 1
		foreach c in USD {

		di "one: `varlistshort`c''"
		di "two: `varlist`c''"

		eststo clear
		eststo one: corr_table_reg `varlist`c'', indvar(one)
		estadd local Ftest ""
		
		eststo att: corr_table_reg `varlist`c'', indvar(treata_pooled)
		test `varlist`c''
		local fstat : di %3.2f `r(p)'
		estadd local Ftest "`fstat'"
		
		eststo cre: corr_table_reg `varlist`c'', indvar(treatc_pooled)
		test `varlist`c''
		local fstat : di %3.2f `r(p)'
		estadd local Ftest "`fstat'"
		
		eststo bdm: corr_table_reg `varlist`c'', indvar(bdmlo)
		test `varlist`c''
		local fstat : di %3.2f `r(p)'
		estadd local Ftest "`fstat'"
		
		lab var d_charcoalbuy_`c' 			"Charcoal consumption (`c'/week)"

		esttab one att cre bdm using "`tables'/Tablea1_Balance_AttCreBDM_`c'.tex",  ///
			cells(	"b(fmt(%9.2f) pattern(0 1 1 1)) mean(pattern(1 0 0 0) fmt(%9.2f)) 			N(pattern(0 0 0 1) fmt(%9.0f))"  ///
					"se(par fmt(%9.2f) pattern(0 1 1 1)) sd(  pattern(1 0 0 0) par([ ]) fmt(%9.2f))								") ///
			scalars("Ftest Joint F-Test") /// 
			label se nonotes noobs replace nomtitles wrap collabels(none) nostar tex fragment varwidth(40) modelwidth(8) ///
			mgroups(" \shortstack{ Sample \\ Mean}  & \shortstack{Attention \\ Treatment} & \shortstack{Credit \\ Treatment}  & \shortstack{Subsidy \\ Treatment}  & N ", span erepeat(\cmidrule(lr){3-5}))

		}

}

use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear


if `AttritionTable' == 1	{

	include "${main}/Do/0. Master.do"

	preserve

		use "`dataclean'/SMS_clean_sms_replication.dta", clear
		keep if TsinceV2>=0 & CsinceV2<=16
		keep respondent_id CsinceV2
		duplicates drop // Only count Max 1 sms per SMS cycle
		
		keep respondent_id
		
		bys respondent_id: g obs = _N
		duplicates drop
		
		merge 1:1 respondent_id using "`dataclean'/Visit123_clean_replication_noPII.dta", keepusing(respondent_id)
		drop if _merge == 1 // Drop a few people who were disqualified due to nonresponse, lying to field officers, couldn't be contacted, etc. 
		
		replace obs = 0 if missing(obs) & _merge == 2
		drop _merge 
		
		tab obs, mi
	
		su obs,d
		g sms_few = (obs < `r(p50)')
		lab var sms_few "Responded to relatively few SMSes"
		
		keep respondent_id sms_few
		
		tempfile smsfew
		save `smsfew'
		
	restore 
	
	preserve

		use "`dataclean'/SMS_clean_sms_2020_replication_noPII.dta", clear
		keep respondent_id CsinceV2
		duplicates drop // Only count Max 1 sms per SMS cycle
		
		keep respondent_id
		
		bys respondent_id: g obs = _N
		duplicates drop
		
		merge 1:1 respondent_id using "`dataclean'/Visit123_analysis_replication_noPII.dta", keepusing(respondent_id Visit2)
		drop if _merge == 1 // Drop a few people who were disqualified due to nonresponse, lying to field officers, couldn't be contacted, etc. 
		
		replace obs = 0 if missing(obs) & _merge == 2
		drop _merge 
		
		
		tab obs if Visit2==1, mi
		su obs  if Visit2==1,d
		drop Visit2
		
		
		su obs,d
		g sms_few = (obs < `r(p50)')
		lab var sms_few "Responded to relatively few SMSes"
		
		keep respondent_id sms_few
		rename sms_few sms_few_2020
		
		tempfile smsfew2020
		save `smsfew2020'
		
	restore
	
	
	preserve
	
		merge 1:1 respondent_id using `smsfew' 
		drop if _merge==2
		drop _merge 
		
		merge 1:1 respondent_id using `smsfew2020' 
		drop if _merge==2
		drop _merge 
		
		foreach var of varlist treata treatc treata_pooled treatc_pooled { 
			replace `var'=v1_`var' if missing(`var')
		}
		
		keep if !missing(treata_pooled) & !missing(treatc_pooled) & !missing(bdmlo)
		
		* Define variables that we want to check for balance: 
		local varlistKSH = "b_female age b_residents b_children savings_KSH hhincome_week_KSH d_TOTALbuy_KSH d_charcoalbuy_KSH c_cookstoveprice_KSH g_invest_KSH"
		local varlistUSD0 = "bdmlo treatc_pooled treata_pooled 			b_female age b_residents b_children savings_USD hhincome_week_USD d_TOTALbuy_USD d_charcoalbuy_USD c_cookstoveprice_USD g_invest_USD"
		
		local varlistUSD1 = "bdmlo treatc_pooled treata_pooled jikokoa  b_female age b_residents b_children savings_USD hhincome_week_USD d_TOTALbuy_USD d_charcoalbuy_USD c_cookstoveprice_USD g_invest_USD"
		
		
		lab var bdmlo 			"BDM Treatment (Price <= 15 USD)"
		lab var treatc_pooled 	"Credit Treatment"
		lab var treata_pooled	"Attention Treatment"
		keep Visit2 Visit3 sms_few sms_few_2020 `varlistUSD1'
		
		* Attention Treatment and Credit Treatment - KSH
		g one = 0
		replace one = 1 if _n == 1
		local c = "USD"
		
		replace Visit2=abs(1-Visit2) // Attrited, rather than included 
		replace Visit3=abs(1-Visit3)
		
		
		eststo clear	
		eststo v1: corr_table_reg_rev `varlist`c'0', depvar(Visit2)
		test `varlist`c'0'
		local fstat : di %3.2f `r(p)'
		estadd local Ftest "`fstat'"
		su Visit2
		local smean : di %3.2f `r(mean)'
		estadd local smean "`smean'"
		
		
		eststo v2: corr_table_reg_rev `varlist`c'1', depvar(Visit3)
		test `varlist`c'1'
		local fstat : di %3.2f `r(p)'
		estadd local Ftest "`fstat'"
		su Visit3
		local smean : di %3.2f `r(mean)'
		estadd local smean "`smean'"
		
		eststo v3: corr_table_reg_rev `varlist`c'1', depvar(sms_few)
		test `varlist`c'1'
		local fstat : di %3.2f `r(p)'
		estadd local Ftest "`fstat'"
		su sms_few
		local smean : di %3.2f `r(mean)'
		estadd local smean "`smean'"
		
		eststo v4: corr_table_reg_rev `varlist`c'1', depvar(sms_few_2020)
		test `varlist`c'1'
		local fstat : di %3.2f `r(p)'
		estadd local Ftest "`fstat'"
		su sms_few_2020
		local smean : di %3.2f `r(mean)'
		estadd local smean "`smean'"
		
		esttab v1 v2 v3 v4 using "`tables'/TableA4_Attrition.tex",  ///
			cells(	"b(fmt(%9.3f) pattern(1 1 1 1 1))"  ///
					"se(par fmt(%9.3f) pattern(1 1 1 1 1)) 								") ///
			stats(Ftest smean, label("Joint F-Test p-Value" "Sample Mean")) /// 
			label nonum se nonotes varwidth(45) noobs replace nomtitles wrap collabels(none) nostar tex fragment  ///
			mgroups(" \shortstack{Attrited \\ (Visit 2)} & \shortstack{Attrited \\ (Visit 3)}  & \shortstack{Attrited \\ (SMSes-1)}  & \shortstack{Attrited \\ (SMSes-2)}", span) 
		
	tab Visit3 
	
	
restore

}

***************************************************
*************** TREATMENTS ON WTP OLS *************
if `TreatmentsWTPOLS' == 1 {

preserve

	foreach c in USD {

		encode pracTIOLIitem, g(item)
		eststo clear
		
		* FULL SAMPLE - TREATMENT GROUPS 
		eststo c: reg finwtp_`c' treatc_pooled `CONTROLS3'
		
		estadd local sample "Full"
		su finwtp_`c' if treatc_pooled==0
		estadd scalar cmean = r(mean)
	
		eststo a: reg finwtp_`c' treata_pooled `CONTROLS3'
		estadd local sample "Full"
		su finwtp_`c' if treata_pooled==0
		estadd scalar cmean = r(mean)
		
		eststo aa: reg finwtp_`c' a1 a2 `CONTROLS3'
		estadd local sample "Full"
		su finwtp_`c' if treata_pooled==0
		estadd scalar cmean = r(mean)
	
		eststo cc: reg finwtp_`c' c1 c2 `CONTROLS3'
			test c1 = c2
			local fstat : di %3.2f `r(p)'
			estadd local WMequal "`fstat'"
		estadd local sample "Full"
		estadd local scontr "Yes"
		su finwtp_`c' if treatc_pooled==0
		estadd scalar cmean = r(mean)
	
		eststo aacc: reg finwtp_`c' a1 a2 c1 c2 `CONTROLS3'
		estadd local sample "Full"
		su finwtp_`c' if treata_pooled==0 & treatc_pooled==1
		estadd scalar cmean = r(mean)
	
		eststo ac: reg finwtp_`c' treata_pooled treatc_pooled treat_both `CONTROLS3'
		estadd local sample "Full"
		su finwtp_`c' if treat_any==0
		estadd scalar cmean = r(mean)

		** SUB SAMPLES
		eststo a1a2: reg finwtp_`c' c1 c2 a2 `CONTROLS3' if treata_pooled==1
		estadd local sample "A1 \& A2"
		su finwtp_`c' if treata==1 // =A1
		estadd scalar cmean = r(mean)
		
		eststo c1c2: reg finwtp_`c' a1 a2 c2 `CONTROLS3' if treatc_pooled==1
		estadd local sample "C1 \& C2"
		su finwtp_`c' if treata==1 // =A1
		estadd scalar cmean = r(mean)
	
		
		g ac1 = treata_pooled * c1
		g ac2 = treata_pooled * c2
		 
		g a1c = a1 * treatc_pooled
		g a2c = a2 * treatc_pooled
		
		g a1c1 = a1*c1
		g a1c2 = a1*c2 
		g a2c1 = a2*c1 
		g a2c2 = a2*c2
		
		lab var treata_pooled "Attention (pooled)"
		lab var treatc_pooled "Credit (pooled)"
		lab var a1 "~~~~~ \emph{Attention (A1 only)}"
		lab var a2 "~~~~~ \emph{Attention (A2 only)}"
		lab var c1 "~~~~~ \emph{Credit (C1 only)}"
		lab var c2 "~~~~~ \emph{Credit (C2 only)}"
		lab var treat_both 		"Attention (pooled) X Credit (pooled)"
		
		lab var a1c1 "\emph{Attention (A1) X Credit (C1)}"
		lab var a1c2 "\emph{Attention (A1) X Credit (C2)}"
		lab var a2c1 "\emph{Attention (A2) X Credit (C1)}"
		lab var a2c2 "\emph{Attention (A2) X Credit (C2)}"
		
		lab var ac1 "\emph{Attention (Pooled) X Credit (C1)}"
		lab var ac2 "\emph{Attention (Pooled) X Credit (C2)}"
		lab var a1c "\emph{Attention (A1) X Credit (Pooled)}"
		lab var a2c "\emph{Attention (A2) X Credit (Pooled)}"
		
		lab var t_benefits "Attention to benefits"
		lab var t_costs "Attention to costs"
		
		lab var t_benefits_C 	"Credit (pooled) X Attention to benefits" 
		lab var t_costs_C 		"Credit (pooled) X Attention to costs" 
		
		
		* MAIN
		esttab c a ac cc aa aacc a1a2 c1c2 using "`tables'/TableB2_Treatments_WTP_Main_`c'.tex", ///
			drop(`CONTROLS3' _cons) b(2) se(2) ///
			order(treatc_pooled c1 c2 treata_pooled a1 a2 treat_both) ///
			scalars("cmean Control Mean" "sample Sample") /// 
			nomtitles obs num /// 
			nonotes label replace f booktabs ///
			nostar
		
		
	}
	
restore	
}


*******************************************************************************
************* IV OF BDM PRICE ON STOVE OWNERSHIP ON SPENDING ******************
if `IVPriceSpending' == 1 {

	eststo clear
	
	******************** 1 YEAR ENDLINE SMSES ****************
	
	use "`dataclean'/SMS_clean_sms_2020_replication_noPII.dta", clear
	merge m:1 respondent_id using "`dataclean'/Visit123_analysis_replication_noPII.dta", ///
		keepusing(jikokoa price_USD bdmlo finwtp_USD endline_date `CONTROLS' `TREATMENTS' treatc_pooled treata_pooled) 
	keep if _merge == 3 // some people dropped due to non-completion
	drop _merge
	
	* Import pre-adoption average (replace with mean if missing, for treata==0)
	merge m:1 respondent_id using "`dataclean'/SMS_clean_resp_replication.dta", keepusing(sms_amount_weekly_pre)
	drop if _merge == 2 // Some people merge == 1: didn't do SMSes last year, but have them this year 
	
	su sms_amount_weekly_pre
	replace sms_amount_weekly_pre=`r(mean)' if missing(sms_amount_weekly_pre)
	
	* Convert KSH to USD and generate IHS
	replace amount_weekly = amount_weekly/100 		// USD
	gen log_amount_weekly = log(amount_weekly)
	gen ihs_amount_weekly = asinh(amount_weekly)
	
	lab var amount_weekly 		"Weekly charcoal spending (USD)"
	lab var log_amount_weekly 	"Log of weekly charcoal spending (USD)"
	lab var ihs_amount_weekly 	"IHS of weekly charcoal spending (USD)"
	
	* Winsorize at 99th percentile:
	assert !missing(amount_weekly)
	su amount_weekly,d
	replace amount_weekly = `r(p99)' if amount_weekly > `r(p99)'
	
	*Create treatment interaction variables
		gen treat_none=(treatc_pooled==0 & treata_pooled==0)
		gen treat_conly=(treatc_pooled==1 & treata_pooled==0)
		gen treat_aonly=(treatc_pooled==0 & treata_pooled==1)
		gen treat_ac=(treatc_pooled==1 & treata_pooled==1)
	
		local t_intercepts "treat_none treat_conly treat_aonly treat_ac"
		
	foreach var of varlist treat_none treat_conly treat_aonly treat_ac {
		gen jikokoa_`var'=jikokoa*`var'
		gen price_USD_`var'=price_USD*`var'
		
		
		if "`var'"=="treat_none" {
			label var jikokoa_`var' "Control"
			label var price_USD_`var' "Control"
		}
		if "`var'"=="treat_conly" {
			label var jikokoa_`var' "Credit Only (pooled)"
			label var price_USD_`var' "Credit Only (pooled)"
		}
		if "`var'"=="treat_aonly" {
			label var jikokoa_`var' "Attention Only (pooled)"
			label var price_USD_`var' "Attention Only (pooled)"
		}
		if "`var'"=="treat_ac" {
			label var jikokoa_`var' "Credit and Attention (pooled)"
			label var price_USD_`var' "Credit and Attention (pooled)"
		}
	
	}
	
	* Prep for IV:
	keep respondent_id jikokoa jikokoa_treat* price_USD price_USD_treat* bdmlo finwtp_USD ///
		amount_weekly log_amount_weekly ihs_amount_weekly ///
		SMS_date midline_date endline_date CsinceV2 TsinceV2	sms_amount_weekly_pre `CONTROLS' `t_intercepts' `TREATMENTS' treatc_pooled
		
*   Time series dummy variables
	su CsinceV2	
	local m = 1
	forv k = `r(min)'/`r(max)' {
		g TsinceV2_`m' = (TsinceV2==`k')
		g CsinceV2_`m' = (CsinceV2==`k')
		g jikokoa_d`m' = jikokoa * CsinceV2_`m'
		g price_d`m'=price_USD * CsinceV2_`m'
		lab var jikokoa_d`m' "`m'"
		lab var price_d`m' "`m'"
		local m = `m'+1
	}	
				
	*** REGRESSIONS WITH SMS DATA ***
	eststo clear
	bys respondent_id: g n = _n
					
	eststo iv2_sms1yr: xi: ivreg2 amount_weekly finwtp_USD TsinceV2_* i.SMS_date i.treata i.treatc sms_amount_weekly_pre `CONTROLS' (jikokoa=price_USD), cluster(respondent_id)	
	eststo bytreat_iv2_sms1yr: xi: ivreg2 amount_weekly finwtp_USD TsinceV2_* i.SMS_date `t_intercepts' sms_amount_weekly_pre `CONTROLS' (jikokoa_treat*=price_USD_treat*), cluster(respondent_id)	

	estadd local Pcontr "Yes" : iv2_sms1yr bytreat_iv2_sms1yr
	estadd local Scontr "Yes" : iv2_sms1yr bytreat_iv2_sms1yr
	estadd local outcome "Spending" : iv2_sms1yr bytreat_iv2_sms1yr
	estadd local data "SMSes" : iv2_sms1yr bytreat_iv2_sms1yr
	su amount_weekly if bdmlo==0
	estadd scalar cmean = r(mean) : iv2_sms1yr bytreat_iv2_sms1yr
	
	* IV (IHS)	
	eststo ihs2_sms1yr: xi: ivreg2 ihs_amount_weekly finwtp_USD TsinceV2_* i.SMS_date i.treata i.treatc sms_amount_weekly_pre `CONTROLS' 		 (jikokoa=price_USD), cluster(respondent_id)
	eststo bytreat_ihs2_sms1yr: xi: ivreg2 ihs_amount_weekly finwtp_USD TsinceV2_* i.SMS_date `t_intercepts' sms_amount_weekly_pre `CONTROLS' 		 (jikokoa_treat*=price_USD_treat*), cluster(respondent_id)

	
	estadd local Pcontr "Yes" : ihs2_sms1yr bytreat_ihs2_sms1yr
	estadd local Scontr "Yes" : ihs2_sms1yr bytreat_ihs2_sms1yr
	estadd local outcome "Log spending" : ihs2_sms1yr bytreat_ihs2_sms1yr
	estadd local data "SMSes" : ihs2_sms1yr bytreat_ihs2_sms1yr
	su ihs_amount_weekly if bdmlo==0
	estadd scalar cmean = r(mean) : ihs2_sms1yr bytreat_ihs2_sms1yr
	
		
	
	******************** 1 MONTH SMSES ****************
	
	use "`dataclean'/SMS_clean_sms_replication.dta", clear


	* POST Adoption data only:
	drop if missing(SMS_date) | missing(midline_date)
	keep if (midline_date < SMS_date) 
	
	* Import V2 date: 
	
	preserve
		use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear
		
		keep if Visit2==1
		tab Visit2
		keep respondent_id jikokoa price_USD finwtp_USD g_char_week_v3_USD ///
			bdmlo treata* a1 a2 treatc* c1 c2 ///
			endline_date midline_date `CONTROLS' `TREATMENTS'
			
		rename g_char_week_v3_USD g_char_week_USD 
		isid respondent_id 
		sort respondent_id
		tempfile V2
		save `V2'
		
	restore

	merge m:1 respondent_id using `V2'
	* assert _merge != 1 // Only have Post data for people for whom we have Visit 2 data; some people dropped due to non compliance etc
	keep if _merge ==3
	drop _merge

	* Import pre-adoption average (replace with mean if missing, for treata==0)
	merge m:1 respondent_id using "`dataclean'/SMS_clean_resp_replication.dta", keepusing(sms_amount_weekly_pre)
	assert _merge != 1
	keep if _merge == 3
	
	su sms_amount_weekly_pre
	replace sms_amount_weekly_pre=`r(mean)' if missing(sms_amount_weekly_pre)
	
	* Convert KSH to USD and generate IHS
	replace amount_weekly = amount_weekly/100 		// USD
	gen log_amount_weekly = log(amount_weekly)
	gen ihs_amount_weekly = asinh(amount_weekly)
	
	lab var amount_weekly 		"Weekly charcoal spending (USD)"
	lab var log_amount_weekly 	"Log of weekly charcoal spending (USD)"
	lab var ihs_amount_weekly 	"IHS of weekly charcoal spending (USD)"
	
	* Winsorize at 99th percentile:
	assert !missing(amount_weekly)
	su amount_weekly,d
	replace amount_weekly = `r(p99)' if amount_weekly > `r(p99)'
	
	*Create treatment interaction variables
		gen treat_none=(treatc_pooled==0 & treata_pooled==0)
		gen treat_conly=(treatc_pooled==1 & treata_pooled==0)
		gen treat_aonly=(treatc_pooled==0 & treata_pooled==1)
		gen treat_ac=(treatc_pooled==1 & treata_pooled==1)
	
		local t_intercepts "treat_none treat_conly treat_aonly treat_ac"
		
	foreach var of varlist treat_none treat_conly treat_aonly treat_ac {
		gen jikokoa_`var'=jikokoa*`var'
		gen price_USD_`var'=price_USD*`var'
		
		
		if "`var'"=="treat_none" {
			label var jikokoa_`var' "Control"
			label var price_USD_`var' "Control"
		}
		if "`var'"=="treat_conly" {
			label var jikokoa_`var' "Credit Only (pooled)"
			label var price_USD_`var' "Credit Only (pooled)"
		}
		if "`var'"=="treat_aonly" {
			label var jikokoa_`var' "Attention Only (pooled)"
			label var price_USD_`var' "Attention Only (pooled)"
		}
		if "`var'"=="treat_ac" {
			label var jikokoa_`var' "Credit and Attention (pooled)"
			label var price_USD_`var' "Credit and Attention (pooled)"
		}
	
	}
	
	* Prep for IV:
	keep respondent_id jikokoa jikokoa_treat* price_USD price_USD_treat* bdmlo finwtp_USD ///
		amount_weekly log_amount_weekly ihs_amount_weekly ///
		SMS_date midline_date endline_date CsinceV2 TsinceV2	sms_amount_weekly_pre `CONTROLS' `TREATMENTS' `t_intercepts' treatc_pooled
	
	
	

	su CsinceV2	
	local m = 1
	forv k = `r(min)'/`r(max)' {
		g TsinceV2_`m' = (TsinceV2==`k')
		g CsinceV2_`m' = (CsinceV2==`k')
		g jikokoa_d`m' = jikokoa * CsinceV2_`m'
		g price_d`m'=price_USD * CsinceV2_`m'
		lab var jikokoa_d`m' "`m'"
		lab var price_d`m' "`m'"
		local m = `m'+1
	}	
				
	*** REGRESSIONS WITH SMS DATA ***
	
	bys respondent_id: g n = _n
	
	* OLS:
	eststo ols1: reg amount_weekly jikokoa finwtp_USD price_USD `CONTROLS', cluster(respondent_id)
	eststo bytreat_ols1: reg amount_weekly jikokoa_treat* `t_intercepts' finwtp_USD price_USD `CONTROLS', cluster(respondent_id)
	estadd local Pcontr "No" : ols1 bytreat_ols1
	estadd local Scontr "Yes" : ols1 bytreat_ols1
	estadd local outcome "OLS" : ols1 bytreat_ols1
	estadd local data "SMSes" : ols1 bytreat_ols1
	su amount_weekly if jikokoa==0
	estadd scalar cmean = r(mean) : ols1 bytreat_ols1
		
	eststo iv2: xi: ivreg2 amount_weekly finwtp_USD TsinceV2_* i.SMS_date i.treata i.treatc sms_amount_weekly_pre `CONTROLS' (jikokoa=price_USD), cluster(respondent_id)
	eststo bytreat_iv2: xi: ivreg2 amount_weekly finwtp_USD TsinceV2_* i.SMS_date `t_intercepts' sms_amount_weekly_pre `CONTROLS' (jikokoa_treat*=price_USD_treat*), cluster(respondent_id)

	estadd local Pcontr "Yes" : iv2 bytreat_iv2
	estadd local Scontr "Yes" : iv2 bytreat_iv2
	estadd local outcome "Spending" : iv2 bytreat_iv2
	estadd local data "SMSes" : iv2 bytreat_iv2
	su amount_weekly if bdmlo==0
	estadd scalar cmean = r(mean) : iv2 bytreat_iv2
	
	
	
	eststo bytreat_ihs2: xi: ivreg2 ihs_amount_weekly finwtp_USD TsinceV2_* i.SMS_date `t_intercepts' sms_amount_weekly_pre `CONTROLS' 		 (jikokoa_treat*=price_USD_treat*), cluster(respondent_id)
	
	eststo ihs2: xi: ivreg2 ihs_amount_weekly finwtp_USD TsinceV2_* i.SMS_date i.treata i.treatc sms_amount_weekly_pre `CONTROLS' 		 (jikokoa=price_USD), cluster(respondent_id)
	
	estadd local Pcontr "Yes" : ihs2 bytreat_ihs2
	estadd local Scontr "Yes" : ihs2 bytreat_ihs2
	estadd local outcome "Log spending" : ihs2 bytreat_ihs2
	estadd local data "SMSes" : ihs2 bytreat_ihs2
	su ihs_amount_weekly if bdmlo==0
	estadd scalar cmean = r(mean) : ihs2 bytreat_ihs2
	*/
	label var price_USD 	"BDM Price (USD)"
	label var jikokoa 		"Bought Cookstove (=1)"
	label var finwtp_USD 	"WTP (USD)"
	
	
	* Unconditional Local Quantile TE using Frolich and Melly 2008 Note: Method requires controls entered by type and needs binary instrument
	if `ivqte'==1{
		xi : bootstrap, reps(1000) cluster(respondent_id) : ivqte ihs_amount_weekly (jikokoa=bdmlo), quantiles(0.01(0.01)0.99) continuous(finwtp_USD sms_amount_weekly_pre d_charcoalbuy_KSH savings_KSH b_incomeself_KSH b_residents b_children) dummy(TsinceV2_* i.SMS_date i.treata i.treatc RiskAverse CreditConstrained)
		matrix QTE_B=e(b)
		matrix QTE_se=e(se)
		
		version 15.0 
		putexcel set "`datamed'/QTE.xlsx", replace
		putexcel A1=matrix(QTE_B)
		putexcel A2=matrix(QTE_se)
		putexcel close
		
		
	}
	
	version 12.0 
	
	*** Import Endline Data ***
	use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear
	isid respondent_id
	cou
	keep if Visit3==1
	
	foreach var of varlist log_bucket_kg_st finwtp_USD treata treatc jikokoa price_USD `CONTROLS' {
		di "`var' : "
		cou if missing(`var')
	}

		*Create treatment interaction variables
		gen treat_none=(treatc_pooled==0 & treata_pooled==0)
		gen treat_conly=(treatc_pooled==1 & treata_pooled==0)
		gen treat_aonly=(treatc_pooled==0 & treata_pooled==1)
		gen treat_ac=(treatc_pooled==1 & treata_pooled==1)
	
		local t_intercepts "treat_none treat_conly treat_aonly treat_ac"
		
	foreach var of varlist treat_none treat_conly treat_aonly treat_ac {
		gen jikokoa_`var'=jikokoa*`var'
		gen price_USD_`var'=price_USD*`var'
		
		
		if "`var'"=="treat_none" {
			label var jikokoa_`var' "Control"
			label var price_USD_`var' "Control"
		}
		if "`var'"=="treat_conly" {
			label var jikokoa_`var' "Credit Only (pooled)"
			label var price_USD_`var' "Credit Only (pooled)"
		}
		if "`var'"=="treat_aonly" {
			label var jikokoa_`var' "Attention Only (pooled)"
			label var price_USD_`var' "Attention Only (pooled)"
		}
		if "`var'"=="treat_ac" {
			label var jikokoa_`var' "Credit and Attention (pooled)"
			label var price_USD_`var' "Credit and Attention (pooled)"
		}
	
	}
	
	
	* (fs) First stage
	eststo fs2: reg jikokoa price_USD finwtp_USD i.treata i.treatc `CONTROLS', cluster(respondent_id)
	estadd local Pcontr "Yes"
	estadd local Scontr "Yes"
	estadd local outcome "First Stage"
	estadd local data "Midline"
	local fstat : di %3.2f `e(F)'
	estadd local Fstat "`fstat'"
	
	* (3) Endline Charcoal
	rename g_char_week_v3_USD g_char_week_USD 
	su g_char_week_USD, detail
	replace g_char_week_USD = `r(p99)' if g_char_week_USD>`r(p99)' & !missing(g_char_week_USD)
	g log_g_char_week = log(g_char_week_USD)
	g ihs_g_char_week = asinh(g_char_week_USD)
	
	
	eststo buckIHS: xi: ivreg2 ihs_bucket_kg_st finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD) 
	eststo bytreat_buckIHS: xi: ivreg2 ihs_bucket_kg_st finwtp_USD `t_intercepts' `CONTROLS' (jikokoa_treat*=price_USD_treat*) 
	estadd local Pcontr "Yes" : buckIHS bytreat_buckIHS
	estadd local Scontr "Yes" : buckIHS bytreat_buckIHS
	estadd local outcome "IHS KG" : buckIHS bytreat_buckIHS
	estadd local data "Buckets" : buckIHS bytreat_buckIHS
	su ihs_bucket_kg_st if bdmlo==0
	estadd scalar cmean = r(mean) : buckIHS bytreat_buckIHS
	
	
	*** EXPORT RESULTS *** 

	label var price_USD 	"BDM Price (USD)"
	label var jikokoa 		"Bought Cookstove (=1)"
	label var finwtp_USD 	"WTP (USD)"

	*** PAPER *** 
	esttab ols1 fs2 iv2 ihs2 buckIHS iv2_sms1yr ihs2_sms1yr using "`tables'/Table2_IVcharcoal_PAPER.tex", ///
				keep(price_USD finwtp_USD jikokoa) b(2) se(2) ///
				order(price_USD finwtp_USD jikokoa) ///
				scalars("cmean Control Mean" "Scontr Socioeconomic controls" "data Data Source") /// 
				mgroups("\shortstack{OLS}" "\shortstack{First Stage}" "\shortstack{IV Estimate \\ (1-month endline)}" "\shortstack{IV Estimate \\ (1-year endline)}"  , pattern(1 1 1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(} ) span  erepeat(\cmidrule(lr){@span})) ///
				mtitles("USD" "Bought Stove" "USD" "IHS(USD)" "IHS(KG)" "USD" "IHS(USD)" ) ///
				nonotes label replace  f booktabs ///
				nostar num
	
	esttab bytreat_ols1 bytreat_iv2 bytreat_ihs2 bytreat_buckIHS bytreat_iv2_sms1yr bytreat_ihs2_sms1yr using "`tables'/TableA2_IVcharcoal_bytreat_PAPER.tex", ///
		keep(jikokoa_treat_*) b(2) se(2) varlabels(jikokoa_treat_none "\addlinespace Control" jikokoa_treat_conly "\addlinespace Credit Only (pooled)" jikokoa_treat_aonly "\addlinespace Attention Only (pooled)" jikokoa_treat_ac "\addlinespace Credit and Attention (pooled)") ///
		scalars("cmean Control Mean" "Scontr Socioeconomic controls" "data Data Source") /// 
		mgroups("\shortstack{OLS}" "\shortstack{IV Estimate \\ (1-month endline)}" "\shortstack{IV Estimate \\ (1-year endline)}"  , pattern(1 1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(} ) span erepeat(\cmidrule(lr){@span})) ///
		mtitles("USD" "USD" "IHS(USD)" "IHS(KG)" "USD" "IHS(USD)" ) ///
		nonotes label replace  f booktabs nostar num					

}

* IV of BDM PRICE on HEALTH
if `IVotherOutcomes' == 1 {
	
	local hCONTROLS = subinstr("`CONTROLS'", "v1_beliefs_annual_mean v1_beliefs_annual_sd", " ", .) 

	
		**********************
		* 1-YEAR ENDLINE 
	eststo clear 
	
	// Add the new data file Visit123_E1_analysis_replication.dta
	use "`dataclean'/Visit123_E1_analysis_replication.dta", clear
	
	// Remove respondents if they have not been part of Visit 2 or Endline1
	drop if Visit2 == 0
	drop if Endline1 == 0

	// Clean health variables
		
		// Standardize health beliefs
		su health_beliefs_v1, d
		replace health_beliefs_v1 = (health_beliefs_v1 - `r(mean)')/`r(sd)'
			
		// Create health index
		egen el1_health_index = rowmean(	el1_d2_cough_resp 	el1_d2_breath_resp 	///
								el1_d2_cough_child 	el1_d2_breath_child )							
		su el1_health_index if jikokoa==0
		replace el1_health_index = (el1_health_index-`r(mean)')/`r(sd)'
		
		lab var el1_health_index 			"Index of Health (Endline)"
		
		
		// Create variable for continued usage of old jikokoa
		gen continued_use = (el1_g_c5_3_usage >= 1 & el1_g_c5_3_usage<=3)
		
		lab var continued_use				"Continued Use of Old Jikokoa"
		label var continued_use 	"Continued old stove use (=1)"
	
		// Create health belief indicators
		gen health_beliefs_high = 0 if !missing(health_beliefs_v1)
		sum health_beliefs_v1, d
		replace health_beliefs_high = 1 if health_beliefs_v1 >= r(mean) & !missing(health_beliefs_v1)
	
	// IMPACT ON HEALTH OUTCOMES

		// IV
		
		local var = "el1_health_index"
		
		eststo healthLT1: xi: ivreg2 `var' 					finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
		estadd local sample "All"
		su `var' if jikokoa==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
		estadd local data "Endline"
		

		
		// IV 
		// continued use of old jikokoa instead of WTP
		
		eststo healthLT2: xi: ivreg2 `var' continued_use 	finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
		estadd local sample "All"
		su `var' if jikokoa==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
		estadd local data "Endline"

	
		
		**********************
		* 1-MONTH ENDLINE 
		
		use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear
	
	keep if Visit3==1

	* Remove missing: 
	su b_incomeself_KSH
	replace b_incomeself_KSH=`r(mean)' if missing(b_incomeself_KSH)

	*** Beliefs about Health on WTP *** 
	su health_beliefs_v1 if jikokoa==0, detail
	replace health_beliefs_v1 = (health_beliefs_v1 - `r(mean)')/`r(sd)'
		
	* Dollar value: 
	replace v1_beliefs_annual_mean =  v1_beliefs_annual_mean/100
	replace v2_beliefs_annual_mean =  v2_beliefs_annual_mean/100
	
	g interaction = health_beliefs_v1  * b_children 
	
	
	* Standardize the beliefs so these are comparable
	su v1_beliefs_annual_mean if jikokoa==0
	g st_v1_beliefs_annual_mean = (v1_beliefs_annual_mean-`r(mean)')/`r(sd)'
	
	su v2_beliefs_annual_mean if jikokoa==0
	g st_v2_beliefs_annual_mean = (v2_beliefs_annual_mean-`r(mean)')/`r(sd)'
	
	su st_* if jikokoa==0
	
	
	eststo healthWTP: reg finwtp_USD health_beliefs_v1 b_children interaction treat*pooled treat_both `CONTROLS' v2_beliefs_annual_mean st_v2_beliefs_annual_mean 
	
	
	* estadd local sample "C1 \& C2"
	su finwtp_USD if jikokoa==0
	estadd scalar cmean = r(mean)
	estadd local Scontr "Yes"
		
	*** Impact of stove on time use, network, health *** 
	su d1_use_minutes_daily, d
	replace d1_use_minutes_daily = `r(p99)' if d1_use_minutes_daily > `r(p99)' & !missing(d1_use_minutes_daily)
	
	local var = "d1_use_minutes_daily"
	eststo time: xi: ivreg2 `var' finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
	estadd local sample "All"
	su `var'  if jikokoa==0
	estadd scalar cmean = r(mean)
	estadd local Scontr "Yes"

	local var = "g_c3_TOTAL"
	eststo network: xi: ivreg2 `var' finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
	estadd local sample "All"
	su `var' if jikokoa==0
	estadd scalar cmean = r(mean)
	estadd local Scontr "Yes"
	
	su health_index_v3 if jikokoa==0
	replace health_index_v3 = (health_index_v3-`r(mean)')/`r(sd)'
	
	local var = "health_index_v3"
	eststo health1: xi: ivreg2 `var' finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
	estadd local sample "All"
	su `var' if jikokoa==0
	estadd scalar cmean = r(mean)
	estadd local Scontr "Yes"

	g continued_use = (g_c5_3_usage >= 1 & g_c5_3_usage<=3)
		
	local var = "health_index_v3"
	
	eststo health2: xi: ivreg2 `var' continued_use 				finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
	estadd local sample "All"
	su `var' if jikokoa==0
	estadd scalar cmean = r(mean)
	estadd local Scontr "Yes"

	su bucket_kg_st, detail
	replace bucket_kg_st = `r(mean)' if missing(bucket_kg_st)
	eststo health3: xi: ivreg2 `var' continued_use bucket_kg_st finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
	estadd local sample "All"
	su `var' if jikokoa==0
	estadd scalar cmean = r(mean)
	estadd local Scontr "Yes"
	
	********************1 year endline
	
	
		
	*** Export *** 
	
	lab var continued_use 				"Continued old stove use (=1)"
	lab var health_beliefs_v1 			"Health beliefs (index)" 
	lab var v2_beliefs_annual_mean 		"Savings beliefs (USD)" 
	lab var st_v2_beliefs_annual_mean 	"Savings beliefs (index)" 
	lab var bucket_kg_st 				"Charcoal usage (KG/month)"
	


	* PAPER 
	
	esttab healthWTP time network health1 health2 health3 healthLT1 healthLT2 using "`tables'/Table4_IV_other_outcomes.tex", ///
				keep(health_beliefs_v1 v2_beliefs_annual_mean jikokoa continued_use bucket_kg_st ) b(2) se(2) ///
				order(health_beliefs_v1 v2_beliefs_annual_mean jikokoa continued_use bucket_kg_st ) ///
				scalars("cmean Control Mean" "Scontr Socioeconomic controls") /// 
				mgroups(	"\shortstack{WTP \\ (USD)}" ///
							"\shortstack{Minutes \\ cooking per day }" ///
							"\shortstack{Adoptions \\ in network}"  ///
							"\shortstack{Health Symptoms Index \\ (1-month follow-up)}" ///
							"\shortstack{Health Symptoms Index \\ (1-year follow-up)}" , ///
					pattern(1 1 1 1 0 0 1 0 ) prefix(\multicolumn{@span}{c}{) suffix(} ) span   erepeat(\cmidrule(lr){@span})) ///
				nomtitles ///
				nonotes label replace  f booktabs ///
				nostar num
	
	
}		

	
* IV of BDM PRICE on Endline Survey Outcomes
if `IV1YRendlineOutcomes' == 1 {
	
	// Add the new data file Visit123_E1_analysis_replication.dta
	use "`dataclean'/Visit123_E1_analysis_replication.dta", clear
	
	// Remove respondents if they have not been part of Visit 2 or Endline1
	drop if Visit2 == 0
	drop if Endline1 == 0

	
	// Clean savings variables
		
		// If the respondent does not have a mobile banking account, then they have 0 mobile savings
		replace el1_g2a = 0 if el1_g1a == 0
		
		// If the respondent is not a SACCO, merry-go-round, or ROSCA participant, then they have made 0 contributions
		replace el1_g2b = 0 if el1_g1b_96 == 1
		
		// If the respondent is not a SACCO, merry-go-round, or ROSCA participant, then they receive 0 contributions
		replace el1_g2b2 = 0 if el1_g1b_96 == 1
		
		// If the respondent does not have a formal banking account, then they have 0 formal savings 
		replace el1_g2c = 0 if el1_g1c == 0

		// Top-coding of savings variables
		foreach var of varlist ///
			el1_g2a el1_g2b ///
			el1_g2b2 el1_g2c {
			foreach n in -88 -99 {
				replace `var' = . if `var' == `n'
			}
			su `var', d
			replace `var' = `r(p99)' if `var' > `r(p99)' & !missing(`var')
			tab `var', mi
		}
		
		// Create a variable for all available funds
		gen el1_total_savings = el1_g2a + el1_g2c + el1_g2b2 if (!missing(el1_g2a) & !missing(el1_g2c) & !missing(el1_g2b2))
		lab var el1_total_savings           "Total Savings (USD)"
		
		// Top-coding of total savings
		su el1_total_savings, d
		replace el1_total_savings = `r(p99)' if el1_total_savings > `r(p99)' & !missing(el1_total_savings)
	
		// Create savings variables in USD and with IHS transformation
		gen el1_g2a_USD = el1_g2a / 100 if !missing(el1_g2a)
		lab var el1_g2a_USD					"Mobile Banking Account Savings (USD)"
		
		gen el1_g2c_USD = el1_g2c / 100 if !missing(el1_g2c)
		lab var el1_g2c_USD 				"Formal Banking Account Savings (USD)"
		
		gen el1_g2b2_USD = el1_g2b2 / 100 if !missing(el1_g2b2)
		lab var el1_g2b2_USD 				"SACCO Available Withdrawal (USD)"
		
		gen el1_total_savings_USD = el1_total_savings /100 if !missing(el1_total_savings)
		lab var el1_total_savings_USD 		"Total Savings (USD)"

		* Indicators 
		gen el1_g2a_USD_pos = (el1_g2a_USD>0) if !missing(el1_g2a_USD)
		lab var el1_g2a_USD_pos				"Has Mobile Savings (=1)"
		
		gen el1_g2c_USD_pos = (el1_g2c_USD>0) if !missing(el1_g2c_USD) 
		lab var el1_g2c_USD_pos 			"Has Formal Savings (=1)"
		
		gen el1_g2b2_USD_pos= (el1_g2b2_USD>0) if !missing(el1_g2b2_USD) 
		lab var el1_g2b2_USD_pos			"Has SACCO (=1)"
				
		gen el1_total_savings_USD_pos = (el1_total_savings_USD>0) if !missing(el1_total_savings_USD)
		lab var el1_total_savings_USD_pos 	"Has Savings (=1)"
		
		* IHS conditional on >0 only:
		gen el1_g2a_USD_log = log(el1_g2a_USD) if !missing(el1_g2a_USD) & el1_g2a_USD>0
		lab var el1_g2a_USD_log				"Log(Mobile Savings)"
		
		gen el1_g2c_USD_log = log(el1_g2c_USD) if !missing(el1_g2c_USD) & el1_g2c_USD>0
		lab var el1_g2c_USD_log 			"Log(Formal Savings)"
		
		gen el1_g2b2_USD_log = log(el1_g2b2_USD) if !missing(el1_g2b2_USD) & el1_g2b2_USD>0
		lab var el1_g2b2_USD_log			"Log(SACCO Payout)"
				
		gen el1_total_savings_USD_log = log(el1_total_savings_USD) if !missing(el1_total_savings_USD) & el1_total_savings_USD>0
		lab var el1_total_savings_USD_log 	"Log(Total Savings)"

		
	// IMPACT ON SAVINGS
	
		// IV
		// mobile savings USD
		
		local var = "el1_g2a_USD"
		
		eststo savings1: xi: ivreg2 `var' finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
		su `var' if bdmlo==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
		estadd local data "Endline"
		
		local var = "el1_g2a_USD_pos"
		
		eststo savings2: xi: ivreg2 `var' finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
		su `var' if bdmlo==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
		estadd local data "Endline"
		
		// IV
		// mobile savings IHS
		
		local var = "el1_g2a_USD_log"
		
		eststo savings3: xi: ivreg2 `var' finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
		su `var' if bdmlo==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
		estadd local data "Endline"
		
		// IV 
		// formal savings USD
		
		local var = "el1_g2c_USD"
		
		eststo savings4: xi: ivreg2 `var' finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
		su `var' if bdmlo==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
		estadd local data "Endline"
		
		local var = "el1_g2c_USD_pos"
		
		eststo savings5: xi: ivreg2 `var' finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
		su `var' if bdmlo==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
		estadd local data "Endline"
		
		// IV 
		// formal savings IHS
		
		local var = "el1_g2c_USD_log"
		
		eststo savings6: xi: ivreg2 `var' finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
		su `var' if bdmlo==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
		estadd local data "Endline"
		
		// IV
		// SACCO withdrawal USD
		
		local var = "el1_g2b2_USD"
		
		eststo savings7: xi: ivreg2 `var' finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
		su `var' if bdmlo==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
		estadd local data "Endline"	
		
		local var = "el1_g2b2_USD_pos"
		
		eststo savings8: xi: ivreg2 `var' finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
		su `var' if bdmlo==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
		estadd local data "Endline"	
		
		// IV
		// SACCO withdrawal IHS
		
		local var = "el1_g2b2_USD_log"
		
		eststo savings9: xi: ivreg2 `var' finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
		su `var' if bdmlo==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
		estadd local data "Endline"	
		
		// IV 
		// total available savings (mobile, formal, SACCO, etc.) USD
		
		local var = "el1_total_savings_USD"
		
		eststo savings10: xi: ivreg2 `var' finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
		su `var' if bdmlo==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
		estadd local data "Endline"
		
		local var = "el1_total_savings_USD_pos"
		
		eststo savings11: xi: ivreg2 `var' finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
		su `var' if bdmlo==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
		estadd local data "Endline"
		
		// IV 
		// total available savings (mobile, formal, SACCO, etc.) IHS
		
		local var = "el1_total_savings_USD_log"
		
		eststo savings12: xi: ivreg2 `var' finwtp_USD i.treata i.treatc `CONTROLS' (jikokoa=price_USD)
		su `var' if bdmlo==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
		estadd local data "Endline"

	// EXPORT RESULTS 
	
	
	label var price_USD			"BDM Price (USD)"
	label var jikokoa 			"Bought Cookstove (=1)"
	label var finwtp_USD 		"WTP (USD)"
	

	// PAPER 
		
	esttab savings1 savings2 savings3 savings4 savings5 savings6  ///
			using "`tables'/TableB1_IVsavings_ENDLINE_a.tex", ///
				keep(finwtp_USD jikokoa) b(2) se(2) ///
				order(finwtp_USD jikokoa) ///
				scalars("cmean Control Mean" "Scontr Socioeconomic controls") ///
				mgroups("\shortstack{Mobile Savings}" "\shortstack{Formal Savings}", ///
					pattern (1 0 0 1 0 0 ) prefix(\multicolumn{@span}{c}{) suffix(} ) span erepeat(\cmidrule(lr){@span})) ///
				mtitles("USD" "$>$0 (=1)" "Log(USD)" "USD" "$>$0 (=1)" "Log(USD)") ///
				nonotes label replace f booktabs ///
				nostar num

				
	esttab savings7 savings8 savings9 savings10 savings11 savings12 ///
			using "`tables'/TableB1_IVsavings_ENDLINE_b.tex", ///
				keep(finwtp_USD jikokoa) b(2) se(2) ///
				order(finwtp_USD jikokoa) ///
				scalars("cmean Control Mean" "Scontr Socioeconomic controls") ///
				mgroups("\shortstack{SACCO}" "\shortstack{Total Savings}", ///
					pattern (1 0 0 1 0 0 ) prefix(\multicolumn{@span}{c}{) suffix(} ) span erepeat(\cmidrule(lr){@span})) ///
				mtitles("USD" "$>$0 (=1)" "Log(USD)" "USD" "$>$0 (=1)" "Log(USD)") ///
				nonotes label replace f booktabs ///
				nostar num

				


		
}

***************************************************
*************** ATTENTION TREATMENT ON BELIEFS *************

if `AttentionBeliefs' == 1 {

use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear
	
	foreach c in USD {
	
		keep `CONTROLS' treata_pooled a1 a2 c1 c2 finwtp_`c' v*_beliefs_annual_mean price_USD
		
		su v1_beliefs_annual_mean if treata_pooled==0
		g v1_beliefs_annual_st = (v1_beliefs_annual_mean - `r(mean)') / `r(sd)'
		
		su v2_beliefs_annual_mean if treata_pooled==0
		g v2_beliefs_annual_st = (v2_beliefs_annual_mean - `r(mean)') / `r(sd)'
		
		eststo clear
		
		eststo BA : reg v2_beliefs_annual_st v1_beliefs_annual_st 	treata_pooled 	price_USD c1 c2 d_charcoalbuy_KSH spend50 savings_KSH b_incomeself_KSH RiskAverse CreditConstrained b_residents b_children d_jikokoalast_years
			estadd local sample "Full"
			su v2_beliefs_annual_st if treata_pooled==0
			estadd scalar cmean = r(mean)
		
		eststo BAA: reg v2_beliefs_annual_st v1_beliefs_annual_st 	a1 a2 			price_USD c1 c2 d_charcoalbuy_KSH spend50 savings_KSH b_incomeself_KSH RiskAverse CreditConstrained b_residents b_children d_jikokoalast_years
			estadd local sample "Full"
			su v2_beliefs_annual_st if treata_pooled==0
			estadd scalar cmean = r(mean)
		
		lab var v1_beliefs_annual_st	 "Baseline beliefs" 
		lab var treata_pooled "Attention (pooled)"
		lab var a1 "~~~~~ \emph{Attention (A1 only)}"
		lab var a2 "~~~~~ \emph{Attention (A2 only)}"
		
		*** MAIN PAPER 
		esttab BA BAA using "`tables'/TableA7_Treatments_Beliefs_`c'.tex", ///
			keep(v1_beliefs_annual_st treata_pooled a1 a2 ) b(2) se(2) ///
			order(v1_beliefs_annual_st treata_pooled a1 a2 ) ///
			scalars("cmean Control Mean") /// 
			nomtitles obs num /// 
			mgroups(		"\shortstack{Endline \\ Beliefs }"  , ///
					pattern(1 0) prefix(\multicolumn{@span}{c}{) suffix(} ) span) ///
			nonotes label replace f booktabs ///
			nostar

			
		
	}
	
clear

}
	
			
*******************************************************************************
************* MECHANISMS ******************

if `Mechanisms' == 1 {

		use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear
		
		encode pracTIOLIitem, g(item)
		
		keep if Visit2==1
		local c = "USD"

		* Replace missings (to maintain sample size when including controls in regression):
		foreach var of varlist b_incomeself_* {
			su `var', detail
			replace `var' = `r(mean)' if missing(`var')
		}		

		foreach var of varlist `CONTROLS3' {
			di "`var' : "
			cou if missing(`var')
		}
		
		eststo clear
		
		* FULL SAMPLE
		eststo caFI: reg finwtp_`c' treatc_pooled t_benefits t_costs `CONTROLS3' 
		estadd local sample "Full"
		su finwtp_`c' if treatc_pooled==0 & treata_pooled==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
			
			estadd local CostsC ""
			estadd local CostsCeq "" 
			estadd local Ftest ""
			estadd local CBequal "" 
			
	
		
		* CREDIT INTERACTION
		* Full sample:
		eststo cXaF: reg finwtp_`c' treatc_pooled t_benefits t_benefits_C t_costs t_costs_C `CONTROLS3'
		estadd local sample "Full"
		su finwtp_`c' if treatc_pooled==0 & treata_pooled==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
		
			*reg, coefl
			test t_benefits = t_costs
			local fstat : di %3.2f `r(p)'
			estadd local CBequal "`fstat'"
			
			test t_costs = t_costs_C
			local fstat : di %3.2f `r(p)'
			estadd local CostsCeq "`fstat'"
			
			test t_costs + t_costs_C = 0 
			local fstat : di %3.2f `r(p)'
			estadd local CostsC "`fstat'"
			
			test t_costs t_costs_C
			local fstat : di %3.2f `r(p)'
			estadd local Ftest "`fstat'"
		

		
		* TRIPLE INTERACTION  
		eststo cXaXpb: reg finwtp_`c' treatc_pooled t_benefits t_benefits_C t_costs t_costs_C PB CreditXPB  CreditXPBXcosts `CONTROLS3'
		estadd local sample "Full"
		su finwtp_`c' if treatc_pooled==0 & treata_pooled==0 & PB==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
		
		* CREDIT ATTENTION & PB
		eststo cXaPB0: reg finwtp_`c' treatc_pooled t_benefits t_benefits_C t_costs t_costs_C `CONTROLS3' if PB==0
		estadd local sample "TI=0"
		su finwtp_`c' if treatc_pooled==0 & treata_pooled==0 & PB==0
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
		
			test t_benefits = t_costs
			local fstat : di %3.2f `r(p)'
			estadd local CBequal "`fstat'"
			
			test t_costs = t_costs_C
			local fstat : di %3.2f `r(p)'
			estadd local CostsCeq "`fstat'"
			
			test t_costs + t_costs_C = 0 
			local fstat : di %3.2f `r(p)'
			estadd local CostsC "`fstat'"
			
			test t_costs t_costs_C
			local fstat : di %3.2f `r(p)'
			estadd local Ftest "`fstat'"
		
		eststo cXaPB1: reg finwtp_`c' treatc_pooled t_benefits t_benefits_C t_costs t_costs_C `CONTROLS3' if PB==1
		estadd local sample "TI=1"
		su finwtp_`c' if treatc_pooled==0 & treata_pooled==0 & PB==1
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
	
			test t_benefits = t_costs
			local fstat : di %3.2f `r(p)'
			estadd local CBequal "`fstat'"
			
			test t_costs = t_costs_C
			local fstat : di %3.2f `r(p)'
			estadd local CostsCeq "`fstat'"
			
			test t_costs + t_costs_C = 0 
			local fstat : di %3.2f `r(p)'
			estadd local CostsC "`fstat'"
			
			test t_costs t_costs_C
			local fstat : di %3.2f `r(p)'
			estadd local Ftest "`fstat'"
		
		
		* RISK AVERSION
		eststo RA0: reg finwtp_`c' t_benefits t_costs treatc_pooled `CONTROLS3' 
		estadd local sample "All"
		su finwtp_`c' if treatc_pooled==0 & treata_pooled==0 
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"
	
		eststo RA1: reg finwtp_`c' t_benefits t_costs treatc_pooled RAxC `CONTROLS3' 
		estadd local sample "All"
		su finwtp_`c' if treatc_pooled==0 & treata_pooled==0 
		estadd scalar cmean = r(mean)
		estadd local Scontr "Yes"

			
		lab var treatc_pooled "Credit"
		lab var a1 			"Attention to Benefits"
		lab var a2 			"Attention to Benefits-Costs"
		lab var CxA0 		"Credit X A Control"
		lab var CxA1 		"Credit X A (Benefits)"
		lab var CxA2 		"Credit X A (Benefits, Costs)"
		lab var PB			"Time inconsistent"
		lab var CreditXPB	"Credit X Time inconsistent"
		lab var RiskAverse	"RA (Risk Aversion)" 
		lab var RAxC		"Risk aversion X Credit"
		lab var RAxA1		"RA X Attention to Benefits"
		lab var RAxA2		"RA X Attention to Benefits, Costs"
		
			
		lab var treatc_pooled "Credit"
		lab var a0			"Ignore Benefits, Costs"
		lab var a1 			"Ignore Costs"
		
		lab var CxA0 		"Credit X Ignore Benefits, Costs"
		lab var CxA1 		"Credit X Ignore Costs"
		
		lab var PB			"Time inconsistent"
		lab var CreditXPB	"Time inconsistent X Credit"
		
		
		lab var RiskAverse	"Risk aversion" 
		
		lab var t_benefits_C 	"Attention to benefits X Credit"
		
		lab var RAxt_benefits 	"Risk aversion X Attention to benefits"
		lab var RAxt_costs		"Risk aversion X Attention to costs"
		
		lab var c1 "Credit (Weekly)"
		lab var c2 "Credit (Monthly)"

		lab var d_jikokoalast_years "Belief about stove durability (years)"
		
		lab var t_benefits 		"Attention to benefits" //  $(\beta^+)$
		lab var t_costs 		"Attention to costs"
		lab var t_costs_C 		"Attention to costs X Credit"

		lab var CreditXPBXcosts	"Attention to costs X Time inconsistent X Credit"

		

		*** PAPER (COMBINED)*** 
		esttab caFI cXaF cXaPB0 cXaPB1 cXaXpb using "`tables'/Table5_Credit_PB_`c'_main_newcomb.tex", ///
			keep(  treat*pooled t_benefits t_costs t_benefits_C t_benefits* t_costs_C t_costs* PB CreditXPB CreditXPBXcosts) ///
			order( treat*pooled t_benefits t_costs t_benefits_C t_benefits* t_costs_C t_costs* PB CreditXPB CreditXPBXcosts) ///
			b(2) se(2) ///
			scalars("cmean Control Mean" "sample Sample") /// 
			nomtitles obs num /// 
			nonotes label replace f booktabs ///
			nostar		
		
	
		esttab RA0 RA1 using "`tables'/Table6_Mechanisms_RA_`c'.tex", ///
			keep(  treat*pooled RiskAverse RAxC d_jikokoalast_years) ///
			order( treat*pooled RiskAverse RAxC d_jikokoalast_years) ///
			b(2) se(2) scalars("cmean Control Mean" "sample Sample") /// 
			nomtitles obs num /// 
			nonotes label replace f booktabs ///
			nostar		

}

* Table A5: robustness

	clear all
	include "${main}/Do/0. Master.do"

	* What is the breakdown of future bias by treatment?

	use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear
	
	encode pracTIOLIitem, g(item)

	gen TI_type=-1*(tasks_change_3<0)+1*(tasks_change_3>0) if !missing(tasks_change_3)
	tab TI_type


	egen all_treat=group(treata treatc)

	label def all_treat_lab 1 "C0 A0" 2 "C1 A0" 3 "C2 A0" 4 "C0 A1" 5 "C1 A1" 6 "C2 A1" 7 "C0 A2" 8 "C1 A2" 9 "C2 A2"

	label val all_treat all_treat_lab
	label var all_treat "Treatment Cells"


	* What are the effects of credit after dealing with default different ways?

			*Deflating by default rate
			g finwtp_recabUSD = finwtp_USD*.72 if treatc_pooled==1
			replace finwtp_recabUSD=finwtp_USD if treatc_pooled==0
			
			merge 1:1 respondent_id using "`raw_confidential'/Payments_Data_Total_replication.dta", gen(_paymerge)
		
			gen finwtp_less_default=finwtp_KSH
			replace finwtp_less_default=TOTALPAID if !missing(TOTALPAID) & TOTALPAID<price_KSH
			replace finwtp_less_default=finwtp_less_default/100
			
			
			gen finwtp_nodefaulters=finwtp_KSH
			replace finwtp_nodefaulters=. if !missing(TOTALPAID) & fracpaid!=1
			assert finwtp_nodefaulters==finwtp_KSH if treatc_pooled==0
			replace finwtp_nodefaulters=finwtp_nodefaulters/100 
			
			
			gen TOTALPAID_USD=TOTALPAID/100 if !missing(TOTALPAID)
			replace TOTALPAID_USD=price_USD if treatc_pooled==0 & jikokoa==1
			replace TOTALPAID_USD=0 if jikokoa==0

			foreach var of varlist finwtp_USD TOTALPAID_USD finwtp_less_default finwtp_recabUSD finwtp_nodefaulters {
				eststo drob_`var': reg `var' treatc_pooled `CONTROLS3'
				su `var' if treatc_pooled==0
				estadd scalar contmean=r(mean) : drob_`var'
				
			}
			
	esttab drob_* using "`tables'/TableB3_DefaultRobustnessTables_repl.tex",  f b(2) se(2) keep(treatc_pooled) replace booktabs label nostar ///
			num /// 
			mgroups(		"\shortstack{WTP}" "\shortstack{ Payments \\ Received }" "\shortstack{ Replacing with \\ Amount Paid \\ for Defaulters }" "\shortstack{ Deflating \\ by Average \\ Default Rate }"  "\shortstack{ Dropping \\ Defaulters }"   , ///
					pattern(1 1 1 1 1) prefix(\multicolumn{@span}{c}{) suffix(} ) span) ///
			nomtitles ///
			varlab(treatc_pooled "Credit (pooled)") ///
			stats(N contmean, label( "Observations" "Control Mean") layout( "\multicolumn{1}{c}{@}" "@") fmt(0 2)) 

