include "${main}/Do/0. Master.do"
clear all

	pause off
	
	local import_raw = 1
	local export_Box = 0	// Export the 1) thank you payment, 2) instalment, 3) SMS survey files to Box

	**************************************************************
	**************** Import SurveyCTO data - Visit 3 *************
	************************************************************** 

	if `import_raw' == 1 {

	* Import for each date separately
	foreach date in 0620 0726 {
		preserve
			insheet using "`raw'/Visit 3/Stoves_V3_2019`date'.csv", clear
			if "`date'" != "0620" drop if strpos(today, "Jun 17") | strpos(today, "Jun 18") | strpos(today, "Jun 19") | strpos(today, "Jun 20")
			foreach var in ///
				g_c5_noshow g_c5_1_sold_why g_c5_1_sold_money g_c5_4_payhow  ///
			/*	sms_newnumber* */ /*hhphone*/ {
				cap tostring `var', replace
			}
			replace nosms_select="" if nosms_select=="."
			tempfile import
			save `import'
		restore
		append using `import'
	}
	
	cou
	
	foreach var of varlist * { 
		cap replace `var' = "" if `var'=="."
	}

	assert a_resp==1
	drop a_resp 

	
	drop if key=="uuid:6a039d49-ef1c-47fe-ba07-fc8eb7f0ee04" // Practice
	drop if key=="uuid:d942b2a0-482a-4f9c-bfc7-2b6eb3b9d1cb" // Submitted corrections
	drop if key=="uuid:16a01623-bcb3-4ae0-b8dc-89a5b3f1a2a0" // Submitted corrections
	
	drop if key=="uuid:e0d31ba3-457b-45e2-8bde-65ad24967a82" // Duplicate entries of 027db7f
	
	drop if key=="uuid:f2d0a26e-7c50-4e97-a1ce-7ecc5823e819" // Duplicate entries of 16a512c

	drop if key=="uuid:82dc381d-5456-47af-9288-1dc40d170c81" // Duplicate entries of c9b1z40
	
	drop if key=="uuid:4478de7b-53c7-4b72-b257-687e5725f437" // Duplicate entries of bc765b9 

	drop if key=="uuid:475d7fe4-a3f4-4784-802b-4d00c75c0271" // Wrong person answering, 4az0f46
	
	*drop if key=="uuid:d61d3bd3-e9e9-4229-8636-ebdc74be3dd6" // Added comments
	*drop if key=="uuid:7f82ffc2-6d67-4b88-8db6-a0096fcb7aac" // Added comments
	*drop if key=="uuid:f3bea740-6642-4c4f-9a4f-ae4483fb95e1" // Added comments

	duplicates drop
	isid respondent_id 
	
	save "`datamed'/Visit3_raw_replication.dta", replace

	} 
	************************************************************

	use "`datamed'/Visit3_raw_replication.dta", clear
	
	assert respondent_id==respondent_id2
	drop respondent_id2
	replace respondent_id=lower(respondent_id)
	replace respondent_id=subinstr(respondent_id, "e", "z", .)

	* Survey version: 
	replace formdef_version = formdef_version - 1900000000
	* Fix date:
	g endline_date = date(today, "MDY",2019)
	format endline_date %td

	* Confirm that all Visit 3 respondents can be matched to a Visit 2 survey:
	merge 1:1 respondent_id using "`dataclean'/Visit12_clean_replication_noPII.dta", keepusing(respondent_id baseline_date midline_date) 
	assert _merge != 1 // No Visit 3 for smoeone without a Visit 2
	keep if _merge == 3
	drop _merge 
	
