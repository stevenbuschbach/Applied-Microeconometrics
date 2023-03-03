/*This replicates all except for:
(i) randomized variables,
(ii) received_sms (it has a correction that does not invalidate the main results)

NOTE: the output is not actually used in the next script (CleanV2.do). 
This is because to replicate the original results we need the exact values
for all of the randomized variables.
This script is there is to show the procedure that we followed.*/

clear all 
include "${main}/Do/0. Master.do"
set rng kiss32

use "`raw'/Visit1_medium_original.dta", clear 

sort respondent_id 

***************************************************************
*************** AFTER VISIT 1 IS COMPLETE *********************
***************************************************************

// Fix seed moving forward (same as above)
set seed 		258429
set sortseed 	545073

********* Assign hidden BDM prices, stratifying on the 9 treatment cells & baseline charcoal spending *********

* Generate Strata Variable
gen tiebreak=runiform()

* Sort NEGATIVELY by d_charcoalbuy so that the lowest consumers
* (likely with lower variance) are misfits
gsort treat_cells -d_charcoalbuy tiebreak
by treat_cells: g strata=ceil(_n/18)
drop tiebreak

tab strata
bys strata: su d_charcoalbuy
tab treat_cells strata // Want to have 18 in each cell 
pause

randtreat, generate(treat_region) strata(treat_cells strata) unequal(1/18 7/18 8/18 2/18) misfits(wstrata)

gen bdmprice = (treat_region==0)*round(runiform(350, 450)) + (treat_region==1)*round(runiform(1000, 1200)) + (treat_region==2)*round(runiform(2500, 2700)) + (treat_region==3)*round(runiform(1, 2989))

drop treat_region
lab var bdmprice "BDM Price"
pause

* Check for balance
bys treata_p treatc_p: su bdmprice
bys treat_cells: su bdmprice
bys strata: su bdmprice
pause
su d_charcoalbuy if bdmprice>=350 & bdmprice<=450
su d_charcoalbuy if bdmprice>=1000 & bdmprice<=1200
su d_charcoalbuy if bdmprice>=2500 & bdmprice<=2700
pause

/*
********* Tracking Sheet for use by FOs *********

g Visit2_targetdate = baseline_date+28
format Visit2_targetdate %tdmon-DD

/*rename a_foname a_foname_visit1 */
*/
*sort Visit2_targetdate
*sort a_area Visit2_targetdate a_village
/*
export excel a_area Visit2_targetdate a_village ///
	respondent_id name ///
	/*phone_number b_phoneb1 newphone_number*/ ///
	gpslatitude gpslongitude /* a_foname_visit1*/ ///
	using "`dataclean'/Visit2_Contacts.xlsx", ///
	replace firstrow(variables)

export excel a_area Visit2_targetdate a_village ///
	respondent_id/* name*/ ///
	/*phone_number b_phoneb1 newphone_number*/ ///
	gpslatitude gpslongitude /*a_foname_visit1*/ ///
	using "`dataclean'/Visit2_Contacts.xlsx", ///
	replace firstrow(variables)
*/

********* Export for BDM envelopes *********

*sort a_area Visit2_targetdate a_village

/*
forv n = 1/5 {
	export excel /// 
		a_area a_village Visit2_targetdate respondent_id name bdmprice phone_number /// 
		using "`data'/Visit2_BDMenvelopes_draft_week`n'.xlsx" if week==`n', replace firstrow(variables)
}
*/

 
********* Assign PRACTICE BDM prices *********

g pracBDMitem = (runiform()<0.5) // Choosing which 1 out of the 2 goods to get for TIOLI v BDM practice
tostring pracBDMitem, replace 
replace pracBDMitem="Lotion" if pracBDMitem=="0"
replace pracBDMitem="KipandeYaSabuni" if pracBDMitem=="1"

g pracTIOLIitem = "Lotion" if pracBDMitem == "KipandeYaSabuni" 
replace pracTIOLIitem = "KipandeYaSabuni" if pracBDMitem == "Lotion" 

tab pracBDMitem pracTIOLIitem
pause

cap drop pracBDMprice*

g pracBDMprice1 = rnormal(100, 35) 
g pracBDMprice2 = rnormal(100, 35) 
forv z = 1/10 {
	forv n = 1/2 {
		* Store price: 120 & 150 
		replace pracBDMprice`n'=rnormal(100, 35) if pracBDMprice`n'<1 | pracBDMprice`n'>110
		replace pracBDMprice`n'=round(pracBDMprice`n')
	}
}
forv n = 1/2 {
	assert pracBDMprice`n'>=1 & pracBDMprice`n'<=110
}
assert pracBDMprice1+pracBDMprice2<=300

pause

su pracBDMprice1
su pracBDMprice2
pause

* Bar soap is 120, Lotion 100, so increase bar soap prices slightly: 
replace pracBDMprice1=round(pracBDMprice1*1.2) if pracTIOLIitem=="KipandeYaSabuni"
replace pracBDMprice2=round(pracBDMprice2*1.2) if pracBDMitem=="KipandeYaSabuni"
pause

bys pracTIOLIitem: su pracBDMprice1, d
bys pracBDMitem: su pracBDMprice2, d

pause

hist pracBDMprice2 if pracBDMitem=="KipandeYaSabuni", width(10) start(0) freq lcolor(gs12) color(gs10) `white' ylabel(, nogrid)
pause
hist pracBDMprice2 if pracBDMitem=="Lotion", width(10) start(0) freq lcolor(gs12) color(gs10) `white' ylabel(, nogrid)
pause

tab pracBDMprice1 pracTIOLIitem, mi
tab pracBDMprice2 pracBDMitem, mi
rename pracBDMprice1 pracpriceTIOLI
rename pracBDMprice2 pracpriceBDM
lab var pracpriceTIOLI  "PLANNED TIOLI price (Ksh)"
lab var pracpriceBDM 	"PLANNED BDM practice price (Ksh)" 
pause

********* Assign a random effort task between 1-10 *********

g random10 = floor(runiform()*10)+1
tab random10, mi
pause
assert random10>=1 & random10<=10

********* Did we receive any SMS from this respondent? *********

replace respondent_id="380e07" if respondent_id=="3.80E+07"
replace respondent_id=lower(respondent_id)
replace respondent_id = subinstr(respondent_id, "e", "z", .)
replace respondent_id = subinstr(respondent_id, "+", "", .)
replace respondent_id = subinstr(respondent_id, ".", "", .)

merge 1:1 respondent_id using "`raw_confidential'/SMS_any_resp_replication.dta"
drop if _merge == 2
assert _merge == 1 | _merge == 3
drop _merge

replace received_sms=0 if missing(received_sms) 
assert received_sms==0 | received_sms==1
tab baseline_date received_sms, mi

pause

********* Did this respondent receive their Visit 1 payment late? *********

g thankyou_late = (baseline_date <= 21664)
tab thankyou_late, mi


saveold "`datamed'/Visit1_clean_replication_without_PII.dta", replace version(12)


