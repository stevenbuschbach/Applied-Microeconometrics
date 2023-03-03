* import_Stoves_E2020S.do
*
* 	Imports and aggregates "Stoves_E2020S" (ID: Stoves_E2020S) data.
*
*	Inputs:  "Stoves_E2020S_WIDE.csv"
*	Outputs: "Stoves_E2020S.dta"
*
*	Output by SurveyCTO June 15, 2020 11:46 PM.

* initialize Stata
clear all
set more off
set mem 100m

* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile "Stoves_E2020S_WIDE.csv"
local dtafile "Stoves_E2020S_WIDE.dta"
local corrfile "Stoves_E2020S_corrections.csv"
local note_fields1 ""
*local text_fields1 "tablet_id duration respondent_id respondent_id2 hhstove a_noresp_why g_c1_comments g_c5_4_payhow g_c5_4_payhow_more g_stove_other g_stovetype g_c5_returned g_c5_other" /*g_c1_comments is not available as it contains PII */
local text_fields1 "tablet_id duration respondent_id respondent_id2 hhstove a_noresp_why g_c5_4_payhow g_stove_other g_stovetype g_c5_returned g_c5_other"
local text_fields2 "g_c5_1_sold_why g_c5_1_sold_money g1b sms_newnumber sms_newnumber2 instanceid"
local date_fields1 "today"
local datetime_fields1 "submissiondate"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`raw'/Endline/`csvfile'", names clear

* drop extra table-list columns
cap drop reserved_name_for_field_*
cap drop generated_table_list_lab*