/* Cannot be run, requires PII data. Not relevant for results.
		
		* Export to Suleian for appreciation payments:
	tostring hhphone, replace

	
	if `export_Box'==1 {
		preserve 
		rename hhphone paymentnumber
		rename hhname payname 
		
		g thankyou_visit3 = 300
		
		// Respondent requested to be paid here in comment:
		replace paymentnumber = "********40" if respondent_id == "390z53d" 

		sort endline_date
		if `export_Box' == 1 {
			outsheet /// 
				respondent_id paymentnumber payname thankyou_visit3 endline_date /// 
				using "`dataclean'/stoves_thankyoupayments_ALL_Visit3.csv", comma replace 
		}
		
		outsheet /// 
			respondent_id payname paymentnumber payname thankyou_visit3 endline_date /// 
			using "`dataclean'/stoves_thankyoupayments_ALL_Visit3.csv", comma replace 

		restore
	}*/



	*** ASH WEIGHT DATA 
				
	replace bucket_kg = bucket_weight if missing(bucket_kg) 
	drop bucket_weight

	
	*** CLEAN VARIABLES 
	foreach var of varlist ///
		g_char_w* bucket_* ///
		g_c4_save* g_c4_spend* {
		foreach n in -888 -999 -88 -99 88 99 888 999 {
			replace `var' = . if `var' == `n'
		}
		tab `var', mi
		pause
	}


	*** CHARCOAL REMEMBERING VARIABLES
	*sort endline_date a_foname
	sort endline_date
	
	* First day, some FOs mis-understood this question:
	replace g_char_3days = (g_char_yest + g_char_dby + g_char_3days) if ///
		(g_char_yest + g_char_dby > g_char_3days) & ///
		(endline_date>=21717 & endline_date<=21724 ) // First 3 days of surveying only 
	replace g_char_week = . if g_char_3days>g_char_week & ///
		(endline_date>=21717 & endline_date<=21724 ) // First 3 days of surveying only 
	*tab a_foname if g_char_yest + g_char_dby > g_char_3days, sort
	assert g_char_yest + g_char_dby <= g_char_3days
	assert g_char_3days<=g_char_week

	* Remove useless comments (correctly entered in the actual variables): 
	replace g_c1_comments="" if g_char_3days<g_char_week & !missing(g_char_week)
	replace g_c1_comments="" if g_char_week == 0
	
	* Small edits: 
	replace g_char_3days = 180 if g_c1_comments=="She spends Ksh 60 per day on charcoal, but when she cooks meals like githeri she uses Ksh 120 per day, on average she uses 180 for three days and 420 per week"
	replace g_char_3days = 130 if g_c1_comments=="She buys one debe of charcoal at 100 and uses it for three days, in a week she spends 250 on charcoal"
	
	replace g_char_3days = 150 if g_c1_comments=="The last 3 days she spent Ksh 150 The last 7 days she spent Ksh 300 "
	replace g_char_week  = 300 if g_c1_comments=="The last 3 days she spent Ksh 150 The last 7 days she spent Ksh 300 "
	
	replace g_char_3days = 210 if g_c1_comments=="The last 3 days she spent Ksh 210 The last 7 days she spent Ksh 500"
	replace g_char_week  = 500 if g_c1_comments=="The last 3 days she spent Ksh 210 The last 7 days she spent Ksh 500"
	
	replace g_char_3days = 150 if g_c1_comments=="The last 3 days she spent Ksh 150 The last 7 days she spent Ksh 350"
	replace g_char_week  = 350 if g_c1_comments=="The last 3 days she spent Ksh 150 The last 7 days she spent Ksh 350"
	
	replace g_char_3days = 600  if g_c1_comments=="The last 3 days she spent Ksh 600 The last 7 days she spent Ksh 1,400"
	replace g_char_week  = 1400 if g_c1_comments=="The last 3 days she spent Ksh 600 The last 7 days she spent Ksh 1,400"
	
	replace g_char_week  = 440 if g_c1_comments=="The last 3 days she spent Ksh 150 The last 7 days she spent Ksh 440"
	
	replace g_char_3days = 105 if g_c1_comments=="She used charcoal for Kshs. 70 for 2 days"
	replace g_char_3days = 70  if g_c1_comments=="Now that she  uses jiko okoa she uses Ksh 50 on charcoal for three days, 150 for charcoal in a week"
	
	replace g_char_week  = 250 if g_c1_comments=="The past 3 days she spent Ksh 100 The last 7 days she spent Ksh 250"
	replace g_char_week  = 300 if g_c1_comments=="Last 3 days she spent Ksh 100 Last 7 days she spent Ksh 300"
	replace g_char_week = 280 if g_c1_comments=="3 days she spent Ksh70 7 days she spent Ksh280"
	
	replace g_char_week = 350 if g_c1_comments=="3 days she spent Ksh140 7 days she spent Ksh 350"
	replace g_char_week = 300 if g_c1_comments=="In three days she buys 150ksh In one week she spends 300ish Buys charcoal twice in one week"
	
	replace g_char_week  = 360 if g_c1_comments=="She did spent kes. 240 for the past 3 days and kes. 360 in 7 days"
	replace g_char_3days = 240 if g_c1_comments=="She did spent kes. 240 for the past 3 days and kes. 360 in 7 days"

	replace g_char_week  = 160 if g_c1_comments=="For the past 3 days is kes 120 Spent kes 160 within the past 7 days as she has been away for the past 2 weeks."
	replace g_char_3days = 120 if g_c1_comments=="For the past 3 days is kes 120 Spent kes 160 within the past 7 days as she has been away for the past 2 weeks."

	replace g_char_week  = 200 if g_c1_comments=="Spends 100ksh for 3 days Buys charcoal for 200ksh in one week Buys charcoal twice in one week"
	replace g_char_week  = 600 if g_c1_comments=="For 3 days in a week he spends 300kshs In one week he spends 600ksh  Buys charcoal twice a week"

	replace g_char_week  = 200 if g_c1_comments=="For 3days she spends 100ksh on charcoal In a week she spends 200ksh Buys charcoal twice in a week"
	replace g_char_3days = 150 if g_c1_comments=="In 3days she spends 150ksh on charcoal In one week she spends 300ksh Buys charcoal twice a week"

	replace g_char_3days = 270 if g_c1_comments=="For three days she spends 270 on charcoal In one week she spends 360. Buys charcoal twice in a week"

	* Added a wrong constraints in the survey:
	
	replace g_char_week  = 560 if g_c1_comments=="Used 70 in the past three days and 560 in the past 7 days"
	replace g_char_week  = 280 if g_c1_comments=="Used 70 in the past three days and 280 in the past 7days"
	replace g_char_week  = 350 if g_c1_comments=="3 days 210 and in the past 7days she spent 350"
	replace g_char_week  = 105 if g_c1_comments=="70 used in the last three days and 105 used in the last 7days"
	replace g_char_week  = 490 if g_c1_comments=="Used 140 in the past three days and 490 in the past 7 days"
	replace g_char_week = 240 if g_c1_comments=="She bought  charcoal worth Kshs. 240 for the whole week."
	replace g_char_week  = 250 if g_c1_comments=="She used charcoal worth Kshs. 250 for the past one week"
	replace g_char_week = 630 if g_c1_comments=="In the past 3 days the respondent used  Kshs. 90 and in the past one week she used Kshs. 630"

	replace g_char_week  = 315 if g_c1_comments=="She uses Ksh 45 daily on charcoal since she started using jiko okoa, 135 for three days and 315 per week"
	replace g_char_3days = 135 if g_c1_comments=="She uses Ksh 45 daily on charcoal since she started using jiko okoa, 135 for three days and 315 per week"

	replace g_char_dby  = 150 if g_c1_comments=="She uses 150 per day on most days, in a week she uses 1050 on charcoal, 450 for three days"
	replace g_char_week  = 1050 if g_c1_comments=="She uses 150 per day on most days, in a week she uses 1050 on charcoal, 450 for three days"
	replace g_char_3days = 450 if g_c1_comments=="She uses 150 per day on most days, in a week she uses 1050 on charcoal, 450 for three days"

	replace g_char_week  = 250 if g_c1_comments=="She uses less charcoal now that she uses jiko okoa.She uses Ksh 100 on charcoal for three days,and, in a week she spends 250 on charcoal"
	
	replace g_char_week  = 700 if g_c1_comments=="3 days she spent Ksh 300 7 days she spent Ksh 700"
	replace g_char_3days = 300 if g_c1_comments=="3 days she spent Ksh 300 7 days she spent Ksh 700"

	replace g_char_week  = 980 if g_c1_comments=="Usage for 3 days is Ksh 420 For 7 days is Ksh 980"
	replace g_char_3days = 420 if g_c1_comments=="Usage for 3 days is Ksh 420 For 7 days is Ksh 980"

	replace g_char_week  = 500 if g_c1_comments=="For 3 days is Ksh 300 For  7 days is Ksh 500"
	replace g_char_3days = 300 if g_c1_comments=="For 3 days is Ksh 300 For  7 days is Ksh 500"

	replace g_char_week  = 640 if g_c1_comments=="Total money spent on charcoal in the last three days is kes. 240 Total money spent on charcoal in the last 7days is kes. 640"
	replace g_char_3days = 240 if g_c1_comments=="Total money spent on charcoal in the last three days is kes. 240 Total money spent on charcoal in the last 7days is kes. 640"

	replace g_char_week  = 270 if g_c1_comments=="Past 3 days has used kes180 7days has spend kes 270"
	replace g_char_3days = 180 if g_c1_comments=="Past 3 days has used kes180 7days has spend kes 270"

	replace g_char_week  = 800 if g_c1_comments=="For the past 3 days, she has spent 520  And for the past 7 days she did spent 800 in total"
	replace g_char_3days = 520 if g_c1_comments=="For the past 3 days, she has spent 520  And for the past 7 days she did spent 800 in total"

	replace g_char_week  = 700 if g_c1_comments=="For 3 days she spends, 420 In a week, she spends 700"
	replace g_char_3days = 420 if g_c1_comments=="For 3 days she spends, 420 In a week, she spends 700"

	replace g_char_week  = 640 if g_c1_comments=="For 3 days she spends 420 on charcoal For 7days in a week, she spends 640ksh"
	replace g_char_3days = 420 if g_c1_comments=="For 3 days she spends 420 on charcoal For 7days in a week, she spends 640ksh"

	replace g_char_week  = 420 if g_c1_comments=="For 3 days she spends 210 ksh In a week she spends 420ksh"
	replace g_char_3days = 210 if g_c1_comments=="For 3 days she spends 210 ksh In a week she spends 420ksh"

	replace g_char_week  = 420 if g_c1_comments=="For 3days he uses 210ksh on charcoal In one week, he uses 420 ksh"
	replace g_char_3days = 210 if g_c1_comments=="For 3days he uses 210ksh on charcoal In one week, he uses 420 ksh"

	replace g_char_week  = 280 if g_c1_comments=="3days-140 7days-280"
	replace g_char_3days = 140 if g_c1_comments=="3days-140 7days-280"

	replace g_char_week  = 800 if g_c1_comments=="3days-400 7days-800"
	replace g_char_3days = 400 if g_c1_comments=="3days-400 7days-800"

	replace g_char_week  = 560 if g_c1_comments=="3days -240 7days-560"
	replace g_char_3days = 240 if g_c1_comments=="3days -240 7days-560"

	replace g_char_week  = 600 if g_c1_comments=="3days-300 7days-600"
	replace g_char_3days = 300 if g_c1_comments=="3days-300 7days-600"

	replace g_char_week  = 240 if g_c1_comments=="For 3 days have used 120 For 7 days used 240"
	replace g_char_3days = 120 if g_c1_comments=="For 3 days have used 120 For 7 days used 240"

	replace g_char_week  = 450 if g_c1_comments=="Past 3 days kes. 240 In 7'days kes. 450"
	replace g_char_3days = 240 if g_c1_comments=="Past 3 days kes. 240 In 7'days kes. 450"

	replace g_char_week  = 500 if g_c1_comments=="For the past 3 days she has used kes 240 For 7 days she has used 500"
	replace g_char_3days = 240 if g_c1_comments=="For the past 3 days she has used kes 240 For 7 days she has used 500"

	replace g_char_week  = 700 if g_c1_comments=="The respondent used 300 in the last 3 days and 700 in the last 7 days"
	replace g_char_3days = 300 if g_c1_comments=="The respondent used 300 in the last 3 days and 700 in the last 7 days"

	replace g_char_week  = 245 if g_c1_comments=="Used charcoal worth 105 in the last 3 days and 245 for the last 7 days"
	replace g_char_3days = 105 if g_c1_comments=="Used charcoal worth 105 in the last 3 days and 245 for the last 7 days"

	replace g_char_week  = 280 if g_c1_comments=="Used charcoal worth 120 in the last 3 days and 280 in the past 7 days"
	replace g_char_3days = 120 if g_c1_comments=="Used charcoal worth 120 in the last 3 days and 280 in the past 7 days"

	replace g_char_week  = 490 if g_c1_comments=="For 3days she spend ksh 210 and spend  ksh 490 in 7days"
	replace g_char_3days = 210 if g_c1_comments=="For 3days she spend ksh 210 and spend  ksh 490 in 7days"

	replace g_char_week  = 150 if g_c1_comments=="3days she spend ksh.75 and ksh.150 in 7 days of charcoal"
	replace g_char_3days = 75 if g_c1_comments=="3days she spend ksh.75 and ksh.150 in 7 days of charcoal"

	replace g_char_week  = 420 if g_c1_comments=="3days she spent ksh.210 and ksh 420 in 7days on charcoal"
	replace g_char_3days = 210 if g_c1_comments=="3days she spent ksh.210 and ksh 420 in 7days on charcoal"

	replace g_char_week  = 240 if g_c1_comments=="3days she spend ksh.240 and spend ksh 240 in the last 7days to since she had travelled."
	replace g_char_3days = 240 if g_c1_comments=="3days she spend ksh.240 and spend ksh 240 in the last 7days to since she had travelled."

	replace g_char_week  = 700 if g_c1_comments=="3days, she spend ksh.300 and spend ksh 700 for 7days"
	replace g_char_3days = 300 if g_c1_comments=="3days, she spend ksh.300 and spend ksh 700 for 7days"

	replace g_char_week  = 210 if g_c1_comments=="The respondent has used 140 shillings for charcoal in the past three days and 210 in one week since the household buys charcoal thrice in a week"
	replace g_char_3days = 140 if g_c1_comments=="The respondent has used 140 shillings for charcoal in the past three days and 210 in one week since the household buys charcoal thrice in a week"

	replace g_char_week  = 600 if g_c1_comments=="The respondent has used 200 in the last three days and Six hundred in the last seven days"
	replace g_char_3days = 200 if g_c1_comments=="The respondent has used 200 in the last three days and Six hundred in the last seven days"

	replace g_char_week  = 490 if g_c1_comments=="The respondent for the past 3 days has used 210 and 490 in one week"
	replace g_char_3days = 210 if g_c1_comments=="The respondent for the past 3 days has used 210 and 490 in one week"

	replace g_char_week  = 210 if g_c1_comments=="The respondent has used 70 in the last three days and 210 in a week"
	replace g_char_3days = 70  if g_c1_comments=="The respondent has used 70 in the last three days and 210 in a week"

	replace g_char_week  = 300 if g_c1_comments=="3 days=Ksh.100 7 days=Ksh. 300"
	replace g_char_week  = 600 if g_c1_comments=="Last 3 days total =Ksh.300 and last 7 days=Ksh.600"
		
	* Measurement invalid if = 0 (person just was not measuring)
	replace bucket_kg = . if bucket_kg == 0

	* Person mixed up lbs and kg: 
	replace bucket_lbs = 4.2 if key=="uuid:f3bea740-6642-4c4f-9a4f-ae4483fb95e1"
	replace bucket_kg = 2 if key=="uuid:f3bea740-6642-4c4f-9a4f-ae4483fb95e1"
	
	replace bucket_lbs = 3 if key=="uuid:893b41f8-9243-40df-8942-c2dd7cdccb6a"
	replace bucket_kg = 2 if key=="uuid:893b41f8-9243-40df-8942-c2dd7cdccb6a"
	
	
	*
	reg bucket_kg g_char_week

	* Roughly, 30 KSH = 1 KG of charcoal
	local conversion = 30

	
	* KG Purchased: 
	g char_used_month_kg = ((g_char_week*(30.5/7))/`conversion') // Kilograms
	reg bucket_kg char_used_month_kg
	
	g log_bucket_kg = asinh(bucket_kg) 
	g log_char_used_month_kg = asinh(char_used_month_kg)
	
	reg log_bucket_kg log_char_used_month_kg
	reg bucket_kg char_used_month_kg

	* Standardize by number of days between visits to reduce noise:
	g bucket_kg_st = (bucket_kg / (endline_date - midline_date)) * 25 
	g log_bucket_kg_st = log(bucket_kg_st) 
	g ihs_bucket_kg_st = asinh(bucket_kg_st)
	lab var bucket_kg_st "Bucket weight (KG, standardized)"
	lab var log_bucket_kg_st "Log of bucket weight (KG, standardized)"
	lab var ihs_bucket_kg_st "IHS of bucket weight (KG, standardized)"
	
	*/
	tab g_char_week, mi



	*** NETWORK IMPACTS
	replace g_c3_neighbors = 0 if missing(g_c3_neighbors) & g_c2_neighbors==0
	assert !missing(g_c3_neighbors)
	foreach var of varlist g_c3_family g_c3_friends g_c3_other {
		replace `var' = 0 if missing(`var') & g_c2_others==0
		assert !missing(`var')
	}
	g g_c3_TOTAL = g_c3_neighbors + g_c3_family + g_c3_friends + g_c3_other
	bys hhstove: su g_c3_TOTAL
	pause

	*** STOVE
	assert g_stove!=1
	bys hhstove: su g_stove_other

	*** BELIEFS
	cou if g_c4_spend_jikokoa> g_c4_spend_jiko 
	assert `r(N)'==5

	*** TASTE etc
	tab g_c5_6_taste
	tab d3_taste

	// Traditional owners: g_c4_save_jiko g_c4_spend_jiko g_c4_spend_jikokoa
	// New owners: g_c4_save_jiko2 g_c4_spend_jiko2 g_c4_spend_jikokoa2

	*** HEALTH

	assert !missing(d2_cough_resp)
	assert !missing(d2_breath_resp)
	egen health_index_v3 = rowmean(	d2_cough_resp 	d2_breath_resp 	///
							d2_cough_child 	d2_breath_child )							
	assert !missing(health_index_v3)
	lab var health_index_v3 	"Index of Health (Endline)"
						
	reg health hhstove

	replace d3_taste = lower(d3_taste)
	replace d3_taste = "" if d3_taste=="no"
				
	* br d_ivself*


	************************************************************

	g Visit3 = 1
	
	drop submissiondate today duration instanceid formdef_version key 
	drop /*hhphone hhname*/ hhwtp hhpay hhstove treatc treatc2 bdmweekly bdmmonthly 
	drop tasksv2 tasksv3 midline_date 
	drop nosms_* received_sms sms_responded sms_noairtime 
	
	foreach var of varlist  g1a g1b g1c ///
		 g2a g2b g2b2 g2c g1g1 		/*z_info_note */ ///
		baseline_date /* bz7 */ d2_breath_child d2_breath_resp d2_cough_child ///
		d2_cough_resp d2_hours_child d2_hours_resp f_health_longterm f_health_trad_adult ///
		f_health_trad_child f_health_work g1b_1 g1b_2 g1b_3 g1b_96 ///
		g_char* /*sms_newnumber sms_newnumber2 */	{
		rename `var' `var'_v3
	}
	
		
	save "`dataclean'/Visit3_clean_replication.dta", replace
	

	
	merge 1:1 respondent_id using "`dataclean'/Visit12_clean_replication_noPII.dta"
	
	assert _merge != 1 // Never a Visit 3 that does not have a Visit 2
	drop _merge 

	replace Visit3=0 if missing(Visit3)

	* Should have data from June 17-20, 24-30, July 1-today
	tab endline

	save "`dataclean'/Visit123_clean_replication_noPII.dta", replace

