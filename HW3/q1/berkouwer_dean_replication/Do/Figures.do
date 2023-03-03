include "${main}/Do/0. Master.do"
use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear
local CONTROLS = "d_charcoalbuy_USD savings_USD b_incomeself_USD RiskAverse CreditConstrained b_residents b_children"

g savingsperc = sms_amount_weekly_post_KSH / sms_amount_weekly_pre_KSH
bys jikokoa: su  savingsperc ,d

 
local SAVINGS = 1-exp(-0.50) /* From Table 2, column 4*/
di "`SAVINGS'"

* SET GRAPH FONT 
/* Correct Mac fonts
graph set eps fontfaceserif "PTSerif-Roman"
graph set ps fontface "PTSerif-Roman"
*graph set window fontface "PTSerif-Regular" // THIS WORKS FOR MAC TO GET LATEX
 */

/* Correct Windows fonts */
graph set window fontface "Palatino Linotype"
graph set eps fontface "Palatino Linotype"

	
* IN PAPER
local visit1						= 1
local TIOLIBDM 						= 1
local Demand_Setup					= 1
local Demand_Treatments				= 1
local Demand_dRobustness 			= 1
local SMSDiD						= 1
local SavingsheteroByWTP			= 1
local SMSattrition					= 1
local WTPmovement					= 1
local usagespending					= 1
local Demand_Repay 					= 1


							****** AFTER VISIT 1 *******

if `visit1' == 1 {
	
	
	use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear

	cou
	assert `r(N)'==1011 // Only ever run on full V1 sample (used to be 1018)
	
	***********************************************************
	************* RESPONDENT CHARACTERISTICS ******************
	
	* Best things Jikokoa
	graph bar (mean) ///
		d_bestthings_1 d_bestthings_5 d_bestthings_7 ///
		d_bestthings_4 d_bestthings_3 d_bestthings_6 d_bestthings_2, ///
		nolabel legend(/*position(3)*/ cols(1) region(lcolor(white) margin(r+20 t+5)) ///
			label(1 "Save money") label(2 "Less smoke") label(3 "Save time") ///
			label(4 "Taste") label(5 "Durable") label(6 "I'll be modern") label(7 "Others will like it")) ///
		bar(1, color(gs2)) bar(2, color(gs4)) bar(3, color(gs6)) bar(4, color(gs8)) bar(5, color(gs10)) bar(6, color(gs12)) bar(7, color(gs14)) ///
		`white' ysize(2) xsize(1.7) scale(1.5) /// 
		ytitle("Fraction of respondents", margin(r+5)) ylabel(0(0.25)1, nogrid)
	*graph export "`graphs'/FigureC1B_JikokoaBestThings.pdf", replace
	graph export "`graphs'/FigureC1B_JikokoaBestThings.eps", replace
	*graph export "`graphs'/FigureC1B_JikokoaBestThings.png", replace
		
	* Stove attributes
	graph bar (mean) ///
		d_attributes_save d_attributes_smoke d_attributes_easy d_attributes_cheap d_attributes_taste d_attributes_looks, ///
		nolabel graphregion(margin(t+5)) legend(/*position(3)*/ region(lcolor(white)) cols(1) margin(r+5) ///
		label(4 "Price") label(3 "Ease of use") label(6 "Looks") label(1 "Save money") label(2 "Less smoke") label(5 "Taste")) ///
		bar(1, color(gs2)) bar(2, color(gs4)) bar(3, color(gs6)) bar(4, color(gs8)) bar(5, color(gs10)) bar(6, color(gs12)) ///
		`white' ysize(2) xsize(1.8) scale(1.6) /// 
		ytitle("Average preference ratio", margin(r+5)) ylabel(, nogrid)
	*graph export "`graphs'/FigureC1A_Attributes.pdf", replace
	graph export "`graphs'/FigureC1A_Attributes.eps", replace
*	graph export "`graphs'/FigureC1A_Attributes.png", replace

	hist price_USD, freq width(1) start(0) /// 
		color(gs10) lcolor(black) legend(off) `white' ///
		xlabel(0(5)30, angle(0)) ///
		ylabel(0(50)250, angle(0) nogrid) scale(1.4) ///
		xtitle("BDM Hidden Price (USD)") ytitle("Number of Respondents") title("") 
*	graph export "`graphs'/FigureA4_PriceDistributionMain_USD.pdf", replace
	graph export "`graphs'/FigureA4_PriceDistributionMain_USD.eps", replace
	*graph export "`graphs'/FigureA4_PriceDistributionMain_USD.png", replace

}		
		
						
							****** AFTER VISIT 2 *******
		
*****************************************************
*************** CONFIRM THAT TIOLI=BDM *************

if `TIOLIBDM' == 1 {
use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear

	keep if Visit2==1

	* TIOLI
	replace pracbuy_tioli = . if pracTIOLIitem=="Lotion" & (pracprice1<10 | pracprice1>110)	
	replace pracbuy_tioli = . if pracTIOLIitem=="KipandeYaSabuni" & (pracprice1<11 | pracprice1>120)
	sort pracTIOLIitem pracprice1 
	
	* TIOLI Bins:
	by pracTIOLIitem: g Group = round(_n/50)
	sort pracTIOLIitem Group
	by pracTIOLIitem Group: egen meanbuy=mean(pracbuy_tioli)
	by pracTIOLIitem Group: egen meanprice=mean(pracprice1)
	
	bys meanprice meanbuy: g n = _n
	
	* BDM
	g finwtp_lotion = prac_finwtp if pracBDMitem=="Lotion"
	g finwtp_soap   = prac_finwtp if pracBDMitem=="KipandeYaSabuni"
	
	foreach good in lotion soap {	
		cumul finwtp_`good', g(cumul_`good')
		replace cumul_`good' = 1-cumul_`good'
	}

	* Convert to USD: 
		foreach var of varlist finwtp_lotion finwtp_soap pracprice1 meanprice {	
			replace `var' = `var' / 100
		}
			

		
		twoway ///
			(lowess finwtp_lotion cumul_lotion  , bwidth(0.1) sort lcolor(gs8))  ///
			(lowess finwtp_soap	  cumul_soap	, bwidth(0.1) sort lcolor(midblue))  ///
			(lpoly meanprice meanbuy if n==1 & pracTIOLIitem=="Lotion"	, bwidth(0.1) degree(1) mcolor(gs8) msymbol(S) lcolor(gs8) lpattern(dash)) ///	
			(lpoly meanprice meanbuy if n==1 & pracTIOLIitem=="KipandeYaSabuni", bwidth(0.1) degree(1) mcolor(midblue) msymbol(S) lcolor(midblue) lpattern(dash)) ///	
			(scatter meanprice meanbuy if n==1 & pracTIOLIitem=="Lotion"	, mcolor(gs8) msize(small) msymbol(S) lcolor(gs8) lpattern(dash)) ///	
			(scatter meanprice meanbuy if n==1 & pracTIOLIitem=="KipandeYaSabuni", mcolor(midblue) msize(small) msymbol(S) lcolor(midblue) lpattern(dash)), ///	
			`white' ///
			ytitle("Price (USD)") xtitle("Q") ylabel(, nogrid angle(0)) ///
			scale(1.8) xsize(2.1) ysize(1) aspectratio(0.7) /// 
			legend(	col(1) pos(3) order(1 2 3 4) nocolfirst region(lcolor(white)) ///
				label(1 "BDM (Lotion)") ///
				label(2 "BDM (Soap)") ///
				label(3 "TIOLI (Lotion)") ///
				label(4 "TIOLI (Soap)"))
	*	graph export "`graphs'/FigureA5_BDM_tioli_USD_scatter.png", replace
	*	graph export "`graphs'/FigureA5_BDM_tioli_USD_scatter.pdf", replace
		graph export "`graphs'/FigureA5_BDM_tioli_USD_scatter.eps", replace

}



