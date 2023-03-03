include "${main}/Do/0. Master.do"

clear all
set rng kiss32
pause off

include "${main}/Do/0. Master.do"
cap rm "`datamed'/Treatments_Week1_replication_noPII.dta"
cap rm "`datamed'/Treatments_Week2_replication_noPII.dta"
cap rm "`datamed'/Treatments_Week3_replication_noPII.dta"
cap rm "`datamed'/Treatments_Week4_replication_noPII.dta"
cap rm "`datamed'/Treatments_Week5_replication_noPII.dta"

**************************************************************
*************** Import SurveyCTO data - Visit 1 **************
**************************************************************

********* Import Raw Data *********



local state "X2f26d6c1c43f462544a474abacbdd93d0003162c"

foreach which_week in 1 2 3 4 5 ///
	{
		
		clear 

		if `which_week'==1 {
			local dates = "0417 0418"
		}
		if `which_week'==2 {
			local dates = "0417 0418 0423 0424 0425 0426"
		}
		if `which_week'==3 {
			local dates = "0417 0418 0423 0424 0425 0426 0429 0430 0502 0503"
		}
		if `which_week'==4 {
			local dates = "0417 0418 0423 0424 0425 0426 0429 0430 0502 0503 0506 0507 0508 0509 0510"
		}
		if `which_week'==5 {
			local dates = "0417 0418 0423 0424 0425 0426 0429 0430 0502 0503 0506 0507 0508 0509 0510 0513 0514"
		}


	foreach date in `dates'   ///
	 {
	preserve
		insheet using "`raw'/Visit 1/StovesVisit1_2019`date'.csv", clear
		foreach var of varlist ///
			/*phone_number b_phone* newphone_number* */ ///
			b_occupationself b_occupationothers ///
			g1b g1e bz1 /* bz6 bz7 */ g2g ///
			c_charcoalseller  c_charcoalseller_other ///
			cz2 d_tastetext ///
			*comment* ///
			 {
			tostring `var', replace
		}
		/* cap tostring b_income_none, replace  */
		tempfile import
		save `import'
	restore
	append using `import'
}

// Only consented respondents
keep if a_consent==1

// One person withdrew consent: 
drop if key == "uuid:c60168d3-b0c0-4863-b0c5-737058eeea19" // ID: 8******, phone: 7********

// Clean IDs
replace respondent_id="736e34" if respondent_id=="7.36E+34"
replace respondent_id="557e20" if respondent_id=="5.57E+20"

* Save raw data file
save "`datamed'/RawSurveyDataV1.dta", replace
 


/********* Import Saved Data *********/

use "`datamed'/RawSurveyDataV1.dta", clear

********* Identification *********


assert phone_number==b_phone2
assert b_phoneb1 == b_phoneb2
assert newphone_number == newphone_number2
drop b_phone2 b_phoneb2 newphone_number2 
replace  b_phoneb1="" if b_phoneb1=="95"
assert !missing(phone_number)

drop if key=="uuid:12f129db-7c0a-4ab9-895b-f075fad24fa7" // SurveyCTO technical accidental duplicate submissions
drop if key=="uuid:08d83db5-848f-4d1c-84d1-894a46a2082a" // Two FOs registered the same respondent on different days. Keeping only the original. 

isid respondent_id
/*isid phone_number*/

 *Fix some date errors: 
replace today = "Apr 26, 2019" if ///
	key=="uuid:e9bc055b-0dbd-4e5d-9cb8-fee598fd4066" | ///
	key=="uuid:c3d4fa08-ebd2-4c4f-9d11-ac6993fd49cd"
replace today = "Apr 26, 2019" if today=="Apr 26, 2018"	
replace today = "May 3, 2019" if /// 
	key=="uuid:7d19817b-84f6-46d8-acce-34efa2a88c57"
replace today = "May 6, 2019" if today=="May 4, 2019" & a_foname=="**********"
replace today = "May 7, 2019" if today=="05-May-19"
replace today = "May 7, 2019" if today=="07-May-19"
*/
g baseline_date = date(today, "MDY",2019)
format baseline_date %td
/*tab a_foname today*/

* Fix villages where possible 

replace a_village = "MCCAandB" if missing(a_village) & a_area=="Mukuru" & gpslatitude<-***** & gpslongitude>******
replace a_village = "MCCAandB" if missing(a_village) & a_area=="Mukuru" & gpslatitude<****** & gpslatitude>-****** & gpslongitude>****** & gpslongitude<******
*/


foreach resp in fd09037 3db04ce 8cd3f4c {
	replace a_village = "48AandB" if respondent_id=="`resp'"
}
replace a_village = "Kayole" if missing(a_village) & a_area=="Kayole"
assert !missing(a_village)

********* Clean charcoal variable & Only keep people who met criteria for inclusion: *********

cou if d_maincooking!=3 | d_charcoalbuy<300
drop if d_maincooking!=3 | d_charcoalbuy<300
tab today, mi
tab a_foname today, mi

isid respondent_id 
sort respondent_id

cap drop if d_alwaystaker==1

********* Export for respondent payments *********
g thankyou_visit1 = .
replace thankyou_visit1 = totallose if g_outcome==0  	// Lost the Risk Game
replace thankyou_visit1 = totalwin  if g_outcome==1 	// Won the Risk Game
assert !missing(thankyou_visit1)
 
* In case respondents want to be paid on a different number.
g paymentnumber = phone_number
replace paymentnumber = newphone_number if newphone_number!="."
g payname = name
replace payname = newname if !missing(newname)

***** EXPORT ALL RESPONDENT PAYMENTS ***** 
 *All payments
sort baseline_date


********* Assign to C0/C1/C2 and A0/A1/A2 groups (week by week) *********

g week=.
g treata=.
g treatc=.


* Import treatment for respondents that have already been assigned, by week
bys week: tab treatc treata, mi
forv week = 1/5 {
	cap merge 1:1 respondent_id using "`datamed'/Treatments_Week`week'_replication_noPII.dta", update
	cap replace week = `week' if missing(week) & _merge == 4
	cap assert _merge != 2
	cap drop _merge 
}
bys week: tab treatc treata, mi
drop if respondent_id=="842b837" // Respondent withdrew consent, but this is not changed in the treatments file
	
	/* Only run this ONCE PER WEEK*/
		
	* Run only once per week
	preserve

	* Set the local of the WEEK you're currently in
	local week = `which_week'
	
		* Only assign treatment to people who have not yet been assigned treatment
		
		if `week'!=1 {
			keep if missing(treata)

		}
		cap drop treat_cells 
		
		* Generate Strata Variable
		gen tiebreak=runiform()
		
		* Sort NEGATIVELY by d_charcoalbuy so that the lowest consumers
		* (likely with lower variance) are misfits
		gsort - d_charcoalbuy tiebreak
		drop tiebreak
		gen strata=ceil(_n/21)
		
		replace week = `week'

		
		
		* Set Seed from Random.org
		* Different seeds for each week, so that order is different every time s
		if `week'==1 {
			set seed		806427
			set sortseed 	709833
		}
		if `week'==2 {
			set seed 		902360
			set sortseed 	963213
		}
		if `week'==3 {
			set seed 		657378
			set sortseed 	466457
		}
		if `week'==4 {
			set seed 		934071
			set sortseed 	962615
		}
		if `week'==5 {
			set seed 		488435
			set sortseed 	383725
		}

		* Randomize into nine regions (A0, A1, A2 by C0, C1, C2)
		randtreat, generate(treat_cells) strata(strata) misfits(wstrata) ///
			unequal(2/21  2/21  2/21  ///
					2/21  2/21  2/21  ///
					3/21  3/21  3/21 ) 
		

		
		* Assign into attention treatments (unequally)
		replace treata = 0 if treat_cells==0 | treat_cells==1 | treat_cells==2
		replace treata = 1 if treat_cells==3 | treat_cells==4 | treat_cells==5
		replace treata = 2 if treat_cells==6 | treat_cells==7 | treat_cells==8
	
		* Assign into credit treatments (equally)
		replace treatc = 0 if treat_cells==0 | treat_cells==3 | treat_cells==6
		replace treatc = 1 if treat_cells==1 | treat_cells==4 | treat_cells==7
		replace treatc = 2 if treat_cells==2 | treat_cells==5 | treat_cells==8
	
		tab treatc treata, mi
		
		keep respondent_id treata treatc treat_cells week
		isid respondent_id
		sort respondent_id
		
		save "`datamed'/Treatments_Week`week'_replication_noPII.dta" // NO REPLACE: randomize ONCE
		
restore

pause endweek, week=`which_week'
	

* Import the treatments you just assigned
bys week: tab treatc treata, mi
merge 1:1 respondent_id using "`datamed'/Treatments_Week`week'_replication_noPII.dta", update
assert _merge != 2
drop _merge
tab treatc treata, mi
bys week: tab treatc treata, mi
	
		
	
// Fix seed moving forward
set seed 		258429
set sortseed 	545073
		
bys treat_cells: su d_charcoalbuy
*pause
	
cou if missing(treatc) | missing(treata)
assert `r(N)'==0

* Generate pooled treatments
g treata_pooled = (treata==1 | treata==2)
g treatc_pooled = (treatc==1 | treatc==2)
lab var treata_pooled "Attention treatment (pooled)"
lab var treatc_pooled "Credit treatment (pooled)"

* Assign labels to all treatments
lab def attention 	0 "Control" 1 "Attention to Benefits" 2 "Attention to Benefits and Costs"
lab val treata attention
lab def credit 		0 "Control" 1 "Credit (Monthly)" 2 "Credit (Weekly)"
lab val treatc credit
lab def att_pooled 	0 "Control" 1 "Attention (pooled)"
lab val treata_pooled att_pooled
lab def cre_pooled 	0 "Control" 1 "Credit (pooled)"
lab val treatc_pooled cre_pooled
lab var treat_cells   "All 9 treatment cells"

tab treata treatc, mi
tab treata_pooled  treatc_pooled, mi
bys treata_pooled  treatc_pooled: su d_charcoalbuy
bys treata_pooled  treatc_pooled week : su d_charcoalbuy
*pause

********* Export SMS instructions for Elijah *********

			
* Respondents in A0 receive Matatu SMSes. 
* Respondents in A1/A2 receive Charcoal SMSes. 
g sms_category = . 
replace sms_category = 1 if treata_pooled==0
replace sms_category = 2 if treata_pooled==1
	
* Respondents in C0 do not receive a credit reminder one week in advance.
* Respondents in C1/C2 receive a credit reminder one week in advance.
g credit_reminder = ""
replace credit_reminder = "No"  if treatc_pooled==0
replace credit_reminder = "Yes" if treatc_pooled==1
	
g category = "sms_protocal"
tab baseline_date
format baseline_date %tdCCYYNNDD
tab baseline_date
*pause

					
********* Create a treatments file for use in CleanSMSdata *********

preserve
	keep /phone_number respondent_id baseline_date treata treatc treata_pooled treatc_pooled 
	isid respondent_id
	isid phone_number
	*save "`data'/RespondentTreatments.dta", replace
	saveold "`datamed'/RespondentTreatments.dta", replace version(12)
restore

********* Clean Variables *********

* Generalizable cleaning
foreach var of varlist b_incomeself b_incomeothers b_rent ///
	c_cookstoveprice c_cookstovemonth c_cookstoveyear c_charcoalfreq /// 
	d_jikokoalast ///
	g1g1 g2a g2c g2b g2b2 {
	foreach k in -99 -999 999 -888 888 -777 777 -8888 -9999 -88888 -99999 {
		replace `var' = . if `var' == `k'
	}
}

foreach var of varlist c_cookstovemonth {
	foreach k in 98 {
		replace `var' = . if `var' == `k'
	}
}

* Demographics 
g age = 2019-b_yob
g b_female = 1-b_male
lab var age 			"Respondent age"
lab var b_male 			"Sex (male=1)"
lab var b_female 		"Sex (female=1)"
lab var b_residents 	"Number of household residents"
lab var b_children		"Number of child residents"


* Energy consumption
egen d_TOTALbuy = rowtotal(d_*buy)
lab var d_TOTALbuy 		"Total energy consumption (Ksh/week)"
lab var d_charcoalbuy	"Charcoal consumption (Ksh/week)"

* Old Jiko
replace c_cookstoveyear=2018 if c_cookstoveyear==2019 & c_cookstovemonth==10
g jiko_months = (2019-c_cookstoveyear)*12 + (4-c_cookstovemonth) if baseline_date <= date("04302019", "MDY")
replace jiko_months = (2019-c_cookstoveyear)*12 + (5-c_cookstovemonth) if baseline_date >= date("05012019", "MDY")
lab var jiko_months			"Age of old jiko (months)" 
lab var c_newcookstovewhen 	"When will you buy next jiko? (months)"
lab var c_newcookstovebuy 	"How many jiko's do you buy per year?"
lab var c_cookstoveprice	"Price of old jiko (Ksh)" 

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

* Cookstove Attributes

lab var d_attributes_cheap	"Price" 
lab var d_attributes_easy	"Ease of Use"
lab var d_attributes_looks	"Looks"
lab var d_attributes_save	"Saves charcoal"
lab var d_attributes_smoke	"Less smoke"
lab var d_attributes_taste	"Taste"

foreach var of varlist d_attributes_* {
	replace `var' = `var' / 2
}


****** Economics ******



* Clean raw variables first:
replace b_incomeself   = b_incomeself/7   if baseline_date<=21668 & a_foname=="*********" // Was doing Weekly 
replace b_incomeothers = b_incomeothers/7 if baseline_date<=21668 & a_foname=="*********" // Was doing Weekly 

replace b_incomeothers=2400 if b_incomeothers==24000
replace b_incomeself=1400 if b_incomeself==14000

replace b_incomeself   = b_incomeself/30.5 if key == "uuid:ae97af06-6381-4925-8c48-31dd511a4e81" // Was doing Monthly
replace b_incomeothers = b_incomeothers/30.5  if key == "uuid:11a2b968-2c82-4236-aaa2-425c3fecc760" // Was doing Monthly

replace b_incomeself=100 if b_rent==1500100
replace b_rent = 1500 if b_rent==1500100

* THEN generate new variables:
egen hhincome = rowtotal(b_incomeself b_incomeothers), missing
g hhincome_week = hhincome*7
g frac_income_ch = d_charcoalbuy/(hhincome*7)
g frac_income_en = d_TOTALbuy/(hhincome*7)
g b_rent_week = b_rent*(7/30.5)

* Label all variables: 
lab var b_rent 			"Household rent (Ksh/month)"
lab var b_rent_week 	"Household rent (Ksh/week)"

lab var hhincome "Household income (Ksh/day)"
lab var hhincome_week "Household income (Ksh/week)"
lab var frac_income_ch "Charcoal spending as fraction of income"
lab var frac_income_en "Energy spending as fraction of income"

su frac_income_ch, detail
su frac_income_en, detail



* Borrowing and Savings activities
replace g2a = 0 if g1a!=1


* Math questions
g mathcorrect_1 = (math1==105)
g mathcorrect_2 = (math2==208)
g mathcorrect_3 = (math3==1011.75)
g mathcorrect_4 = (math4==2094)
g mathcorrect_5 = (math5==1665)
g mathcorrect_6 = (math6==490)
g mathcorrect_7 = (math7==935)
g mathcorrect_8 = (math8==913.75)
egen mathcorrect_total = rowtotal(mathcorrect_*)
lab var mathcorrect_total "Number of math questions correct (0-8)"

* Risk game
tab g_outcome
lab var g_invest "Risky investment amount (0-400 Ksh)"


* Savings beliefs
drop d_beans*a 
replace d_beanmax=. if d_beanmax==-999
foreach var of varlist d_bean* { 
	rename `var' v1_`var' 
}
		

******** Import decisions to prepare for Visit 2 *********
preserve

	import excel using "`raw'/Decisions_insheet.xlsx", clear firstrow
	rename B decisions1_text
	rename C decisions2_text
	rename D decisions3_text
	rename E decisions4_text
	rename F decisions5_text
	forv n = 1/5 {
		g decisions`n' = decision
	}
	
	forv n = 1/5 {
	foreach c in 128 166 226 {
		replace decisions`n'_text = subinstr(decisions`n'_text, "`=char(`c')'", "", .)
	}
	replace decisions`n'_text = subinstr(decisions`n'_text, " .. ", "             ", .)
}

	tempfile decisions
	save `decisions'
	
restore

cou
forv n = 1/5 {
	merge m:1 decisions`n' using `decisions', keepusing(decisions`n'_text) keep(match) nogen
}
order *, alpha

forv n = 1/5 {
	foreach c in 128 166 226 {
		replace decisions`n'_text = subinstr(decisions`n'_text, "`=char(`c')'", "", .)
	}
	replace decisions`n'_text = subinstr(decisions`n'_text, " .. ", "             ", .)
	
********* Evaluate FO performance *********

* Evaluate respondents
cou if !missing(beans_no20)       
assert `r(N)'==0

*g preferencereversal = (decisions2>decisions1 | decisions3>decisions2 | decisions4>decisions3 | decisions5>decisions4)
}

********* Save Visit 1 Clean Surveys *********
isid respondent_id 
*save "`data'/Visit1_medium.dta", replace
saveold "`datamed'/Visit1_medium_replication.dta", replace version(12)




		} /*End of bigger loop */


		

