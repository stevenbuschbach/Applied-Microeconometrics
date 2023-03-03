****************************************************************************
******************* 4. Payments Data ***************************************
****************************************************************************

* PREAMBLE
{

// For additional information about cases, see "Dropbox > Cookstoves > Main > Do > Manual_Changes.txt"

	// respondent_id : 670bf58
	// Decision: drop from payments; drop from survey

//Returned the jikokoa

	// respondent_id : zcz0a7f
	// Context: The g_c5_other variable says "She called back the very day to be collected as she said she might forfeit in paying."
	// Decisoin: Drop

	// respondent_id : 66bcf38
	// Context: The g_c5_other variable says "Return it to busara"
	// Decisoin: Drop

	// respondent_id : 4z63435
	// 	Context: The g_c5_other variable says "It was taken back because she was unable to pay"
	// Decisoin: Drop

	// respondent_id : 0f2fa7d 
	//	Context: The respondent bought the jiko, i.e. jikokoa == 1, had the jiko during the Visit3 endline, i.e. g_jikokoa == 1, but during the one-year endline, the respondent reports that the jiko was taken back, i.e. el1_g_c5_other == "The jiko was taken back by the field officer"
	// Decisoin: Drop

	// respondent_id : d97cz8c 
	// Context: The respondent bought the jiko, i.e. jikokoa == 1, had the jiko during the Visit3 endline, i.e. g_jikokoa == 1, but during the one-year endline, the respondent reports that the jiko was taken back for failure of payment, i.e. el1_g_c5_other == "Was repossessed by Busara when failed to pay"
	// Decisoin: Drop
			

// Other

	// respondent_id : z95zab8 
	// Context: Visi2 == 1; Visit 3 == 0; Endline1 == 1; during one-year endline, the respondent claims that they never had the jikokoa, i.e. el1_g_c5_other == "I didn't purchase"; appears as having paid "None" in the April data
	// Decision: keep in payments data; drop from endline

	// respondent_id : 23afd44
	// Context: el1_g_c5_other == "I didn't have it before"; check updated data to see if respondent completed final 200 KSH of payment
	// Decision: keep in payments data; drop from endline

	// respondent_id : 798z07
	// Context: el1_g_c5_other == "Never got a Jikokoa, was away when the were being given"; however, the payment data shows the respondent bought a jikokoa
	// Decision: keep in payments data; drop from endline
	
	// respondent_id : 3b23107
	// Context: Appears once in the December Payments Data and once in the March Payments Data, but under different numbers
	// Decision: combine payments
		
	// respondent_id : 3d53c17
	// Context: FO filled in the wrong respondent's details 
	// Decision: drop from survey data 
		
}


* SET PATHS, DIRECTORIES and GRAPH STYLES 
{
	* Set path
		include "${main}/Do/0. Master.do"

	* Last data update:
		local date = "1205"

	* Set graph styles
		graph set eps fontfaceserif "PTSerif-Roman"
		graph set ps fontface "PTSerif-Roman"
		graph set eps fontface "Serif"
		*graph set eps fontface "Garamond"

		graph set window fontface "Serif"
		graph set window fontface "PTSerif-Regular"
		*graph set window fontface "PTSerif-Roman"

		*** MAC, EPS CORRECT:
		graph set eps fontface "Palatino Linotype"
		graph set window fontface "Palatino Linotype"
}


