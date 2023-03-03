/*NOTE: this script does NOT use the output from the previous script
(CleanV1_solved_received_sms_issue.do). This is because that script replicates 
everything except for: (i) the randomized variables and (ii) received_sms, 
and we need the exact values of the randomized variables to be able to replicate 
the main results. */

include "${main}/Do/0. Master.do"
clear all

pause off


**************************************************************
**************** Import SurveyCTO data - Visit 2 *************
************************************************************** 

* Import for each date separately
foreach date in 0701 {
	preserve
		insheet using "`raw'/Visit 2/StovesVisit2_2019`date'.csv", clear
		foreach var in ///
			/*hhname */f_failure f_info_sale f_mpesaconfirm /*f_payname*/ /// 
			h_note /// 
			jikokoa_comments /// 
			prac_arguments /// 
			register_nowhy /// 
			nosms_select 		/*	z_info_note */ /// 
			comment* *comment {
			cap tostring `var', replace
		}
		replace nosms_select="" if nosms_select=="."
		tempfile import
		save `import'
	restore
	append using `import'
}

foreach var of varlist * { 
	cap replace `var' = "" if `var'=="."
}

drop if a_consent!=1
assert a_consent==1

cou if respondent_id=="3f2af22"


duplicates drop
replace respondent_id="557e20" if respondent_id=="5.57E+22"
replace respondent_id="736e34" if respondent_id=="7.36E+36"
replace respondent_id="380e07" if respondent_id=="3.80E+07"

replace respondent_id=lower(respondent_id)

// Went back a day later to give stove, submitted other survey:
drop if key=="uuid:f11ff28b-c0db-4878-b5cf-b48d8065159f" // ID: 5dc2483

// Wrong person. Correct person was surveyed later.
drop if key=="uuid:adc3f2fa-d85d-4297-86f1-b60e8af1cb21" // ID: 0c1d19e

/*
tostring hhphone b_phone1 b_phone2, replace*/


* FO entered wrong respondent ID on 5/22: 
replace respondent_id="68cd33f" 			if key=="uuid:72f139db-4c31-468b-822f-72f5df842446"
/*replace hhname = "M******* ******* *****" 	if key=="uuid:72f139db-4c31-468b-822f-72f5df842446"*/
/*replace hhphone = "*******34" 				if key=="uuid:72f139db-4c31-468b-822f-72f5df842446"
replace b_phone = 1 		if key=="uuid:72f139db-4c31-468b-822f-72f5df842446"
replace b_phone1 = "" 		if key=="uuid:72f139db-4c31-468b-822f-72f5df842446" 
replace b_phone2 = "" 		if key=="uuid:72f139db-4c31-468b-822f-72f5df842446"
*/
replace decision1 = 9 		if key=="uuid:72f139db-4c31-468b-822f-72f5df842446"
replace decision2 = 4 		if key=="uuid:72f139db-4c31-468b-822f-72f5df842446"
replace decision3 = 19 		if key=="uuid:72f139db-4c31-468b-822f-72f5df842446"
replace decision4 = 7 		if key=="uuid:72f139db-4c31-468b-822f-72f5df842446"
replace decision5 = 21 		if key=="uuid:72f139db-4c31-468b-822f-72f5df842446"
replace nosms_newnum = 0 	if key=="uuid:72f139db-4c31-468b-822f-72f5df842446"

/*
replace sms_newnumber = . 	if key=="uuid:72f139db-4c31-468b-822f-72f5df842446"
replace sms_newnumber2 = . 	if key=="uuid:72f139db-4c31-468b-822f-72f5df842446"
*/

isid respondent_id 

* Save raw data file
save "`datamed'/RawSurveyDataV2_replication.dta", replace


********* Import Saved Data *********

use "`datamed'/RawSurveyDataV2_replication.dta", clear


* For ease of data use (but may be useful later):
drop net* snet* x* *beans*a *beans*a_w

* Permanent drop:
drop pracgoodbdm_conf

* Re-create treatment variables: 
g treata_pooled = (treata==1 | treata==2) 
g treatc_pooled = (treatc==1 | treatc==2) 

********* Basic cleaning **********

* New phone numbers (keep old ones also)
/*g phone_number_v1 = hhphone

g phone_number_v2 = hhphone
assert b_phone1 == b_phone2
drop b_phone2
replace phone_number_v2 = b_phone1 if b_phone == 0
*/
********* Identification **********

replace today = "May 17, 2019" if today == "17-May-19"
g midline_date = date(today, "MDY",2019)
format midline_date %td
/*tab a_foname midline_date*/
pause

tab formdef_v today
pause

********* Respondent Info *********


********* Duration *********

* People in Attention Treatment should have significatly longer Attention Duration:
replace durationattention = durationattention - durationinstallments
bys treata_pooled: su durationattention, d
pause


********* View any latest comments *********

gsort -midline_date
pause 

********* Random interesting variables *********

tab g_askhealth, mi
tab showid_legal, mi
tab f_respargu_yn, mi
tab h_agreed, mi
tab attw_help
pause

sort midline_date 
foreach var of varlist prac_arguments /*z_info_note */ comment* register_nowhy {	
	list midline_date `var' if !missing(`var') & `var'!="."
}
pause

********* Low take-up of the commitment device means weekly>monthly must be concentration bias *********
tab payswitch

pause

/* Cannot be run, requires PII 
********* SMS *********

list nosms_select nosms_newnum nosms_why if received_sms==0
tab nosms_select if received_sms==0, mi sort
pause

				preserve
					
					* People who gave new numbers for the SMSes now all receive charcoal:						
					rename respondent_id participant_id
					rename sms_newnumber phone_number
				/*	rename hhname name*/
					
					g sms_category = 2 
					g credit_reminder = "No"				
					g category = "sms_protocal"
					g baseline_date = midline_date-5
					
					format baseline_date %tdCCYYNNDD
					tab baseline_date
					sort baseline_date 
					
					if `export_Box' == 1 {
						outsheet /// 
							participant_id phone_number/* name*/ baseline_date sms_category credit_reminder category ///
							if nosms_newnum==1 ///
							using "`datamed'/baseline_data_V2_replication.csv", replace comma
					}
					
					outsheet ///
						participant_id phone_number /*name*/ baseline_date sms_category credit_reminder category ///
						if nosms_newnum==1 ///
						using"`datamed'/baseline_data_V2_replication.csv", replace comma
				restore
	*/			
