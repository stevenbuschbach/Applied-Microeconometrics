// Figures for main text and appendix
clear all
set more  off
set graph off
*cd  "/home/aneko/OUI/DF2/RR2/"

// Key variables
use "../Data/Data_public.dta", clear
	local ii = 3  
	gen agec = (int(age*`ii')/`ii')+1/(2*`ii')
	bys agec: gen id0 =_n
	g age_p1    = age^1
	g age_p2    = age^2
	g age_p3    = age^3
	g age_p4    = age^4
	g age40     = age>=40
	g age_q1    = ((age-40)^1)*age40
	g age_q2    = ((age-40)^2)*age40
	g age_q3    = ((age-40)^3)*age40
	g age_q4    = ((age-40)^4)*age40
	g lwage0    = ln(monthly_wage_0)
	g lwagen0   = ln(monthly_wage_n0) 
	g ay1	    = ned if ned<2*365
	g ay2       = ned<=30*7
	g ay3       = ned<=39*7
	g ay4       = wg_c if ned<2*365
	g ay5       = lwagen0               if ned<2*365 & wv
	g ay6       = lwagen0>lwage0+ln(.5) if ned<2*365 & wv & !mi(lwagen0) & !mi(lwage0)
tempfile Data_II
save `Data_II', replace
	
// Global var lists
gl varp1 age_p1				  	age_q1	
gl varp2 age_p1	age_p2			  	age_q1	age_q2	
gl varp3 age_p1	age_p2	age_p3		  	age_q1	age_q2	age_q3	
gl varp4 age_p1	age_p2	age_p3	age_p4  	age_q1	age_q2	age_q3	age_q4
/*gl cova  /// many covariates are not included in the public data, so the estimates with controls are not replicable
	i.recalls_bl3yc   i.rrecalls_l3yc  i.recallrate_c    i.recallrate_4c i.end_w  ///
	i.industry   i.region  i.blue i.education i.female i.married i.aust ///  
	i.tenure_c i.work5_c i.work2_c  i.firmsize_c_m   i.malefrac_c_m i.workerage_c_m i.meanWage_c_m i.exp_r_m*/


//F1 
//panel A
use `Data_II', clear
	gen tot = _N
	bys agec: gen nec = _N
	replace nec = nec/tot
	
twoway ///
	(scatter nec   agec   if id0==1, mcolor(black) msize(small)) ///
	(qfit    nec   agec   if id0==1 & age>40, lcolor(black) ) ///
	(qfit    nec   agec   if id0==1 & age<40, lcolor(black) ), ///
	xline(40, lp(dash) lcolor(gs10)) ///
	xt("Age at layoff") yt("Density") leg(off) graphregion(fcolor(white)) ///
	subtitle("Panel a: Distribution of Age",size(small)) 
	
//Panel B
gen y = ln(monthly_wage_0)
egen m  = mean(y), by(agec)
twoway ///
	(scatter m    agec if   id0==1, mcolor(black) msize(small)) /// 
	(qfit    y    age   if   age>=40, lcolor(black) ) ///
	(qfit    y    age   if   age<40 , lcolor(black) ), ///
	xline(40, lp(dash) lcolor(gs10)) graphregion(fcolor(white)) legend(off)  ///
	ytitle("Log previous wage") xt("Age at layoff")  ///
	subtitle("Panel b: Covariates Around UI Extension Threshold",size(small) ) name(F1B, replace)
	
gr combine F1A F1B, col(1) graphregion(fcolor(white)) ysize(8.5) xsize(5.5)  name(F1, replace)
qui graphexportpdf Figure01

//F2
use "../Data/Data_public_pre_reform.dta", clear 
	gen ay1 = ned if ned<2*365
	gen ay4 = wg_c if ned<2*365
	local ii = 3
	gen agec = (int(age*`ii')/`ii')+1/(2*`ii')
	bys agec: gen id0 =_n
	gen y = ay1
	egen m = mean(y), by(agec)
	
twoway ///
	(scatter m    agec if   id0==1, mcolor(black) msize(small)) /// 
	(qfit    ay1    age   if   age>=40, lcolor(black) ) ///
	(qfit    ay1    age   if   age<40 , lcolor(black) ), ///
	xline(40, lp(dash) lcolor(gs10)) graphregion(fcolor(white)) legend(off)  ///
	ytitle("Non-employment duration (days)") xtitle("Age at layoff") subtitle("Panel a",size(small) ) ///
	       name(F2A, replace)
		   
cap drop y m
gen y = ay4
egen m  = mean(y), by(agec)
twoway ///
	(scatter m    agec if   id0==1, mcolor(black) msize(small)) /// 
	(qfit    y    age   if   age>=40, lcolor(black) ) ///
	(qfit    y    age   if   age<40 , lcolor(black) ), ///
	xline(40, lp(dash) lcolor(gs10)) graphregion(fcolor(white)) legend(off)  ///
	ytitle("Wage change between jobs") ///
	xtitle("Age at layoff") subtitle("Panel b",size(small) ) name(F2B, replace)
drop y m 

gr combine F2A F2B, col(1) graphregion(fcolor(white)) name(F2, replace) ysize(8.5) xsize(5.5)  
qui graphexportpdf Figure02

//F3
use `Data_II', clear
	gen y = ay1
	local tit = "Non-employment duration"
	egen m  = mean(y), by(agec)
	
twoway ///
	(scatter m    agec  if   id0==1, mcolor(black) msize(small)) /// 
	(qfit    y    age   if   age>=40, lcolor(black) ) ///
	(qfit    y    age   if   age<40 , lcolor(black) ), ///
	xline(40, lp(dash) lcolor(gs10)) graphregion(fcolor(white)) legend(off) ///
	ytitle("`tit'") xtitle("Age at layoff") subtitle("Panel a ",size(small) ) name(F3a, replace)
	
drop y m 
gen y = ay3
local tit = "Prob. of finding job within 39 weeks"
egen m  = mean(y), by(agec)

twoway ///
	(scatter m    agec if   id0==1, mcolor(black) msize(small)) /// 
	(qfit    y    age   if   age>=40, lcolor(black) ) ///
	(qfit    y    age   if   age<40 , lcolor(black) ), ///
	xline(40, lp(dash) lcolor(gs10)) graphregion(fcolor(white)) legend(off)  ///
	ytitle("`tit'")  subtitle("Panel b ",size(small) ) xtitle("Age at layoff") name(F3b, replace) 
	
drop y m
gen y = ay4
local tit = "Wage change between jobs"
egen m  = mean(y), by(agec)

twoway ///
	(scatter m    agec if   id0==1, mcolor(black) msize(small)) /// 
	(qfit    y    age   if   age>=40, lcolor(black) ) ///
	(qfit    y    age   if   age<40 , lcolor(black) ), ///
	xline(40, lp(dash) lcolor(gs10)) graphregion(fcolor(white)) legend(off) ///
	ytitle("`tit'") xtitle("Age at layoff") subtitle("Panel c",size(small) ) name(F3c, replace)
	
drop y m 
gen y = ay6   
local tit = "Prob(New wage > 0.5 old wage)"
egen m = mean(y), by(agec)

twoway ///
	(scatter m    agec if   id0==1, mcolor(black) msize(small)) /// 
	(qfit    y    age   if   age>=40, lcolor(black) ) ///
	(qfit    y    age   if   age<40 , lcolor(black) ), ///
	ytitle("`tit'") xline(40, lp(dash) lcolor(gs10)) graphregion(fcolor(white)) legend(off) ///
	xtitle("Age at layoff") subtitle("Panel d",size(small) ) name(F3d, replace) 
	
gr combine F3a F3c F3b F3d, col(2) graphregion(fcolor(white))  ysize(8.5) xsize(11) 
qui graphexportpdf Figure03


/*
{ //F4  & TableA9 
{ //F4a 
import delimited LittStata.txt, clear
replace ewg    = subinstr(ewg   , ",", ".",.)
replace ewg_sd = subinstr(ewg_sd, ",", ".",.) 
replace eud    = subinstr(eud   , ",", ".",.)
replace eud_sd = subinstr(eud_sd, ",", ".",.)
replace eud_r  = subinstr(eud_r, ",", ".",.) 
destring, replace
g eud_c1 = eud-1.96*eud_sd
g eud_c2 = eud+1.96*eud_sd
g ewg_c1 = ewg-1.96*ewg_sd
g ewg_c2 = ewg+1.96*ewg_sd
g ui_e = ui_s+ui_d
g ui_e_e = ui_d/ui_s
replace ewg_c1=-.03  if p=="Lalive(b)"  
g r=0
twoway ///
(rspike  ewg_c1 ewg_c2 eud, lc(black)) ///
(rspike  eud_c1 eud_c2 ewg, lc(black) hor) ///
(scatter ewg           eud, mlabel(p) mlabcolor(black) mcolor(black) mlabsize(vsmall) mlabposition(8) msize(small)) ///
, leg(off) xline(0, lc(gs10)) yline(0, lc(gs10)) graphregion(fcolor(white)) xt("UI effect on non-enmployment duration") yt("UI effect on wage") ///
subt("Panel a: Results across studies" , size(small)) name(F4a, replace)
local tn = "A9"
local mem =0
qui reg ewg eud
											qui outreg2 using table_`tn',  noparen nocons excel addstat("Mean", `mem')  replace
qui reg ewg eud_r
											qui outreg2 using table_`tn',  noparen nocons excel addstat("Mean", `mem')  append
qui reg ewg ui_s
											qui outreg2 using table_`tn',  noparen nocons excel  addstat("Mean", `mem')  append
qui reg ewg ui_e
											qui outreg2 using table_`tn',  noparen nocons excel addstat("Mean", `mem')  append
qui reg ewg ui_e_e
											qui outreg2 using table_`tn',  noparen nocons excel addstat("Mean", `mem')  append
							
}
{ //F4b
use if es & ned<2*365 & !mi(ay4) using "Data.dta", clear
{ //Create variables
cap drop ee
g ee= end_m*31+end_d 

g        x1c = female
g        x2c = married
g        x3c = blue
g        x4c = aust
g        x5c = exp_r
egen  x6c = xtile(tenure)       , n(2)
egen  x7c = xtile(end)          , n(2)                            
egen  x8c = xtile(ee)           , n(2) 
egen  x9c = xtile(zipcode_m)    , n(2)
egen  x10c = xtile(work5)       , n(2)
egen  x11c = xtile(nace95)      , n(2)
egen  x12c = xtile(firmsize)    , n(2)
egen  x13c = xtile(work10)      , n(2)
egen  x14c = xtile(wage0_pc)    , n(2)
recode education (0/1=0) (2/6=1)     	   , gen(x21c)
recode industry  (0/2=3)(4/7=4)		   , gen(x22c) 

g        x1b = female
g        x2b = married
g        x3b = blue
g        x4b = aust
g        x5b = exp_r 
egen  x6b = xtile(tenure)       , n(4)
egen  x7b = xtile(end)          , n(4)                            
egen  x8b = xtile(ee)           , n(4)  
egen  x9b = xtile(zipcode_m)    , n(4)
egen  x10b = xtile(work5)       , n(4)
egen  x11b = xtile(nace95)      , n(4)
egen  x12b = xtile(firmsize)    , n(4)
egen  x13b = xtile(work10)      , n(4)
egen  x14b = xtile(wage0_pc)    , n(4)
 g    x21b = education
 g    x22b = industry
local i = 0
g eud=.
g ewg=.
cap drop n
g n =.
egen ned_cp=  xtile(pned2o), n(100) 

}
qui foreach j in   1 2 3 4 5 6 7 8 9 10 11 12 13 14 21 22  {
cap drop  categ
egen      categ = group(x`j'b)
sum   categ
local max = r(max)
cap drop pp
g temp =1
egen pp = total(temp), by(categ ned_cp)
drop temp
disp "`j'"
forvalues cc    = 1(1)`max'{
	local i = `i' +1
	disp "`cc'"
	reg      ay1    $varp2 age40   if categ==`cc' [aw=1/pp]         
	replace  eud   = _b[age40]  									             if _n   ==`i'	
	reg      ay4    $varp2 age40   if categ==`cc' [aw=1/pp]          
	replace  ewg   = _b[age40]  										      if _n   ==`i'	
	replace  n       = e(N)       if _n   ==`i'			
}
}
qui foreach j1 in  1 2 3 4 5 6 7 8 9 10 11 12 13 14 21 22 {
	foreach j2 in  1 2 3 4 5 6 7 8 9 10 11 12 13 14 21 22 {
		if `j1'>`j2' {
			cap drop  categ
			egen      categ = group(x`j1'c x`j2'c)
			sum   categ
			local max = r(max)
			cap drop pp
			g temp =1
			egen pp = total(temp), by(categ ned_cp)
			drop temp			
			forvalues cc    = 1(1)`max'{
				local i = `i' +1
				reg      ay1    $varp2 age40   if categ==`cc' [aw=1/pp]         
				replace  eud   = _b[age40]											   if _n   ==`i'	
				reg      ay4    $varp2 age40   if categ==`cc' [aw=1/pp]          
				replace  ewg   = _b[age40] 										    if _n   ==`i'	
				replace  n       = e(N)        if _n   ==`i'					
			}
		}
	}
}


keep eud ewg n
drop if eud==.
qui  reg  ewg   eud
local coef  =  string( _b[eud],"%9.5f")
local se     =  string(_se[eud],"%9.5f")
binscatter ewg    eud if n>100000, n(50) reportreg mc(black) lc(black) graphregion(fcolor(white)) xt("UI effect on non-enmployment duration") yt("UI effect on wage") nofastxtile  ///
note("Coefficient = `coef'" ///
	"        (`se')", position(3) ring(0) size(small)) subt("Panel b: Results across sub-samples" , size(small)  ) name(F4b, replace) 
gr combine F4a F4b, col(1) xsize(5.5) ysize(8.5)  graphregion(fcolor(white))    
qui graphexportpdf Figure04
}
}
{ //F5
use     `Data_II', clear
recode ned (1/139=20)(140/209=30)(210/273=39)(274/365=52)(366/456=65)(457/730=95), gen(ww)
foreach ii in 20 30 39 52 65 95{
	g nj`ii' = ww==`ii'
	}
g num  = 1 	
collapse (sum) num nj* , by(agec)
g hj20 = nj20/num
g hj30 = nj30/(num-nj20)
g hj39 = nj39/(num-nj20-nj30)
g hj52 = nj52/(num-nj20-nj30-nj39)
g hj65 = nj65/(num-nj20-nj30-nj39-nj52)
g hj95 = nj95/(num-nj20-nj30-nj39-nj52-nj65)
keep hj* age
reshape long hj ,i(age) j(ww)
label define wwl 20 "0-20 weeks" 30 "21-30 weeks" 39 "31-39 weeks" 52 "40-52 weeks" 65 "53-65 weeks" 95 "66-104 weeks"
label value  ww wwl
twoway ///
(scatter hj age, mcolor(black) msize(vsmall) ylabel(#2)) ///
(qfit    hj age if age>=40, lcolor(black) msize(small)) ///
(qfit    hj age if age< 40, lcolor(black) msize(small)) ///
, xline(40, lp(dash) lcolor(gs10))  ytitle("Hazard of finding a job in interval") xtitle("Age at layoff")  ///  
by(ww, leg(off) graphregion(fcolor(white)) yrescale row(2) subtitle("Panel a", size(small)) note("") ) name(F6a, replace)
// PanelB
use     `Data_II', clear
local uni = "m"
replace ned_`uni' = 57 if ned_`uni'>57 
tempfile B_0
save    `B_0'
qui sum  ned_`uni'
    local  mmin = r(min)
    local  mmax = r(max)
levelsof ned_`uni', local(lev)
qui foreach  ded of local lev {
	g       dhaz_`ded' = 0 if ned_`uni'>=`ded'
	replace dhaz_`ded' = 1 if ned_`uni'==`ded'	
	reg     dhaz_`ded' $varp2 age40
	g       coeff`ded' = _b[age40]
	g          se`ded' = _se[age40]
				 	
}
keep coeff* se*
duplicates drop
g n =1
reshape long coeff se, i(n) j(ned_`uni')
drop if ned_`uni'==`mmax'
g c1 = coef + 1.96*se
g c2 = coef - 1.96*se
sort ned
twoway ///
(connect c1       ned, lc(gs10 ) mcolor(gs10 ) msize(small)    lp(dash)) ///
(connect c2       ned, lc(gs10 ) mcolor(gs10 ) msize(small)    lp(dash) ) ///
(connect coeff    ned, lc(black) mcolor(black) msize(small)) ///
,  xline(30 39, lp(dash) lcolor(gs10)) yline(0, lcolor(gs10))  leg(off) ytitle("UI effect on hazard of finding job") graphregion(fcolor(white)) xtitle(Weeks since layoff) xlabel(13 26 30 39 52) ///
subtitle("Panel b", size(small)) ylabel(-.03(.015).03) name(F6b, replace)
gr combine F6a F6b, col(1) graphregion(fcolor(white))  name(F6_1, replace)
// Panel C
use if ned<2*365 using    `Data_II', clear
recode ned (1/139=20)(140/209=30)(210/273=39)(274/365=52)(366/456=65)(457/730=95), gen(ww)
label define wwl 20 "0-20 weeks" 30 "21-30 weeks" 39 "31-39 weeks" 52 "40-52 weeks" 65 "53-65 weeks" 95 "66-104 weeks"
collapse  (mean) m=ay4, by(agec ww)
twoway ///
(scatter m age           , mcolor(black) msize(vsmall) ylabel(#2)) ///
(qfit    m age if age>=40, lcolor(black) msize(small)) ///
(qfit    m age if age< 40, lcolor(black) msize(small)) ///
, xline(40, lp(dash) lcolor(gs10))  ytitle("Wage change for jobs found in interval") xtitle("Age at layoff") ///
by(ww, leg(off) graphregion(fcolor(white)) yrescale row(2)  subtitle("Panel c", size(small)) )  name(F6c, replace)
//Panel D 
use     `Data_II', clear
keep if ned_m<=53
tempfile A_1
save    `A_1'
use `A_1', clear
levelsof ned_m, local(lev)
foreach dfe of local lev {
qui reg ay4 age40 $varp2 if ned_m ==`dfe'
g       coeff`dfe' = _b[age40]
g          se`dfe' = _se[age40]
}

keep coeff* se*
duplicates drop
g n =1
reshape long coeff se, i(n) j(ned_`uni')
drop n
drop if ned_`uni'==`mmax'
g c1 = coef + 2*se
g c2 = coef - 2*se
sort ned
tempfile B_0
save    `B_0'
use     `A_1', clear
g y = ay4-pay4
levelsof ned_m, local(lev)
foreach dfe of local lev {
qui reg y  age40 $varp2 if ned_m ==`dfe'
g       coeffr`dfe' = _b[age40]
g          ser`dfe' = _se[age40]
}
keep coeffr* ser*
duplicates drop
g n =1
reshape long coeffr ser, i(n) j(ned_`uni')
drop if ned_`uni'==`mmax'
g c1r = coeffr + 1.96*ser
g c2r = coeffr - 1.96*ser
sort ned
merge 1:1 ned_`uni' using `B_0'
twoway ///
(connect c1r       ned, lc(gs10 ) mcolor(gs10 ) msize(small)    lp(dash)) ///
(connect c2r       ned, lc(gs10 ) mcolor(gs10 ) msize(small)    lp(dash) ) ///
(connect coeff     ned, lcolor(black) mcolor(black) msize(small)) ///
(connect coeffr    ned, lcolor(black) mcolor(blue) msize(small) msym(D)) ///
,  xline(30 39, lp(dash) lcolor(gs10)) yline(0, lcolor(gs10))  leg(off) graphregion(fcolor(white)) xtitle("Weeks since layoff") xlabel(13 26 30 39 52) ytitle("UI effect on wage by month since layoff") ///
subtitle("Panel d", size(small)) name(F6d, replace) 
gr combine F6c F6d, col(1) graphregion(fcolor(white))  name(F6_2, replace)
gr combine F6_1 F6_2, col(2) graphregion(fcolor(white)) xsize(7) ysize(5.5)
qui graphexportpdf Figure05	
}
{ //F6
local ss1 = .05    
local bb1 = 0
local bb2 = 2
use if !mi(ay4) & es using "Data.dta", clear
local ii = 0 
forvalues cc = `bb1'(`ss1')`bb2'{
local ii = `ii'+1 
qui g    y   = monthly_wage_n0>=monthly_wage_0 * `cc' 
qui g    y1  = y if age>37 & age<=40 
qui egen amea`ii' = mean(y1)
	qui reg     y $varp2 age40 $cova
	g       coeff`ii' = _b[age40]
	g          se`ii' = _se[age40]
cap drop y y1
}
keep coeff* se* amea* 
duplicates drop
g n =1
reshape long coeff se amea, i(n) j(ns)
drop n
g c1 = coef + 1.96*se
g c2 = coef - 1.96*se
sort ns 
replace ns = `bb1'+`ss1'*(ns-.5)-1
twoway ///
(line    c1       n, lc(gs2 ) mcolor(gs10 ) msize(small)    lp(dash)) ///
(line    c2       n, lc(gs2 ) mcolor(gs10 ) msize(small)    lp(dash) ) ///
(line    amea      n, lc(gs10)   mcolor(gs4)  yaxis(2)) ///
(connect  coeff    n, lc(black) mcolor(black) msize(small)) ///
, 	subt("Panel a" , size(small)) ///
yline(0, lcolor(gs8)) leg( ring(0) rows(2) pos(7) order(3 4) label(3 "UI Effect on CDF") label(4 "CDF (right axis)") size(vsmall)) ytitle("UI effect on P(wage growth>x)") ytitle("P(wage growth>x)", axis(2)) /// 
graphregion(fcolor(white)) xtitle(x)  ylabel(-.01(.005).01)  ylabel(0(.1)1, axis(2))  xlabel(-.8(.2).8, grid) name(VIa, replace) 
// Panel B
local ss1 = .2    
use if !mi(ay4) & es using "Data.dta", clear
local ii = 0 
forvalues cc = `bb1'(`ss1')`bb2'{  
local ii = `ii'+1 
qui g    y   = monthly_wage_n0>=monthly_wage_0 * `cc' & monthly_wage_n0<monthly_wage_0 * (`cc'+`ss1') 
qui g    y1  = y if age>37 & age<=40 
qui egen amea`ii' = mean(y1)
	qui reg     y $varp2 age40 $cova
	g       coeff`ii' = _b[age40]
	g          se`ii' = _se[age40]
cap drop y y1
}
keep coeff* se* amea*
duplicates drop
g n =1
reshape long coeff se amea, i(n) j(ns)
drop n
g c1 = coef + 1.96*se
g c2 = coef - 1.96*se
sort    ns 
replace ns = `bb1'+`ss1'*(ns-.5)-1  
drop if ns >  `bb2'-1
twoway /// 
(bar     amea      n, barw(`ss1')  fcolor(gs14)  lcolor(gs14)                            yscale(alt)) ///
(line    c1       n, lc(gs2 ) mcolor(gs10 ) msize(small)    lp(dash) yaxis(2) yscale(alt axis(2))) ///
(line    c2       n, lc(gs2 ) mcolor(gs10 ) msize(small)    lp(dash) yaxis(2) yscale(alt axis(2))) ///
(connect coeff    n, lc(black) mcolor(black)                         yaxis(2) yscale(alt axis(2))) ///
, 	subt("Panel b" , size(small)) ///
 yline(0, lcolor(gs8) axis(2)) leg( ring(0) rows(2) pos(10) order(4 1) label(4 "UI Effect on PDF") label(1 "PDF (right axis)") size(vsmall))  ytitle("UI effect on P(wage growth=x)", axis(2)) ytitle("P(wage growth=x)") ///
graphregion(fcolor(white)) xtitle(x) ylabel(-.01(.005).01, axis(2)  grid glcolor(gs14))  ylabel(0(.1).4, nogrid)  xlabel(-.8(.2).8, grid) name(VIb, replace)  
gr combine VIa VIb, col(1) graphregion(fcolor(white)) xsize(6) ysize(8) name(V, replace) 
qui graphexportpdf Figure06
}
!gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=Figures.pdf F*.pdf
}
{ // Figures Appendix
{ //A1 A2
local ff = "A01"
local fn = "A1"
{ 
use     `Data_II', clear
g y = pay1 if !mi(ay1)
local tit = "Predicted Non-employment duration"
{  //graph maker
egen m  = mean(y), by(agec)
twoway ///
(scatter m    agec if   id0==1, mcolor(black) msize(small)) /// 
(qfit    y    age   if   age>=40, lcolor(black) ) ///
(qfit    y    age   if   age<40 , lcolor(black) ) ///
, xline(40, lp(dash) lcolor(gs10)) graphregion(fcolor(white)) legend(off)  ytitle("`tit'") xtitle("Age at layoff") subtitle("Panel a ",size(small) ) name(A, replace)
}
drop y m 
g y = pay3 if !mi(ay3)
local tit = "Predicted Prob. of finding job within 39 weeks"
{  //graph maker
egen m  = mean(y), by(agec)
twoway ///
(scatter m    agec if   id0==1, mcolor(black) msize(small)) /// 
(qfit    y    age   if   age>=40, lcolor(black) ) ///
(qfit    y    age   if   age<40 , lcolor(black) ) ///
, xline(40, lp(dash) lcolor(gs10)) graphregion(fcolor(white)) legend(off)  ytitle("`tit'")  subtitle("Panel b ",size(small) ) xtitle("Age at layoff") name(B, replace) 
}
gr combine A B, col(1) graphregion(fcolor(white)) title("Appendix Figure `fn'", size(small) ) subtitle("UI Effect on Predicted Non-Employment Duration",size(small) ) note( ///
"Note: Panel a plots the predicted non-employment durations (time to next job) for each age. Observations with non-employment durations" ///
"of more than two years are excluded. Panel b plots the predicted probability of finding a job within 39 weeks of layoff for each" ///
"age. The dashed line denotes the cutoff for extended UI benefits eligibility. The solid line represents quadratic fits.", size(tiny)) ///
name(C, replace) 
}
local fn = "A2"
{
use     `Data_II', clear
g y = pay4 if !mi(ay4)
local tit = "Predicted Wage change between jobs"
{  //graph maker
egen m  = mean(y), by(agec)
twoway ///
(scatter m    agec if   id0==1, mcolor(black) msize(small)) /// 
(qfit    y    age   if   age>=40, lcolor(black) ) ///
(qfit    y    age   if   age<40 , lcolor(black) ) ///
, xline(40, lp(dash) lcolor(gs10)) graphregion(fcolor(white)) legend(off)  ytitle("`tit'") xtitle("Age at layoff") subtitle("Panel a ",size(small) ) name(A, replace)
}
drop y m 
g y =   pay6   if !mi(ay6) 
local tit = "Predicted Prob(New wage > 0.5 old wage)"
{  //graph maker
egen m  = mean(y), by(agec)
twoway ///
(scatter m    agec if   id0==1, mcolor(black) msize(small)) /// 
(qfit    y    age   if   age>=40, lcolor(black) ) ///
(qfit    y    age   if   age<40 , lcolor(black) ) ///
, ytitle("`tit'") xline(40, lp(dash) lcolor(gs10)) graphregion(fcolor(white)) legend(off)  xtitle("Age at layoff") subtitle("Panel b ",size(small) ) name(B, replace) 
}
gr combine A B, col(1) graphregion(fcolor(white)) title("Appendix Figure `fn'", size(small) ) subtitle("UI Effect on Predicted Wage", size(small)  ) note( ///
"Note: Panel a plots the predicted change in log wage between the post- and pre-unemployment job for each age. Panel b plots the" ///
"predicted probability that the new wage is higher than 50% of the old wage, which is a proxy for the benefit level. Observations" ///
"with predicted non-employment durations of more than two years are excluded. The dashed line denotes the cutoff for extended UI" ///
"benefits eligibility. The solid line represents quadratic fits.", size(tiny)) ///
name(D, replace)
}
gr combine C D, col(2) graphregion(fcolor(white)) ysize(8) xsize(11) 
qui graphexportpdf F`ff'
!rm -f             F`ff'.eps
}
{ //A3-4
local outputn = "A03"
local fn = "A3"
{ 
{ //A
use     `Data_II', clear
recode ned (1/209=20)(210/365=30)(366/730=39)(731/1095=52)(1096/1460=65)(1461/1825=95), gen(ww)
foreach ii in 20 30 39 52 65 95{
	g nj`ii' = ww==`ii'
	}
g num  = 1 	
collapse (sum) num nj* , by(agec)
g hj20 = nj20/num
g hj30 = nj30/(num-nj20)
g hj39 = nj39/(num-nj20-nj30)
g hj52 = nj52/(num-nj20-nj30-nj39)
g hj65 = nj65/(num-nj20-nj30-nj39-nj52)
g hj95 = nj95/(num-nj20-nj30-nj39-nj52-nj65)
keep hj* age 
reshape long hj ,i(age) j(ww)
label define wwl 20 "0-30 weeks" 30 "30-52 weeks" 39 "1-2 years" 52 "2-3 years" 65 "3-4 years" 95 "4-5 years"
label value  ww wwl
twoway ///
(scatter hj age   	  , mcolor(black) msize(vsmall) ylabel(#2)) ///
(qfit    hj age if age>=40, lcolor(black) msize(small)) ///
(qfit    hj age if age< 40, lcolor(black) msize(small)) ///
, xline(40, lp(dash) lcolor(gs10))  ytitle("Hazard of finding a job in interval") xtitle("Age at layoff")  ///  
by(ww, leg(off) graphregion(fcolor(white)) yrescale row(2) subtitle("Panel a", size(small)) note("") ) name(A, replace)
}
{ //B
use     `Data_II', clear
replace ned_m = 4*int(ned_m/4) if ned_m > 80
replace ned_m = 104 if ned_m>104
tempfile B_0
save    `B_0'
qui sum  ned_m  //    local  mmin = r(min)
    local  mmax = r(max)
levelsof ned_m, local(lev)
qui foreach  ded of local lev {
	g       dhaz_`ded' = 0 if ned_m>=`ded'
	replace dhaz_`ded' = 1 if ned_m==`ded'	
	reg     dhaz_`ded' $varp2 age40
	g       coeff`ded' = _b[age40]
	g          se`ded' = _se[age40]
				 	
}
keep coeff* se*
duplicates drop
g n =1
reshape long coeff se, i(n) j(ned_m)
drop n
drop if ned_m==`mmax'
g c1 = coef + 1.96*se
g c2 = coef - 1.96*se
sort ned
twoway ///
(connect c1       ned, lc(gs10 ) mcolor(gs10 ) msize(small)    lp(dash)) ///
(connect c2       ned, lc(gs10 ) mcolor(gs10 ) msize(small)    lp(dash) ) ///
(connect coeff    ned, lc(black) mcolor(black) msize(small)) ///
,  xline(30 39, lp(dash) lcolor(gs10)) yline(0, lcolor(gs10))  leg(off) ytitle("UI effect on hazard of finding job") graphregion(fcolor(white)) xtitle(Weeks since layoff) xlabel(13 26 30 39 52 78  104)  ///
subtitle("Panel b", size(small)) ylabel(-.03(.015).03) name(B, replace) 
 }
gr combine A B, col(1) graphregion(fcolor(white)) title("Appendix Figure `fn'", size(small) ) subtitle("Dynamic Effect of UI Extension on Hazard Rate", size(small) ) ///
note( ///
"Note: Panel a plots the hazard of finding a job across the non-employment period against the age at layoff. That is, for" ///
"instance, the probability of finding a job in weeks 30-52 conditional on not having found a job until week 30. Panel b" ///
"plots the RD coefficients from different regressions for monthly hazard rates.", size(tiny)) name(C, replace)
}

local fn = "A4"
{
use     `Data_II', clear
keep if ned<1826
recode ned (1/209=20)(210/365=30)(366/730=39)(731/1095=52)(1096/1460=65)(1461/1825=95), gen(ww)
label define wwl 20 "0-30 weeks" 30 "30-52 weeks" 39 "1-2 years" 52 "2-3 years" 65 "3-4 years" 95 "4-5 years"
label value ww wwl
collapse (mean) m=wg_c , by(agec ww)
twoway ///
(scatter m age 		 , mcolor(black) msize(vsmall) ylabel(#2)) ///
(qfit    m age if age>=40, lcolor(black) msize(small)) ///
(qfit    m age if age< 40, lcolor(black) msize(small)) ///
, xline(40, lp(dash) lcolor(gs10))  ytitle("Wage change for jobs found in interval") xtitle("Age at layoff") ///
by(ww, leg(off) graphregion(fcolor(white)) yrescale row(2) note("") subtitle("Panel a", size(small)) )  name(A, replace)
{ //B
use     `Data_II', clear
replace ned_m = 4*int(ned_m/4) if ned_m > 80
replace ned_m = 104 if ned_m>104
tempfile A_1
save    `A_1'
use `A_1', clear
{ //coeff with no control
levelsof ned_m, local(lev)
foreach dfe of local lev {
qui reg ay4 age40 $varp2 if ned_m ==`dfe'
g       coeff`dfe' = _b[age40]
g          se`dfe' = _se[age40]
}

keep coeff* se*
duplicates drop
g n =1
reshape long coeff se, i(n) j(ned_m)
drop n
g c1 = coef + 2*se
g c2 = coef - 2*se
sort ned_m
tempfile B_0
save    `B_0'
}
use `A_1', clear
replace ay4 = ay4-pay4
levelsof ned_m, local(lev)
foreach dfe of local lev {
qui reg ay4  age40 $varp2 if ned_m ==`dfe'
g       coeffr`dfe' = _b[age40]
g          ser`dfe' = _se[age40]
}

keep coeffr* ser*
duplicates drop
g n =1
reshape long coeffr ser, i(n) j(ned_m)
g c1r = coeffr + 2*ser
g c2r = coeffr - 2*ser
sort ned
merge 1:1 ned using `B_0'
drop if ned==104
twoway ///
(connect c1r       ned, lc(gs10 ) mcolor(gs10 ) msize(small)    lp(dash)) ///
(connect c2r       ned, lc(gs10 ) mcolor(gs10 ) msize(small)    lp(dash) ) ///
(connect coeff     ned, lcolor(black) mcolor(black) msize(small)) ///
(connect coeffr    ned, lcolor(black) mcolor(blue) msize(small) msym(D)) ///
,  xline(30 39, lp(dash) lcolor(gs10)) yline(0, lcolor(gs10))  leg(off) graphregion(fcolor(white)) xtitle("Weeks since layoff") xlabel(13 26 30 39 52 78 104) ytitle("UI effect on wage") ///
subtitle("Panel b", size(small))  name(B, replace) // subtitle("Controlling for observables", color(blue))
 }
gr combine A B, col(1) graphregion(fcolor(white))  title("Appendix Figure `fn'",  size(small)) subtitle("Dynamic Effect of UI Extension on Wage", size(small) ) note( ///
"Note: Panel a plots log wage changes for individuals who exit unemployment in different periods against the age at layoff. Panel b" ///
"plots the RD coefficients from different regressions for wage change in each non-employment month.", size(tiny)) /// 
name(D, replace)

}
gr combine C D, col(2) graphregion(fcolor(white)) ysize(8.5) xsize(11)  
qui graphexportpdf F`outputn'
!rm -f             F`outputn'.eps
}
{ //A5-6
local fn1 = "5"
local fn2 = "6"
local outputn = "XX"
local bin  = 2  
local win = 5
local cf = "IK"
local ms = 5  
local ll = `ms'
local lim =`ll'*`bin'
local per =365/`bin'  
local cf = "IK"
local lim =`ll'*`bin'
local per =365/`bin'
local ij = 1  
use     `Data_II', clear
drop if 5*`bin'*`per'>dis_end
tempfile A0
save `A0'
{ //A
use `A0',clear
forvalue dfe = `bin'/`lim' {
qui g         c_`dfe' = ned>`dfe'*`per'
qui replace c_`dfe' = 1  if mi(ned)
if `ij' == 1 {
qui altrdrobust c_`dfe'  age, c(40) all bwselect(`cf')
qui g       coeff`dfe' =  e(tau_cl)
qui g          se`dfe' = e(se_cl)
}
}
keep coeff* se*
qui duplicates drop
g n =1
qui reshape long  coeff se, i(n) j(week)
drop n
g c1 = coeff + 1.96*se
g c2 = coeff - 1.96*se
replace week = week/`bin' 
twoway ///
(line c1       week, lc(black)     lp(dash)) ///
(line c2       week, lc(black)     lp(dash) ) ///
(connect coeff week, lcolor(black) mcolor(black) msize(vsmall)) ///
,  leg(off) ytitle("UI effect on survival rate") xtitle("Censoring level (years since layoff)") /// xline(30 39, lp(dash) lcolor(gs10)) yline(0, lcolor(gs10))  
 graphregion(fcolor(white))  xlabel(1(1)`ms', grid) ///   
 name(A`ij', replace)   subt("Panel b") //
	keep coeff week
	rename coeff surv_s`ij'
	tempfile A1
	save `A1', replace
}
{ //B : NED
use `A0',clear
forvalue dfe = `bin'/`lim' {
	cap drop c_*
	qui g         c_`dfe' = ned           if ned<`dfe'*`per'
	if `ij' == 1 {
		qui altrdrobust c_`dfe'  age, c(40) all bwselect(`cf')
		qui g       coeff`dfe' =  e(tau_cl)
		qui g          se`dfe' = e(se_cl)
	}
	qui egen         mes`dfe'=mean(c_`dfe')
}

keep coeff* se* mes*
qui duplicates drop
g n =1
qui reshape long coeff se mes, i(n) j(week)
drop n
g c1 = coef + 1.96*se
g c2 = coef - 1.96*se
replace week = week/`bin' 
keep   coeff week mes c1 c2
rename coeff ned_s`ij'
rename mes   nedlevel_s`ij'
rename c1      ned_c1
rename c2      ned_c2
qui merge 1:1 week using `A1', nogen
tempfile A1
save    `A1', replace
}
{ //C : winsorized
use `A0',clear
forvalue dfe = `bin'/`lim' {
qui g         c_`dfe' = min(ned,`dfe'*`per') if !mi(ned)
qui replace c_`dfe' =              `dfe'*`per'  if  mi(ned)
if `ij' == 0 {
qui reg c_`dfe' $varp2 age40 if abs(age-40)<`win'  
qui g       coeff`dfe' = _b[age40]
qui g          se`dfe' = _se[age40]
}
if `ij' == 1 {
qui altrdrobust c_`dfe'  age, c(40) all bwselect(`cf')
qui g       coeff`dfe' =  e(tau_cl)
qui g          se`dfe' = e(se_cl)
}
}
keep coeff* se*
qui duplicates drop
g n =1
qui reshape long coeff se, i(n) j(week)
drop n
g c1 = coef + 1.96*se
g c2 = coef - 1.96*se
replace week = week/`bin' 
 keep c1 c2 coeff week
rename coeff nedwin_s`ij'
rename c1      nedwin_c1
rename c2      nedwin_c2
qui merge 1:1 week using `A1', nogen
tempfile A1
save    `A1', replace 
}
{ //D : wage 
use `A0',clear
forvalue dfe = `bin'/`lim' {
	qui g c_`dfe' = wg_c if ned<`dfe'*`per'
	if `ij' == 1 {
		qui altrdrobust c_`dfe'  age, c(40) all bwselect(`cf')
		qui g       coeff`dfe' =  e(tau_cl)
		qui g          se`dfe' = e(se_cl)
	}
	qui egen mes`dfe' = mean(c_`dfe')
}
keep coeff* se* mes*
qui duplicates drop
g n =1
qui reshape long coeff se mes, i(n) j(week)
drop n
g c1 = coef + 1.96*se
g c2 = coef - 1.96*se
replace week = week/`bin' 
keep coeff week mes c1 c2
rename coeff wage_s`ij'
rename c1    wage_s`ij'c1
rename c2    wage_s`ij'c2
rename mes   wagelevel_s`ij'
qui merge 1:1 week using `A1', nogen
tempfile A1
save    `A1', replace
}
{ //SS: survival curve
use `A0',clear
keep if `lim'*`per'<=dis_end
forvalue dfe = `bin'/`lim' {  //replace 1 with `bin'
qui g         c_`dfe' = ned>`dfe'*`per' if !mi(ned)
qui replace c_`dfe' = 1                 if  mi(ned)
}
keep c_* 
collapse (mean) c_*
qui duplicates drop
g n =1
qui reshape long  c_, i(n) j(week)
drop n
replace week = week/`bin' 
g cd_ = int(c_*1000)/1000
twoway ///(line c_        week, lc(black)     lp(dash)) ///(line c2       week, lc(black)     lp(dash) ) /// 
(connect c_ week, lcolor(black) mcolor(black) msize(vsmall)) ///
(scatter c_ week if int(week)==week, mcolor(black) msize(vsmall) mlabel(cd_) mlabang(90)) ///
,  leg(off) ytitle("Survival rate") xtitle("Years since layoff") /// xline(30 39, lp(dash) lcolor(gs10)) yline(0, lcolor(gs10))  
 graphregion(fcolor(white))  xl(1(1)`ms', grid) ylabel(0(.03).2, grid) ///   subtitle("Survival Rate (Prob. of Remaining Unemployed)",  size(m)) ///
 name(SS, replace)   subt("Panel a") //xtitle("Weeks since layoff") 
keep c_ week
rename c_ survlevel
merge 1:1 week using `A1', nogen
tempfile A1
save    `A1', replace 
}
{ //E,F
use `A1', clear
g    nedc_s`ij'=(1-survlevel)*ned_s`ij' //+surv_s`ij'*(week*365-nedlevel_s`ij')
//g nedwinc_s`ij'=           nedwin_s`ij'-surv_s`ij'*365   //for it was `ij' here in the second term !
//local ij =1
//local ms = 5
twoway ///
	(line    ned_s`ij'     week, lcolor(black)) ///
	(line    ned_c1        week, lc(black)     lp(dash)) ///
	(line    ned_c2        week, lc(black)     lp(dash) ) ///
	(connect nedwin_s`ij'  week, lcolor(black) mcolor(black) msize(small)) ///
	(connect nedc_s`ij'    week, lcolor(black) mcolor(black) msize(vsmall) msym(D)) ///	(connect nedwinc_s`ij' week, lcolor(blue)   mcolor(blue) msize(vsmall)) ///
	,   leg(off) ytitle("UI effect on non-employ duration") xtitle("") ///
	 graphregion(fcolor(white))  xlabel(1(1)`ms', grid)  ylabel(0(1)5, grid) name(E`ij', replace)  subt("Panel a")
 
g wagec_s`ij'=(1-survlevel)*wage_s`ij'-surv_s`ij'*wagelevel_s`ij' 
twoway ///
	(line    wage_s`ij'c1        week, lc(black)     lp(dash)) ///
	(line    wage_s`ij'c2        week, lc(black)     lp(dash) ) ///
	(line wage_s`ij'          week, lcolor(black) ) ///
	(connect wagec_s`ij'         week, lcolor(black)   mcolor(black) msize(vsmall)) ///
	,   leg(off) ytitle("UI effect on wage") xtitle("Censoring level (years since layoff)") ///
	 graphregion(fcolor(white))  xlabel(1(1)`ms', grid)  ylabel(-.005(.005).01, grid) /// xlabel(13 30 39 52 78 104 130 156, grid)  subtitle("Survival Rate (Prob. of Remaining Unemployed)",  size(m)) ///
	name(F`ij', replace)  subt("Panel b")
}
gr combine SS    A`ij', col(1) graphregion(fcolor(white))  xsize(8.5) ysize(11)  ///
	 title("Appendix Figure A`fn1'",  size(small)) name(Z1, replace) ///
	 note("Panel A plots the survival rate again the unemployment duration. Panel B plots the effect of the UI extension on each" ///
	 "lelve of survival rate. The RD estiamtes are measured using the optimal bandwitch following Imbens and Kalyanaraman (2012).", size(tiny))
local ij =1
gr combine E`ij' F`ij', col(1) graphregion(fcolor(white))  xsize(8.5) ysize(11)  ///
	 title("Appendix Figure A`fn2'",  size(small)) ///
	 note("Panel A plots three measures of UI duration effect. First, solid line corresponds to the UI duration effect based on"        ///
	 "censored measure of duration. Second, the line with diamond marker is the simple correction of the latter were the correction"    ///
	 "multiplier is the corresponding CDF. Third measure of UI duration effect, uses the wincorized measure of duration," 		    ///
	 "which we argue is the only unbiased one. Panel B, similarly, provides two measures of UI wage effect, the one based on censored"  ///
	 "wage measure in solid line, and the correct version marked by squares. All unemployment spells, which are censored by the ending" ///
	 "date of the dataset before they reach 5 years, are excluded. See section 1.3 in the Online Appendix for details of how these"     ///
	 "measures are defined. ", size(tiny)) name(Z2, replace)
gr combine Z1       Z2, col(2) graphregion(fcolor(white))  ysize(8.5) xsize(11) 
qui graphexportpdf FA0`fn1'.pdf
}
{ //A7-8   
{ //A7, A8a
local fn1 = "7"
local fn2 = "8"
use     `Data_II', clear
drop agec id0
local ii2 = 1
g agec = (int(age*`ii2')/`ii2')+1/(2*`ii2')
          g tot = _N
bys agec: g nec = _N
bys agec: g id0 =_n
replace nec = nec/tot
twoway ///
(scatter nec   agec   if id0==1, lcolor(black) mcolor(black) msize(small)) ///
(qfit    nec   agec   if id0==1, lcolor(black) ) ///
, xline(40, lp(dash) lcolor(gs10)) ///
xt("Age at layoff") yt("Density") leg(off) graphregion(fcolor(white)) subtitle("Panel a ",size(small)) name(X0, replace)
use     `Data_II', clear
drop agec id0
local ii2 = 12
g agec = (int(age*`ii2')/`ii2')+1/(2*`ii2')
          g tot = _N
bys agec: g nec = _N
bys agec: g id0 =_n
replace nec = nec/tot
twoway ///
(connect nec   agec   if id0==1, lcolor(black) mcolor(black) msize(small)) ///
(qfit    nec   agec   if id0==1, lcolor(black) ) ///
, xline(40, lp(dash) lcolor(gs10)) ///
xt("Age at layoff") yt("Density") leg(off) graphregion(fcolor(white)) subtitle("Panel b",size(small)) name(X1, replace)
use     `Data_II', clear
drop agec id0
g agec = (int(age*`ii2')/`ii2')+1/(2*`ii2')
bys agec: g nec = _N
bys agec: g id0 =_n
local win  =4
local win1 = 40-`win'
local win2 = 40+`win'
twoway ///
(connect nec   agec   if age>40-`win' & age<40+`win' & id0==1, lcolor(black) mcolor(black) msize(small)) ///
(qfit    nec   agec   if age>40-`win' & age<40+`win' & id0==1, lcolor(black) ) ///
(scatter nec   agec   if age>40-`win' & age<40+`win' & (int(age-1/12)!=int(age)) & id0==1, mcolor(red) msymbol(D) msize(small))    ///
, xline(40, lp(dash) lcolor(gs10)) xlabel(`win1'(1)`win2', grid) ylabel(6800(400)8200) ///
xt("Age at layoff") yt("Frequency") leg(off) graphregion(fcolor(white)) subtitle("Panel a",size(small)) name(X2, replace)
}
{ // FA 8b
use age birth* es if es  using `Data_II', clear
mmerge birthyear birthmonth using "bm_weight", ukeep(bm_weight) unmatched(master)
capture drop index 
local ii2 = 12
g agec = (int(age*`ii2')/`ii2')+1/(2*`ii2')
capture drop id0 nec 
bys agec: egen nec=sum(bm_weight) 
bys agec: g    id0=_n 
local win  = 4
local win1 = 40-`win'
local win2 = 40+`win'
twoway (connected  nec  agec if age>40-`win' & age<40+`win' & id0==1, lcolor(black) mcolor(black)  msize(small)) ///
       (qfit       nec  agec if age>40-`win' & age<40+`win' & id0==1, lcolor(black) ) ///
,  graphregion(fcolor(white)) yscale(r(6800 8200)) ylabel(6800(400)8000) xlabel(`win1'(1)`win2', grid) ///
xline(40, lp(dash) lcolor(gs10)) ytitle("Frequency Weighted") xtitle("Age at Layoff")  subtitle("Panel b",size(small)) ///
name(X3, replace)
}
gr combine X0 X1, col(1) graphregion(fcolor(white))  name(FA0`fn1', replace) xsize(8.5) ysize(11) title("Appendix Figure A`fn1'", size(small) ) ///
note("Panel a plots the frequency of job separations by age-year category, i.e. the total number of individuals in the analysis sample" ///
"within each age-year category. Panel b does the same at monthly frequency. The dashed line denotes the cutoff for" ///
"extended UI benefits eligibility.", size(tiny))  
gr combine X2 X3, col(1) graphregion(fcolor(white))  name(FA0`fn2', replace) xsize(8.5) ysize(11) title("Appendix Figure A`fn2'", size(small) ) ///
note("Panel a plots the frequency of job separations by age-month category for individuals aged 36 to 44. The red dots highlight" ///
"the first month of each year. Panel b is similar to Panel a, except that individuals are weighted by birth months in the " ///
"population. The dashed line denotes the cutoff for extended UI benefits eligibility.", size(tiny)) 
gr combine FA0`fn1' FA0`fn2', col(2) graphregion(fcolor(white)) ysize(8.5) xsize(11)
qui graphexportpdf FA07
!rm -f             FA07.eps
}
{ //A09-10
{ //FA09a  
local fe3 = "9"
use if !mi(ay1) & !mi(ay4) & es using "Data.dta", clear
qui reg     ay1 $cova if age<40
predict  r1_a, res
qui reg     ay1 $cova if age>=40
predict  r1_b, res
qui reg     ay4 $cova if age<40
predict  r4_a, res
qui reg     ay4 $cova if age>=40
predict  r4_b, res

g       r1 = r1_a if age< 40
replace r1 = r1_b if age>=40
g       r4 = r4_a if age< 40
replace r4 = r4_b if age>=40
drop r1_a r1_b r4_a r4_b

local ij = 0
local mm = .1
qui forvalues dd = -10(`mm')10 {
local ij = `ij'+1
	reg r4 r1 if abs(age-(40-`dd'))<`mm'/2
	g za`ij'= 40-`dd'
	g zb`ij'=_b[r1] 
}
keep za* zb*
duplicates drop
g m = 1
qui reshape long za zb, i(m) j(y)
drop m y 

	qui altrdrobust zb za, c(40) all bwselect(IK)
	qui g       temp_coeff =  e(tau_cl)
	qui g          temp_se = e(se_cl)
	format temp_coeff %20.7f
	format temp_se    %20.7f 
	drop temp_*
local ii=3	
g agec = (int(za*`ii')/`ii')+1/(2*`ii')
bys agec: g id0 =_n
g y = zb
egen m  = mean(y), by(agec)
local tit = "Local correlation btw residual wage and duration"
twoway ///
(scatter m    agec if   id0==1, mcolor(black) msize(small)) /// 
(qfit    y    age   if   age>=40, lcolor(black) ) ///
(qfit    y    age   if   age<40 , lcolor(black) ) ///
, xline(40, lp(dash) lcolor(gs10)) graphregion(fcolor(white)) legend(off)  ytitle("`tit'",size(small)) xtitle("Age at layoff") subtitle("Panel a ",size(small) ) name(FA0`fe3'a, replace) 
}
{ //FA09b 
use if !mi(ay4) & !exp_r & es using "Data.dta", clear
{
g ee= end_m*31+end_d 
g     x1c  = female
g     x2c  = married
g     x3c  = blue
g     x4c  = aust
g     x5c  = exp_r 
recode education (0/1=0) (2/6=1)     	   , gen(x6c)
forvalues ii = 2(1)7 { 
	g x7c`ii' =  industry==`ii' 
}
	g x7c8  =  industry==0  
}	
{ 
local mm = 20
local ss = 8
foreach vv in tenure ee zipcode_m work5 firmsize work10 wage0_pc { 
	egen  temp  = xtile(`vv')       , n(`mm')
	forvalues ii = 2(1)`mm' { 
		g x`ss'c`ii'= 	temp==`ii'
	}
	local ss = `ss'+1
	drop temp
}
}
{
forvalues ii = 1(1)6 {
	g   ax`ii'c=age40*x`ii'c
	g ddx`ii'c=   ay1*x`ii'c	
}
	local ii=7
	forvalues jj = 2(1)8 {
	g ax`ii'c`jj'=age40*x`ii'c`jj'
	g ddx`ii'c`jj'=   ay1*x`ii'c`jj'	
	}
forvalues ii = 8(1)14 {
	forvalues jj = 2(1)`mm' {
	g ax`ii'c`jj'=age40*x`ii'c`jj'
	g ddx`ii'c`jj'=   ay1*x`ii'c`jj'	
	}
}
}

{
foreach ji in 1 4 {
qui reg ay`ji'  age40 ax*c* $varp2 x*c* 
predict r`ji',res 
g qay`ji' =_b[age40]
g say`ji' =_b[_cons]
forvalues ii = 1(1)6 {
	qui replace qay`ji'= qay`ji'+ _b[ax`ii'c]    *x`ii'c
	qui replace say`ji'= say`ji'+ _b[ x`ii'c]    *x`ii'c
}
	local ii=7
	forvalues jj = 2(1)8 {
	qui replace qay`ji'= qay`ji'+ _b[ax`ii'c`jj']*x`ii'c`jj'
	qui replace say`ji'= say`ji'+ _b[ x`ii'c`jj']*x`ii'c`jj'	
	}
forvalues ii = 8(1)14 {
	forvalues jj = 2(1)`mm' {
	qui replace qay`ji'= qay`ji'+ _b[ax`ii'c`jj']*x`ii'c`jj'
	qui replace say`ji'= say`ji'+ _b[ x`ii'c`jj']*x`ii'c`jj'
	}
}
}
}
{ 
reg ay4  ay1 ddx*c* x*c*  
g ddqay =_b[ay1]
forvalues ii = 1(1)6 {
	qui replace ddqay= ddqay+ _b[ddx`ii'c]    *x`ii'c
}
	local ii=7
	forvalues jj = 2(1)8 {
	qui replace ddqay= ddqay+ _b[ddx`ii'c`jj']*x`ii'c`jj'	
	}
forvalues ii = 8(1)14 {
	forvalues jj = 2(1)`mm' {
	qui replace ddqay= ddqay+ _b[ddx`ii'c`jj']*x`ii'c`jj'
	}
}
}
	cap drop dd_q
	egen  dd_q  = xtile(ddqay)       , n(5)
	cap drop n
	egen n = xtile(qay1), n(50)
	egen qay1c=mean(qay1), by(n)
	egen mdd  =mean(ddqay), by(dd_q)
	collapse (mean) qay4,by(qay1c dd_q mdd)
	table dd_q, c(mean mdd)
	bys dd_q (qay1c): g qay4_n = qay4 - qay4[17]
	drop mdd
	reshape wide qay4 qay4_n, i(qay1c) j(dd_q)
twoway ///
(scatter qay4_n2 qay1c, mc(gs5))   ///
(scatter qay4_n3 qay1c, mc(gs8))   ///
(scatter qay4_n4 qay1c, mc(edkblue))   ///
(scatter qay4_n5 qay1c, mc(navy))   ///
(scatter qay4_n1 qay1c, mc(black))  ///	
, name(FA0`fe3'b, replace) legend(row(2) order(5 1 2 3 4) label(5 "1. Highest Negative DD") label(1 "2") label(2 "3") label(3 "4") label(4 "5. lowest Negative DD")) ///
graphregion(color(white)) xt("UI effect on non-enmployment duration (predicted)") yt("UI effect on wage (predicted)", height(10)) subtitle("Panel b ",size(small) ) 
}
gr combine FA09a FA09b,  imargin(10 10 1 1) title("Appendix Figure A`fe3'", size(small) ) ///
subt("The effect of UI extension on survival rate", size(small) )  col(1) xsize(8.5) ysize(11)  graphregion(fcolor(white)) ///
note( ///
"Subfigure a is measuring the effect of UI extension on the correlation between two resduals." ///
"Subfigure b plots the predicted wage change against predicted non-employment duration effect of UI extension," ///
"by groups with different degree of observed dudarion dependence. (see Section A.4)", size(tiny)) name(FA09, replace)
{ //A10  
use     `Data_II', clear
g      y = wg_c  
{ //Find attrition
local uni = "m"
replace ned_`uni' = 57 if ned_`uni'>57 
tempfile B_0
save    `B_0'
qui sum  ned_`uni'
    local  mmin = r(min)
    local  mmax = r(max)
levelsof ned_`uni', local(lev)
qui foreach  ded of local lev {
	g           dhaz_`ded' = ned_`uni'>=`ded'	
	reg     dhaz_`ded' $varp2 age40
	g       coeff`ded' = _b[age40]
	g          se`ded' = _se[age40]
				 	
}
keep coeff* se*
duplicates drop
g n =1
reshape long coeff se, i(n) j(ned_`uni')
drop if ned_`uni'==`mmax'
g c1 = coef + 1.96*se
g c2 = coef - 1.96*se
sort ned
 }
keep ned coeff
rename coeff attrition
tempfile D1
save     `D1', replace
{ //B1
use     `Data_II', clear
local uni = "m"
replace ned_`uni' = 57 if ned_`uni'>57 
merge n:1 ned_m using `D1'
tempfile A_1
save    `A_1'

levelsof ned_`uni', local(lev)
qui foreach  ded of local lev {
	g           dhaz_`ded' = 0 if ned_`uni'>=`ded'
	replace dhaz_`ded' = 1 if ned_`uni'==`ded'	
	reg     dhaz_`ded' $varp2 age40
	g       coeff`ded' = _b[age40]
	g          se`ded' = _se[age40]
				 	
}
keep coeff* se*
duplicates drop
g n =1
reshape long coeff se, i(n) j(ned_`uni')
drop n
drop if ned_`uni'==`mmax'
g c1 = coef + 1.96*se
g c2 = coef - 1.96*se
sort ned
tempfile B_0
save    `B_0'
{ //bound1
local is = 1
use `A_1', clear
levelsof ned_`uni', local(lev)
qui foreach  ded of local lev {
	g           dhaz_`ded' = 0  if ned_`uni'>=`ded'
	replace     dhaz_`ded' = 1  if ned_`uni'==`ded'	
	g            r = runiform() if ned_`uni'<`ded' & !age40
	replace     dhaz_`ded' = 1  if r<attrition
	drop r
	reg     dhaz_`ded' $varp2 age40
	g       coeff`is'`ded' = _b[age40]
	g          se`is'`ded' = _se[age40]			 	
}
keep coeff`is'* se`is'*
duplicates drop
g n =1
reshape long coeff`is' se`is', i(n) j(ned_`uni')
drop n
sort ned
merge 1:1 ned_`uni' using `B_0'
drop  _m
sort ned
tempfile B_0
save    `B_0'
}
{ //bound2
local is = 2
use `A_1', clear
levelsof ned_`uni', local(lev)
qui foreach  ded of local lev {
	disp `ded'
	g           dhaz_`ded' = 0 if ned_`uni'>=`ded'
	replace dhaz_`ded' = 1 if ned_`uni'==`ded'	
	g            r = runiform()  if ned_`uni'<`ded' & !age40
	replace dhaz_`ded' = 0  if r<attrition & !mi(attr)
	drop r
	reg     dhaz_`ded' $varp2 age40
	g       coeff`is'`ded' = _b[age40]
	g          se`is'`ded' = _se[age40]			 	
}
keep coeff`is'* se`is'*
duplicates drop
g n =1
reshape long coeff`is' se`is', i(n) j(ned_`uni')
drop n
sort ned
merge 1:1 ned_`uni' using `B_0'
drop  _m
sort ned
tempfile B_0
save    `B_0'
}
drop if ned==57
twoway ///
(rspike  coeff1 coeff2    ned,    lc(gs10)                   mcolor(blue) msize(small)  msym(T)) ///
(connect c1       ned, lc(gs10 ) mcolor(gs10 ) msize(small)    lp(dash)) ///
(connect c2       ned, lc(gs10 ) mcolor(gs10 ) msize(small)    lp(dash) ) ///
(connect coeff    ned, lc(black) mcolor(black) msize(small)) ///
(scatter  coeff1    ned,                      mcolor(black) msize(small)  msym(+)) ///
(scatter  coeff2    ned,                       mcolor(black) msize(small)  msym(+)) ///
,  xline(30 39, lp(dash) lcolor(gs10)) yline(0, lcolor(gs10))  leg(off) ytitle("UI effect on hazard of finding job") graphregion(fcolor(white)) xtitle(Weeks since layoff) xlabel(13 26 30 39 52) ///
subtitle("Panel a", size(small)) ylabel(-.03(.015).03) name(B1, replace) 
 }

{ //B2
use     `Data_II', clear
g y = wg_c
keep if ned_m<=53
merge n:1 ned_m using `D1'
drop _m
tempfile A_1
save    `A_1'
use `A_1', clear
{ //coeff with no control
levelsof ned_m, local(lev)
foreach dfe of local lev {
qui reg y age40 $varp2 if ned_m ==`dfe'
g       coeff`dfe' = _b[age40]
g          se`dfe' = _se[age40]
}

keep coeff* se*
duplicates drop
g n =1
reshape long coeff se, i(n) j(ned_`uni')
drop n
drop if ned_`uni'==`mmax'
//drop n
g c1 = coef + 2*se
g c2 = coef - 2*se
sort ned
tempfile B_0
save    `B_0'
}
{ //control
use `A_1', clear
replace y = y-pay4
levelsof ned_m, local(lev)
foreach dfe of local lev {
qui reg y  age40 $varp2 if ned_m ==`dfe'
g       coeffr`dfe' = _b[age40]
g          ser`dfe' = _se[age40]
}

keep coeffr* ser*
duplicates drop
g n =1
disp "`uni'"
reshape long coeffr ser, i(n) j(ned_`uni')
drop n
drop if ned_`uni'==`mmax'
g c1r = coeffr + 1.96*ser
g c2r = coeffr - 1.96*ser
sort ned
merge 1:1 ned_`uni' using `B_0'
drop  _m
sort ned
tempfile B_0
save    `B_0'
}
{ //bound1
local is = 1
use `A_1', clear
	sort y
levelsof ned_m, local(lev)
foreach dfe of local lev {
	g n = _n/_N                      if ned_m ==`dfe'  & !age40
	//if `dfe'==14 {
	  //stop // a test
	//}
	expand 2 if n<=attrition 
	drop n
	qui reg y  age40 $varp2  if ned_m ==`dfe'
	g       coeffr`is'`dfe' = _b[age40]
	g          ser`is'`dfe' = _se[age40]
}

keep coeffr`is'* ser`is'*
duplicates drop
g n =1
disp "`uni'"
reshape long coeffr`is' ser`is', i(n) j(ned_`uni')
drop n
drop if ned_`uni'==`mmax'
sort ned
merge 1:1 ned_`uni' using `B_0'
drop  _m
sort ned
tempfile B_0
save    `B_0'
}
{ //bound2
local is = 2
use `A_1', clear
gsort -y
levelsof ned_m, local(lev)
foreach dfe of local lev {
	g n = _n/_N                      if ned_m ==`dfe'   & !age40
	expand 2 if n<=attrition 
	drop n
	qui reg y  age40 $varp2  if ned_m ==`dfe'
	g       coeffr`is'`dfe' = _b[age40]
	g          ser`is'`dfe' = _se[age40]
}

keep coeffr`is'* ser`is'*
duplicates drop
g n =1
disp "`uni'"
reshape long coeffr`is' ser`is', i(n) j(ned_`uni')
drop n
drop if ned_`uni'==`mmax'
sort ned
merge 1:1 ned_`uni' using `B_0'
drop  _m
sort ned
tempfile B_0
save    `B_0'
}

twoway ///
(rspike  coeffr1 coeffr2    ned,    lc(gs10)                   mcolor(blue) msize(small)  ) ///
(connect c1r         ned, lc(gs10 )        mcolor(gs10 ) msize(small)    lp(dash)) ///
(connect c2r         ned, lc(gs10 )       mcolor(gs10 ) msize(small)    lp(dash) ) ///
(connect coeff       ned, lcolor(black) mcolor(black) msize(small)) ///
(connect coeffr      ned, lcolor(black) mcolor(black) msize(small)) ///
(scatter coeffr      ned,                      mcolor(blue)  msize(small)  msym(D)) ///
(scatter coeffr1     ned,                      mcolor(black) msize(small)  msym(+)) ///
(scatter coeffr2     ned,                      mcolor(black) msize(small)  msym(+)) ///
,  xline(30 39, lp(dash) lcolor(gs10)) yline(0, lcolor(gs10))  leg(off) graphregion(fcolor(white)) xtitle(Weeks since layoff) xlabel(13 26 30 39 52) ytitle("UI effect on wage") ///
subtitle("Panel b", size(small))  ///
 name(B2, replace) // subtitle("Controlling for observables", color(blue))
 }
 gr combine B1 B2, c(1)  graphregion(fcolor(white)) xsize(8.5) ysize(11) title("Appendix Figure A10", size(small) ) ///
 note( ///
"Note: This figure extends the analysis of the dynamic effect of UI extension on job finding hazard rates and wage presented"  ///
"in Figure VII and VIII in the paper. It does so by adding bounds correcting for the attrition over the unemployment spell" ///
"(dynamic selection). Two bounds for dynamic UI effects are marked with + symbols, and connected with a solid vertical line."  ///
"They corresponds to an upper and a lower bounds constructed by assuming that the difference in attrition around the  age-40" ///
"cutoff at each point in time corresponds to highest or lowest value of observed values in the distribution of outcome of" ///
"interest.",size(tiny)) name(FA10,replace)
gr combine FA09 FA10, col(2) graphregion(fcolor(white)) ysize(8.5) xsize(11)
qui graphexportpdf FA09
!rm -f             FA09.eps
}
}
{ //A11-2
local ff = "A11"	
local fn = "A11"
{ 
use  if es using `Data_II', clear
g y = ay1
local tit = "Non-employment duration"
{  //graph maker
egen m  = mean(y), by(agec)
twoway ///
(scatter m    agec if   id0==1, mcolor(black) msize(small)) /// 
(qfit    y    age   if   age>=40, lcolor(black) ) ///
(qfit    y    age   if   age<40 , lcolor(black) ) ///
, xline(40, lp(dash) lcolor(gs10)) graphregion(fcolor(white)) legend(off)  ytitle("`tit'") xtitle("Age at layoff") subtitle("Panel a ",size(small) ) name(F3a, replace)
}
drop y m 
qui reg      ay1 i.end_m#i.birthmo
qui predict aay1, res
g y =       aay1 if ned<2*365 
local tit = "Non-employment duration, seasonality adjusted"
{  //graph maker
egen m  = mean(y), by(agec)
twoway ///
(scatter m    agec if   id0==1, mcolor(black) msize(small)) /// 
(qfit    y    age   if   age>=40, lcolor(black) ) ///
(qfit    y    age   if   age<40 , lcolor(black) ) ///
, xline(40, lp(dash) lcolor(gs10)) graphregion(fcolor(white)) legend(off)  ytitle("`tit'")  subtitle("Panel b ",size(small) ) xtitle("Age at layoff") name(F3b, replace) 
}
gr combine F3a F3b, col(1) graphregion(fcolor(white)) title("Appendix Figure `fn': The role of seasonality", size(small) ) subtitle("UI Effect on Non-Employment Duration",size(small) ) note( ///
"Note: Panel a plots average non-employment durations (time to next job) for each age. Observations with non-employment" ///
"durations of more than two years are excluded. Panel b plots the same outcome but after adjusting for seasonality, that" ///
"is adjusted for seasnal patterns using birth and layoff calendar month fixed effects. similar to Table A6. The dashed " ///
"vertical line denotes the cutoff for UI benefit eligibility extension from 30 to 39 weeks at the age-40 threshold." ///
"The solid lines represent quadratic fits. Age bins corresponds to 4-month intervals", size(tiny)) ///
name(C, replace) 
}
local fn = "A12"
{
use  `Data_II', clear
g y = ay5 
local tit = "Post-unemployment wage"
{  //graph maker
egen m  = mean(y), by(agec)
twoway ///
(scatter m    agec if   id0==1, mcolor(black) msize(small)) /// 
(qfit    y    age   if   age>=40, lcolor(black) ) ///
(qfit    y    age   if   age<40 , lcolor(black) ) ///
, xline(40, lp(dash) lcolor(gs10)) graphregion(fcolor(white)) legend(off)  ytitle("`tit'") xtitle("Age at layoff") subtitle("Panel a ",size(small) ) name(F4a, replace)
}
drop y m 
qui reg ay5 i.end_m#i.birthmo //$cova
qui predict aay5, res
g y = aay5 if !mi(ay4)    
local tit = "Post-unemployment wage, seasonality adjusted"
{  //graph maker
egen m  = mean(y), by(agec)
twoway ///
(scatter m    agec if   id0==1, mcolor(black) msize(small)) /// 
(qfit    y    age   if   age>=40, lcolor(black) ) ///
(qfit    y    age   if   age<40 , lcolor(black) ) ///
, ytitle("`tit'") xline(40, lp(dash) lcolor(gs10)) graphregion(fcolor(white)) legend(off)  xtitle("Age at layoff") subtitle("Panel b ",size(small) ) name(F4b, replace) 
}
gr combine F4a F4b, col(1) graphregion(fcolor(white)) title("Appendix Figure `fn': The role of seasonality", size(small) ) subtitle("UI Effect on Wage", size(small)  ) note( ///
"Note: Panel a plots average change in log wage at post-unemployment jobs for each age. Panel b plots the same outcome but" ///
"after adjusting for seasonality, that is adjusted for seasnal patterns using birth and layoff calendar month fixed effects." ///
"similar to Table A6. For both subfigures observations with non-employment durations of more than two years are excluded. The" ///
"dashed vertical line denotes the cutoff for UI eligibility extension from 30 to 39 weeks at the age-40 threshold. The solid" ///
"lines represent quadratic fits. Age bins corresponds to 4-month intervals.", size(tiny)) ///
name(D, replace)
}
gr combine C D, col(2) graphregion(fcolor(white)) ysize(8.5) xsize(11) 
qui graphexportpdf F`ff'
!rm -f             F`ff'.eps
}
{ //A13, AD4
{ //A13
local fn = "A13"
{ //13a 
use if !mi(ay4) using Data.dta, clear
{ 
{ 
g ee= end_m*31+end_d 
g     x1c  = female
g     x2c  = married
g     x3c  = blue
g     x4c  = aust
g     x5c  = exp_r 
recode education (0/1=0) (2/6=1)     	   , gen(x6c)
forvalues ii = 2(1)7 { 
	g x7c`ii' =  industry==`ii' 
}
	g x7c8  =  industry==0  
}	
{ 
local mm = 20
local ss = 8
foreach vv in tenure ee zipcode_m work5 firmsize work10 wage0_pc { //creating x vars (dummies for each continuous var)
	egen  temp  = xtile(`vv')       , n(`mm')
	forvalues ii = 2(1)`mm' { //ommit the first one due to collinearity
		g x`ss'c`ii'= 	temp==`ii'
	}
	local ss = `ss'+1
	drop temp
}
}
{ 
forvalues ii = 1(1)6 {
	g   ax`ii'c=age40*x`ii'c
	g ddx`ii'c=   ay1*x`ii'c	
}
	local ii=7
	forvalues jj = 2(1)8 {
	g ax`ii'c`jj'=age40*x`ii'c`jj'
	g ddx`ii'c`jj'=   ay1*x`ii'c`jj'	
	}
forvalues ii = 8(1)14 {
	forvalues jj = 2(1)`mm' {
	g ax`ii'c`jj'=age40*x`ii'c`jj'
	g ddx`ii'c`jj'=   ay1*x`ii'c`jj'	
	}
}
}
{ 
foreach ji in 1 4 {
qui reg ay`ji'  age40 ax*c* $varp2 x*c* 
predict r`ji',res  
g qay`ji' =_b[age40]
g say`ji' =_b[_cons]
forvalues ii = 1(1)6 {
	qui replace qay`ji'= qay`ji'+ _b[ax`ii'c]    *x`ii'c
	qui replace say`ji'= say`ji'+ _b[ x`ii'c]    *x`ii'c
}
	local ii=7
	forvalues jj = 2(1)8 {
	qui replace qay`ji'= qay`ji'+ _b[ax`ii'c`jj']*x`ii'c`jj'
	qui replace say`ji'= say`ji'+ _b[ x`ii'c`jj']*x`ii'c`jj'	
	}
forvalues ii = 8(1)14 {
	forvalues jj = 2(1)`mm' {
	qui replace qay`ji'= qay`ji'+ _b[ax`ii'c`jj']*x`ii'c`jj'
	qui replace say`ji'= say`ji'+ _b[ x`ii'c`jj']*x`ii'c`jj'
	}
}
}
}
{ 
reg ay4  ay1 ddx*c* x*c*   
g ddqay =_b[ay1]
forvalues ii = 1(1)6 {
	qui replace ddqay= ddqay+ _b[ddx`ii'c]    *x`ii'c
}
	local ii=7
	forvalues jj = 2(1)8 {
	qui replace ddqay= ddqay+ _b[ddx`ii'c`jj']*x`ii'c`jj'	
	}
forvalues ii = 8(1)14 {
	forvalues jj = 2(1)`mm' {
	qui replace ddqay= ddqay+ _b[ddx`ii'c`jj']*x`ii'c`jj'
	}
}
}
}
{ //13a
	qui reg  qay4 qay1
	local coef=string( _b[qay1],"%9.7f")
	local se  =string(_se[qay1],"%9.7f")
	predict p_p
	cap drop n
	egen n    =xtile(qay1), n(100)
	egen qay1c= mean(qay1), by(n)
	egen qay4m= mean(qay4), by(qay1c)
	egen p_pc = mean(p_p), by(qay1c)	
	bys qay1c: g id = _n==1
	g r = runiform()
	cap drop temp*
	foreach ii in 1 4{
		qui winsor2 qay`ii', s(w) cuts(.1 99.9) trim
	}	
	twoway ///
	(scatter qay4w  qay1w if r<.05 , mc(gs14)  msym(p))      ///	
	(line    p_pc  qay1c  if id ==1, lc(black)) ///
	(scatter qay4m qay1c if id ==1, mc(black) msize(small))  ///
	, leg(off)  ylabel(-.06(.02).06) xlabel(-20(10)30) graphregion(color(white)) 	 ///
	name(AF13a, replace) xt("UI effect on non-enmployment duration (predicted)") yt("UI effect on wage (predicted)") /// 	subt("Panel a" , size(small) ) ///
	note("Coefficient = `coef'" ///
	"        (`se')", position(2) ring(0) size(small)) 
	drop n id r qay1c qay4m 	p_p* qay1w qay4w
}	
}
{ //13b
use if es using "Data.dta", clear
drop if mi(ay1) | mi(ay4)
keep if abs(age-40)<3
cap drop x d dx dx2 x2
g x   = age_p1
g d   = age>=40
g dx  = age_q1
g x2  = age_p2
g dx2 = age_q2
g ee= end_m*31+end_d 

g        x1b = female
g        x2b = married
g        x3b = blue
g        x4b = aust
g        x5b = exp_r 
egen  x6b = xtile(tenure)       , n(4)
egen  x7b = xtile(end)          , n(4)                            
egen  x8b = xtile(ee)           , n(4)   
egen  x9b = xtile(zipcode_m)    , n(4)
egen  x10b = xtile(work5)       , n(4)
egen  x11b = xtile(nace95)      , n(4)
egen  x12b = xtile(firmsize)    , n(4)
egen  x13b = xtile(work10)      , n(4)
egen  x14b = xtile(wage0_pc)    , n(4)
 g    x21b = education
 g    x22b = industry
xi i.x1b i.x2b i.x3b i.x4b i.x5b i.x6b i.x7b i.x8b i.x9b i.x10b i.x11b i.x12b i.x13b i.x14b i.x21b i.x22b 
lars ay1 _I*
egen z = group(_Ix5b_1 _Ix6b_4  _Ix22b_3 _Ix3b_1 _Ix1b_1 _Ix6b_2 _Ix8b_4 _Ix8b_2 _Ix10b_3  _Ix8b_3)
qui sum z,d
local c2 = r(max)
bys z d : g pp = _N
egen pp2=min(pp), by(z)
replace z = `c2'+1 if pp2<50
drop pp pp2
egen z2 = group(z)
drop z 
rename z2 z
egen ned_cp=  xtile(pay1), n(5)
bys z ned_cp: g pp = _N
qui g an_w=.
qui g aw_w=.
qui sum z
local c2 = r(max)
qui forvalues ii=1(1)`c2' {
	qui regress  ay1 d x x2 dx dx2 if z==`ii' [aw=1/pp]
	       replace an_w =   _b[d]  if z==`ii'
	qui regress  ay4 d x x2 dx dx2 if z==`ii' [aw=1/pp]
	       replace aw_w =   _b[d]  if z==`ii'
}
tabmiss z
g n =1
collapse (mean) an_w aw_w (count) n , by(z)
	sum n
	reg        aw_w  an_w
	local coef=string( _b[an_w],"%9.7f")
	local se  =string(_se[an_w],"%9.7f")
	qui winsor2 aw_w, s(w) cuts(.1 99.9) trim
	qui winsor2 an_w, s(w) cuts(.1 99.9) trim	
	cap drop n
	egen n    =xtile(an_w), n(20)
	egen an_wc= mean(an_w), by(n)
	egen aw_wm= mean(aw_w), by(an_wc)	
twoway (scatter aw_ww    an_ww  ,mc(gs14) msize(vsmall))(lfit aw_w an_w, lc(black))(scatter aw_wm    an_wc  ,mc(black) msize(small)), name(AF13b, replace)  leg(off) graphregion(fcolor(white)) xtitle("UI effect on non−employment duration ") ytitle("UI effect on wage") subt("Panel b", size(small)  ) ///
	note("Coefficient = `coef'" ///
	"        (`se')", position(2) ring(0) size(small))	
}
gr combine AF13a AF13b, col(1) graphregion(fcolor(white)) title("Appendix Figure `fn'", size(small) ) subtitle("UI wage vs. duration effects", size(small)  ) ///
note("Note: This figure provides empirical evidence for a negative relation between the UI extension effect on non-employment duration" ///
     "its effect on post-unemployment wage. Panel a plots the UI effect on wage against the non-employemnt effect, both predicted" ///
     "using ex-ante pre-determinedobservables, e.g. inudstry, occupation, tenure, etc. It shows both row data as well as a 100-binned" ///
     "scatter plot, where the solid line and the coefficient correspond to the best linear fit on the underlying data using OLS. The raw" ///
     "data correspond to a random 5% of the population, trimmed at .1%. Panel b is replicates the re-sampling method similar to" ///
     "figure Vb but with full interactions among few covartiates selected using a machine learning algorithm (see Appendix B.3)." , size(tiny)) name(FA13, replace) 
}
{ // A14
{ // Prepare Card, Chetty, Weber data
use  "/home/aneko/OUI/Data2/CCW/sample_75_02", clear

global sevpay_break = 3*365
global mth_l = 31
global udur_limit = 140

*Eliminate parts of sample: keep layoffs between 1981-2001, drop volquits and recalls
gen outofsample = endy<=1980|endy>=2002|volquit==1|region==0|recall==1
gen insample = 1-outofsample
keep if insample==1

*Merge on work history data
cap drop _merge
sort penr file
merge penr file using  "/home/aneko/OUI/Data2/CCW/work_history", nokeep
tab _merge
drop _merge

gen gap = noneduration-uduration
gen emp_prior = dempl5-duration>30 if dempl5~=.&duration~=.

gen duration_recenter_sp = duration-$sevpay_break
gen duration_recenter_eb = dempl5-$sevpay_break
gen tenure_cat_sp = int(duration_recenter_sp/$mth_l)+36 if duration_recenter_sp>=0
replace tenure_cat_sp = int((duration_recenter_sp+1)/$mth_l)+35 if duration_recenter_sp<0
gen tenure_cat_eb = int(duration_recenter_eb/$mth_l)+36 if duration_recenter_eb>=0
replace tenure_cat_eb = int((duration_recenter_eb+1)/$mth_l)+35 if duration_recenter_eb<0

*For figures, exclude months 12 and 59
replace tenure_cat_eb = . if tenure_cat_eb==12|tenure_cat_eb==59
replace tenure_cat_sp = . if tenure_cat_sp==12|tenure_cat_sp==59
keep if duration>=365&duration<5*365&dempl5>=365&dempl5<5*365

replace region=8 if region==9
replace region=5 if region==3
replace region=5 if region==6
replace ne_region=8 if ne_region==9
replace ne_region=5 if ne_region==3
replace ne_region=5 if ne_region==6

gen high_ed = education>1 if education~=.
replace high_ed = 0 if education==.
gen married_orig=married
replace married = 0 if married==.
gen sevpay = duration>=$sevpay_break
cap drop eligible30
gen eligible30 =dempl5>=$sevpay_break

*Generate covariates and polynomials

gen lwage=log(wage0)
gen lwage2=lwage^2
gen age2=age^2
gen exper2 = experience^2
tab endmo, gen(endmo_dum)
tab endy, gen(endy_dum)
tab region, gen(reg_dum)
tab industry, gen(ind_dum)
tab tenure_cat_sp, gen(tenure_cat_dum)

*Generate recentered tenure variable
gen dten1 = duration_recenter_sp/365
gen dten2 = dten1^2
gen dten3 = dten1^3
gen dten4 = dten1^4
gen int1 = sevpay*dten1
gen int2 = sevpay*dten2
gen int3 = sevpay*dten3
gen int4 = sevpay*dten4

gen demp1 = duration_recenter_eb/365
gen demp2 = demp1^2
gen demp3 = demp1^3
gen demp4 = demp1^4
gen int_emp1 = eligible30*demp1
gen int_emp2 = eligible30*demp2
gen int_emp3 = eligible30*demp3
gen int_emp4 = eligible30*demp4

gen tenure_mths = duration/$mth_l
gen noneduration_mths = noneduration/$mth_l
gen mths_worked_past5 = dempl5/$mth_l
gen tt_next_job_mths = noneduration/$mth_l
gen wage_change = log(ne_wage0)-log(wage0)
gen nonedur_l20w = noneduration<140
gen nonedur_l52w = noneduration<365
gen nextjob = ne_start<15887
gen totexp_mths = (experience+duration)/$mth_l
gen hasgap = gap>0 if gap<.
gen ann_wage = wage0*14
gen endofyear = (tenure_cat_sp>=21&tenure_cat_sp<=23)|(tenure_cat_sp>=33&tenure_cat_sp<=35)|(tenure_cat_sp>=45&tenure_cat_sp<=47)|(tenure_cat_sp>=57&tenure_cat_sp<=59)

gen cens_ne = ne_start==15887

gen uduration_mths = uduration/$mth_l
gen udur_l20w = uduration<140
gen udur_l52w = uduration<365

gen cens_ne_dur = ne_start+ne_duration>=d(1jul2003) if indnemp==1
replace cens_ne_dur = 1 if ne_duration>5*365
gen ne_dur_mths = 1+int(ne_duration/$mth_l)

gen last_bluec = last_etyp==2
drop last_etyp
gen last_posnonedur = last_nonedur>0

bys benr endy endmo: gen mthcount=_N


drop if mi(noneduration) | mi(wage_change)
keep if noneduration<2*365 & ne_wage0 !=. & wage0 !=. 

* Generate predicted nonemployment duration 
cap drop reg_dum* ind_dum*
replace region=99 if region==.
tab region, gen(reg_dum)
replace industry=99 if industry==.
tab industry, gen(ind_dum)

gen firms_m=firms
foreach x in firms_m {
egen av_`x'=mean(`x')
replace `x'=av_`x' if `x'==.
drop av_`x'
}

global ind_cova female bluecollar austrian age age2 high_ed married experience exper2 lwage lwage2 firms_m last_*
tabmiss $ind_cova
reg noneduration $ind_cova reg_dum2-reg_dum7 ind_dum2-ind_dum7 endy_dum2-endy_dum21 endmo_dum2-endmo_dum12
cap drop pnoneduration
predict pnoneduration

{ //Create variables
cap drop ee
cap drop endday
g endday=day(end)
g ee= endmo*31+endday 

g     x1c = female
g     x2c = married
g     x3c = blue
g     x4c = austrian
egen  x5c = xtile(last_recall), n(2)
egen  x6c = xtile(end) , n(2)                              
egen  x7c = xtile(ee)  , n(2)   //seasonality
gen x8c=(region==1) // vienna
gen x9c=(high_ed==1) // high education
gen x10c=(industry==4|industry==7)  // sales and service
egen  x11c = xtile(firms_m)    , n(2)
egen  x12c = xtile(wage0)    , n(2)

g     x1b = female
g     x2b = married
g     x3b = blue
g     x4b = austrian
egen  x5b = xtile(last_recall), n(2)
egen  x6b = xtile(end) , n(4)                              
egen  x7b = xtile(ee)  , n(4)   //seasonality
recode region (7 99=99)			, gen(x8b)
gen x9b=(high_ed==1) // high education
recode industry (1 6 99=99)			, gen(x10b)
egen  x11b = xtile(firms_m)    , n(4)
egen  x12b = xtile(wage0)    , n(4)
}
tempfile CCW
save    `CCW', replace
}
local ff = "A14"
local fn = "A14"
{ // FA 14a
use    `CCW', clear
{
local bb  = 10
local i = 0
g eudwp=.
g ewgwp=.
g eudwp_se=.
g eudwp_p=.
g ewgwp_se=.
g ewgwp_p=.
g zx =.
g zx2 =.
g zc =.
cap drop n
g n =.
egen ned_cp=  xtile(pnoneduration),n(100)
}
foreach j in   1 2 3 4 5 6 7 8 9 10 11 12   {
cap drop  categ
egen      categ = group(x`j'b)
qui sum   categ
local max = r(max)
cap drop pp
bys categ ned_cp: g pp = _N
forvalues cc    = 1(1)`max'{
	local i = `i' +1
	qui reg      noneduration sevpay eligible30 dten1-dten3 int1-int3 demp1-demp3 int_emp1-int_emp3 if categ==`cc' [aw=1/pp]         
	qui replace  eudwp   = _b[eligible30]  if _n   ==`i'	
	qui replace  eudwp_se= _se[eligible30] if _n   ==`i'	
	qui replace  eudwp_p = (2 * ttail(e(df_r), abs(_b[eligible30]/_se[eligible30]))) if _n   ==`i'	

	qui reg      wage_change sevpay eligible30 dten1-dten3 int1-int3 demp1-demp3 int_emp1-int_emp3 if categ==`cc' [aw=1/pp]          
	qui replace  ewgwp   = _b[eligible30]  if _n   ==`i'	
	qui replace  ewgwp_se= _se[eligible30] if _n   ==`i'	
	qui replace  ewgwp_p = (2 * ttail(e(df_r), abs(_b[eligible30]/_se[eligible30]))) if _n   ==`i'	

	qui replace  n       = e(N)       if _n   ==`i'			
	qui replace  zx      = `j'        if _n   ==`i'	
	qui replace  zc      = `cc'       if _n   ==`i'	
}
}

foreach j1 in 1 2 3 4 5 6 7 8 9 10 11 12  {
foreach j2 in 1 2 3 4 5 6 7 8 9 10 11 12  {
if `j1'>`j2' {
cap drop  categ
egen      categ = group(x`j1'c x`j2'c)
qui sum   categ
local max = r(max)
cap drop pp
bys categ ned_cp: g pp = _N
gen help1=eudwp==.
sort help1
drop help1
forvalues cc    = 1(1)`max'{
	local i = `i' +1
	qui reg      noneduration sevpay eligible30 dten1-dten3 int1-int3 demp1-demp3 int_emp1-int_emp3 if categ==`cc' [aw=1/pp]         
	qui replace  eudwp   = _b[eligible30]  if _n   ==`i'	
	qui replace  eudwp_se= _se[eligible30] if _n   ==`i'	
	qui replace  eudwp_p = (2 * ttail(e(df_r), abs(_b[eligible30]/_se[eligible30]))) if _n   ==`i'	
	qui reg      wage_change sevpay eligible30 dten1-dten3 int1-int3 demp1-demp3 int_emp1-int_emp3 if categ==`cc' [aw=1/pp]          
	qui replace  ewgwp   = _b[eligible30]  if _n   ==`i'	
	qui replace  ewgwp_se= _se[eligible30] if _n   ==`i'	
	qui replace  ewgwp_p = (2 * ttail(e(df_r), abs(_b[eligible30]/_se[eligible30]))) if _n   ==`i'	
	qui replace  n       = e(N)       if _n   ==`i'		
	qui replace  zx      = `j1'        if _n   ==`i'
	qui replace  zx2     = `j2'        if _n   ==`i'	
	qui replace  zc      = `cc'       if _n   ==`i'	
}
}
}
}

di `i'
drop if eudwp==.
keep eud* ewg* n zc zx zx2

	cap drop x y xw yw ym xc
	g x = eudwp
	g y = ewgwp 
	reg        y  x
	local coef=string( _b[x],"%9.7f")
	local se  =string(_se[x],"%9.7f")
	qui winsor2 x, s(w) cuts(1 99) trim
	qui winsor2 y, s(w) cuts(1 99) trim	
	cap drop n
	egen n    =xtile(x), n(20)
	egen xc= mean(x), by(n)
	egen ym= mean(y), by(xc)	
twoway (scatter yw xw ,mc(gs14) msize(vsmall))(lfit y x, lc(black))(scatter ym    xc  ,mc(black) msize(small)), leg(off) graphregion(fcolor(white)) ///
	xtitle("UI effect on non−employment duration ") ytitle("UI effect on wage") subt("Panel a", size(small)  ) ///
	note("Coefficient = `coef'" ///
	"        (`se')", position(2) ring(0) size(small)) name(A, replace)
summarize n, d
count if eudwp_p<0.05
count if ewgwp_p<0.05
count if eudwp_p<0.05 &  ewgwp_p<0.05
}
{ // FA 14b
use    `CCW', clear
xi i.x1b i.x2b i.x3b i.x4b i.x5b  i.x6b i.x7b i.x8b i.x9b i.x10b i.x11b i.x12b 
lars noneduration _I*
cap drop z
cap drop pp
cap drop pp2
egen z = group(_Ix2b_1  _Ix3b_1 _Ix4b_1  _Ix6b_2  _Ix6b_4   _Ix8b_2 _Ix8b_4   _Ix8b_5  _Ix8b_8 _Ix8b_99  _Ix11b_4   _Ix12b_2  _Ix12b_3  _Ix12b_4  )  
codebook z

sum z,d
local c2 = r(max)
bys z eligible30 : g pp = _N
sum pp, d
egen pp2=min(pp), by(z)
replace z = `c2'+1 if pp2<100 //combinning all the small cells
tab z
drop pp
codebook z

egen z2 = group(z)
drop z 
rename z2 z

egen ned_cp=  xtile(pnoneduration), n(5)
bys z ned_cp: g pp = _N
sum z,d
local c2 = r(max)

gen an_w=.
gen an_w_se=.
gen an_w_p=.
gen aw_w=.
gen aw_w_se=.
gen aw_w_p=.
sum z
local c2 = r(max)
qui forvalues ii=1(1)`c2' {
	qui regress  noneduration sevpay eligible30 dten1-dten2 int1-int2 demp1-demp2 int_emp1-int_emp2 if z==`ii' [aw=1/pp]
	qui    replace an_w =   _b[eligible30]  if z==`ii'
	qui	   replace an_w_se= _se[eligible30] if z==`ii'	
	qui	   replace an_w_p = (2 * ttail(e(df_r), abs(_b[eligible30]/_se[eligible30]))) if z==`ii'	
		   
	qui regress  wage_change sevpay eligible30 dten1-dten2 int1-int2 demp1-demp2 int_emp1-int_emp2 if z==`ii' [aw=1/pp]
	qui    replace aw_w =   _b[eligible30]  if z==`ii'
	qui	   replace aw_w_se= _se[eligible30] if z==`ii'	
	qui	   replace aw_w_p = (2 * ttail(e(df_r), abs(_b[eligible30]/_se[eligible30]))) if z==`ii'	
		   
}

g n =1
collapse (mean) an_w aw_w /*an_uw aw_uw an aw */ an_w_se an_w_p aw_w_se aw_w_p (count) n , by(z)
count
count if aw_w==0 | an_w==0
drop if aw_w==0 | an_w==0

qui reg        aw_w  an_w
	predict xb, xb
	local coef=string( _b[an_w],"%9.7f")
	local se  =string(_se[an_w],"%9.7f")
twoway(scatter aw_w    an_w ,mc(black)  msize(small)) (line xb an_w, lc(black)), name(Bo, replace) leg(off) graphregion(fcolor(white)) xtitle("UI effect on non-employment duration ")  ///
ytitle("UI effect on wage") subt("Panel b" , size(small)) ///
note("Coefficient = `coef'" ///
	"        (`se')", position(2) ring(0) size(small))

	cap drop x y xw yw ym xc
	g x = an_w
	g y = aw_w 
	reg        y  x
	local coef=string( _b[x],"%9.7f")
	local se  =string(_se[x],"%9.7f")
	qui winsor2 x, s(w) cuts(1 99) trim
	qui winsor2 y, s(w) cuts(1 99) trim	
	cap drop n
	egen n    =xtile(x), n(20)
	egen xc= mean(x), by(n)
	egen ym= mean(y), by(xc)	
twoway (scatter yw xw ,mc(gs14) msize(vsmall))(lfit y x, lc(black))(scatter ym    xc  ,mc(black) msize(small)), leg(off) graphregion(fcolor(white)) ///
	xtitle("UI effect on non−employment duration ") ytitle("UI effect on wage") subt("Panel b", size(small)  ) ///
	note("Coefficient = `coef'" ///
	"        (`se')", position(2) ring(0) size(small)) name(B, replace)	

summarize n, d
count if an_w_p<0.05
count if aw_w_p<0.05
count if an_w_p<0.05 & aw_w_p<0.05
}
gr combine A B, col(1) graphregion(fcolor(white)) title("Appendix Figure `fn'", size(small) ) subtitle("UI wage vs. duration effects, UI extension 20-30 wks", size(small) ) note( ///
"Note: This figure provides empirical evidence for a negative relation between the UI effect on non-employment duration and its" ///
" effect on post-unemployment wage for the analysis sample in Card, Chetty, Weber (2007a). Both panels plot the estimated UI" ///
"effect on wage against its effect on non-employment duration for subgroups in the sample. Subgroups in Panel a are defined by " ///
"dummy indicators plus first-order interactions between them. Subgroups in Panel b are determined by higher order interactions" ///
"between dummy indicators (see Appendix B.3). They show both row data (trimmed at 1%) as well as a binned scatter plot, " /// 
"where the solid line and the coefficient correspond to the best linear fit on the underlying data using OLS." , size(tiny)) name(F`ff', replace)  ysize(8.5) xsize(5.5) 
}
gr combine FA13 FA14, col(2) graphregion(fcolor(white)) ysize(8.5) xsize(11)  
qui graphexportpdf FA13
!rm -f             FA13.eps
}
}
!gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile=AppF"$S_DATE".pdf FA01.pdf FA03.pdf FA05.pdf  FA07.pdf FA09.pdf  FA11.pdf  FA13.pdf
!rm -f  FA*.pdf  
!rm -f  *.eps  
