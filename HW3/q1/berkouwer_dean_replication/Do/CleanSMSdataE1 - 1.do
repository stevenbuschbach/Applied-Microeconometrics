include "${main}/Do/0. Master.do"
pause off
use "`datamed'/Endline1_raw_replication.dta", clear
keep respondent_id hhname hhphone sms_yesno nosms_newnum sms_newnumber 
drop if sms_yesno==0
rename hhphone phone_number
replace phone_number = sms_newnumber if nosms_newnum==1
assert !missing(phone_number)
save "`datamed'/Endline_2020_phones_replication.dta", replace


use "`datamed'/Visit12_clean_replication.dta", clear
	keep respondent_id *phone*
	drop b_phone d_anyphone d_phonebuy
	assert phone_number_v1==hhphone
	local n = 1
	foreach var of varlist *phone* {
			destring `var', replace 
			rename `var' phonenr`n'
			local n = `n'+1
	}
	rename respondent_id respondent_id2
save "`datamed'/numbers_replication.dta", replace
	
preserve
	use "`datamed'/Visit12_clean_replication.dta", clear
	keep v1_phone_number respondent_id baseline_date midline_date treata treatc treata_pooled treatc_pooled /*bdmprice*/
	rename v1_phone_number phone_number
	isid respondent_id
	isid phone_number
	cou
	save "`datamed'/RespondentTreatments_replication.dta", replace
	cap saveold "`datamed'/RespondentTreatments_replication.dta", replace version(12)
restore 


import excel using "`raw2020'/Cookstoves Messages_Data_2020-10-08.xlsx", clear firstrow
		
duplicates drop
save "`datamed'/SMS_incoming_2020_replication.dta", replace


*************** USE DATA ****************** 
use "`datamed'/SMS_incoming_2020_replication.dta", clear
replace MESSAGE = trim(MESSAGE)
drop if missing(MESSAGE) // 8,366 messages

* Fix respondent:
g phone_number = substr(RESPONDENT, strpos(RESPONDENT, "+")+4, .)
unique phone_number 
destring phone_number, replace
g SMS_name = substr(RESPONDENT, 1, strpos(RESPONDENT, "+")-2) // Don't need name for now
drop RESPONDENT

* Extract date:
g SMS_date=date(subinstr(substr(DATETIMERECIEVED, 1, strpos(DATETIMERECIEVED, "2020")+4), ",", "", .), "MDY",2019)
format SMS_date %td
g SMS_hour= trim(substr(DATETIMERECIEVED, strpos(DATETIMERECIEVED, "2020")+6, 2))
replace SMS_hour = subinstr(SMS_hour, ":", "", .)
g SMS_min= trim(substr(DATETIMERECIEVED, strpos(DATETIMERECIEVED, ":")+1, 2))
replace SMS_min = "0" if !strpos(DATETIMERECIEVED, ":")
destring SMS_hour SMS_min, replace
replace SMS_hour = SMS_hour + 12 if strpos(DATETIMERECIEVED, "p.m.")
drop DATETIMERECIEVED

rename MESSAGE message 
duplicates drop

* Import respondent_id and treatment status from surveys
merge m:1 phone_number using "`datamed'/Endline_2020_phones_replication.dta"
tab _merge // 7,155       84.70, missing: 1246
drop _merge

replace respondent_id = lower(respondent_id)
bys respondent_id: g N = _N
tab N
drop N


cou if missing(respondent_id)
forv n = 1/9 {
	rename phone_number phonenr`n'
	merge m:m phonenr`n' using "`datamed'/numbers_replication.dta", keepusing(respondent_id2)
	drop _merge 
	rename phonenr`n' phone_number
	replace respondent_id=respondent_id2 if missing(respondent_id) & !missing(respondent_id2)
	drop respondent_id2
}
cou if missing(respondent_id)

replace respondent_id = "Z6df877" if SMS_name == "I**** ******" & missing(respondent_id)
replace respondent_id = "ff0f93d" if SMS_name == "C******* *******" & missing(respondent_id)

drop if respondent_id == "85f0d22" & SMS_hour == 17 & SMS_min == 40

cou
cou if missing(respondent_id)
drop if missing(respondent_id)
replace respondent_id=lower(respondent_id)
merge m:1 respondent_id using "`datamed'/RespondentTreatments_replication.dta", keepusing(baseline_date midline_date treata treatc treata_pooled treatc_pooled)
tab _merge // 7,278       95.37
drop if missing(message) // 8,366 messages
drop _merge 

drop phone_number hhname sms_newnumber SMS_name
save "`data'/public/SMS_2020_without_PII.dta", replace