********* TIOLI + Practice BDM Variables *********

su prac_finwtp if pracgoodbdm=="KipandeYaSabuni"
su prac_finwtp if pracgoodbdm=="Lotion"
pause

********* Real BDM Variables *********

* Check that name and payment on envelope was correct: 
/*
replace name_envelope=1 if missing(name_envelope) & today=="May 17, 2019" // Forgot to make it required
assert name_envelope==1*/

sort /*a_foname */midline_date
replace f_pricecorrect=1 if f_pricewritten==hhbdm // Three FO said "no" but then entered the same price
replace f_pricewritten=. if f_pricewritten==price
assert f_pricecorrect==1
assert price == hhbdm
list/* a_foname*/ hhbdm f_pricecorrect f_pricewritten price  if f_pricecorrect!=1 & f_pricewritten==price
pause

// P**** ****** had a typo: 
replace jikokoa = 1 if jikokoa==0 & respondent_id=="63ebd28"


sort midline_date
g win_bdm = (finwtp>=price) 
tab jikokoa win_bdm, mi
list /*a_foname*/ midline respondent_id treatc win_bdm price finwtp jikokoa if win_bdm==1 & jikokoa!=1 
cou if win_bdm==1 & jikokoa!=1
assert `r(N)'==8
pause
 
lab var finwtp 	"WTP (KES)"
lab var win_bdm "WTP $>=$ Price"
lab var jikokoa "Jikokoa (=1)"

* Check for BDM authenticity
g wtp_normalized = finwtp - price
lab var wtp_normalized "WTP - Price (KSH)"


* Check switches:
g diff = finwtp!=finwtp_first
g update = finwtp-finwtp_first
sort update
list midline/* a_foname*/ finwtp_first price finwtp update if diff==1 & finwtp_first != 0 & finwtp>=price & finwtp_first < price & update<1000
pause

********* Post-BDM: Payment Groups *********

* Confirm that people switched from Monthly to Weekly only if payswitch==1
lab var treatc2 "Credit Treatment Arm, after self-selection by C2"
bys payswitch: tab treatc treatc2, mi
pause

* How many people in instalments + win paid at least some amount, or the total amount, today?
tab paytoday if treatc_pooled==1 & win_bdm==1, mi
cou if treatc_pooled==1 & win_bdm==1 & paytoday>0
cou if treatc_pooled==1 & win_bdm==1 & paytoday==price
pause

* Make sure everyone who got a Jikokoa made the correct payment: 
replace f_payment = 1140 if price==1140 & f_payment==140 & key=="uuid:f3bff69b-ccba-47d0-ab26-35ea0bc748da" // 
list /*a_foname hhname */midline_date treatc treatc2 win_bdm price finwtp jikokoa f_payment key if treatc==0 & win_bdm==1 & jikokoa==1 & (price != f_payment)
cou if treatc==0 & win_bdm==1 & jikokoa==1 & (price != f_payment) 
assert `r(N)'==0

