**Code to clean the 2019 SMSs, and generate file that indicates whether we received an SMS from the participant */

include "${main}/Do/0. Master.do"
clear all 

foreach file in "2019-04-17_2019-06-10" {
	preserve
		import excel using "`raw'/SMS Responses/Messages_`file'.xlsx", clear firstrow
		
		tempfile import
		save `import'
	restore
	
	append using `import'
}


duplicates drop
save "`datamed'/SMS_incoming_replication.dta", replace

*************** USE DATA ****************** 
include "${main}/Do/0. Master.do"
use "`datamed'/SMS_incoming_replication.dta", clear

* Fix respondent:
g phone_number = substr(RESPONDENT, strpos(RESPONDENT, "+")+4, .)
g SMS_name = substr(RESPONDENT, 1, strpos(RESPONDENT, "+")-2)
drop RESPONDENT

* People who have started responding with a different number: 
replace phone_number=  "*******26" if phone_number == "*******74"
replace phone_number= "*******90" if phone_number == "*******82"
replace phone_number= "*******68" if phone_number == "*******65"
replace phone_number= "*******76" if phone_number == "*******95"

replace phone_number= "*******44" if phone_number == "*******56"
replace phone_number= "*******51" if phone_number == "*******47"
replace phone_number= "*******88" if phone_number == "*******60"
replace phone_number= "*******54" if phone_number == "*******98"
replace phone_number= "*******95" if phone_number == "*******65"

replace phone_number= "*******08" if phone_number == "*******49"
replace phone_number= "*******73" if phone_number == "*******63"
replace phone_number= "*******62" if phone_number == "*******62"

replace phone_number= "*******55" if phone_number == "*******85"
replace phone_number= "*******96" if phone_number == "*******00"
replace phone_number= "*******59" if phone_number == "*******27"
replace phone_number= "*******24" if phone_number == "*******15"
replace phone_number= "*******66" if phone_number == "*******19"
replace phone_number= "*******08" if phone_number == "*******79"

* 1 person has withdrawn consent: 
drop if phone_number=="*******08"

* Extract date:
g SMS_date=date(subinstr(substr(DATETIMERECIEVED, 1, strpos(DATETIMERECIEVED, "2019")+4), ",", "", .), "MDY",2019)
format SMS_date %td
g SMS_hour= trim(substr(DATETIMERECIEVED, strpos(DATETIMERECIEVED, "2019")+6, 2))
replace SMS_hour = subinstr(SMS_hour, ":", "", .)
g SMS_min= trim(substr(DATETIMERECIEVED, strpos(DATETIMERECIEVED, ":")+1, 2))
replace SMS_min = "0" if !strpos(DATETIMERECIEVED, ":")
destring SMS_hour SMS_min, replace
replace SMS_hour = SMS_hour + 12 if strpos(DATETIMERECIEVED, "p.m.")
drop DATETIMERECIEVED

rename MESSAGE message 
duplicates drop

preserve 	
	use "`raw'/Visit1_medium_original.dta", clear
	keep phone_number respondent_id baseline_date treata treatc treata_pooled treatc_pooled /*bdmprice*/
	save "`datamed'/RespondentTreatments_replication.dta", replace
restore
merge m:1 phone_number using "`datamed'/RespondentTreatments_replication.dta"

tab phone_number if _merge ==1
assert _merge!=1 // All SMSes can be matched to a respondent
drop if _merge == 2 // Drop non-SMS respondents
assert _merge == 3
drop _merge

********* Clean some respondent_id *********
replace respondent_id="380e07" if respondent_id=="3.80E+07"
replace respondent_id = lower(respondent_id)


* REPLACE SURVEY ID SO THEY DO NOT HAVE E IN THEM (excel has a hard time reading):
replace respondent_id = subinstr(respondent_id, "e", "z", .)
replace respondent_id = subinstr(respondent_id, "+", "", .)
replace respondent_id = subinstr(respondent_id, ".", "", .)

include "${main}/Do/0. Master.do"

*************** BASICS ****************** 

replace phone_number = lower(phone_number)
drop if phone_number == "safaricom" | phone_number == "saf offers" | ///
	phone_number == "^22876" | phone_number == "22876"
drop if strpos(message, "You attempted to call me but I was not available")
drop if strpos(message, "Bundle")
drop if strpos(message, "INSTANTLY!")


g amount = trim(message)

*check 1:1 match between respondent_id and phone_number
egen group = group(respondent_id)
su group, meanonly

foreach i of num 1/`r(max)' {
 	tab phone_number if group == `i'
  }
  

g received_sms=1

preserve 
	drop phone_number SMS_name 
	collapse (mean) received_sms, by(respondent_id)
	lab var received_sms "Have we received ANY SMS from this respondent?"
	save "`data'/public/SMS_any_resp_replication.dta", replace
restore  


