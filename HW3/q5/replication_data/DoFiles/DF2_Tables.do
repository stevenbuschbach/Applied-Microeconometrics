// This code create the Tables in the main text and appendix
clear
clear mata
clear matrix
set more  off
set graph off
set maxvar  32767
set matsize 11000
set emptycells drop
*cd  "/home/aneko/OUI/DF2/RR2/"

//Key variables
use "../Data/Data_public.dta", clear
	g age_p1 = age^1
	g age_p2 = age^2
	g age_p3 = age^3
	g age_p4 = age^4
	g age40 = age>=40
	g age_q1 = ((age-40)^1)*age40
	g age_q2 = ((age-40)^2)*age40
	g age_q3 = ((age-40)^3)*age40
	g age_q4 = ((age-40)^4)*age40
	g lwage0    = ln(monthly_wage_0)
	g lwagen0   = ln(monthly_wage_n0) 
	g ay1	    = ned if ned<2*365
	g ay2       = ned<=30*7
	g ay3       = ned<=39*7
	g ay4       = wg_c if ned<2*365
	g ay5       = lwagen0               if ned<2*365 & wv
	g ay6       = lwagen0>lwage0+ln(.5) if ned<2*365 & wv & !mi(lwagen0) & !mi(lwage0)


//global var lists
// gl varp1 age_p1				  			age_q1	
gl varp2 age_p1	age_p2 age_q1 age_q2	
// gl varp3 age_p1	age_p2	age_p3		  	age_q1	age_q2	age_q3	
// gl varp4 age_p1	age_p2	age_p3	age_p4  age_q1	age_q2	age_q3	age_q4
// gl cova  i.end_w  // many covariates are not included in the public data, so the estimates with controls are not replicable

// T2
local tn = "2"

cap drop y
g y = ay1
qui sum y if abs(age-40)<3
local mem = r(mean)
qui reg y  age40 $varp2
qui outreg2 using table_`tn',  noparen nocons excel keep(age40) addstat("Mean", `mem') replace 

cap drop y
g y = ay2
qui sum y if abs(age-40)<3
local mem = r(mean)
qui reg y age40 $varp2
qui outreg2 using table_`tn',  noparen nocons excel keep(age40)  addstat("Mean", `mem')  append

cap drop y
g y = ay3
qui sum y if abs(age-40)<3
local mem = r(mean)
qui reg y age40 $varp2
qui outreg2 using table_`tn',  noparen nocons excel keep(age40)  addstat("Mean", `mem')  append

											
cap drop y
g y = ay4
qui sum y if abs(age-40)<3
local mem = r(mean)
qui reg y  age40 $varp2
qui outreg2 using table_`tn',  noparen nocons excel keep(age40)  addstat("Mean", `mem')  append
						
cap drop y
g y = ay5
qui sum y if abs(age-40)<3
local mem = r(mean)
qui reg y  age40 $varp2
qui outreg2 using table_`tn',  noparen nocons excel keep(age40)  addstat("Mean", `mem')  append
											
cap drop y
g y = ay6
qui sum y if abs(age-40)<3
local mem = r(mean)
qui reg y  age40 $varp2
qui outreg2 using table_`tn',  noparen nocons excel keep(age40)  addstat("Mean", `mem')  append

