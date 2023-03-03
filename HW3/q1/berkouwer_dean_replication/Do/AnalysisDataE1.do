include "${main}/Do/0. Master.do"

pause off

local import_raw = 1
local export_Box = 0	// Export the 1) thank you payment, 2) instalment, 3) SMS survey files to Box


use "`dataclean'/Endline1_clean_replication_noPII.dta", clear

*** SPENDING
assert g_char_yest <= g_char_3days
assert g_char_3days<=g_char_week

lab var g_char_week 	"Charcoal spending (Week; KSH)"
lab var g_char_3days	"Charcoal spending (3 days; KSH)"
lab var g_char_yest		"Charcoal spending (Yesterday; KSH)"

lab var g_stove "Have you purchased a Jikokoa since we last visited?"

replace g_c5_other="" if respondent_id=="789dcb9"
replace g_c5_gone=. if respondent_id=="789dcb9"
replace g_jikokoa=1 if respondent_id=="789dcb9"

g g_char_week_USD =  g_char_week/100	
lab var g_char_week_USD 	"Charcoal spending (Week; USD)"


*** CHARCOAL REMEMBERING VARIABLES
sort endline1_date


* This person gave weird answers in their endline; says they never got the stove (even though in Visit2 and Visit3 they were reasonable + we have record of them paying full amount)

* Drop any 1-year endline survey where stove status is "I never got a jikokoa" 
drop if respondent_id=="798z07" 
drop if respondent_id=="z95zab8" 
drop if respondent_id=="23afd44"


************************************************************
g Endline1 = 1

foreach var of varlist g_*  d2_* g1* g2* c_charcoal* {
	rename `var' el1_`var'
}


merge 1:1 respondent_id using "`dataclean'/Visit123_analysis_replication_noPII.dta"

/* These are the participants dropped from Visit123 because:
 (i) they returned the stove, or
 (ii)  the FO mentions that the respondent was surveyed twice and it is 
 unclear which responses are correct and appear in the data, or
 (iii)  FO filled in the wrong respondent's details.*/
drop if _merge == 1


drop _merge 
replace Endline1=0 if missing(Endline1)

foreach resp in 798z07 z95zab8 23afd44 {
	list respondent_id Visit2 Visit3 Endline1 if respondent_id == "`resp'"
}


save "`dataclean'/Visit123_E1_analysis_replication.dta", replace


	