* continue only if there's at least one row of data to import
if _N>0 {
	* drop note fields (since they don't contain any real data)
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=clock(`tempdtvar',"DMYhms",2025)
						* automatically try without seconds, just in case
						cap replace `dtvar'=clock(`tempdtvar',"DMYhm",2025) if `dtvar'==. & `tempdtvar'~=""
						format %tc `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=date(`tempdtvar',"DMY",2025)
						format %td `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish)
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				cap unab svarlist : `svarlist'
				if _rc==0 {
					foreach stringvar in `svarlist' {
						quietly: replace `ismissingvar'=.
						quietly: cap replace `ismissingvar'=1 if `stringvar'==.
						cap tostring `stringvar', format(%100.0g) replace
						cap replace `stringvar'="" if `ismissingvar'==1
					}
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"

	/*label variable a_foname "Please select your name:"
	note a_foname: "Please select your name:"*/

	label variable respondent_id "Household ID:"
	note respondent_id: "Household ID:"

	label variable respondent_id2 "Household ID:"
	note respondent_id2: "Household ID:"

/*	label variable a_resp "\${a_foname}: are you speaking with \${hhname}?
	note a_resp: "\${a_foname}: are you speaking with \${hhname}?"
	label define a_resp 0 "No" 1 "Yes"
	label values a_resp a_resp*/

	label variable a_consent "We are now conducting a short follow-up survey. You can choose to stop this surv"
	note a_consent: "We are now conducting a short follow-up survey. You can choose to stop this survey at any point in time or refuse to answer certain questions. If you have any questions, you can contact the person in charge of this survey at Busara. At the end we will thank you with a small gift. Do you have 15 minutes to talk with me today?"
	label define a_consent 0 "No" 1 "Yes"
	label values a_consent a_consent

	/*label variable a_noresp "\${a_foname}: Why were you not able to speak with \${hhname}?"
	note a_noresp: "\${a_foname}: Why were you not able to speak with \${hhname}?"
	label define a_noresp 1 "Wants to Reschedule" 23 "Refusal for this round only - Survey is too long" 31 "Refusal for this round only - FR has caregiving duties" 32 "Refusal for this round only - FR has to work" 22 "Refusal for this round only - Other reason" 11 "Permanently unable to survey - no correct phone number" 12 "Permanently unable to survey - contact refusal" 13 "Permanently unable to survey - spouse or parent refusal" 14 "Permanently unable to Survey - in prison" 15 "Permanently unable to Survey - mental illness / disability" 16 "Permanently unable to survey - deceased" 17 "Permanently unable to survey - other reason" 34 "FR is suspicious of Busara" 35 "FR hasn't received further assistance from Busara and doesn't want to participat" -77 "Other"
	label values a_noresp a_noresp */

	label variable a_noresp_why "Provide additional information (not required):"
	note a_noresp_why: "Provide additional information (not required):"

	label variable c_charcoalkes "Price (KES):"
	note c_charcoalkes: "Price (KES):"

	label variable c_charcoalunits "Units:"
	note c_charcoalunits: "Units:"
	label define c_charcoalunits 1 "A tin (metal: mkebe)" 2 "A tin (plastic: kasuku)" 3 "A bucket" 4 "Per sack" 5 "Per 100G" 6 "Per 1KG"
	label values c_charcoalunits c_charcoalunits

	label variable g_char_yest "Think back to yesterday. How much did you spend on charcoal yesterday?"
	note g_char_yest: "Think back to yesterday. How much did you spend on charcoal yesterday?"

	label variable g_char_3days "Think of yesterday, the day before that, and the day before that. How much did y"
	note g_char_3days: "Think of yesterday, the day before that, and the day before that. How much did you spend on charcoal in total in those past 3 days?"

	label variable g_char_week "Think of the last 7 days. How much did you spend on Charcoal in that one week?"
	note g_char_week: "Think of the last 7 days. How much did you spend on Charcoal in that one week?"

	/* label variable g_c1_comments "Comments (optional)"
	note g_c1_comments: "Comments (optional)" */

	label variable g_stove "Have you purchased a Jikokoa since we last visited? Confirm that i"
	note g_stove: "Have you purchased a Jikokoa since we last visited? Confirm that it is the Jikokoa, not a different modern stove"
	label define g_stove 0 "No" 1 "Yes"
	label values g_stove g_stove

	label variable g_c5_4_payjikokoa "How much did you pay for your Jikokoa?"
	note g_c5_4_payjikokoa: "How much did you pay for your Jikokoa?"

	label variable g_c5_4_payhow "How did you obtain the \${g_c5_4_payjikokoa} Ksh to buy your Jikokoa?"
	note g_c5_4_payhow: "How did you obtain the \${g_c5_4_payjikokoa} Ksh to buy your Jikokoa?"

// 	label variable g_c5_4_payhow_more "More information on how they got the money:"
// 	note g_c5_4_payhow_more: "More information on how they got the money:"

	label variable g_stove_other "Have you purchased a different type of modern cooking stove since we last visite"
	note g_stove_other: "Have you purchased a different type of modern cooking stove since we last visited?"

	label variable g_stovetype "FO: Please enter the brand name or other details about their new stove"
	note g_stovetype: "FO: Please enter the brand name or other details about their new stove(s):"

	label variable g_jikokoa "Do you currently still own the Jikokoa stove?"
	note g_jikokoa: "Do you currently still own the Jikokoa stove?"
	label define g_jikokoa 0 "No" 1 "Yes"
	label values g_jikokoa g_jikokoa

	label variable g_c5_gone "What happened to your Jikokoa?"
	note g_c5_gone: "What happened to your Jikokoa?"
	label define g_c5_gone 1 "I gave it away as a gift" 2 "It broke" 3 "It was stolen" 4 "I sold it" 5 "Returned it to Burn/Jikokoa Company" 6 "I pawned it (for a temporary loan)" 99 "Other"
	label values g_c5_gone g_c5_gone

	label variable g_c5_returned "Why did you return it?"
	note g_c5_returned: "Why did you return it?"

	label variable g_c5_other "What happened to your Jikokoa?"
	note g_c5_other: "What happened to your Jikokoa?"

	label variable g_c5_1_pawn_amt "How much money did you pawn the Jikokoa for (What was the size of the loan you r"
	note g_c5_1_pawn_amt: "How much money did you pawn the Jikokoa for (What was the size of the loan you received)?"

	label variable g_c5_1_sold_why "Why did you sell it?"
	note g_c5_1_sold_why: "Why did you sell it?"

	label variable g_c5_1_sold_amt "How much money did you sell the Jikokoa for?"
	note g_c5_1_sold_amt: "How much money did you sell the Jikokoa for?"

	label variable g_c5_1_sold_money "What did you do with this money?"
	note g_c5_1_sold_money: "What did you do with this money?"

	label variable g_c5_jiko "Do you still have a traditional charcoal jiko in this house?"
	note g_c5_jiko: "Do you still have a traditional charcoal jiko in this house?"
	label define g_c5_jiko 0 "No" 1 "Yes"
	label values g_c5_jiko g_c5_jiko

	label variable g_c5_3_work "Does your traditional jiko still work?"
	note g_c5_3_work: "Does your traditional jiko still work?"
	label define g_c5_3_work 0 "No" 1 "Yes"
	label values g_c5_3_work g_c5_3_work

	label variable g_c5_3_usage "How often do you use your traditional jiko?"
	note g_c5_3_usage: "How often do you use your traditional jiko?"
	label define g_c5_3_usage 1 "Every day" 2 "A few times per week" 3 "A few times per month" 4 "Only a few times per year" 0 "Never"
	label values g_c5_3_usage g_c5_3_usage

	label variable g_c5_3_oldjiko "What happened to the old jiko that you used before you bought the Jikokoa?"
	note g_c5_3_oldjiko: "What happened to the old jiko that you used before you bought the Jikokoa?"
	label define g_c5_3_oldjiko 1 "I gave it away as a gift" 2 "It broke" 3 "It was stolen" 4 "I sold it" 99 "Other"
	label values g_c5_3_oldjiko g_c5_3_oldjiko

	label variable g_c5_3_oldjiko_amt "How much money did you sell this old jiko for?"
	note g_c5_3_oldjiko_amt: "How much money did you sell this old jiko for?"

/*	label variable g_c_comments "End of section. Any other comments?"
	note g_c_comments: "End of section. Any other comments?" */

	label variable d2_anychildren "Are there any children (under 16 years old) who regularly eat and sleep in this "
	note d2_anychildren: "Are there any children (under 16 years old) who regularly eat and sleep in this home?"
	label define d2_anychildren 0 "No" 1 "Yes"
	label values d2_anychildren d2_anychildren

	label variable d2_cough_resp "Persistent cough?"
	note d2_cough_resp: "Persistent cough?"
	label define d2_cough_resp 0 "No" 1 "Yes"
	label values d2_cough_resp d2_cough_resp

	label variable d2_breath_resp "Breathlessness at night?"
	note d2_breath_resp: "Breathlessness at night?"
	label define d2_breath_resp 0 "No" 1 "Yes"
	label values d2_breath_resp d2_breath_resp

	label variable d2_cough_child "Persistent cough?"
	note d2_cough_child: "Persistent cough?"
	label define d2_cough_child 0 "No" 1 "Yes"
	label values d2_cough_child d2_cough_child

	label variable d2_breath_child "Breathlessness at night?"
	note d2_breath_child: "Breathlessness at night?"
	label define d2_breath_child 0 "No" 1 "Yes"
	label values d2_breath_child d2_breath_child

	label variable g1a "Do you use any mobile money services, like M-Pesa, Airtel Money, or Equitel?"
	note g1a: "Do you use any mobile money services, like M-Pesa, Airtel Money, or Equitel?"
	label define g1a 0 "No" 1 "Yes" 98 "Respondent refuses to answer"
	label values g1a g1a

	label variable g1b "Do you participate in a SACCO, merry-go-round, or ROSCA?"
	note g1b: "Do you participate in a SACCO, merry-go-round, or ROSCA?"

	label variable g1c "Do you have a savings account in a formal bank?"
	note g1c: "Do you have a savings account in a formal bank?"
	label define g1c 0 "No" 1 "Yes" 98 "Respondent refuses to answer"
	label values g1c g1c

	label variable g2a "What is the total amount in shillings in your mobile banking account right now?"
	note g2a: "What is the total amount in shillings in your mobile banking account right now?"

	label variable g2b "What is the total amount in shillings of SACCO / merry-go-round / ROSCA contribu"
	note g2b: "What is the total amount in shillings of SACCO / merry-go-round / ROSCA contributions that you made last month?"

	label variable g2b2 "If you received money from your SACCO / merry-go-round / ROSCA today, how much m"
	note g2b2: "If you received money from your SACCO / merry-go-round / ROSCA today, how much money would this be?"

	label variable g2c "What is the total amount in shillings in your formal bank account right now?"
	note g2c: "What is the total amount in shillings in your formal bank account right now?"

// 	label variable bz7 "Comments (optional)"
// 	note bz7: "Comments (optional)"

	label variable sms_yesno "Thank you very much for your time today. We are almost at the end of the survey."
	note sms_yesno: "Thank you very much for your time today. We are almost at the end of the survey. We just have one final request. We are wondering if you are willing to enrol in another SMS survey about your charcoal spending? It will be very similar to last year. Over the next one month, you will receive one text message once every three (3) days. When you reply, we will send you KES 20 in Airtime as a thank you. In addition, if you respond to at least 10 SMSes, you will receive an ADDITIONAL 200 Kes! Would you be willing to participate in this survey?"
	label define sms_yesno 0 "No" 1 "Yes"
	label values sms_yesno sms_yesno

	/*label variable nosms_newnum "Note: We have your phone number listed as \${hhphone} Would you like us to send "
	note nosms_newnum: "Note: We have your phone number listed as \${hhphone} Would you like us to send the SMSes to a different number instead?"
	label define nosms_newnum 0 "No" 1 "Yes"
	label values nosms_newnum nosms_newnum*/

	/*label variable sms_newnumber "On what phone number would you like to receive the SMSes?"
	note sms_newnumber: "On what phone number would you like to receive the SMSes?"

	label variable sms_newnumber2 "Could you please tell me this phone number again?"
	note sms_newnumber2: "Could you please tell me this phone number again?"*/

	*label variable z_info_note "Please write a note here if there is anything else important:"
*	note z_info_note: "Please write a note here if there is anything else important:"






	* append old, previously-imported data (if any)
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data if overwrite_old_data is 0
		* (alternatively drop in favor of new data if overwrite_old_data is 1)
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & ((`overwrite_old_data' == 0 & new_data_row == 1) | (`overwrite_old_data' == 1 & new_data_row ~= 1))
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* OPTIONAL: LOCALLY-APPLIED STATA CORRECTIONS
*
* Rather than using SurveyCTO's review and correction workflow, the code below can apply a list of corrections
* listed in a local .csv file. Feel free to use, ignore, or delete this code.
*
*   Corrections file path and filename:  Stoves_E2020S_corrections.csv
*
*   Corrections file columns (in order): key, fieldname, value, notes

capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						gen origvalue=value
						replace value=string(clock(value,"DMYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
						* allow for cases where seconds haven't been specified
						replace value=string(clock(origvalue,"DMYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
						drop origvalue
					}
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						replace value=string(clock(value,"DMY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					}
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}