cou if treatc_pooled==1 & win_bdm==1 & (paytoday != f_payment) & paytoday>0
assert `r(N)'==0

* Make sure everyone who was supposed to make a payment today actually did: 
sort midline_date 
list /*a_foname*/ respondent_id  f_failure  if !missing(f_failure) & f_failure!="."
cou if f_complete == 0
assert `r(N)'==7
pause
	
* Make sure nobody paid TOO MUCH: 
assert missing(f_paytoomuch)

	
* Make sure people who were supposed to get a cookstove actually did: 
cou if jikokoa==0
assert `r(N)'==1

* Make sure everyone registered their stoves:
replace register_yn = 1 if key=="uuid:f11ff28b-c0db-4878-b5cf-b48d8065159f"
 
list midline_date /*a_foname */register_nowhy if !missing(register_nowhy) & register_nowhy!="."
cou if register_yn == 0
assert `r(N)'==4
pause


* Just replacing missing
replace treatc2=treatc if win_bdm==0 & missing(treatc2)
assert !missing(treatc2)

* People who selected to pay everything today, effectively switched into the C0 group: 
replace treatc2=0 if paytoday == price
pause


********* Attention variables *********

* FO put daily instead of weekly savings: 
forv n = 1/52 {
	replace attw`n' = attw`n'*7 if respondent_id=="df21e0e"
}

********* Beans *********



********* Export respondent thank-you payments ********* 

* Thank you amount is 300Ksh, minus deductions of TIOLI and BDM price if they won those
g thankyou_visit2 = 300 
replace thankyou_visit2 = 300 - pracprice1 				if pracbuy_tioli==1 & pracbuy_bdm==0  
replace thankyou_visit2 = 300 - pracprice2 				if pracbuy_tioli==0 & pracbuy_bdm==1  
replace thankyou_visit2 = 300 - pracprice1 - pracprice2 if pracbuy_tioli==1 & pracbuy_bdm==1  

/* Cannot be run, requires PII
preserve 
	rename phone_number_v2 paymentnumber
	rename hhname payname 
	
	sort midline_date
	if `export_Box' == 1 {
		outsheet /// 
			respondent_id payname paymentnumber thankyou_visit2 midline_date /// 
			using "`raw'/stoves_thankyoupayments_ALL_Visit2.csv", comma replace 
	}
	
	outsheet /// 
		respondent_id payname paymentnumber thankyou_visit2 midline_date /// 
		using "`raw'/stoves_thankyoupayments_ALL_Visit2.csv", comma replace 

restore
	*/			
	
********* Export instalment payment instructions for Elijah ********* 

