************************************************************************

cap: program drop corr_table_reg
program define corr_table_reg, eclass 
	syntax varlist, indvar(varname) [controls(string)] 

tempname est_b est_V b V se est_F F N mean sd
foreach var of local varlist {
	reg `var' `indvar' `controls'

	* Save results from regression
	mat `est_b' 	= e(b)
	mat `est_V' 	= e(V)
	mat `est_F'		= e(F)

	* Get mean and sd from indvar for control group
	su `var' if `indvar'==0

	* Construct the fake "regression matrixes" which look like the results from a normal reg function
	mat `b'  	  	= nullmat(`b')   , `est_b'[1,1]
	mat `se' 		= nullmat(`se')  , `=sqrt(`est_V'[1,1])'
	mat `N'  		= nullmat(`N'), e(N)	
	mat `mean'  	= nullmat(`mean'), r(mean)
	mat `sd'  		= nullmat(`sd'), r(sd)
	mat `F'		  	= nullmat(`F'), `est_F'
}

* Label the output matricies
foreach mat in b se F N mean sd {
	mat coln ``mat'' = `varlist'
	mat rown ``mat'' = `indvar'
}

* Construct the fake "variance matrix" (only the diagonal matters to calculate t-statistics)
mat `V' = `se''*`se'
 
* Return the results in e() to be read by eststo. 
ereturn post `b' `V', depname("`indvar'") 
ereturn local cmd "corr_table"
foreach mat in F N mean sd {
	ereturn mat `mat' = ``mat''
}

end


cap: program drop corr_table_reg_rev
program define corr_table_reg_rev, eclass 
	syntax varlist, depvar(varname) [controls(string)] 

tempname est_b est_V b V se est_F F N mean sd
foreach var of local varlist {
	reg `depvar' `var' `controls'

	* Save results from regression
	mat `est_b' 	= e(b)
	mat `est_V' 	= e(V)
	mat `est_F'		= e(F)

	* Get mean and sd from indvar for control group
	su `depvar' 

	* Construct the fake "regression matrixes" which look like the results from a normal reg function
	mat `b'  	  	= nullmat(`b')   , `est_b'[1,1]
	mat `se' 		= nullmat(`se')  , `=sqrt(`est_V'[1,1])'
	mat `N'  		= nullmat(`N'), e(N)	
	mat `mean'  	= nullmat(`mean'), r(mean)
	mat `sd'  		= nullmat(`sd'), r(sd)
	mat `F'		  	= nullmat(`F'), `est_F'
}

* Label the output matricies
foreach mat in b se F N mean sd {
	mat coln ``mat'' = `varlist'
	mat rown ``mat'' = `depvar'
}

* Construct the fake "variance matrix" (only the diagonal matters to calculate t-statistics)
mat `V' = `se''*`se'
 
* Return the results in e() to be read by eststo. 
ereturn post `b' `V', depname("`depvar'") 
ereturn local cmd "corr_table"
foreach mat in F N mean sd {
	ereturn mat `mat' = ``mat''
}

end


************************************************************************	 

/*
clear 
sysuse auto
g treatment = (mpg > 25)

eststo clear
eststo: corr_table_reg mpg rep78 headroom trunk weight, indvar(treatment)

esttab using "location/testreg.tex", ///
	cells("mean(fmt(%9.2f)) b(fmt(%9.2f) star) N(fmt(%9.0f))" "sd(par([ ]) fmt(%9.2f)) se(par fmt(%9.2f)) ") ///
	label se noobs replace nonumbers nomtitles varwidth(38) wrap longtable ///
	collabels("Control Mean" "Treatment Effect" "N") star(* 0.10 ** 0.05 *** 0.01)
*/
	
	
	
	
	
	