* CLEAN DATA
{
****************************************************************************
******************* PAYMENTS DATA - DECEMBER 2019 **************************
****************************************************************************
		import excel using "`raw'/Payments_2019-12-05.xlsx", clear firstrow allstring  /*Note: this file is not available in the Public repository, as it contains PII */

		* Transform amounts paid from string to int
		destring AMOUNTPAID, replace 

		* Remove country code from phone number variable
		replace PHONE = subinstr(PHONE, "254", "", 1)
		rename PHONE f_payphone
		
		* Create new date variable from string
		g PAYdate = date(DATEPAID, "YMD",2019)
		format PAYdate %td
		
		* Individual Cases:
		* Please search the respondent_id in:
		* Dropbox > Cookstoves> Main > Do > "Manual_Changes.txt"
		{
			// for respondent id: 9b5c179
			replace f_payphone = "7********" if f_payphone == "7********"
			
			// for respondent id: 57f5cb2
			replace f_payphone = "7********" if f_payphone == "7********" & AMOUNTPAID == 100
			
			// for respondent id: 670bf58
			drop if f_payphone == "7********"
			
			// for respondent_id : 3b23107
			replace f_payphone = "7********" if f_payphone == "7********" & RESPONDENT == "G****** K*******_+2***********"
			
			// for respondent_id: 670bf58 / 
			drop if f_payphone == "7********" | f_payphone == "7********"
			
			// for respondent_id: 047bz69
			drop if f_payphone == "*********"
				
			// for respondent_id: 2bd040z
			drop if f_payphone == "*********"
		}
		
		* Sum all payments on the same day by the same f_payphone
		bysort f_payphone PAYdate : replace AMOUNTPAID = sum(AMOUNTPAID)
		bysort f_payphone PAYdate : keep if _n == _N
		
		isid f_payphone PAYdate
		
		* Drop respondent and string date
		drop DATEPAID RESPONDENT 

		tempfile payments
		save `payments'
		
****************************************************************************
******************* PAYMENTS DATA - APRIL 2021 **************************
****************************************************************************
		import excel using "`raw'/Cookstoves_Payments_2021-04-12_list.xlsx", clear firstrow allstring /*Note: this file is not available in the Public repository, as it contains PII */
		
		* Transform amounts paid from string to int
		destring AMOUNTPAID, replace
		
		* Remove country code from phone number variable
		replace PHONE = subinstr(PHONE, "254", "", 1)
		rename PHONE f_payphone
		
		* Manually adjust three pay dates that are in the wrong format
		replace DATEPAID = "2019-05-30" if f_payphone == "7********" & RESPONDENT == "H***** A*****" & AMOUNTPAID == 351
			
		replace DATEPAID = "2019-05-20" if f_payphone == "7********" & RESPONDENT == "L**** N**** L******" & AMOUNTPAID == 506
			
		replace DATEPAID = "2019-06-05" if f_payphone == "7********" & RESPONDENT == "R**** O****" & AMOUNTPAID == 707
					
		* Create new date variable from string
		g PAYdate = date(DATEPAID, "YMD",2019)
		format PAYdate %td
		
		* Individual Cases
		* Please search the respondent_id in:
		* Dropbox > Cookstoves> Main > Do > "Manual_Changes.txt"
		{
			// for respondent id: 9b5c179
			replace f_payphone = "7********" if f_payphone == "7********"
				
			// for respondent id: 57f5cb2
			replace f_payphone = "7********" if f_payphone == "7********" & AMOUNTPAID == 100
				
			// for respondent_id : 3b23107
			replace f_payphone = "7********" if f_payphone == "7********" & RESPONDENT == "PHONE_NOT_FOUND_G***** K******_+254*********"
		
			// for respondent_id: z902085
			replace f_payphone = "7********" if f_payphone == "7********"
			
			// for respondent_id: 927623a
			replace f_payphone = "7********" if f_payphone == "7********"
				
			// for respondent_id: df88faa
			replace f_payphone = "7********" if f_payphone == "7********"
				
			// for respondent_id: a104d2f
			replace f_payphone = "7********" if f_payphone == "7********"
				
			// for respondent_id: 7c916b0
			replace f_payphone = "7********" if f_payphone == "7********"
				
			// for respondent_id: 595b311
			replace f_payphone = "7********" if f_payphone == "7********"
				
			// for respondent_id: 022705c
			replace f_payphone = "7********" if f_payphone == "7********"
				
			// for respondent_id: 85b7657
			replace f_payphone = "7*********" if f_payphone == "7********"
				
			// for respondent_id: z3z51aa
			replace f_payphone = "7********" if f_payphone == "7********"
				
			// for respondent_id: 8c724db
			replace f_payphone = "7********" if f_payphone == "7********"	
				
			// for respondent_id: 6z8b158
			replace f_payphone = "7********" if f_payphone == "74*******"
				
			// for respondent_id: az2b5z6
			replace f_payphone = "7********" if f_payphone == "7********"
				
			// for respondent_id: caf3z35
			replace f_payphone = "7********" if f_payphone == "7********"
				
			// for respondent_id: 57f5cb2
			replace f_payphone = "7********" if f_payphone == "7********"
				
			// for respondent_id: 7b13769
			replace f_payphone = "7********" if f_payphone == "7********" & AMOUNTPAID == 909
				
			// for respondent_id: 3c5ddaa
			replace f_payphone = "7********" if f_payphone == "7********" & AMOUNTPAID == 1161
				
			// for respondent_id: 45z8081
			replace f_payphone = "*******" if f_payphone == "*******" & AMOUNTPAID == 1165
				
			// for respondent_id: 670bf58; 
			drop if f_payphone == "7********" | f_payphone == "7********"
				
			// for respondent_id: 9cbaa4z
			replace f_payphone = "7********" if f_payphone == "7********" & RESPONDENT ==  "N**** K*******_+2***********"
				
			// for respondent_id: 5722f55
			replace f_payphone = "7********" if f_payphone == "7********"
				
			// for respondent_id: 0897f55
			replace f_payphone = "7********" if f_payphone == "7********"
				
			// for respondent_id: 047bz69
			drop if f_payphone == "7********"
				
			// for respondent_id: 2bd040z
			drop if f_payphone == "7*******"
			
			// for respondent_id: 2271c36
			replace f_payphone = "7********" if f_payphone == "7********"
		}
			
		* Sum all payments on the same day by the same f_payphone
		bysort f_payphone PAYdate : replace AMOUNTPAID = sum(AMOUNTPAID)
		bysort f_payphone PAYdate : keep if _n == _N
		
		isid f_payphone PAYdate
		
		* Drop respondent and string date
		drop DATEPAID RESPONDENT
		
		* Merge with December Payments Data	
		merge 1:1 f_payphone PAYdate AMOUNTPAID using `payments'
		
		* There are 2 cases for which we have different total payments on the same day in December and April datasets; keep the higher amount
		bysort f_payphone PAYdate : egen temp1 = max(AMOUNTPAID)
		bysort f_payphone PAYdate : drop if temp1 != AMOUNTPAID
		
		drop temp1 _merge
		
		isid f_payphone PAYdate
		
		tempfile newpayments
		save `newpayments'

****************************************************************************
******************* PAYMENTS DATA - MARCH 2020 *****************************
****************************************************************************
		import excel using "`raw'/Errors_Underpay_2020-03-24.xlsx", clear firstrow /*Note: this file is not available in the Public repository, as it contains PII */
		
		* Drop payment date and last amount paid variables
		drop Date* Amountlastpaid
		
		* Individual Cases
		* Please search the respondent_id in:
		* Dropbox > Cookstoves> Main > Do > "Manual_Changes.txt" 
		{
			// Entry was missing a leading plus, so added it to match the rest of the phone numbers
			replace PhoneNumber = "+254********" if PhoneNumber == "254********"
			
			// for respondent_id : c436bc3
			replace PhoneNumber = "+254*******" if PhoneNumber == "+254********"
			
		}
		
		* Remove country code from phone number variable
		replace PhoneNumber = substr(PhoneNumber, 5, .) 
		rename PhoneNumber f_payphone
		
		* Individual Cases
		* Please search the respondent_id in:
		* Dropbox > Cookstoves> Main > Do > "Manual_Changes.txt"
		{
		// for respondent_id: 670bf58; 
			drop if f_payphone == "74******" | f_payphone == "72******"
		
		}
		
		* If respondents have a valye of "None" for payments_received,
		* then set their value to "0".
		rename payments_received TOTALPAID_V2
		replace TOTALPAID_V2="0" if TOTALPAID_V2=="None"
		
		* Transform amounts from string to int
		destring TOTALPAID_V2, replace 
			
		keep f_payphone TOTALPAID_V2
		
		tempfile nonpayment_update
		save `nonpayment_update'
		
****************************************************************************
******************* SURVEY DATA ********************************************
****************************************************************************
		use "`datamed'/Visit123_analysis_replication.dta", clear
		
		quietly: findname, type(string) local(strvars)

		
		foreach var of local strvars{
				list respondent_id `var' if strpos(`var', "0******")>0
		}

 local march_merge_2_ids "0b7a749 a694bbc z3cb153 8acd8zf 45z8081 2271c36"
 
		* Keep only respondents if second visit happened
		keep if Visit2==1

		* Keep only if people actually purchased jikokoa
		keep if jikokoa == 1

		* Confirm that phone numbers and names are not missing;
		* if f_payphone is missing, replace it with f_payohonec
		* if f_payname is missing, replace it with f_paynamec
		assert missing(f_payphone) | missing(f_payphonec)
		replace f_payphone = f_payphonec if missing(f_payphone) & !missing(f_payphonec) 
		assert !missing(f_payphone)
		replace f_payname = f_paynamec if missing(f_payname) & !missing(f_paynamec) 
		assert !missing(f_payname)

		* Individual Cases:
		* Please search the respondent_id in:
		* Dropbox > Cookstoves> Main > Do > "Manual_Changes.txt"
		{
			// for respondent_id : c436bc3
			// the f_payphone and f_payphonec were entered incorrectly; use alternative phone variable
			replace f_payphone = phone_number_v1 if respondent_id == "c436bc3"
				
			// for respondent_id : 57f5cb2
			replace f_payphone = "7*******" if respondent_id=="57f5cb2"
			
			// for respondent_id : 3a8b663 
			replace f_payphone = "7********" if respondent_id == "3a8b663"
			
			// for respondent_id : 70ba83b 
			replace f_payphone = "7********" if respondent_id == "70ba83b"
			
			// for respondent_id: 8acd8zf
			replace f_payphone = "7********" if respondent_id == "8acd8zf"
			
			// for respondent_id: 0b7a749
			replace f_payphone = "7********" if respondent_id == "0b7a749"
		}
		
		
		* Remove everything after paytoday in final version
		keep respondent_id name f_payname f_payphone ///
			baseline_date midline_date ///
			price_KSH bdmweekly bdmmonthly treatc2 treatc paytoday ///
		
		* Check to see if f_payphone uniquely identifies the oservations 
		isid f_payphone

****************************************************************************
******************* LIST OF UNIQUE IDs AND PHONE NUMBERS *******************
****************************************************************************	
		* Create a file that uniquely identifies respondent_ids and f_payphones 
		* that appear in the payments data
		preserve
			keep respondent_id f_payphone
			duplicates drop
			isid resp
			save "`datamed'/resp_phonepay_replication.dta", replace	
		restore

****************************************************************************
******************* MERGE PAYMENT AND SURVEY DATA **************************
****************************************************************************
		* Drop obs for whom payments are < 7 days since midline (for weekly);
		* this drops 0 observations
		drop if ((date("`date'19", "MDY",2019) < midline_date+7) & treatc2==1)
		
		* Drop obs for whom payments are < 28 days since midline (for monthly);
		* this drops 0 observations
		drop if ((date("`date'19", "MDY",2019) < midline_date+28) & treatc2==2)

		* Merge payments and survey data
		merge 1:m f_payphone using `newpayments'
		
		br respondent_id _merge if respondent_id == "94d535a" | respondent_id == "693a283" | respondent_id == "a6b647z" | respondent_id == "cfc7453" | respondent_id == "10b2b81" | respondent_id == "a2z1fz1" | respondent_id == "b32baff" | respondent_id == "cdcd1d0" | respondent_id == "z61d9c7" | respondent_id == "2b2b7z2" | respondent_id == "966b315" | respondent_id == "9c4b22b"
		
		* 96.19 % matched
		tab _merge

		* Confirm that up-front payments were correct:
		* Two people in the credit control paid too much respondent_id 7b13769 and respondent_id 26dfd28; both of them had a payment after their midline_visit, and the total amount they paid exceeds what they were supposed to pay, i.e. price_KSH.
		cou if (_merge == 3 & treatc2==0 & AMOUNTPAID != price_KSH) & respondent_id != "7b13769" & respondent_id != "26dfd28"
		di `r(N)'
		assert `r(N)'==0
	
		* Drop unmatched payments from payments data			
		drop if _merge == 2
			
		* Create indicator for people who have paid nothing 
		* Assume paid nothing if we do not merge from master, i.e. _merge == 1
		g paynone = 0
		replace paynone = 1 if _merge==1
			
		* Keep only matched payments, or people we know paid nothing
		keep if _merge == 3 | paynone == 1
		
		* Remove unnecessary variables
		drop _merge f_payname name f_payphone
		
		** There are 1948 payments and 570 unique respondent_ids
		unique respondent_id

		* Collapse sums payments from respondents on the same PAYdate
		* Note that the collapse changes the AMOUNTPAID variable for _merge == 1 cases to 0
		collapse (sum) AMOUNTPAID, by(respondent_id ///
			baseline_date midline_date PAYdate price_KSH bdmweekly bdmmonthly treatc2 treatc paytoday)
		
		* After collapse there are 1948 payments from 570 respondents
		unique respondent_id
		
		* For people that have not yet paid at all, pretend that PAYdate is just midline date: 
		sort respondent_id
		replace PAYdate = midline_date+1 if missing(PAYdate)

		isid respondent_id PAYdate
		sort respondent_id PAYdate
		
		* Create a tracker for number of payments by respondent
		by respondent_id: g PAYno = _n

		* T = Time between payment date and V2
		g T = PAYdate - midline_date 
		lab var T "Days since V2"
		order respondent_id PAYno T baseline_date midline_date PAYdate AMOUNTPAID 

		save "`datamed'/PaymentsData_medium1_replication.dta", replace

****************************************************************************
******************* RESPONDENT-LEVEL DATA **********************************
****************************************************************************
		use "`datamed'/PaymentsData_medium1_replication.dta", clear

		* Save respondent-level data to merge in later:
		keep respondent_id bdmweekly bdmmonthly midline_date treatc2 treatc price_KSH baseline_date paytoday
		tab treatc2, mi

		duplicates drop 
		isid respondent_id 
		tempfile respinfo
		save `respinfo'
			
****************************************************************************
******************* 1-Year PANEL *******************************************
****************************************************************************
		* Generate a panel: 1 year of data for everyone
		keep respondent_id bdmweekly bdmmonthly midline_date treatc2 treatc price_KSH paytoday
			
		* Add 365 observations x number of unique ids
		expand 375
			
		* T == time between V2 and payment date
		bys respondent_id: g T = _n - 1
			
		* running_date == actual date of the T dates
		bys respondent_id: g running_date = midline_date + T 
		format running_date %td

		* Create a payments variable
		g payment = . 
		
		* Assume full price was paid on first day for upfront payment group
		replace payment = price_KSH if T==1 & treatc2==0
			
		* Assume bdmweekly was paid every 7 days for weekly payment group for 12 weeks since midline
		replace payment = bdmweekly  if mod(T, 7)==0 & T != 0 & treatc2==1 & T <= 84
			
		* Assume bdmmonthly was paid every 28 days for monthly payment group for 12 weeks since midline
		replace payment = bdmmonthly if mod(T,28)==0 & T != 0 & treatc2==2 & T <= 84

		* Assume payments were 0 for all other days
		replace payment = 0 if missing(payment)
			
		* MINPAID == rolling sum of theoretical payments
		bys respondent_id (T) : g MINPAID = sum(payment)
			
		* Add upfront payments to MINPAID for weekly and monthly groups
		replace MINPAID = MINPAID + paytoday if !missing(paytoday) & treatc2!=0
		
		drop payment bdmweekly bdmmonthly price_KSH

		tempfile minpaid 
		save `minpaid'
			
****************************************************************************
******************* CLEAN PANEL ********************************************
****************************************************************************
		use "`datamed'/PaymentsData_medium1_replication.dta", clear
		
		* These static values will be merged from `respinfo'
		drop midline_date bdmweekly bdmmonthly price_KSH baseline_date 

		* Merge the T dates and schedule of minimum payments
		merge 1:1 respondent_id T using `minpaid'
		drop _merge

		* Merge static values 
		merge m:1 respondent_id using `respinfo'
		drop _merge

		* Create rolling sum of actual payments 
		bys respondent_id (T) : gen TOTALPAID = sum(AMOUNTPAID)
		
		* Check no payments after Dec 5, 2019 -- date of the December Payments Data
		count if !missing(AMOUNTPAID) & (running_date > date("`date'19", "MDY"))
		assert `r(N)'==0
		

		preserve
			sort respondent_id T
			by respondent_id: keep if _n == _N
			su T,d
			local maxT = `r(min)'
		restore
		drop if T>`maxT'
		
		isid respondent_id T
		sort respondent_id T
		order respondent_id treatc2 price_KSH bdmweekly bdmmonthly baseline_date midline_date ///
			T running_date MINPAID TOTALPAID PAYno PAYdate AMOUNTPAID
		
		* Check to see if we have no missing minimum and total payments
		assert !missing(MINPAID) & !missing(TOTALPAID)
		
		* On track if total cumulative paid is at least as large as required amount:
		g ONTRACKind = (TOTALPAID >= MINPAID)
		
		* Create a variable for fraction paid
		g ONTRACKfr = (TOTALPAID / MINPAID)
		replace ONTRACKfr = 1 if TOTALPAID >= MINPAID & !missing(ONTRACKfr)
		
		* Only keep data post the first required payment: 
		keep if treatc2==0 | ( (running_date >= midline_date+7) & treatc2==1) | ( (running_date >= midline_date+28) & treatc2==2)
		
		unique respondent_id
		
		* Only keep those assigned to credit
		keep if treatc!=0 
		
		unique respondent_id
			
		// payments data clean panel
		save "`data'/public/Payments_Data_Panel_replication.dta", replace
		
****************************************************************************
******************* CLEAN TOTAL PAYMENTS ***********************************
****************************************************************************
		use "`data'/public/Payments_Data_Panel_replication.dta", clear

		unique respondent_id
		* 461 people bought the stove and are on weekly or monthly payments
		isid respondent_id running_date
		sort respondent_id running_date
		
		* keep only last record for each respondent
		by respondent_id: keep if _n == _N
		isid respondent_id 
		
		* match a phone number to each respondent in the data
		* there are 575 unique respondent_id - f_payphone combinations; 
		* we match 463 (the ones in the master data) and there are 112 not matched from the using data
		* NEW: 570 unique respondent_id - f_payphone combinations;
		* NEW: we match 461 (the ones in the master data) and there are 109 not matched from the using data
		merge 1:1 respondent_id using "`datamed'/resp_phonepay_replication.dta"
		isid respondent_id
		drop if _merge == 2
		assert _merge == 3
		keep respondent_id treatc2 price_KSH TOTALPAID f_payphone treatc MINPAID paytoday bdmweekly bdmmonthly
		
		* Merge survey and updated payments data
		merge 1:1 f_payphone using `nonpayment_update'
		order respondent_id treatc2 price_KSH* TOTALPAID*

		* Deletes 13 observations from March 2020 update;  
		* for all of them, TOTALPAID_V2 == 0
		drop if _merge == 2
		drop _merge
		
		// Checking if prices include interest payments
		*********************
				gen min_1 = MINPAID
				gen min_2 = . 
				replace min_2 = price_KSH if treatc2 == 0 & !missing(price_KSH)
				replace min_2 = paytoday + 12*bdmweekly if !missing(paytoday) & !missing(bdmweekly) & treatc2 == 1
				replace min_2 = paytoday + 3*bdmmonthly if !missing(paytoday) & !missing(bdmmonthly) & treatc2 == 2
				
				assert(!missing(min_2))
				
				gen check = 0
				replace check = 1 if min_1 == min_2
				sum check, d
		
				assert(check == 1)
				
				drop min_1 min_2 check
		*********************
		
		* Replace total payment == updated total payment
		* Make sure that if TOTALPAID = max{TOTALPAID, TOTALPAID_V2}
		replace TOTALPAID = TOTALPAID_V2 if TOTALPAID != TOTALPAID_V2 & !missing(TOTALPAID_V2) & TOTALPAID_V2 > TOTALPAID
		
		* Special Case of Two Payments
		replace TOTALPAID = TOTALPAID + TOTALPAID_V2 if respondent_id == "3b23107"
		
		drop TOTALPAID_V2

		* Replace total payment == entire stove price for those who chose to pay immediately
		replace TOTALPAID=price_KSH if treatc2==0
		
		* Check to see if there are no missing payments
		assert !missing(TOTALPAID) & !missing(MINPAID)
		
		* Calculate fraction of payments made by respondents 
		g fracpaid = TOTALPAID/MINPAID
		
		* 55 people overpaid 
		count if fracpaid>1 & !missing(fracpaid)
		
		* Replace fraction_paid == 1 if respondents overpaid
		replace fracpaid = 1 if fracpaid>1 & !missing(fracpaid)

		* Check to see that fraction_paid is not missing for any respondent 
		assert !missing(fracpaid)
	
		drop f_payphone
		// payments data clean total 
		save "`data'/public/Payments_Data_Total_replication.dta", replace
}