/* 
assert f_payphone  == f_payphone2
assert f_payphonec == f_payphonec2
drop f_payphone2  f_payphonec2

foreach var of varlist f_payphone* sms_newnumber sms_newnumber2 {
	tostring `var', replace
}

	
replace f_payphone="" if f_payphone=="."
replace f_payphonec="" if f_payphonec=="."
		
preserve

	keep if jikokoa == 1 // Only people who purchased the stove pay
	
	rename respondent_id participant_id 
	
	rename midline_date baseline_date 
	format baseline_date %tdCCYYNNDD

	

	* Use the MPESA phone number and name as the phone number and name for this: 
	cou if  !missing(f_payphone) & !missing(f_payphonec)
	assert `r(N)'==0
	cou if  !missing(f_payname) & !missing(f_paynamec)
	assert `r(N)'==0
	
	drop phone_number*
	rename f_payphone 	phone_number
	rename f_payname name
	
	* People paying in instalments entered it elsewhere:
	replace phone_number = f_payphonec if !missing(f_payphonec)
	replace name = f_paynamec if !missing(f_paynamec)
	
	* Use treatc2 for all the below:
	* incorporates monthly respondents who switched to weekly 
	* and also instalment who paid everything today (relative to treatc)
	
	* Save how much they want to pay today. Should be 0 for all upfront folks.
	assert missing(paytoday) if treatc==0 
	g prepay_amount = paytoday
	replace prepay_amount = 0 if treatc2==0
	tab prepay_amount treatc, mi
	tab prepay_amount treatc2, mi
	pause
		
	assert treatc2>=0 & treatc2<=2
	g payment_group = "upfront"
	replace payment_group = "weekly" if treatc2==1
	replace payment_group = "monthly" if treatc2==2 
		
	* Upfront payment, weekly payment, or monthly payment (whichever is relevant)
	g price_amount = price
	replace price_amount = bdmweekly if treatc2==1
	replace price_amount = bdmmonthly if treatc2==2

	sort treatc treatc2
	list treatc treatc2 payswitch payment_group finwtp price paytoday prepay_amount price_amount   
	pause
	
	g category = "payments_protocal"
	
	sort baseline_date
	if `export_Box' == 1 {
		outsheet ///
			participant_id phone_number name baseline_date payment_group price_amount category prepay_amount ///
			using "`datamed'/survey_data_PaymentsProtocol_replication.csv", replace comma
	}

	outsheet ///
		participant_id phone_number name baseline_date payment_group price_amount category prepay_amount ///
		using "`datamed'/survey_data_PaymentsProtocol_replication.csv", replace
		
restore
*/

********* Save Visit 2 Clean surveys

// Clean 'jikokoa ownership' variable
replace jikokoa = 0 if missing(jikokoa)


* REPLACE SURVEY ID SO THEY DO NOT HAVE E IN THEM (excel has a hard time reading):
replace respondent_id = subinstr(respondent_id, "e", "z", .)
replace respondent_id = subinstr(respondent_id, "+", "", .)
replace respondent_id = subinstr(respondent_id, ".", "", .)


isid respondent_id 
save "`dataclean'/Visit2_clean_replication_noPII.dta", replace
outsheet using "`datamed'/Visit2_clean_replication_noPII.csv", replace comma 


********* Combine with Visit 1 Clean surveys
use "`raw'/Visit1_clean_original.dta", clear

	drop tabletid formdef_version instanceid key duration /// 
		a_agree a_consent credit_reminder received_sms thankyou_late ///
		prac_decisions*  ///
		pracpriceTIOLI pracpriceBDM ///
		strata bdmprice 

	foreach var of varlist ///
		submissiondate today /* f2_comment */ beans_no20 treat* {
		rename `var' v1_`var'
	}
	
	replace respondent_id = lower(respondent_id) 
	isid respondent_id 
	
	tempfile V1
	save `V1'

	
use "`dataclean'/Visit2_clean_replication_noPII.dta", clear


g Visit2 = 1
merge 1:1 respondent_id using `V1' 
assert _merge != 1 // Never a Visit 2 that does not have a Visit 1
drop _merge 
replace Visit2=0 if missing(Visit2)


drop date_raw date_now date_week date_month
/*
replace name = "C******* ******* *****" if name == "V********"*/

isid respondent_id 
save "`dataclean'/Visit12_clean_replication_noPII.dta", replace