**********************************************
************* DEMAND CURVES ******************

if `Demand_Setup' == 1 | `Demand_Treatments' == 1 | `Demand_dRobustness' == 1 | `Demand_Repay' == 1 {	
		 
	foreach c in USD {
	
	use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear
		
		keep if Visit2==1

		cumul finwtp_`c' if (treata==0), g(cumul)
			
		cumul finwtp_`c' if (treata==0), g(cumul_a0)
		cumul finwtp_`c' if (treata==1), g(cumul_a1)
		cumul finwtp_`c' if (treata==2), g(cumul_a2)
		
		cumul finwtp_`c' if (treatc==0), g(cumul_c0)
		cumul finwtp_`c' if (treatc==1), g(cumul_c1)
		cumul finwtp_`c' if (treatc==2), g(cumul_c2)
		
		cumul finwtp_`c' if (treatc_pooled==1) & (treata_pooled==0), g(cumul_c)
		cumul finwtp_`c' if (treata_pooled==1) & (treatc_pooled==0), g(cumul_a)
		
		cumul finwtp_`c' if (treata==0) & treatc_pooled==0, g(cumul_c0a0)
		cumul finwtp_`c' if (treata==1) & treatc_pooled==0, g(cumul_c0a1)
		cumul finwtp_`c' if (treata==2) & treatc_pooled==0, g(cumul_c0a2)
		cumul finwtp_`c' if (treata==0) & treatc_pooled==1, g(cumul_c1a0)
		cumul finwtp_`c' if (treata==1) & treatc_pooled==1, g(cumul_c1a1)
		cumul finwtp_`c' if (treata==2) & treatc_pooled==1, g(cumul_c1a2)
	
		cumul finwtp_`c' if RiskAverse==0 & (treata==1) & treatc_pooled==1, g(cumul_c1a1NRA)
		cumul finwtp_`c' if RiskAverse==0 & (treata==2) & treatc_pooled==1, g(cumul_c1a2NRA)
		cumul finwtp_`c' if RiskAverse==1 & (treata==1) & treatc_pooled==1, g(cumul_c1a1RA)
		cumul finwtp_`c' if RiskAverse==1 & (treata==2) & treatc_pooled==1, g(cumul_c1a2RA)
		
		cumul finwtp_`c' if PB==0 & treatc_pooled==0, g(cumul_c0PB0)
		cumul finwtp_`c' if PB==0 & treatc_pooled==1, g(cumul_c1PB0)
		cumul finwtp_`c' if PB==1 & treatc_pooled==0, g(cumul_c0PB1)
		cumul finwtp_`c' if PB==1 & treatc_pooled==1, g(cumul_c1PB1)
		
		
		lab var finwtp_`c' 			"Histogram of WTP"
		
		g 		savings_2yrpred = 	( d_charcoalbuy_`c' * `SAVINGS' ) * 13 * 0.985945
		lab var savings_2yrpred 	"Breakeven demand curve (Discount 0.9)" 
		
		* Can't bid more than 5000 // How to handle?
		assert !missing(savings_2yrpred)
		if "`c'"=="KSH" replace savings_2yrpred = 5000 if savings_2yrpred>5000 
		if "`c'"=="USD" replace savings_2yrpred = 50 if savings_2yrpred>50 
	
		cumul d_charcoalbuy_`c', g(cumul_pay)
		foreach var of varlist cumul* {
			replace `var' = 1-`var'
		}


	if `Demand_Setup' == 1 {


		
		* Savings line, WTP histogram, and pure control demand curve: 
		twoway ///
			(hist finwtp_`c' if treatc_pooled==0 & treata_pooled==0, frac width(5) start(0) horizontal color(gs13) lcolor(gs9) xaxis(1)) /// 
			(lowess savings_2yrpred cumul_pay, bwidth(0.3) sort lpattern("-..") xaxis(1) color(black)) /// 
			(lowess finwtp_`c' cumul_c0a0	 , bwidth(0.2) sort xaxis(1) lcolor(gs10)),  ///
			`white' ///
			ytitle("`c'") ///
			xtitle("Q", axis(1))  ///
			ylabel(#5, angle(90) nogrid) ///
			xtick(0(0.25)1, tlcolor(white) axis(1)) ///
			xtick(0(0.25)1, tlcolor(white) axis(1)) ///
			aspectratio(1, placement(left)) scale(1.5) xsize(2.3) ysize(1) ///
			legend(cols(1) position(3) order(2 3 1 4) region(lcolor(white)) ///
					label(1 "Pure control histogram of WTP" ) ///
					label(2 "Breakeven demand curve (3-month horizon)" ) ///
					label(3 "Pure control demand curve")) 

		*graph export "`graphs'/Figure5_Demand_WTPS_`c'_C0A0onlyHist_PAPER.png", replace
		*graph export "`graphs'/Figure5_Demand_WTPS_`c'_C0A0onlyHist_PAPER.pdf", replace
		graph export "`graphs'/Figure5_Demand_WTPS_`c'_C0A0onlyHist_PAPER.eps", replace
		

		
	}
	

	
	if `Demand_Treatments' == 1 {
		
		

		
		*** MAIN CREIDT 
		twoway ///
			(lowess savings_2yrpred cumul_pay, bwidth(0.3) sort lpattern("-..") xaxis(1) color(white)) /// 
			(lowess finwtp_`c' cumul_c0a0, bwidth(0.2) sort xaxis(1) lcolor(gs10))  ///
			(lowess finwtp_`c' cumul_c, bwidth(0.2) sort xaxis(1) lpattern(longdash) lcolor(midblue)),  ///
				`white' ///
			ytitle("`c'" " ") ///
			xtitle("Q", axis(1)) /*xtitle("", axis(2))*/ ///
			ylabel(#5, angle(0) nogrid) ///
			/*xlabel(0(0.1)1, noticks nolabels axis(2))*/ xtick(0(0.25)1, tlcolor(white) axis(1)) ///
		aspectratio(1, placement(left)) scale(1.35) xsize(1.1) ysize(1.3) ///
			legend(cols(1) position(7) order(2 3) region(lcolor(white)) bmargin(l=-5) /// 
					label(2 "No credit, no attention") ///
					label(3 "Credit treatment, no attention"))
		*graph export "`graphs'/Figure6A.png", replace
	*	graph export "`graphs'/Figure6A.pdf", replace
		graph export "`graphs'/Figure6A.eps", replace

		
		twoway ///
			(lowess savings_2yrpred cumul_pay, bwidth(0.3) sort lpattern("-..") xaxis(1) color(white)) /// 
			(lowess finwtp_`c' cumul_c0a0, bwidth(0.2) sort xaxis(1) lcolor(gs10))  ///
			(lowess finwtp_`c' cumul_a, bwidth(0.2) sort xaxis(1) lcolor(dkorange) lpattern(longdash)),  ///
				`white' ///
			ytitle("`c'" " ") ///
			xtitle("Q", axis(1)) /*xtitle("", axis(2))*/ ///
			ylabel(#5, angle(0) nogrid) ///
			/*xlabel(0(0.1)1, noticks nolabels axis(2))*/ xtick(0(0.25)1, tlcolor(white) axis(1)) ///
		aspectratio(1, placement(left)) scale(1.35) xsize(1.1) ysize(1.3) ///
			legend(cols(1) position(7) order(2 3) region(lcolor(white)) bmargin(l=-5) ///
					label(2 "No credit, no attention") ///
					label(3 "No credit, attention treatment") )
	*	graph export "`graphs'/Figure6B.png", replace
		graph export "`graphs'/Figure6B.eps", replace
	*	graph export "`graphs'/Figure6B.pdf", replace
		
		

		
		*** CONCENTRATION BIAS 
		
		twoway ///
			(lowess finwtp_`c' cumul_c0, bwidth(0.2) sort xaxis(1) lcolor(gs10))  ///
			(lowess finwtp_`c' cumul_c1, bwidth(0.2) sort xaxis(1) lpattern(longdash) lcolor(midblue))  ///
			(lowess finwtp_`c' cumul_c2, bwidth(0.2) sort xaxis(1) lcolor(dkorange)),  ///
				`white' ///
			ytitle("`c'" " ") ///
			xtitle("Q", axis(1)) /*xtitle("", axis(2))*/ ///
			ylabel(#5, angle(0) nogrid) ///
			/*xlabel(0(0.1)1, noticks nolabels axis(2))*/ xtick(0(0.25)1, tlcolor(white) axis(1)) ///
			aspectratio(1, placement(left)) scale(1.5) xsize(2) ysize(1) ///
			legend(cols(1) position(3) order(1 2 3 ) region(lcolor(white)) ///
					label(1 "No Credit") ///
					label(2 "Credit (Weekly)") ///
					label(3 "Credit (Monthly)") )
		*graph export "`graphs'/FigureA17_Demand_WTPS_`c'_CWM.png", replace
		graph export "`graphs'/FigureA17_Demand_WTPS_`c'_CWM.eps", replace
		*graph export "`graphs'/FigureA17_Demand_WTPS_`c'_CWM.pdf", replace

		

	}

	
	
	if `Demand_dRobustness' == 1 {
	
	g 		savings_2yrpred_22 = 	0.924 * ( d_charcoalbuy_`c' * `SAVINGS' ) * 13 * 0.674769057
	g 		savings_2yrpred_50 = 	( d_charcoalbuy_`c' * `SAVINGS' ) * 13 * 0.912046037
	g 		savings_2yrpred_70 = 	( d_charcoalbuy_`c' * `SAVINGS' ) * 13 * 0.953434431
	g 		savings_2yrpred_80 = 	( d_charcoalbuy_`c' * `SAVINGS' ) * 13 * 0.970533211
	g 		savings_2yrpred_90 = 	( d_charcoalbuy_`c' * `SAVINGS' ) * 13 * 0.985945294
	g 		savings_2yrpred_95 = 	( d_charcoalbuy_`c' * `SAVINGS' ) * 13 * 0.993125681
	g 		savings_2yrpred_99 = 	( d_charcoalbuy_`c' * `SAVINGS' ) * 13 * 0.998648246
	g 		savings_2yrpred_1 = 	( d_charcoalbuy_`c' * `SAVINGS' ) * 13 * 1
		
	twoway ///
			(lowess savings_2yrpred_50 cumul_pay, bwidth(0.3) sort xaxis(1) color(black)) /// 
			(lowess savings_2yrpred_1 cumul_pay, bwidth(0.3) sort lpattern(longdash) xaxis(1) color(black)) /// 
			(lowess finwtp_`c' cumul_c0, bwidth(0.2) sort xaxis(1) lwidth(0.7) lcolor(gs12))  ///
			(lowess finwtp_`c' cumul_c, bwidth(0.2) sort xaxis(1) lcolor(orange) lpattern(shortdash))  ///
			(lowess savings_2yrpred_22 cumul_pay, bwidth(0.3) sort xaxis(1) lpattern(dot) lwidth(0.9) color(blue)), /// 
				`white' ///
			graphregion(margin(r+10)) ytitle("`c'", margin(r+5) ) ///
			xtitle("Q", axis(1)) /*xtitle("", axis(2))*/ ///
			ylabel(#5, angle(0) nogrid) ///
			/*xlabel(0(0.1)1, noticks nolabels axis(2))*/ xtick(0(0.25)1, tlcolor(white) axis(1)) ///
			xsize(2.5) ysize(1) scale(1.2) aspectratio(0.85) ///
			legend(cols(1) position(3) margin(r+20) order(3 4 1 2 5) region(lcolor(white)) ///
					label(1 "Breakeven demand curve (d=0.5)" ) ///
					label(2 "Breakeven demand curve (d=1)" ) ///
					label(3 "No Credit") ///
					label(4 "Credit") /// 
					label(5 "Breakeven demand curve (BHJ)" ) )
	*	graph export "`graphs'/FigureA15_Demand_WTPS_`c'_dRobustness.png", replace
		graph export "`graphs'/FigureA15_Demand_WTPS_`c'_dRobustness.eps", replace
	*	graph export "`graphs'/FigureA15_Demand_WTPS_`c'_dRobustness.pdf", replace


		
	}
	
	
	
	if `Demand_Repay' == 1 {
	
		g finwtp_recab`c' = finwtp_`c'*.72
		
		cumul finwtp_recab`c' if treatc_pooled==1, g(cumul_c1rec)
		replace cumul_c1rec = 1 - cumul_c1rec
		
		su finwtp_USD if treatc_pooled==0 & treata_pooled==0
		local mean1 = `r(mean)'
		
		reg finwtp_USD treatc_pooled
		reg finwtp_recab`c' treatc_pooled
		
		di "New treatment effect:"
		di _b[treatc_pooled] / `mean1'
		
		
		*** SLIDES: CREDIT WITH BREAKEVEN INTEREST RATE
		twoway ///
			(lowess savings_2yrpred cumul_pay, bwidth(0.3) sort lpattern("-..") xaxis(1) color(white)) /// 
			(lowess finwtp_`c' cumul_c0a0 if finwtp_`c'<40, bwidth(0.2) sort xaxis(1) lcolor(gs10))  ///
			(lowess finwtp_recab`c' cumul_c1rec if finwtp_`c'<40, bwidth(0.2) sort xaxis(1) lwidth(0.6) lpattern(shortdash) lcolor(red))  ///
			(lowess finwtp_`c' cumul_c if finwtp_`c'<40, bwidth(0.2) sort xaxis(1) lpattern(longdash) lcolor(midblue)),  ///
				`white' ///
			ytitle("`c'" " ") ///
			xtitle("Q", axis(1)) /*xtitle("", axis(2))*/ ///
			ylabel(#5, angle(0) nogrid) ///
			/*xlabel(0(0.1)1, noticks nolabels axis(2))*/ xtick(0(0.25)1, tlcolor(white) axis(1)) ///
			aspectratio(1, placement(left)) scale(1.5) xsize(2.5) ysize(1) ///
			legend(cols(1) position(3) order(1 2 4 3) region(lcolor(white)) /// bmargin(l=-10) 
					label(1 "                       " "             ") ///
					label(2 "No credit") ///
					label(3 "Credit treatment (Deflated by average default rate)") ///
					label(4 "Credit treatment") )
		*graph export "`graphs'/FigureA20C_Demand_WTPS_`c'_C_repay.png", replace
		*graph export "`graphs'/FigureA20C_Demand_WTPS_`c'_C_repay.pdf", replace
		graph export "`graphs'/FigureA20C_Demand_WTPS_`c'_C_repay.eps", replace
		
		
		* Examine with actual repaid rather than broadly applied rate
		merge 1:1 respondent_id using "`raw_confidential'/Payments_Data_Total_replication.dta", gen(_paymerge)
	
		gen finwtp_less_default=finwtp_KSH
		replace finwtp_less_default=TOTALPAID if !missing(TOTALPAID) & TOTALPAID<price_KSH
		replace finwtp_less_default=finwtp_less_default/100
		
		cumul finwtp_less_default if treatc_pooled==1, g(cumul_c1default)
		replace cumul_c1default=1 - cumul_c1default
		
				twoway ///
			(lowess savings_2yrpred cumul_pay, bwidth(0.3) sort lpattern("-..") xaxis(1) color(white)) /// 
			(lowess finwtp_`c' cumul_c0a0 if finwtp_`c'<40, bwidth(0.2) sort xaxis(1) lcolor(gs10))  ///
			(lowess finwtp_less_default cumul_c1default if finwtp_less_default<40, bwidth(0.2) sort xaxis(1) lwidth(0.6) lpattern(shortdash) lcolor(red))  ///
			(lowess finwtp_`c' cumul_c if finwtp_`c'<40, bwidth(0.2) sort xaxis(1) lpattern(longdash) lcolor(midblue)),  ///
				`white' ///
			ytitle("`c'" " ") ///
			xtitle("Q", axis(1)) /*xtitle("", axis(2))*/ ///
			ylabel(#5, angle(0) nogrid) ///
			/*xlabel(0(0.1)1, noticks nolabels axis(2))*/ xtick(0(0.25)1, tlcolor(white) axis(1)) ///
			aspectratio(1, placement(left)) scale(1.5) xsize(2.5) ysize(1) ///
			legend(cols(1) position(3) order(1 2 4 3) region(lcolor(white)) /// bmargin(l=-10) 
					label(1 "                       " "             ") ///
					label(2 "No credit") ///
					label(3 "Credit treatment (Actual payments for defaulters)") ///
					label(4 "Credit treatment") )
		*graph export "`graphs'/FigureA20B_Demand_Default_WTPS_`c'_C_repay.png", replace
		*graph export "`graphs'/FigureA20B_Demand_Default_WTPS_`c'_C_repay.pdf", replace
		graph export "`graphs'/FigureA20B_Demand_Default_WTPS_`c'_C_repay.eps", replace
		
		* Examine after dropping defaulters
	
		gen finwtp_nodefaulters=finwtp_KSH
		replace finwtp_nodefaulters=. if !missing(TOTALPAID) & fracpaid!=1
		assert finwtp_nodefaulters==finwtp_KSH if treatc_pooled==0
		replace finwtp_nodefaulters=finwtp_nodefaulters/100 
		
		cumul finwtp_nodefaulters if treatc_pooled==1, g(cumul_c1nodefaulters)
		replace cumul_c1nodefaulters=1 - cumul_c1nodefaulters
		
				twoway ///
			(lowess savings_2yrpred cumul_pay, bwidth(0.3) sort lpattern("-..") xaxis(1) color(white)) /// 
			(lowess finwtp_`c' cumul_c0a0 if finwtp_`c'<40, bwidth(0.2) sort xaxis(1) lcolor(gs10))  ///
			(lowess finwtp_nodefaulters cumul_c1nodefaulters if finwtp_nodefaulters<40, bwidth(0.2) sort xaxis(1) lwidth(0.6) lpattern(shortdash) lcolor(red))  ///
			(lowess finwtp_`c' cumul_c if finwtp_`c'<40, bwidth(0.2) sort xaxis(1) lpattern(longdash) lcolor(midblue)),  ///
				`white' ///
			ytitle("`c'" " ") ///
			xtitle("Q", axis(1)) /*xtitle("", axis(2))*/ ///
			ylabel(#5, angle(0) nogrid) ///
			/*xlabel(0(0.1)1, noticks nolabels axis(2))*/ xtick(0(0.25)1, tlcolor(white) axis(1)) ///
			aspectratio(1, placement(left)) scale(1.5) xsize(2.5) ysize(1) ///
			legend(cols(1) position(3) order(1 2 4 3) region(lcolor(white)) /// bmargin(l=-10) 
					label(1 "                       " "             ") ///
					label(2 "No credit") ///
					label(3 "Credit treatment (Excluding those who defaulted)") ///
					label(4 "Credit treatment") )
		*graph export "`graphs'/FigureA20D_Demand_NoDefaulters_WTPS_`c'_C_repay.png", replace
		*graph export "`graphs'/FigureA20D_Demand_NoDefaulters_WTPS_`c'_C_repay.pdf", replace
		graph export "`graphs'/FigureA20D_Demand_NoDefaulters_WTPS_`c'_C_repay.eps", replace
		
		*Examine amounts paid by condition
		
		gen TOTALPAID_USD=TOTALPAID/100 if !missing(TOTALPAID)
		replace TOTALPAID_USD=price_USD if treatc_pooled==0 & jikokoa==1
		replace TOTALPAID_USD=0 if jikokoa==0
		
		cumul TOTALPAID_USD if treatc_pooled==1, g(cumul_c1TOTALPAID)
		replace cumul_c1TOTALPAID=1-cumul_c1TOTALPAID
		cumul TOTALPAID_USD if treatc_pooled==0 & treata_pooled==0, g(cumul_c0a0TOTALPAID)
		replace cumul_c0a0TOTALPAID=1-cumul_c0a0TOTALPAID
		
		twoway ///
			(lowess savings_2yrpred cumul_pay, bwidth(0.3) sort lpattern("-..") xaxis(1) color(white)) /// 
			(lowess TOTALPAID_USD cumul_c0a0TOTALPAID , bwidth(0.2) sort xaxis(1) lcolor(gs10))  ///
			(lowess TOTALPAID_USD cumul_c1TOTALPAID, bwidth(0.2) sort xaxis(1) lwidth(0.6) lpattern(shortdash) lcolor(red))  ///
			(lowess finwtp_`c' cumul_c if finwtp_`c'<40, bwidth(0.2) sort xaxis(1) lpattern(longdash) lcolor(white)),  ///
				`white' ///
			ytitle("`c'" " ") ///
			xtitle("Q", axis(1)) /*xtitle("", axis(2))*/ ///
			ylabel(#5, angle(0) nogrid) ///
			/*xlabel(0(0.1)1, noticks nolabels axis(2))*/ xtick(0(0.25)1, tlcolor(white) axis(1)) ///
			aspectratio(1, placement(left)) scale(1.5) xsize(2.5) ysize(1) ///
			legend(cols(1) position(3) order(1 2 3 4) region(lcolor(white)) /// bmargin(l=-10) 
					label(1 "                       " "             ") ///
					label(2 "No credit, amount paid") ///
					label(3 "Credit treatment, amount paid") ///
					label(4 "                       " "             ") )
		*graph export "`graphs'/FigureA20A_Demand_AmountPaid_WTPS_`c'_C_repay.png", replace
		*graph export "`graphs'/FigureA20A_Demand_AmountPaid_WTPS_`c'_C_repay.pdf", replace
		graph export "`graphs'/FigureA20A_Demand_AmountPaid_WTPS_`c'_C_repay.eps", replace
		
	
	
}	
	}
}
	
	
use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear					
		
							****** SMS / VISIT 3 *******
*
****************************************************
*************** SMS DIFF IN DIFF GRAPH *************

if `SMSDiD' == 1 {
	
	use "`dataclean'/SMS_clean_sms_replication.dta", clear
	
	* Import V2 date: 
	preserve
		use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear
		tab Visit2
		

		keep respondent_id jikokoa treata_pooled treatc_pooled price_USD finwtp_USD bdmlo treatc treata ///
			sms_amount_weekly_pre_USD sms_amount_weekly_post_USD `CONTROLS'
		foreach var of varlist `CONTROLS' {
			su `var', detail
			cap replace `var' = `r(mean)' if missing(`var')
		}

		isid respondent_id 
		sort respondent_id
		tempfile V2
		save `V2'
	restore

	merge m:1 respondent_id using `V2'
	keep if _merge ==3 
	replace amount_weekly = amount_weekly/100 // USD
	
	drop if (SMS_date < midline_date) & treata_pooled == 0 // Drop pre-visit2 control data (those are Matatu SMSes)
	
	* Winsorize at 99th percentile:
	assert !missing(amount_weekly)
	su amount_weekly,d
	replace amount_weekly = `r(p99)' if amount_weekly > `r(p99)'
	drop if missing(CsinceV2)
	
	*
	preserve
		statsby mean=r(mean) ub=r(ub) lb=r(lb) n=r(N), by(CsinceV2 jikokoa) clear : ci amount_weekly
	
		// Drop imprecise results:
		tab n
		drop if n < 75
	
		// Offset:
		replace CsinceV2 = CsinceV2-0.2 if jikokoa==1
		replace CsinceV2 = CsinceV2-0.1 if CsinceV2==0 
		
		replace CsinceV2 = CsinceV2 * 3 // Graph works better as daily display 
		
		foreach c in USD {
		
			if "`c'"=="KSH" replace mean = mean*100
			if "`c'"=="KSH" replace ub = ub*100
			if "`c'"=="KSH" replace lb = lb*100
			if "`c'"=="USD" local l=10
			if "`c'"=="KSH" local l=1000
		
		
			* DESCRIPTIVE:
			twoway  (lfit mean CsinceV2 if jikokoa==0 & CsinceV2<=0, lcolor(gs10) connect(l)) ///	
					(lfit mean CsinceV2 if jikokoa==0 & CsinceV2> 1 , lcolor(gs10) connect(l)) ///	
					(lfit mean CsinceV2 if jikokoa==1 & CsinceV2<=0, lcolor(dkorange*0.5) connect(l)) ///	
					(lfit mean CsinceV2 if jikokoa==1 & CsinceV2> 1 , lcolor(dkorange*0.5) connect(l)) ///	
					(rcap ub lb Csince if jikokoa==1, mcolor(dkorange dkorange) lcolor(dkorange dkorange)) ///
					(rcap ub lb Csince if jikokoa==0, mcolor(gs6 gs6) lcolor(gs6 gs6)) ///
					(scatter mean CsinceV2 if jikokoa==1, mcolor(dkorange) msymbol(S) lcolor(dkorange) lpattern(dash) connect(none)) ///	
					(scatter mean CsinceV2 if jikokoa==0, mcolor(gs6) msymbol(T) lcolor(gs6) lpattern(shortdash) connect(none)), ///
					`white' scale(1.5) /// 
					xline(0, lcolor(midblue)) ///
					xsize(2.5) ysize(1.2) ///
					aspectratio(0.7) ///
					yscale(range(0 `l')) /// 
					ylabel(#10, nogrid angle(0)) xlabel(-21(7)64, angle(0)) /// 
					ytitle("Weekly charcoal spending (`c')") ///
					xtitle("Days since main visit", margin(t+5)) ///
					legend(cols(1) pos(3) label(8 "Did not adopt") label(7 "Adopted stove") label(6 "95% CI") order(7 8 6) region(lcolor(white)) )
	
			*graph export "`graphs'/Figure4_DiffInDiffCharcoal_`c'_PAPER.pdf", replace
			graph export "`graphs'/Figure4_DiffInDiffCharcoal_`c'_PAPER.eps", replace
			*graph export "`graphs'/Figure4_DiffInDiffCharcoal_`c'_PAPER.png", replace	width(2500) height(1400)
			
		}
		
	restore	
	*/
	
	*
	preserve
		local c = "USD"
		
		* CAUSAL: 
		local CONTROLS = "d_charcoalbuy_USD savings_USD b_incomeself_USD RiskAverse CreditConstrained b_residents b_children"

		keep `CONTROLS' treata treatc treata_pooled treatc_pooled WsinceV2 TsinceV2 CsinceV2 jikokoa finwtp_USD price_USD amount_weekly respondent_id SMS_date
		
		* Only people who responded to at least 5 SMSes in each round:
		bys respondent_id: g N = _N
		tab N
		keep if (N>=10 & treata_pooled==1) | (N>=5 & treata_pooled==0) 
		tab N
		drop N

		* Only periods with at least 100 respondents:
		tab CsinceV2 
		bys CsinceV2: g N = _N
		* keep if N>100
		tab CsinceV2 
		drop N
		
		keep if CsinceV2 >= -7 & CsinceV2 <= 20
		
		local m = 1
		local relocate  ""
		local labels 	""
		su CsinceV2	
		
		forv k = `r(min)'/`r(max)' {
			g CsinceV2_`m' = (CsinceV2==`k')
			g jikokoa_d`m' = (CsinceV2_`m' * jikokoa)
			g price_d`m'   = (CsinceV2_`m' * price_USD)
			g finwtp_d`m'  = (CsinceV2_`m' * finwtp_USD)
			g treatc_d`m'  = (CsinceV2_`m' * treatc_pooled) 
			lab var jikokoa_d`m' "`m'"
			lab var price_d`m' "`m'"
			local j = `k' * 3
			local J = `k' - 0.02
			local relocate "`relocate' jikokoa_d`m' = `J'"
			if mod(`j',15)==0  local labels `"`labels' `J' "`j'" "'
			local m = `m'+1
		}	

		*** WINSORIZE *** 
		su amount_weekly,d
		drop if amount_weekly>`r(p99)'
		drop if missing(amount_weekly)
		g log_amount_weekly = asinh(amount_weekly)
		
		*** RUN IV ESTIMATION *** 
		eststo clear
		set matsize 5000
		eststo: ivregress 2sls log_amount_weekly (jikokoa_d* = price_d*), cluster(respondent_id)

		*** PLOT COEFFICIENTS *** 
			coefplot, ///
				keep(jikokoa_d*) relocate(`relocate') drop(_cons) /// 
				connect(l) mcolor(gs6) /*msymbol(T)*/ lcolor(gs6) ///
				ciopts(recast(rarea) color(gs14))   ///
				addplot( 	(scatteri -1 0.2 1 0.2, connect(l) msymbol(i) lcolor(midblue)            ) /// 
							(scatteri 0 -7 0 20		, connect(l) msymbol(i) lcolor(gs6) lwidth(thin) ) ) /// 
				/*xline(0.2, lcolor(midblue)) yline(0, lcolor(gs14))*/ ///
				xlabel(`labels') vertical omitted /// 
				plotregion(color(white)) graphregion(color(white)) graphregion(style(none)) bgcolor(white) ///
				scale(1.3) aspectratio(0.7) legend(off) ///
				xtitle("Days since main visit") ytitle("IV Coefficient on weekly" "charcoal spending (Log)") ///
				ylabel(-1(0.25)1, nogrid angle(horizontal)) ///
				xlabel(, nogrid) ///
				title("")
	*	graph export "`graphs'/FigureA10_DiffInDiffCharcoalIV_`c'_PAPER.pdf", replace
		graph export "`graphs'/FigureA10_DiffInDiffCharcoalIV_`c'_PAPER.eps", replace
	*	graph export "`graphs'/FigureA10_DiffInDiffCharcoalIV_`c'_PAPER.png", replace	
			
	restore
	
*/
	
	
}
		
**************************************************
*************** SMS ATTRITION GRAPHS *************

if `SMSattrition' == 1 {
	
	* Create dataset of whether we received an SMS during a cycle from a respondent:
	use "`dataclean'/SMS_clean_sms_replication.dta", clear
	keep respondent_id CsinceV2 SMS_date 
	duplicates drop 
	duplicates drop respondent_id CsinceV2, force // Some people responded on 2 days within 1 cycle. Drop 1. 
	isid respondent_id CsinceV2
	g received_sms = 1
		
	tempfile smses
	save `smses'
	
	use "`dataclean'/SMS_clean_sms_replication.dta", clear
	keep respondent_id 
	duplicates drop
	expand 44
	bys respondent_id: g CsinceV2 = _n - 21
	
	merge 1:1 respondent_id CsinceV2 using `smses'
	assert _merge != 2
	drop _merge 

	* Import treatment variables from main data:
	merge m:1 respondent_id using "`dataclean'/Visit123_analysis_replication_noPII.dta", ///
		keepusing(jikokoa bdmlo treata_pooled treatc_pooled baseline_date midline_date)
	keep if _merge ==3 
	drop _merge 
	
	replace received_sms = 0 if missing(received_sms)

	* Label SMS_date relative to the midline date:
	forv i = 1/38 {
		replace SMS_date = (SMS_date[_n+1])-3 if ///
			missing(SMS_date) & !missing(SMS_date[_n+1]) & ///
			respondent_id==respondent_id[_n+1]
	}
	forv i = 1/22 {
		replace SMS_date = (SMS_date[_n-1])+3 if ///
			missing(SMS_date) & !missing(SMS_date[_n-1]) & ///
			respondent_id==respondent_id[_n-1]
	}
	
	// If this assertion is false, increase the "38" and "22" above (it's just cycling through):
	assert !missing(SMS_date) 
		
	* Drop pre-baseline SMS dates for EVERYONE:
	drop if (SMS_date < baseline_date)
	
	* Drop pre-midline SMS dates for ATTENTION CONTROL only (matatu SMSes):
	drop if ((SMS_date < midline_date) | (SMS_date < baseline_date+30)) //		& treata_pooled==0
	
	* Drop all dates beyond latest day of SMS data (from Elijah): 
	drop if SMS_date > mdy(07,31,2019)-2
	
	* Now, calculate fraction of received_sms, by SMS cycle and treatment group: 
	replace CsinceV2  = CsinceV2 *3
	
	* Only large enough sample size: 
	bys CsinceV2: g N = _N
	keep if N > 250
	drop N
	
	
	preserve
		collapse (mean) received_sms, by(CsinceV2 bdmlo)
	
		twoway 	(scatter received_sms CsinceV2 if bdmlo==0, msymbol(D) mcolor(gs8)) /// 
				(scatter received_sms CsinceV2 if bdmlo==1, mcolor(green)), ///
				xtitle("Days since Visit 2") ytitle("Fraction SMSes responded", margin(r+5)) /// 
				legend( col(1) position(7) margin(r+20) region(lstyle(color(white))) ///
					label(1 "High BDM price (> USD 15)") label(2 "Low BDM price (< USD 15)")) /// 
				xsize(1) ysize(1) /// 
				`white' graphregion(margin(t=10)) ylabel(0(0.25)1, nogrid) scale(1.6)
	*	graph export "`graphs'/FigureA18A_SMS_Attrition_BDMlo.pdf", replace
		graph export "`graphs'/FigureA18A_SMS_Attrition_BDMlo.eps", replace
		*graph export "`graphs'/FigureA18A_SMS_Attrition_BDMlo.png", replace	
		*graph export "`graphs'/FigureA18A_SMS_Attrition_BDMlo.pdf", replace	

	restore

	preserve
		collapse (mean) received_sms, by(CsinceV2 jikokoa)
	
		twoway 	(scatter received_sms CsinceV2 if jikokoa==0, msymbol(D) mcolor(gs8)) /// 
				(scatter received_sms CsinceV2 if jikokoa==1, mcolor(dkorange)), ///
				xtitle("Days since Visit 2") ytitle("Fraction SMSes responded", margin(r+5)) /// 
				legend( col(1) margin(r+20) region(lstyle(color(white))) ///
					label(1 "Did not adopt") label(2 "Adopted Jikokoa")) /// 
				xsize(1) ysize(1) /// 
				`white' graphregion(margin(t=10)) ylabel(0(0.25)1, nogrid) scale(1.6)
	*	graph export "`graphs'/FigureA18B_SMS_Attrition_Jikokoa.pdf", replace
		graph export "`graphs'/FigureA18B_SMS_Attrition_Jikokoa.eps", replace
		*graph export "`graphs'/FigureA18B_SMS_Attrition_Jikokoa.png", replace	
	restore
	
	preserve
		collapse (mean) received_sms, by(CsinceV2 treata_pooled)
	
		twoway 	(scatter received_sms CsinceV2 if treata_pooled==0, msymbol(D) mcolor(gs8)) /// 
				(scatter received_sms CsinceV2 if treata_pooled==1, mcolor(blue)), ///
				xtitle("Days since Visit 2") ytitle("Fraction SMSes responded", margin(r+5)) /// 
				legend( col(1) margin(r+20) region(lstyle(color(white))) ///
					label(1 "Attention control") label(2 "Attention treatment")) /// 
				xsize(1) ysize(1) /// 
				`white' graphregion(margin(t=10)) ylabel(0(0.25)1, nogrid) scale(1.6)
		*graph export "`graphs'/FigureA18C_SMS_Attrition_Attention.pdf", replace
		graph export "`graphs'/FigureA18C_SMS_Attrition_Attention.eps", replace
	*	graph export "`graphs'/FigureA18C_SMS_Attrition_Attention.png", replace	
	restore
	
	preserve
		collapse (mean) received_sms, by(CsinceV2 treatc_pooled)
	
		twoway 	(scatter received_sms CsinceV2 if treatc_pooled==0, msymbol(D) mcolor(gs8)) /// 
				(scatter received_sms CsinceV2 if treatc_pooled==1, mcolor(red)), ///
				xtitle("Days since Visit 2") ytitle("Fraction SMSes responded", margin(r+5)) /// 
				legend( col(1) margin(r+20) region(lstyle(color(white))) ///
					label(1 "Credit control") label(2 "Credit treatment")) /// 
				xsize(1) ysize(1) /// 
				`white' graphregion(margin(t=10)) ylabel(0(0.25)1, nogrid) scale(1.6)
	*	graph export "`graphs'/FigureA18D_SMS_Attrition_Credit.pdf", replace
		graph export "`graphs'/FigureA18D_SMS_Attrition_Credit.eps", replace
	*	graph export "`graphs'/FigureA18D_SMS_Attrition_Credit.png", replace	
	restore
	
	
	* Histogram of N of SMSes by respondent:
	preserve
	use "`dataclean'/SMS_clean_sms_replication.dta", clear
	keep if TsinceV2>=0 & CsinceV2<=16
	keep respondent_id CsinceV2
	duplicates drop // Only count Max 1 sms per SMS cycle
	
	keep respondent_id
	
	bys respondent_id: g obs = _N
	duplicates drop
	
	merge 1:1 respondent_id using "`dataclean'/Visit123_analysis_replication_noPII.dta", keepusing(respondent_id Visit2)


	keep if Visit2==1
	
	replace obs = 0 if missing(obs) & _merge == 2
	tab obs, mi
	
	twoway  (hist obs, freq start(-0.5) width(1) lcolor(gs10) fcolor(gs13)), /// 
			`white' scale(1.5) /// 
			xsize(1.7) ysize(1) ///
			ylabel(0(50)150, nogrid angle(0)) xlabel(0(5)20, angle(0)) /// 
			ytitle("Number of respondents") ///
			xtitle("Number of SMSes replied to (out of 16)") ///
			legend(off)
		
*	graph export "`graphs'/FigureA21_SMSesbyResp.png", replace
*	graph export "`graphs'/FigureA21_SMSesbyResp.pdf", replace
	graph export "`graphs'/FigureA21_SMSesbyResp.eps", replace
	
restore 
}

	
**********************************************************
*************** SAVINGS HETEROGENEITY BY WTP *************

if `SavingsheteroByWTP' == 1 {

		include "${main}/Do/0. Master.do"

	**** SPENDING ON X AXIS, WTP ON Y AXIS
	use "`dataclean'/Visit123_E1_analysis_replication.dta", clear
	
	preserve
		keep d_charcoalbuy_USD
		replace d_charcoalbuy_USD = 12 if d_charcoalbuy_USD>12 & !missing(d_charcoalbuy_USD)
	
		g n = _n + 100 
		g treatc_pooled = 1
		tempfile histogram
		save `histogram' 
	restore
	
	su d_charcoalbuy_USD,d
	replace d_charcoalbuy_USD = `r(p99)' if d_charcoalbuy_USD>`r(p99)'
		
	sort treatc_pooled d_charcoalbuy_USD
	by treatc_pooled: g n = floor(_n/50)
	bys treatc_pooled: g N = _N
	tab N
	drop if N<10
	drop N 
	bys n treatc_pooled: egen ave_charcoalbuy = mean(d_charcoalbuy_USD)
	sort treatc_pooled d_charcoalbuy_USD 
	*br treatc_pooled d_charcoalbuy_USD n ave_charcoalbuy finwtp_USD
			
	statsby mean=r(mean) ub=r(ub) lb=r(lb), by(n treatc_pooled ave_charcoalbuy) clear : ci el1_g_char_week_USD
	
	merge 1:1 n treatc_pooled using `histogram' 
	
	replace ave_charcoalbuy  = 12 if ave_charcoalbuy >12 & !missing(ave_charcoalbuy)
	twoway  (lfit mean ave_charcoalbuy if treatc_pooled==0 , lcolor(gs10) connect(l)) ///	
			(lfit mean ave_charcoalbuy if treatc_pooled==1 , lcolor(dkorange*0.5) connect(l)) ///	
			(rcap ub lb ave_charcoalbuy if treatc_pooled==1, mcolor(dkorange dkorange) lcolor(dkorange dkorange)) ///
			(rcap ub lb ave_charcoalbuy if treatc_pooled==0, mcolor(gs6 gs6) lcolor(gs6 gs6)) ///
			(scatter mean ave_charcoalbuy if treatc_pooled==1, mcolor(dkorange) msymbol(S) lcolor(dkorange) lpattern(dash) connect(none)) ///	
			(scatter mean ave_charcoalbuy if treatc_pooled==0, mcolor(gs6) msymbol(T) lcolor(gs6) lpattern(shortdash) connect(none)) ///
			(hist d_charcoalbuy_USD, freq start(2.5) width(1) lcolor(gs10) fcolor(gs13) yaxis(2)), /// 
			`white' scale(1.5) /// 
			xsize(1.8) ysize(1.6) ///
			yscale(range(0 10)) xscale(range(3 12)) /// 
			ylabel(0(3)10, nogrid angle(0)) xlabel(3(3)12, angle(0)) /// 
			ylabel(0(10)2500, noticks nolabels nogrid axis(2)) yscale(lstyle(none) axis(2)) ytitle("", axis(2)) ///
			ytitle("Endline charcoal spending" "(USD per Week)",size(small)) ///
			xtitle("Baseline Charcoal Spending" "(USD per Week)", size(small)) ///
			legend(cols(1) pos(6) label(6 "Did not adopt") label(5 "Adopted stove") label(4 "95% CI") order(6 5 4) region(lcolor(white)) )
		
*	graph export "`graphs'/FigureA16C_Spending_BaseEnd.png", replace
	graph export "`graphs'/FigureA16C_Spending_BaseEnd.eps", replace
*	graph export "`graphs'/FigureA16C_Spending_BaseEnd.pdf", replace

	
	**** SPENDING ON X AXIS, WTP ON Y AXIS
	use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear
	
	su d_charcoalbuy_USD,d
	replace d_charcoalbuy_USD = `r(p99)' if d_charcoalbuy_USD>`r(p99)'
	
	sort treatc_pooled d_charcoalbuy_USD
	by treatc_pooled: g n = floor(_n/50)
	bys treatc_pooled: g N = _N
	tab N
	drop if N<10
	drop N 
	bys n treatc_pooled: egen ave_charcoalbuy = mean(d_charcoalbuy_USD)
	sort treatc_pooled d_charcoalbuy_USD 
	br treatc_pooled d_charcoalbuy_USD n ave_charcoalbuy finwtp_USD
			
	statsby mean=r(mean) ub=r(ub) lb=r(lb), by(n treatc_pooled ave_charcoalbuy) clear : ci finwtp_USD
	
	merge 1:1 n treatc_pooled using `histogram' 
	
	replace ave_charcoalbuy  = 12 if ave_charcoalbuy >12 & !missing(ave_charcoalbuy)
	twoway  (lfit mean ave_charcoalbuy if treatc_pooled==0 , lcolor(gs10) connect(l)) ///	
			(lfit mean ave_charcoalbuy if treatc_pooled==1 , lcolor(dkorange*0.5) connect(l)) ///	
			(rcap ub lb ave_charcoalbuy if treatc_pooled==1, mcolor(dkorange dkorange) lcolor(dkorange dkorange)) ///
			(rcap ub lb ave_charcoalbuy if treatc_pooled==0, mcolor(gs6 gs6) lcolor(gs6 gs6)) ///
			(scatter mean ave_charcoalbuy if treatc_pooled==1, mcolor(dkorange) msymbol(S) lcolor(dkorange) lpattern(dash) connect(none)) ///	
			(scatter mean ave_charcoalbuy if treatc_pooled==0, mcolor(gs6) msymbol(T) lcolor(gs6) lpattern(shortdash) connect(none)) ///
			(hist d_charcoalbuy_USD, freq start(2.5) width(1) lcolor(gs10) fcolor(gs13) yaxis(2)), /// 
			`white' scale(1.5) /// 
			xsize(1.8) ysize(1.6) ///
			yscale(range(0 10)) xscale(range(3 12)) /// 
			ylabel(#10, nogrid angle(0)) xlabel(3(3)12, angle(0)) /// 
			ylabel(0(10)2500, noticks nolabels nogrid axis(2)) yscale(lstyle(none) axis(2)) ytitle("", axis(2)) ///
			ytitle("WTP (USD)", size(small)) ///
			xtitle("Baseline Charcoal Spending" "(USD per Week)", size(small)) ///
			legend(cols(1) pos(6) label(6 "Did not adopt") label(5 "Adopted stove") label(4 "95% CI") order(6 5 4) region(lcolor(white)) )
		
	*graph export "`graphs'/FigureA16A_WTPbySpending_USD.png", replace
	graph export "`graphs'/FigureA16A_WTPbySpending_USD.eps", replace
	*graph export "`graphs'/FigureA16A_WTPbySpending_USD.pdf", replace
	

	
	*** WTP on X AXIS, SPENDING ON Y AXIS 
	use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear
	
	preserve
		keep finwtp_USD
		g n = _n + 100 
		g jikokoa = 1
		tempfile histogram
		save `histogram' 
	restore
	
	drop if missing(sms_amount_weekly_post_USD)
	su sms_amount_weekly_post_USD,d
	replace sms_amount_weekly_post_USD = `r(p99)' if sms_amount_weekly_post_USD>`r(p99)'
	
	sort jikokoa finwtp_USD
	by jikokoa: g n = floor(_n/50)
	bys jikokoa n: g N = _N
	tab N
	drop if N<10
	drop N 
	bys n jikokoa: egen ave_finwtp_USD = mean(finwtp_USD)
	sort jikokoa finwtp_USD
	br jikokoa finwtp_USD n ave_finwtp_USD sms_amount_weekly_post_USD
		
	statsby mean=r(mean) ub=r(ub) lb=r(lb), by(n jikokoa ave_finwtp_USD) clear : ci sms_amount_weekly_post_USD 
	
	merge 1:1 n jikokoa using `histogram' 
	
	twoway  (lfit mean ave_finwtp_USD if jikokoa==0 , lcolor(gs10) connect(l)) ///	
			(lfit mean ave_finwtp_USD if jikokoa==1 , lcolor(dkorange*0.5) connect(l)) ///	
			(rcap ub lb ave_finwtp_USD if jikokoa==1, mcolor(dkorange dkorange) lcolor(dkorange dkorange)) ///
			(rcap ub lb ave_finwtp_USD if jikokoa==0, mcolor(gs6 gs6) lcolor(gs6 gs6)) ///
			(scatter mean ave_finwtp_USD if jikokoa==1, mcolor(dkorange) msymbol(S) lcolor(dkorange) lpattern(dash) connect(none)) ///	
			(scatter mean ave_finwtp_USD if jikokoa==0, mcolor(gs6) msymbol(T) lcolor(gs6) lpattern(shortdash) connect(none)) ///
			(hist finwtp_USD, freq start(0) width(2.5) lcolor(gs10) fcolor(gs13) yaxis(2)), /// 
			`white' scale(1.4) /// 
			xsize(1.8) ysize(1.6) ///
			yscale(range(0 10)) /// 
			ylabel(#10, nogrid angle(0)) xlabel(0(10)50, angle(0)) /// 
			ylabel(0(10)700, noticks nolabels nogrid axis(2)) yscale(lstyle(none) axis(2)) ytitle("", axis(2)) ///
			ytitle("Endline charcoal spending" "(USD per Week)") ///
			xtitle("WTP (USD)") ///
			legend(cols(1) pos(6) label(6 "Did not adopt") label(5 "Adopted stove") label(4 "95% CI") order(6 5 4) region(lcolor(white)) )
		
	*graph export "`graphs'/FigureA16B_TbyWTP_USD.png", replace
	graph export "`graphs'/FigureA16B_TbyWTP_USD.eps", replace
	*graph export "`graphs'/FigureA16B_TbyWTP_USD.pdf", replace
	
	
	
	
}


**********************************************************
****************** WTP Movement **************************

if `WTPmovement' == 1 {
	use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear
	
	keep if g_jikokoa!=0
	
	g interaction = finwtp_USD * jikokoa
	reg g_c2_wtp_USD finwtp_USD jikokoa interaction
	
	*** WTP VARIABLES
	twoway 	(function y=x, range(0 50) lcolor(blue)) ///
			(scatter g_c2_wtp_USD finwtp_USD if jikokoa==0, msymbol(smcircle) mcolor(gs10) msize(small)) /// 
			(scatter g_c2_wtp_USD finwtp_USD if g_jikokoa==1, msymbol(Th) mcolor(dkorange) msize(small)) /// 
			(lfit	 g_c2_wtp_USD finwtp_USD if jikokoa==0, lcolor(gs10) lwidth(medthick)) /// 
			(lfit	  g_c2_wtp_USD finwtp_USD if g_jikokoa==1, lcolor(dkorange) lwidth(medthick)), /// 
			scale(1.5) `white' ///
			legend(	rows(2) cols(1) position(6) region(lcolor(white)) order(2 3) /// 
					label(2 "Did not buy stove") label(3 "Bought stove")) /// 
			ylabel(, nogrid angle(0)) ///
			ytitle("Revised WTP (USD)") xtitle("Original BDM WTP (USD)") 

*	graph export "`graphs'/FigureA6_wtp_movement.png", replace
	graph export "`graphs'/FigureA6_wtp_movement.eps", replace
	*graph export "`graphs'/FigureA6_wtp_movement.pdf", replace
		
}


if `usagespending' == 1{
	

	
	use "`dataclean'/Visit123_analysis_replication_noPII.dta", clear
	su d1_use_minutes_daily , d
	replace d1_use_minutes_daily = `r(p95)' if d1_use_minutes_daily>`r(p95)' & !missing(d1_use_minutes_daily)
 
	twoway 	(kdensity d1_use_minutes_daily if bdmlo==0 & treatc_pooled==0, color(gs10)) /// 
			(kdensity d1_use_minutes_daily if bdmlo==1 & treatc_pooled==1, color(orange)), /// 
		legend(	region(lcolor(white)) position(7) rows(2) order(1 2) bmargin(l=-5) /// 
			label(1 "Control" "(8% adoption)") label(2 "Subsidy and credit treatment" "(93% adoption)")) /// 
		aspectratio(0.5) scale(1.5) ysize(1.3) xsize(1.9) `white' ///
		ylabel(none, nogrid) yscale(lcolor(white)) ///
		xlabel(0(60)360) ///
		xtitle(" " "Daily time cooking (minutes)") ytitle("") 

*	graph export "`graphs'/FigureA11_reboundeffect.png", replace
	graph export "`graphs'/FigureA11_reboundeffect.eps", replace
	*graph export "`graphs'/FigureA11_reboundeffect.pdf", replace
	
}



**********************************************************
*********  figures that use repayment data ***************

 
* FigureA19: PANEL A - PAYMENT FRACTION HISTOGRAM

		use "`raw_confidential'/Payments_Data_Total_replication.dta", clear					
		
		reg frac price
		* y=(1+x)*(0.9261676-(0.34325*(1+x)))*2500
		
		* Histogram of fraction paid at the end
		cou if !missing(fracpaid)
		twoway 	(histogram fracpaid, width(0.05) start(0) frac color(gs8)      ), ///
				legend(off) ///
				scale(1.4) scheme(s1color) /// 
				xlabel(0(0.1)1) ylabel(0(0.1)0.6, angle(0) ) ///
				ytitle("Fraction of respondents") ///
				xtitle("Fraction paid at end") /// 
				title("") 		`white' 
		*graph export "`graphs'/FigureA7A_Payment_Fraction_Histogram_last.png", replace
		graph export "`graphs'/FigureA7A_Payment_Fraction_Histogram_last.eps", replace	
	*	graph export "`graphs'/FigureA7A_Payment_Fraction_Histogram_last.pdf", replace	

		
* FIGURE A17: PANEL BDM

include "${main}/Do/0. Master.do"
		use "`raw_confidential'/Payments_Data_Panel_replication.dta", clear

		* Check to see if panel is identified by respondnet id and days of payment
		isid respondent_id T

		* Collapse the data to a panel of payments by day and credit treatment
		collapse (mean) ONTRACKind ONTRACKfr, by(T treatc)

		* T to WEEKS for graphs:
		g D = mod(T, 7)
		replace T = T/7
		lab var T "Weeks since V2"

		* Look at the first 12 weeks only
		keep if T <= 12

		* Average fraction of required payment over time 
		twoway 	(line ONTRACKfr T if treatc==1 & T>=1, color(gs8)      ) ///
				(line ONTRACKfr T if treatc==2 & T>=4, color(dkorange) lpattern(dash)), ///
				legend( pos(6) col(1) region(lcolor(white)) ///
					label(1 "Weekly Deadlines") label(2 "Monthly Deadlines") ) ///
				scale(1.3) /// xline(12, lcolor(midblue)) 
				scheme(s1color) /// 
				xlabel(0(1)12) ylabel(0(0.2)1, angle(0) ) ///
				ytitle("Average fraction of required paid") ///
				xtitle("Weeks since Midline Visit", margin(t+3)) /// 
				title("") 		`white' 
		*graph export "`graphs'/FigureA7B_Payment_Ontrack_Timeline_Daily_fr.png", replace
		*graph export "`graphs'/FigureA7B_Payment_Ontrack_Timeline_Daily_fr.pdf", replace	
		graph export "`graphs'/FigureA7B_Payment_Ontrack_Timeline_Daily_fr.eps", replace	

	