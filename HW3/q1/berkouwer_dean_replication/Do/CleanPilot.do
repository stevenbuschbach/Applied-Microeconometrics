clear all
include "${main}/Do/0. Master.do"


* LOCALS
local savings = 0.53 // From Estimation results below.
local CONTROLS = "b_rent b_residents b_children b_incomehh g2_savings d_charcoalbuy"


********************************************************************
*************************** SURVEY DATA ****************************

* Import all days survey data

local files : dir "`raw'/Pilot/" files "*.csv"
foreach file in `files' {
	preserve
		di "STARTING FILE: `file'"
		insheet using "`raw'/Pilot/`file'", comma clear names
		tostring bz3 bz4 /* bz6 bz7 */ b_occupationothers ///
			c_charcoal* c_buymoreother d_nobuy /// 
			g1d g1f g2d g2g g2h /// 
			cz* /* f_failure */, replace
			
		cap tostring d_tastetext f_info_sale  z_info_note , replace 

		g file = "`file'"
		order file
		tempfile new
		save `new'
	restore
	append using `new'
}


* Drop duplicates from across the file names: 
foreach var of varlist cz1 /* cz3 */ d_tastetext g2h g2g  z_info_note  { 
	replace `var'="" if `var'=="."
}

drop file tabletid /* latitude longitude */ z_location* 
duplicates drop

gen date = clock(submissiondate, "MD20Yhm")
replace date = dofc(date)
format %td date


* Drop practice surveys (from Feb 7-8)

drop if today == "7-Feb-18"
drop if today == "8-Feb-18" &  a_hhid==158512

bysort a_hhid: gen n_within = _n

drop if a_hhid == 158652 & n_within == 2
drop if a_hhid == 158543 & n_within == 2


*  COUNT BEFORE CLEANING: 
cou

* Drop the lollipop practice questions:
drop prac_*

* Drop other WTP process questions
drop max* min* x* wtp* *check*

* Labels
include "`dofiles'/labels.do"

* CLEAN THE DATE 
rename today date_old
g today = date(date_old, "DM20Y") 
drop date_old
tab today
format today %td
tab today

* FEASIBLE ERRORS
* People who qualified but then didn't have the money: 
cou if (finwtp<price) & !missing(f_complete)
assert `r(N)'==0
cou if (finwtp>price) & f_complete==0
tab f_complete, mi
tab finwtp price if f_complete == 0

list today /* f_failure */ f_info_sale if f_complete==0
	
* Consent to SMS: 
tab g_consent_sms, mi

* Crude measure of treatment: 
* g jikokoa = (finwtp>price) if f_complete!=0 // 
g win_bdm = (finwtp>=price) // 
g jikokoa = f_complete==1 //
lab var finwtp "WTP (KES)"
lab var jikokoa "Jikokoa (=1)"
	
* CLEAN VARIABLES
tab g2b2 g1b, mi

destring c_charcoalfreq, replace

foreach var of varlist b_incomeself b_incomeothers ///
	c_cookstoveprice c_cookstovemonth c_cookstoveyear c_charcoalfreq /// 
	d_jikokoalast ///
	g1g1 g2a g2c g2b g2b2 {
	foreach k in 96 98 99 999 8888 9999 88888 99999 {
		replace `var' = . if `var' == `k'
	}
	tab `var', mi
}

* GENERATE NEW VARIABLES
* Income
egen b_incomehh = rowtotal(b_incomeself b_incomeothers)
lab var b_incomehh "Household income (KES/day)"

* Savings
* G2A: impute with mean for early surveys where was not asked.
su g2b2
replace g2b2 = `r(mean)' if missing(g2b2) & today <= 21224
su g2a
replace g2a = `r(mean)' if missing(g2a)
replace g2b = 0 if g1b == "96" & missing(g2b) 
replace g2c = 0 if g1c == 2 & missing(g2c)
egen g2_savings = rowtotal(g2a g2c) 
lab var g2_savings "Current saving in cash (KES)

lab var d_charcoalbuy "Charcoal spending (KES/week)"
lab var d_jikokoalast "Expected durability (months)"

g charcoal_income = d_charcoalbuy / (b_incomehh*7)
lab var charcoal_income "Charcoal spending as a proportion of household income"
su charcoal_income, detail


