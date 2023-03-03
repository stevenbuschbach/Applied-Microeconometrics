	clear all
	* Master settings:
	include "${main}/Do/0. Master.do"
	pause off
	
	local import_raw = 1
	local export_Box = 0	// Export the 1) thank you payment, 2) instalment, 3) SMS survey files to Box

	 
	
	**************************************************************
	**************** Import SurveyCTO data - Visit 3 *************
	************************************************************** 

	if `import_raw' == 1 {
		insheet using "`raw'/Endline/Stoves_E2020S_WIDE.csv", clear

	foreach var of varlist * { 
		cap replace `var' = "" if `var'=="."
	}

	outsheet using "`datamed'/Stoves_E2020S_WIDE_replication_noPII.csv", replace comma
	
	local datum : di %tdNN-dd-YYYY daily("$S_DATE","DMY")
	
	preserve
	generate formated_date = date(submissiondate, "MDYhm")
	keep if formated_date <= 22089
	save "`datamed'/Endline1_raw_replication_noPII.dta", replace
	restore
	}
	
	
	************************************************************

	cd "`datamed'"
	include "${main}/Do/ImportStovesE2020.do"
	
	assert a_resp==1
	drop a_resp 

	isid respondent_id 
	
	tab today 

	assert respondent_id==respondent_id2
	drop respondent_id2
	replace respondent_id=lower(respondent_id)
	replace respondent_id=subinstr(respondent_id, "e", "z", .)
	
	drop submissiondate tablet_id duration /* hhphone hhname */ key 
	
	* Survey version: 
	replace formdef_version = formdef_version - 2000000000
	* Fix date:
	rename today endline1_date 
	
	* Confirm that all Visit 3 respondents can be matched to a Visit 2 survey:
	merge 1:1 respondent_id using "`dataclean'/Visit12_clean_replication_noPII.dta", keepusing(respondent_id) 
	assert _merge != 1 // No Endline 1 for someone without a Visit 2
	keep if _merge == 3
	drop _merge 
		
	sort respondent_id	
	save "`dataclean'/Endline1_clean_replication_noPII.dta", replace
	