* OLD JIKO / CHARCOAL
g jiko_months = (2018-c_cookstoveyear)*12 + (2-c_cookstovemonth)
lab var jiko_months "Age of old jiko (months)" 
lab var c_newcookstovewhen "When will you buy next jiko? (months)"
lab var c_newcookstovebuy "How many jiko's do you buy per year?"


lab def freq 	1	"More than once per day" ///
				2	"Once per day" ///
				3	"Once every 2-3 days" ///
	4	"Once every 4-6 days" ///
	5	"Once per week" ///
	6	"Once every 10 days" ///
	7	"Once every two weeks" ///
	8	"Once every three weeks" ///
	9	"Once every month" ///
	10	"Less than once per month"
lab val c_charcoalfreq freq
	
* OTHER DEMOGRAPHIC DATA
lab var b_residents "Number of household residents"
lab var c_cookstoveprice "Price of current jiko (KES)"

replace b_educ = 0 if b_educ == 96 // "No education"
g educ_prim = (b_educ >= 8) // Completed primary
g educ_somesec = (b_educ >= 9) // Continued beyond primary
lab var educ_somesec "Some secondary education"
	

foreach var of varlist g2d g2h g2i {
lab var `var'_1	"My business"
lab var `var'_2	"A friend or family member's business"
lab var `var'_3	"To buy agricultural inputs"
lab var `var'_4	"To buy appliances (television, radio, etc.)"
lab var `var'_5	"Health expenses"
lab var `var'_6	"School expenses"
lab var `var'_7	"Special ceremonies (marriage, birth, funeral, etc.)"
lab var `var'_8	"To buy or build a new house"
lab var `var'_9	"To pay for other loans"
lab var `var'_10 "To buy another tangible asset"
lab var `var'_97 "Other"
}



label variable d_nobuy_1 "It's too expensive"
label variable d_nobuy_2 "I don't know where to buy"
label variable d_nobuy_3 "I have never heard of it"
label variable d_nobuy_4 "I don't think it will save money" 
label variable d_nobuy_5 "I can borrow a jiko from someone else" 
label variable d_nobuy_6 "Maybe it will not work"
label variable d_nobuy_7 "I don't like the taste of food cooked with Jikokoa"
label variable d_nobuy_8 "I really like the taste of food from a traditional jiko"
label variable d_nobuy_9 "It is not healthy" 
label variable d_nobuy_10 "There are a lot of fake jikokoa's/sellers"
label variable d_nobuy_11 "I worry that it will break" 
label variable d_nobuy_12 "I am too old" 
label variable d_nobuy_13 "I don't know how to use it" 
label variable d_nobuy_97 "Other" 

* How many people volunteered that it was hard to pay at once/would buy if could pay in installments?
g d_nobuy_installments = 0
foreach phrase in "raise the money" "raise at once" "Raising the required money" ///
	"raise the cash at once" /// 
	"instalment" "one off payment" "pay bit by bit" "installment" /// 
	{
	replace d_nobuy_installments = 1 if ///
		strpos(d_nobuy_detail, "`phrase'") | ///
		strpos(d_nobuy_other, "`phrase'") | /// 
		strpos(z_info_note, "`phrase'")
} 

tab d_nobuy_installments, mi


* DOES IT AFFECT TASTE?
tab d_taste // missing for earliest 2 dates

* OCCUPATION
replace b_occupationself=subinstr(b_occupationself, "97", "", .)
replace b_occupationself=subinstr(b_occupationself, "96", "", .)
replace b_occupationself=trim(b_occupationself)

label variable d_bestthings_1	"I will save money"
label variable d_bestthings_2	"My friends / family will like it"
label variable d_bestthings_3	"It won't break very often"
label variable d_bestthings_4	"Food will taste better"
label variable d_bestthings_5	"Less smoke indoors"
label variable d_bestthings_6	"I will be more modern"
label variable d_bestthings_7	"I will save time"
label variable d_bestthings_99	"Other"


* Expected WTP: calculate WTP if it equalled what hh would save after 3/6/12/24 months 
* of usage:
cap drop simwtp* 

g simwtp3 = (d_charcoalbuy*`savings') * 13 // 50% savings for 13 weeks = 3 months
g simwtp6 = (d_charcoalbuy*`savings') * 26 // 50% savings for 26 weeks = 6 months
g simwtp12 = (d_charcoalbuy*`savings') * 52 // 50% savings for 52 weeks = 12 months
g simwtp24 = (d_charcoalbuy*`savings') * 104 // 50% savings for 104 weeks = 24 months

* Expected WTP: calculate WTP if it equalled what hh would save after 3/6/12/24 months 
* of usage, using 7.5\% interest loan and payback entirely from savings
set more off
cap drop simwtp* 
cap drop save_monthly
cap drop paid_* 
cap drop outstanding_* 
cap drop saved_*

local savings = 0.53

g save_monthly = (d_charcoalbuy * `savings') * 4.5
g outstanding_1 = (4000 * 1.075) - save_monthly
forv n = 2/24 {
	local m = `n'-1
	g paid_`n' = save_monthly 
	replace paid_`n' = (outstanding_`m' * 1.075) if (outstanding_`m' * 1.075) < save_monthly

	g outstanding_`n' = (outstanding_`m' * 1.075) - paid_`n'
	g saved_`n' = save_monthly - paid_`n'
}
egen simwtp12_loan = rowtotal(saved_2  saved_3  saved_4  saved_5  saved_6 ///
					  saved_7 saved_8  saved_9  saved_10 saved_11 saved_12)
egen simwtp24_loan = rowtotal(simwtp12_loan ///
						saved_13 saved_14 saved_15 saved_16 saved_17 saved_18 /// 
						saved_19 saved_20 saved_21 saved_22 saved_23 saved_24)
drop save_monthly paid_* outstanding_* saved_* 

** CREATE WTP QUINTILES AT HOUSEHOLD LEVEL
		
	* Create dummies for 4 WTP quantiles
	xtile hi_finwtp = finwtp, nquantiles(2)
	xtile q_finwtp = finwtp, nquantiles(4)
	cap lab def q_finwtp 1 "Very Low WTP" 2 "Low WTP" 3 "High WTP" 4 "Very High WTP"
	cap lab def hi_finwtp 1 "Low WTP" 2 "High WTP"
	lab val q_finwtp q_finwtp
	lab val hi_finwtp hi_finwtp
	
	tab hi_finwtp, gen(hi_finwtp_)
	tab q_finwtp, gen(q_finwtp_)
	
	* Create interaction terms
		
	local k=1
	foreach var of varlist q_finwtp_* {
		g jikokoa_q`k'=jikokoa*q_finwtp_`k'
		g price_q`k'=price*q_finwtp_`k'
		lab var jikokoa_q`k' "Jikokoa X Quantile `k'"
		lab var price_q`k' "Jikokoa X Quantile `k'"
		lab var q_finwtp_`k' "Quantile `k'" 
		local k=`k'+1
	}
	
	lab var hi_finwtp_1 "Low WTP (=1)" 	
	lab var hi_finwtp_2 "High WTP (=1)" 
	
	g jikokoa_hi1=jikokoa*hi_finwtp_1
	g price_hi1=price*hi_finwtp_1
	g jikokoa_hi2=jikokoa*hi_finwtp_2
	g price_hi2=price*hi_finwtp_2

	lab var jikokoa_hi1 "Jikokoa (=1) X Low WTP (=1)"
	lab var price_hi1 "Price (KES) X Low WTP (=1)"

	lab var jikokoa_hi2 "Jikokoa (=1) X High WTP (=1)"
	lab var price_hi2 "Price (KES) X High WTP (=1)"
	
* CLEANING FOR TABLES/GRAPHS
lab var finwtp "WTP (KES)"
lab var jikokoa "Jikokoa (=1)"
lab var price "BDM Price (KES)"

rename today survey_date 
g hh = _n

* GENERATE LOG VARIABLES
foreach var of varlist ///
	b_incomeself b_incomeothers b_incomehh ///
	d_charcoalbuy ///
	g2_savings g2a g2c /// 
	finwtp {
	 g log_`var' = log(`var')
}

* 95% TOP-CODING CERTAIN VARIABLES
foreach var of varlist b_income* ///
	d_charcoalbuy /// 
	g2_savings g2a g2c {
	qui su `var', detail
	replace `var' = `r(p95)' if `var' > `r(p95)' & !missing(`var')
*	replace `var' = `r(p99)' if `var' > `r(p99)' & !missing(`var')
}

save "`dataclean'/Pilot_clean.dta", replace


