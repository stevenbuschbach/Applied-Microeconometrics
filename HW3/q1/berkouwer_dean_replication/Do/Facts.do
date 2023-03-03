
include "${main}/Do/0. Master.do"
use "`dataclean'/Visit123_E1_analysis_replication.dta", clear

global savings_USD = 2.28 /* Result from Tables.do; Table 2 Col (3) */
global fraction_log = -0.50 /* Result from Tables.do; Table 2 Col (4) */
global savings = 1-exp($fraction_log)
global discount_rate 0.900752897
global jikokoa_cost = 40

/* ABSTRACT & INTRODUCTION */

* 39% reduction in charcoal spending
di $savings

* 295% annual return
* See Section 4.1

* Abstract: $237 over the stove's two-year lifespan 
* Introduction: This yields private savings of USD 237 [...] (over two years, or 52 * 2 = 104 weeks).
di $savings_USD*52*2 
di $savings_USD*52

/* 3.5 tons of carbon dioxide-equivalent, valued at USD 147 when applying 42 */
/* Two years: $295 in emissions reductions */
/* CO2 at USD 6 per ton */
* See Section 4.2

/* Each USD 1 of subsidy would generate USD 19 in total welfare gains. */

/* willing to pay $12 */
/* The loan doubles WTP, from USD 12 to USD 25. */
* Table 5, Column (1)

/* This reminder reduces the effect of credit by USD 3 */
* Table 5, Column (2) 

/* Introduction & Section 1: "The share in low-income countries is often even higher:  the 
energy burden for the median household in our study sample is 22 percent of 
household income." */

	quietly su d_TOTALbuy_USD, d
	local energy_spending = `r(p50)'
	quietly su  hhincome_week_USD, d 
	local household_budget = `r(p50)'
	local energy_share =  `energy_spending'/ `household_budget'
	display `energy_share'

/* MAIN PAPER */

	
/* Section 2.1: More than 98 percent of respondents had heard of the stove, 
primarily via television (64 percent), via a friend, neighbor, or family member 
(39 percent), on the radio (21 percent), or in a billboard, newspaper, or bus
 advertisement (11 percent). */
*preserve
	gen max = wordcount(d_awareness)
	summarize max
	local max_d_awareness = `r(max)'

	gen match_0 = 0 /*Never heard*/
	gen match_3 = 0
	gen match_4 = 0
	gen match_5 = 0
	gen match_6 = 0
	gen match_7 = 0
	gen match_8 = 0
	gen match_20 = 0
	gen match_21 = 0


	forval j = 1/`max_d_awareness' { 
		 replace match_0 = 1 if real(word(d_awareness, `j')) == 0
		 replace match_3 = 1 if real(word(d_awareness, `j')) == 3
		 replace match_4 = 1 if real(word(d_awareness, `j')) == 4
		 replace match_5 = 1 if real(word(d_awareness, `j')) == 5
		 replace match_6 = 1 if real(word(d_awareness, `j')) == 6
		 replace match_7 = 1 if real(word(d_awareness, `j')) == 7
		 replace match_8 = 1 if real(word(d_awareness, `j')) == 8
		 replace match_20 = 1 if real(word(d_awareness, `j')) == 20
		 replace match_21 = 1 if real(word(d_awareness, `j')) == 21
	}


	/*Share who heard about the stove */
	count if match_0 == 1
	display 1- `r(N)'/1011

	/*Share who heard about it via TV*/
	count if match_3 == 1
	display `r(N)'/1011

	/*Share who heard about it via radio*/
	count if match_4 == 1
	display `r(N)'/1011

	/*Share who heard about it via a friend, neighbor, or family member*/
	count if match_6 == 1 | match_7 == 1 | match_8 == 1
	display `r(N)'/1011
	*restore

	/*Share who heard about it via a billboard, newspaper, or bus advertisement*/
	count if match_5 == 1 | match_20 == 1 | match_21 == 1
	display `r(N)'/1011

	/* Section 4.2: "Only 10 people had not heard of the Jikokoa stove at baseline [...]" */

	count if match_0 == 1 & Visit3 == 1


/* Section 2.1: When asked an open-ended question about the Jikokoa's best
 features, 87 percent of respondents state financial savings, while only 52
 percent state reduced smoke and 22 percent state time savings. Figure A2 
 shows that the savings are almost twice as salient to respondents as the
 next best attributes. */



	/* MAIN PAPER */
	gen best_max = wordcount(d_bestthings)
	summarize best_max
	local max_d_bestthings = `r(max)'


	gen best_match_1 = 0
	gen best_match_2 = 0
	gen best_match_3 = 0
	gen best_match_4 = 0
	gen best_match_5 = 0
	gen best_match_6 = 0
	gen best_match_7 = 0
	gen best_match_8 = 0
	gen best_match_9 = 0
	gen best_match_10 = 0
	gen best_match_97 = 0
	gen best_match_99 = 0

	forval j = 1/`max_d_bestthings' { 
		 replace best_match_1 = 1 if real(word(d_bestthings, `j')) == 1
		 replace best_match_2 = 1 if real(word(d_bestthings, `j')) == 2
		 replace best_match_3 = 1 if real(word(d_bestthings, `j')) == 3
		 replace best_match_4 = 1 if real(word(d_bestthings, `j')) == 4
		 replace best_match_5 = 1 if real(word(d_bestthings, `j')) == 5
		 replace best_match_6 = 1 if real(word(d_bestthings, `j')) == 6
		 replace best_match_7 = 1 if real(word(d_bestthings, `j')) == 7
		 replace best_match_97 = 1 if real(word(d_bestthings, `j')) == 97
		 replace best_match_99 = 1 if real(word(d_bestthings, `j')) == 99
	}

	/* Percentage who stated financial savings */
	mean best_match_1
	/* Percentage who stated less smoke */
	mean  best_match_5
	/* Percentage who stated time savings */
	mean  best_match_7 

	/*Section 2.1: "All but three of the 1,018 subjects believe the food will taste
	 the same or better." */
	count if (d_taste == 1|d_taste == 2) 

/*Section 2.1: The median respondent in our sample (correctly) believes that
(i) the Jikokoa has an expected lifespan of three years and
 (ii) typically needs to buy a new traditional jiko each year." */

/*(i) Expected lifespan of Jikokoa */
	quietly su d_jikokoalast_years, detail
	di `r(p50)'

/* (ii) How often they typically need to buy a new traditional jiko, in years
 (Question is: "In an average year, how many jiko's do you usually buy?") */
	quietly su c_newcookstovebuy, detail
	di `r(p50)'


/*Section 1.2: Loans are common in this context (86 percent of respondents
 borrowed at least once last year [...] " */
	cou if g1d!="96" | g1b!="96"
	di `r(N)'/1011

/* Section 2.2: More than one-third of respondents had sought out a loan in the
 past year and been refused [...]" */
	cou if g1e != "96" // Refused by someone
	di `r(N)'/1011

/* Section 2.2: [...] and more than 50 percent of respondents said they would 
borrow more if the cost of borrowing was lower. */
	cou if g1f==2
	di `r(N)'/1011 

/*Section 2.2: People who had not taken a loan in the past year did not do so
 largely because they were worried about their ability to pay back the loan [...] */
	mean g2g_2

/* Section 2.2: The median amount available for short-term borrowing was less
 than USD 20; less than a quarter of the sample was able to borrow the full cost
 of the stove  if they wanted to. */
/*Note: the full cost of the stove was 40USD*/
/*Set FX KES/USD */
	local FX = 100
	gen g1g1_USD = g1g1/`FX' 
	summarize g1g1_US, d 
/*Note: there are only 642 non-missing obs. for g1g1_USD because those
 observations for which g1g1 == -999 (which meant 'I don't know' in the
 context of the survey) were replaced by missing values in the AnalysisData script */


/* Section 2.2: "To qualify for study participation, respondents had to use a 
traditional charcoal jiko as their primary cooking technology and spend at least
 USD 3 per week on charcoal, although this is not usually binding: most 
 households that use a charcoal stove as their primary cooking technology
usually buy at least USD 0.50 per day, or USD 3.50 per week, worth of charcoal" */
/*First, import data for all participants */
	clear all
	local dates = "0417 0418 0423 0424 0425 0426 0429 0430 0502 0503 0506 0507 0508 0509 0510 0513 0514"
	foreach date in `dates'   ///
	 {
	preserve
		insheet using "`raw'/Visit 1/StovesVisit1_2019`date'.csv", clear
		foreach var of varlist ///
			b_occupationself b_occupationothers ///
			g1b g1e /* bz1  bz6 bz7 */ g2g ///
			c_charcoalseller  c_charcoalseller_other ///
			cz2 d_tastetext ///
			*comment* ///
			 {
			tostring `var', replace
		}
		/* cap tostring b_income_none, replace */
		tempfile import
		save `import'
	restore
	append using `import', force
	}

// Only consented respondents
	keep if a_consent==1

// One person withdrew consent: 
	drop if key == "uuid:c60168d3-b0c0-4863-b0c5-737058eeea19" // ID: 842b837, phone: 742270908

/*Finally, compute share of participants who spent less than USD 3  in charcoal
 per week */
	gen d_charcoalbuy_USD = d_charcoalbuy/`FX' 
	count if  d_charcoalbuy_USD < 3 
	local not_eligible = `r(N)'
	count
	local share_not_eligible = `not_eligible'/`r(N)'
	di `share_not_eligible' /* 0.7% of the sample spent less than USD 3 */

	include "${main}/Do/0. Master.do"
	use "`dataclean'/Visit123_E1_analysis_replication.dta", clear

/*Section 4.1 (footnote):  "88 percent of visit 2 surveys were conducted between
 23-33 days of that respondent's visit 1, and 90 percent of visit 3 surveys were
 conducted between 23-33 days of that respondent's visit 2. 90 percent of
 long-term endline surveys were conducted between 12.2 and 13.1 months
of visit 2." */
	/*Time between visit 1 and visit 2 */
	tab timeV12  /*Created in AnalysisData */
	count if timeV12 >= 23 & timeV12 <= 33
	local timeV12_22_33 = `r(N)'
	count if Visit2 == 1 
	display `timeV12_22_33'/`r(N)'

	/*Time between visit 2 and visit 3 */
	tab timeV23 /*Created in AnalysisData */
	count if timeV12 >= 23 & timeV12 <= 33
	local timeV23_22_33 = `r(N)'
	count if Visit3 == 1 
	display `timeV23_22_33'/`r(N)'

	/*Time between visit 2 and long-term endline survey */
	cap drop timeV24 
	cap gen timeV24 = (endline1_date - midline_date)/(365/12)
	count if timeV24 >= 12.2 & timeV24 <= 13.1
	local timeV24_12_13 =  `r(N)'
	count if Endline1 == 1 
	display `timeV24_12_13'/`r(N)'

use "`dataclean'/Visit123_E1_analysis_replication.dta", clear

/* Section 3: "60 percent of participants purchase charcoal at least once a day." */
	count if c_charcoalfreq == 1 |  c_charcoalfreq == 2
	display `r(N)'/1011


/* Section 3: "Households buy a new jiko around once per year, for between USD 2–5." */
*Jiko buy frequency
	quietly su c_newcookstovebuy, detail
	di `r(p50)'

*Jiko price range
	su c_cookstoveprice_USD, detail /*90% paid more than 2 and less than 5 */

/* Section 3: "Within each household, field officers enrolled the primary stove
user, 95 percent of whom were women, largely reflecting Kenyan societal norms
 around household tasks" */
	count if b_male == 0
	display `r(N)'/1011


/*Section 4.3: "The prices range from USD 0.01 to USD 29.99, but neither the
 respondent nor the field officer know the price inside the envelope or the
 distribution of prices." */
	summarize price_USD

/*Section 4.3 (footnote): "While one might be concerned these practice purchase
 opportunities would reduce liquidity, the average price paid for these goods was
 USD 0.68—substantially less than the cost of the stove" */
	qui gen pracprice_TIOLI_USD = pracprice1/`FX'
	qui gen pracprice_BDM_USD = pracprice2/`FX'
	qui su pracprice_TIOLI_USD if pracbuy_tioli == 1
	local average_TIOLI_price = `r(mean)'
	local n_buy_TIOLI = `r(N)'
	qui su pracprice_BDM_USD if pracbuy_bdm == 1
	local average_BDM_price = `r(mean)'
	local n_buy_BDM = `r(N)'
	local n_buy = `n_buy_TIOLI' + `n_buy_BDM'


	di `n_buy_BDM'/`n_buy' * `average_BDM_price' + `n_buy_TIOLI'/`n_buy' * `average_TIOLI_price'

/*Section 4.5: "Using this methodology, 57 percent of respondents are classified
 as exhibiting time-inconsistency" */
	tab PB /*The share with PB == 1 is 56.96 */

/*Section 4.5: "Respondents who choose to invest x < 2 (68 percent) are classified
 as exhibiting risk aversion" */
	local FX = 100 /* FX Rate: 100 Kenyan Shillings per dollar, as of April/May 2019 */
	count if g_invest_KSH < 200 /* Those who invested < 2 USD at the 1 USD = 100 KSH
	 exchange rate. */
	local risk_averse = `r(N)'
	count 
	display `risk_averse'/`r(N)'


/* Section 5: Out of the 955 respondents who completed visit 2, 570 (60 percent)
adopted the stove, paying an average price of USD 15 */
/* Number of participants who completed visit 2 */
	count if Visit2 == 1

	/* Number of adopters */
	count if jikokoa == 1
	local n_adopters_v2 = `r(N)' 
	display `n_adopters_v2' 

	/*Average price paid */
	su price_USD if jikokoa == 1
	di `r(mean)'



/* Section 5:  When asked how they spent their charcoal savings, 53 percent of 
respondents report buying more food, 23 percent report paying school fees, and 
15 percent report buying household items such as soap or
clothes. */

	/* Number of stove adopters who answered visit 3 survey */
	count if g_jikokoa == 1
	global n_adopters_v3 = `r(N)' 
	display ${n_adopters_v3}
 
	/*School fees */ 
	mean g_c5_5_savespend_12 /*23.0% */

	/*Household items */
	count if (g_c5_5_savespend_4 == 1 | g_c5_5_savespend_5 == 1 | g_c5_5_savespend_6 == 1)
	di `r(N)'/${n_adopters_v3}/*14.3*/ 

	/*Food */
	count if (g_c5_5_savespend_1 == 1 | g_c5_5_savespend_2 == 1 | g_c5_5_savespend_3 == 1)
	di `r(N)'/${n_adopters_v3}


/* Section 5.1: "USD 2.28 per week corresponds to USD 119 per year — one month 
 of income for the average respondent" */

/*local savings_USD = 2.273*/ /*Column 3 of Table 2 (Causal impact of stove adoption
 on weekly charcoal spending) */ 
	
	di $savings_USD*52

	/*Savings in terms of months of income for the average respondent */
	summarize b_incomeself_USD
	local average_daily_earning =  `r(mean)'

	local savings_in_months = $savings_USD / (`average_daily_earning' * 7) * 12 
	/* Weekly savings/Weekly earnings is savings in terms of current income,
	 multiplying by 12 indicates how much months of current income the savings are
	 equivalent to.*/
	display `savings_in_months'

	/*Alternative version (as it was being done until now) */
	/*
	local fraction_log = -0.496 // SMS regression
	local savings = 1-exp($fraction_log)

	g weeklysavings = d_charcoalbuy_USD * $savings
	g savingsperc = weeklysavings / (b_incomeself_USD*7)
	su savingsperc,d
	*/

/*Section 1: This yields private savings of USD 237 [...] */
	local private_savings_2years = $savings_USD*52*2 
	display `private_savings_2years'

/*Discounted private savings over 2 years, for fact Q */
	
	local disc_private_savings_2years = $discount_rate * `private_savings_2years'

/*Section 5.1: "Net Present Value  (NPV) after two years of stove ownership is
 USD 174 for the average respondent." */

local NPV_2years = `disc_private_savings_2years' -  $jikokoa_cost /*NPV = Discounted private savings - Jikokoa Cost */
di `NPV_2years'

/* Section 5.1: "Relative to a retail price of USD 40, these savings constitute 
an average internal rate of return (IRR) of 295 percent per year" */
preserve

clear 

set obs 24

gen cf = .
gen t = .

replace cf = - $jikokoa_cost if _n == 1
replace cf = ($savings_USD/7) * (365/12) if _n != 1

replace t = _n-1

irr cf
local monthly_irr = `r(irr)' 
local annual_irr = `r(irr)' * 12

display `monthly_irr' * 100 /*This is already as percentage */
display `annual_irr' * 100  /*This is already as percentage */

restore

* At the monthly 
preserve

clear 

set obs 104

gen cf = .
gen t = .

replace cf = - $jikokoa_cost if _n == 1
*replace cf = ($savings_USD/7) * (365/52) if _n != 1
replace cf = $savings_USD if _n != 1

replace t = _n-1

irr cf
local weekly_irr = `r(irr)' 
local annual_irr = `r(irr)' * 52

display `weekly_irr' * 100 /*This is already as percentage */
display `annual_irr' * 100  /*This is already as percentage */

restore


/* 4.1: 38 percent reduction in total ash generated */
di 1-exp(-0.48)

/*Section 5.2: "The median household spends USD 255 on charcoal per year.  Using local market prices, this implies each household consumes 849 KG of charcoal per year. " */
/*Charcoal spending median household */
g charcoal_annual_consumpt = d_charcoalbuy_USD * 52
su charcoal_annual_consumpt, d
display `r(p50)'

/* Annual charcoal consumption in kg. by median household */
su d_charcoalbuy_USD,d 
local median_ksh_charcoal_week = `r(p50)' /* Median amount of $ spent in charcoal per week, in KSH */
local charcoal_kg_price_ksh = 0.3 /*USD 0.3 at the moment */

di `median_ksh_charcoal_week' * 52 /`charcoal_kg_price_ksh'


/*Section 5.2: "The stove's 40 percent reduction then corresponds to 6.9 metric tons of CO2e in avoided emissions over two years of usage. Using the EPA (2016) estimate for the 2020 social cost of CO2 of USD 42, adoption of a stove generates USD 295 in CO2e emission reductions over two years of usage. Focusing on only the environmental benefits, investing in a Jikokoa reduces greenhouse gas emissions at a cost of USD 5.76 per ton of CO2e." */
/*Reduction in charcoal consumption */
di $savings

global sd = 0.071

*Lower bound of savings, as percentage
local fraction_log_upper =  $fraction_log  + (2 * ${sd})
di `fraction_log_upper'
di 1-exp(`fraction_log_upper') 
*Upper bound of savings, as percentage
local fraction_log_lower =  $fraction_log  - (2 * ${sd})
di 1-exp(`fraction_log_lower') 

*Reduces carbon emissions by 6.9 tons of CO2e over the two-year lifetime of the stove

su d_charcoalbuy_USD,d 
local median_ksh_charcoal_week = `r(p50)' /* Median amount of $ spent in charcoal per week, in KSH */
local charcoal_kg_price_ksh = 0.3 /*USD per KG of charcoal in local market, 0.3 at the moment */
local kg_co2_per_kg_charcoal = 10.5 /*KG of CO2 emitted during production + consumption of charcoal, more detail in paper, footnote 30. */
local kgs_per_ton = 1000
local social_cost_carbon = 42

local emission_reduction_ton = (((`median_ksh_charcoal_week' * 104 * $savings)/`charcoal_kg_price_ksh')*`kg_co2_per_kg_charcoal')/`kgs_per_ton'

display `emission_reduction_ton'

/*Emission reductions in USD generated by adoption of stove over 2 years of usage */
local emission_reduction_USD = ((((`median_ksh_charcoal_week'* 104 *$savings)/`charcoal_kg_price_ksh')*`kg_co2_per_kg_charcoal')/`kgs_per_ton')*`social_cost_carbon' 

di `emission_reduction_USD'

/*Discounted benefits of emission reduction in USD, for fact Q*/
local disc_emission_benefits_2years = `emission_reduction_USD' * $discount_rate
display `disc_emission_benefits_2years'

/*USD cost of reducing a ton of CO2e through investment in Jikokoa */
display $jikokoa_cost/`emission_reduction_ton'


/*Section 5.3: "To value these time savings, we use median earnings of USD 3 per day and assume daily earnings scale linearly with hours worked starting at an 8-hour work day. The time savings correspond to USD 0.34 per day, or 107 percent of median financial savings" */
/*Median earnings in USD*/

summarize b_incomeself_USD, d /*b_incomeself_USD is daily income */
local median_earnings_USD = `r(p50)'
local time_saved = 53.866 /*Column 2, table 4, from Figures.do */

local daily_time_savings = (`median_earnings_USD' / 8) * (`time_saved' / 60) // Income by 8 hours to get hourly income; time saved in minutes by 60 to get hours saved.

display `daily_time_savings'

/*Savings as percentage of median financial savings */
summarize d_charcoalbuy_USD, d
local median_financial_savings_USD = `r(p50)' * $savings
display `median_financial_savings_USD'
local weekly_time_savings_USD  = `daily_time_savings' * 6
display `weekly_time_savings_USD'

display `weekly_time_savings_USD' / `median_financial_savings_USD'



local time_savings_2years = `daily_time_savings'*365*2 // Cooking related savings after 2 years of ownership.
display `time_savings_2years'



/*Discounted savings associated with cooking over 2 years, for fact Q*/

local disc_time_savings_2years = `time_savings_2years' * $discount_rate
display `disc_time_savings_2years'


/* Section 5: "The public and private benefit from two years of ownership, discounting weekly at δ = 0.9 annualized, totals USD 700" */
di `disc_emission_benefits_2years' + `disc_private_savings_2years' + `disc_time_savings_2years'

di `disc_emission_benefits_2years' 
di `disc_private_savings_2years' 
di `disc_time_savings_2years'

/* Section 5.4: "Two-thirds of respondents who adopted the stove said they did not change which foods they cook, and 71 percent said they cook the same
quantity of food as before. 61 percent said that food cooked with the energy efficient stove tasted slightly or a lot better, and fewer than 1 percent said
the food tasted worse." */

* % have not changed which foods they cook
cou if d3_stop =="no" & d3_start=="no"
di `r(N)'/${n_adopters_v3}

* % have not changed the amount they cook
cou if d3_amount == 3 
di `r(N)'/544

* % says food tasted slightly or a lot better
count if g_c5_6_taste == 4 | g_c5_6_taste == 5
local better_food = `r(N)'
count if g_jikokoa == 1
display `better_food'/${n_adopters_v3}

* % who said food tastes worse 
count if g_c5_6_taste < 3
display (`r(N)'/${n_adopters_v3})*100

/*Section 5.4: "Most respondents report that space heating generated by stove usage helps keep them warm during winter months" */

tab d3_heating_yn /* 69.42% reports that the stove helps to keep their house warm when it is cold outside. */

/* Section 5.4: "Despite these heating benefits, few respondents ever burn charcoal purely with the goal of heating their living space." */
preserve 
/* some FOs were entering this wrong */
drop if  d3_heating_mins >= 240 

count if d3_heating_yn == 0 | d3_heating_mins== 0
local stove_for_heating = `r(N)'
count if d3_heating_yn != . /*Check why N = 618 */
di `stove_for_heating'/`r(N)'

/*An alternative is */
count if d3_heating_yn == 0 
local stove_for_heating = `r(N)'
count if d3_heating_yn != . /*Check why N = 618 */
di `stove_for_heating'/`r(N)'
restore

/* SD 2.42 per week, corresponding to a 42 percent reduction (54 log points) */
di 1-exp(-0.56) // Table 2, Column 7


/* Section 5.7: "Second, during the endline survey 99 percent of stove adopters say they recommend the stove to friends and family members." */

count if g_c5_4_recom == 1 | g_c5_4_recom == 2
display `r(N)'/${n_adopters_v3}


/* Section 5.7: "Fewer than 1 percent had ever considered selling it." */

count if g_c5_sellconsider == 1
display `r(N)'/${n_adopters_v3}

/*Section 5.8: "First, cooking is inelastic: a regression of log of time spent
 cooking on log of income yields a coefficient that is not statistically 
 significant from zero." */
g ln_time_using_cookstove = ln(d1_use_morn + d1_use_aft + d1_use_eve)
g ln_income_USD = ln(hhincome_week_USD)

reg ln_time_using_cookstove ln_income_USD


/* Section 5.8: "23 percent state that the amount "increased slightly,"
 but likely do so without cooking for longer or using more charcoal,
 instead simply adding more food into the pot they were already cooking with."*/

cou if d3_amount == 2
di `r(N)'/${n_adopters_v3}/*check if this one is right */

/*Section 5.9: "Of the 1,018 respondents who were enrolled during visit 1, 955 (94 percent) completed visit 2 and 924 (91 percent) completed visit 3" */

*Number of respondents who completed visit 2.
count if Visit2 == 1

*Number of respondents who completed visit 3.
count if Visit3 == 1 

/*Section 6.1: "In the attention control group at the second visit, the average respondent's median belief is that they would save USD 89 over the next year by purchasing the stove; however, the average standard
deviation of their beliefs was USD 15." */
/* Average respondent's median belief */
replace v2_beliefs_annual_median = v2_beliefs_annual_median/`FX' 
mean v2_beliefs_annual_median if treata_pooled == 0 

/* Average standard deviation of beliefs */
replace v2_beliefs_annual_sd = v2_beliefs_annual_sd/`FX'
mean v2_beliefs_annual_sd if treata_pooled == 0



/*Section 7.1: "Factoring in private savings and avoided environmental damages, a subsidy for the energy efficient cookstove would generate USD 19 of welfare gains for every USD 1 of government expenditure." */
local total_savings = `private_savings_2years' + `emission_reduction_USD' + `time_savings_2years'

local welfare_gains_subsidy = `total_savings' / $jikokoa_cost

display `private_savings_2years'
display `emission_reduction_USD'
display `time_savings_2years'

display `total_savings'
display `welfare_gains_subsidy'

/* Section 8: "Despite this, we identify significant under-adoption: participants in the control group are only willing to pay USD 12 for the stove." */

summarize finwtp_USD if treatc_pooled==0 

/* Section 5.1: "Converting `weekly charcoal spending' (in Ksh) to `kilograms charcoal purchased' (in KG) using local charcoal market prices, and comparing KG of charcoal purchased with KG of ash generated from charcoal usage, identifies a charcoal-to-ash conversion ratio of 1.6 percent" */
/*still open */

reg bucket_kg char_used_month_kg


/* Switch to 1 year followup survey */
include "${main}/Do/0. Master.do"
use "`dataclean'/Endline1_clean_replication_noPII.dta", clear

/* Section 5.5 (footnote): "Of the 955 participants who completed visit 2, 875 (92 percent) completed the one-year endline survey." */

count


/* Section 5.5: "Out of the 521 stove adopters re-surveyed one year later, 510 (98 percent) still had the Jikokoa." */


 *First: drop people with a data entry error
foreach id in 798z07 z95zab8 23afd44 66bcf38 789dcb9 zcz0a7f 4z63435 0f2fa7d d97cz8c  3d53c17 {
		drop if respondent_id=="`id'"
}


*Number of stove adopters re-surveyed
cou if hhstove=="1"
local n_adopters_e1yr = `r(N)'
display `n_adopters_e1yr'



* Number of adopters who still have a Jikokoa: 
cou if hhstove=="1" & g_jikokoa==1

/* Section 5.5: "27 percent of adopters still had a working traditional jiko at
 home, 46 percent said their jiko had broken and they simply did not replace it,
 and 23 percent had given their old jiko away as a gift." */

* Percentage of adopters who still had a working traditional jiko at home.
cou if hhstove=="1" & g_jikokoa==1 & g_c5_3_work==1
display `r(N)'/`n_adopters_e1yr'

*Percentage of adopters whose jiko had broken and they did not replace it.
cou if g_c5_3_work == 0 | g_c5_3_oldjiko == 2 /* Jiko broke (regardless of if
 they still have it or not) */
display `r(N)'/`n_adopters_e1yr'

*Percentage of adopters who had given their old jiko as a gift.
cou if g_c5_3_oldjiko == 1 // Gave away as a gift
display `r(N)'/`n_adopters_e1yr'


/*Section 5.5: "Only one person said they had sold their jiko, which is not
 surprising given the lack of a secondary jiko market, likely due to its 
 fragility and low cost." */

count if g_c5_3_oldjiko == 4

/*Section 5 (footnote): "Respondents who did not were still able to buy it at 
retail prices. In the year after visit 2, about 4 percent did so." */
/*Number of individuals who did not buy a Jikokoa during visit 2 */
count if hhstove == "0"
local no_jikokoa = `r(N)'

/*Number of individuals who bought Jikokoa after Visit 2 */
count if g_stove == 1
local bought_jikokoa = `r(N)'

/* Percentage who bought Jikokoa after Visit 2 */
display `bought_jikokoa'/`no_jikokoa'



/*Facts from Pilot */ 

include "${main}/Do/0. Master.do"
use "`dataclean'/Pilot_clean.dta", replace

/* Section 2.1: "In the pilot, we asked 153 subjects why they had not adopted 
the Jikokoa as an open ended question. Answers overwhelmingly had to do with 
affordability. Zero subjects said their food would taste worse, zero subjects
 said that it was not healthy, zero said they worried it would break, four said 
 they were not sure how to use it, and zero mentioned the stove's appearance" */

/*Zero subjects said their food would taste worse */
count if d_nobuy_7 == 1

/* Zero subjects said that it was not healthy */ 
count if d_nobuy_9 == 1

/*Zero said they worried it would break */ 
count if d_nobuy_11 == 1

/* Four said they were not sure how to use it */
count if d_nobuy_13 == 1

/* Zero mentioned the stove's appearance */
list d_nobuy_detail if !missing(d_nobuy_detail) /* No one mentioned appearance in
 the open ended question about reasons for not buying the Jikokoa */

/* Section 6.2.2: "Respondents paying with weekly deadlines are willing to pay
 on average USD 1.29 more for the stove than those paying with monthly deadlines." */
include "${main}/Do/0. Master.do"
use "`dataclean'/Visit123_E1_analysis_replication.dta", clear

local CONTROLS = "d_charcoalbuy_KSH spend50 savings_KSH b_incomeself_KSH RiskAverse CreditConstrained b_residents b_children d_jikokoalast_years v1_beliefs_annual_mean v1_beliefs_annual_sd" 

reg finwtp_USD c2  t_benefits t_costs `CONTROLS' if treatc_pooled==1 /*Coefficient for c2 */

/*Section 8: "More than 60 percent of respondents report using the savings for 
critical household expenditures such as food items and child school fees"*/
count if g_c5_5_savespend_1 == 1 | g_c5_5_savespend_2 == 1 | g_c5_5_savespend_12 == 1
local critical_spending = `r(N)'
count if g_jikokoa == 1
di `critical_spending'/`r(N)'

/*FOOTNOTES*/

/* "47 percent of respondents filled in the sheet entirely independently. 
31 percent of respondents wrote in most of the sheet independently, but required
 some guidance by the field officer. 22 percent of respondents were illiterate
 and the field officer completed their sheet on their behalf." */

tab attw_help


*FACTS GENERATED USING Payments_Data_Total_replication.dta 
include "${main}/Do/0. Master.do"
use "`raw_confidential'/Payments_Data_Total_replication.dta", clear	


			
/* Section 6.3: "By the end of the payment period, the median respondent who 
adopted the stove and was in the credit treatment group had paid 98 percent of 
their price. 13 percent had paid less than 10 percent and the mean repayment
 rate was 72 percent." */ 

	/*Percent paid by median respondent who adopted the stove and was
	in the credit treatment group.*/
	
	summarize fracpaid, d 
	di `r(p50)'

	/**Percentage who had paid less than 10 percent.*/
	count if fracpaid < 0.1
	local less_10_pct = `r(N)'
	count 
	local n_respondents = `r(N)'
	di `less_10_pct'/`n_respondents' 

	/* Mean repayment rate */
	mean fracpaid
	
/*Section 6.3 (footnote): "Around 13 percent of respondents who adopted the
 stove using credit had paid less than 10 percent of the required amount by 
 the end of the payment period: for 56 respondents, we do not have any record
 of them paying any amount." */

/*For the 13%, refer to the previous fact */

/*Participant for which we have no record of them paying any amount */
count if fracpaid == 0
				
/*Section 6.3: "Across all respondents who adopted the stove in the credit
treatment groups, on average 72 percent of the loan was repaid. Thus, a lender
would need to charge an interest rate of 39.2 percent (such that 0.72 = 1
1+r), on top of the market lending rate of 1.16 percent, for a total interest
 rate of 40.1 percent." */
 
	/*Average repayment rate */ 
	quietly su fracpaid, d
	di `r(mean)'

	/*Breakeven interest rate */
	di (1/`r(mean)')-1

	/*Total interest rate */
	di (1/`r(mean)')-1+0.0116

		
/*Section 6.3: "The median respondent in the high subsidy group had paid 
100 percent, whereas the median respondent in the low subsidy group had paid
 67 percent." */
	/*High subsidy group */	
	su fracpaid if price_KSH <= 1500, d 
	di `r(p50)'

	/*Low subsidy group */
	su fracpaid if price_KSH > 1500, d
	di `r(p50)'


/*Section 4.2: :"Around 13 percent of respondents who adopted the stove using
credit had paid less than 10 percent of the required amount by the end of the 
payment period: for 56 respondents, we do not have any record of them paying
any amount." (footnote) */

/*For 56 respondents, we do not have any record of them paying
any amount. */

count if fracpaid == 0

/* Section 6.2.3 (footnote): "We also find no evidence of this ex-post as repayment
 rates across the attention arms are indistinguishable." */
include "${main}/Do/0. Master.do"
merge 1:1 respondent_id using "`dataclean'/Visit123_E1_analysis_replication.dta"
tab treata

drop if treata == 0
gen treata_2 = 1 if treata == 2
replace treata_2 = 0 if treata_2 == .

reg fracpaid treata_2

/* Section 6.3: "When controlling for price, WTP is not correlated with repayment 
rate, suggesting price itself is the mechanism." */
*MINPAID == rolling sum of theoretical payments
reg fracpaid MINPAID finwtp_KSH

/*ONLINE APPENDIX */
include "${main}/Do/0. Master.do"
use "`dataclean'/Visit123_E1_analysis_replication.dta", clear

/* In our sample, 86 percent of respondents had borrowed at least once in that  period, primarily through a Chama or from family or friends. */
/*See above */


/* For all households, in Nairobi broadly and within our sample, loans
primarily served to cover health spending, child's school fees, or business needs.*/
gen loan_max = wordcount(g1d)
summarize loan_max
local max_d_awareness = `r(max)'


gen loan_match_1 = 0
gen loan_match_2 = 0
gen loan_match_3 = 0
gen loan_match_4 = 0
gen loan_match_5 = 0
gen loan_match_6 = 0
gen loan_match_7 = 0
gen loan_match_8 = 0
gen loan_match_9 = 0
gen loan_match_10 = 0
gen loan_match_97 = 0


 forval j = 1/`max_d_awareness' { 
		 replace loan_match_1 = 1 if real(word(g1d, `j')) == 1
		 replace loan_match_2 = 1 if real(word(g1d, `j')) == 2
		 replace loan_match_3 = 1 if real(word(g1d, `j')) == 3
		 replace loan_match_4 = 1 if real(word(g1d, `j')) == 4
         replace loan_match_5 = 1 if real(word(g1d, `j')) == 5
		 replace loan_match_6 = 1 if real(word(g1d, `j')) == 6
		 replace loan_match_7 = 1 if real(word(g1d, `j')) == 7
		 replace loan_match_8 = 1 if real(word(g1d, `j')) == 8
		 replace loan_match_9 = 1 if real(word(g1d, `j')) == 9
		 replace loan_match_10 = 1 if real(word(g1d, `j')) == 10
		 replace loan_match_97 = 1 if real(word(g1d, `j')) == 97

}

count if g1d != "."
local no_missing = `r(N)'

/*Business need (own or owned by friend/neighbor)/ agriculture inputs */
count if loan_match_1 == 1 |  loan_match_2 == 1 |  loan_match_3 == 1 
di `r(N)'/`no_missing'

/*Health/education */
cou if loan_match_5==1 | loan_match_6==1 
di `r(N)'/`no_missing'

/* 70 percent of respondents participate regularly in a Chama or merry-go-round, with payouts generally ranging between USD 10–300. */

* % who participate regularly in a Chama or merry-go-round
count if g1b != "96" /* 96 == "Does not participate in Chama/merry-go-round" */
display `r(N)'/`no_missing'

*Chama/merry-go-round usual range
g g2b2_USD = g2b2/100 /* FX Rate: 100 Kenyan Shillings per dollar, as of April/May 2019 */
g btwn_10_300 = (g2b2_USD >= 10 & g2b2_USD <= 300) if g2b2_USD != .
tab btwn_10_300 /* Share between 10 USD and 300 USD inclusive: 88.3% */

/*  Around half of respondents participate in a Chama that had a payout of at
 least USD 40, the cost of the stove at the time of the study, and around 
 one-third had ever taken out a loan via a mobile banking platform such as M-Shwari. */

* % who participate in a Chama that had a payout of at least USD 40
count if g2b2 <= 4000 /*4000 KSH / 100 KSH/USD = 40 USD */
local less_or_equal_40 = `r(N)'
count if g2b2 != .
display `less_or_equal_40'/`r(N)' 

* % had ever taken out a loan via a mobile banking platform such as M-Shwari.
count if g1a2 == 1
display `r(N)'/`no_missing'

/* There appears to be heterogeneity in access to credit by gender, although
 only 46 respondents (5 percent) were male, so these statistics may be noisy.  */
tab b_male

/*  Around 96 percent of both men and women in our sample use mobile money 
services such as M-Pesa. */
count if g1a == 1
display `r(N)'/`no_missing'

/* 25 percent of women would not be able to access a mobile money loan if they
 wanted to today, while this is the case for only 11 percent of men */

*% of women
count if g1g1 == 0 & b_male == 0 
local women_no_credit = `r(N)'
count if g1g1 != . & b_male == 0 
local female_n = `r(N)'
display `women_no_credit'/`female_n'


*% of men 
count if g1g1 == 0 & b_male == 1 
local men_no_credit = `r(N)'
count if g1g1 != . & b_male == 1 
local male_n = `r(N)'
display `men_no_credit'/`male_n'


/* The median male respondent would be able to borrow USD 38 while the median
 female respondent would be able to borrow only USD 10. */

* Median male
quietly su g1g1 if b_male == 1, detail
display `r(p50)'/`FX'

*Median female
quietly su g1g1 if b_male == 0, detail
display `r(p50)'/`FX'

/* "That said, 68 percent of women and 59 percent of men had not taken out a
 loan (formally or informally) in the past 12 months, and 34 percent of women 
 and 46 percent of men had been refused a loan in the past year, suggesting that
 the overall difference in credit constrainedness by gender is likely small." */
 
tab g1d if b_male == 0 /* 31.71% did not take a loan, 68% TOOK a loan */
tab g1d if b_male == 1 /* 41.13% did not take a loan, 58.7% TOOK a loan */

* % of women who had been refused a loan in the past years
count if g1e != "96" & b_male == 0 /* 96 == Had not been refused a loan" */
local women_refused `r(N)'
count if g1e != "." & b_male == 0
di `women_refused'/`r(N)'

* % of men who had been refused a loan in the past years
count if g1e != "96" & b_male == 1 /* 96 == Had not been refused a loan" */
local men_refused `r(N)'
count if g1e != "." & b_male == 1
di `men_refused'/`r(N)'

/* According to the Nairobi Cross-sectional Slums Survey (2014), whose sampling
 methodology was designed to be statistically representative, 81.6 percent of
 residents had completed primary education, while 70 percent of respondents in
 our sample had" */
count if educ_prim == 1
local finished_primary = `r(N)'
count if educ_prim != .
display `finished_primary'/`r(N)'


/*The average household size was 3.1 in the representative sample, while this was
 4.7 in our sample" */
quietly su b_residents 
di `r(mean)'

/* "According to two proprietary studies completed by a third-party consultant 
on behalf of the cookstove company in 2016 and 2017, consisting of phone surveys
with a random sample of existing customers, only 12 percent of recent adopters
 live below the Kenyan poverty line (Ksh 310 per person per day, or around USD 3),
 while 88 percent of our respondents do" */
g income_day_per_person = hhincome/b_residents
g below_poverty_line = (income_day_per_person < 310)
count if below_poverty_line == 1
display `r(N)'/`no_missing'

/* "More than half of adopters had attended college or university, while
only 5 percent of our respondents have" */
count if  b_educ >= 90 & b_educ <= 140
local college_or_university = `r(N)'
count if b_educ != .
display `college_or_university'/`r(N)'


/* 8 respondents for whom W T Pi ≥ Pi (1.4 percent) were ultimately not able 
to pay Pi for the stove. */
cou if win_bdm==1 & jikokoa!=1


/*"In the majority of cases where the respondent argued upon losing the BDM
 elicitation (around 10 percent of all respondents for whom W T Pi < Pi), the
 argument concerned the high price (the respondent wanted a larger discount) 
 rather than miscomprehension about the process itself, again suggesting that
 comprehension was generally good." */
 
* % of those who lost BDM elicitation that complained
label define f_respargu_yn 0 "Did not complain" 1 "Complained"
label values f_respargu_yn f_respargu_yn
tab f_respargu_yn if win_bdm == 0 

/* In the final question, asked immediately prior to opening the envelope, 
97 percent of respondents answered both questions correctly */

forv n = 1(2)7 {
	cou if !missing(checkbid`n'wronga) | !missing(checkbid`n'wrongb)
}

count if doublecheckfinal1 == 1 & doublecheckfinal2 == 1
local both_correct = `r(N)'
count if doublecheckfinal1 != . & doublecheckfinal2 != .
display `both_correct'/`r(N)'



 /*		Figure A19:  Out of 955 respondents who completed visit 2, 124 (13 percent)
 did not respond to any SMSes in this period. 446 respondents (47 percent) 
 responded to at least half of all SMSes */
 
	include "${main}/Do/0. Master.do"
	use "`dataclean'/SMS_clean_sms_replication.dta", clear
		keep if TsinceV2>=0 & CsinceV2<=16
		keep respondent_id CsinceV2
		duplicates drop // Only count Max 1 sms per SMS cycle
		
		keep respondent_id
		
		bys respondent_id: g obs = _N
		duplicates drop
		
		merge 1:1 respondent_id using "`dataclean'/Visit123_E1_analysis_replication.dta", keepusing(respondent_id Visit2)

		keep if Visit2==1
		
		replace obs = 0 if missing(obs) & _merge == 2
		tab obs, mi
		
		count if Visit2 == 1
		local n_visit2 = `r(N)'
* Number and % who did not respond to any SMSes.
		count if obs == 0
		di `r(N)'/`n_visit2'
		
* Number and % who responded to at least half of all SMSes.
		count if obs >= 8
		di `r(N)'/`n_visit2'


/* Table "Causal impact of stove adoption on long-term financial assets":
	"In Column (12) a log increase of 0.564 corresponds to an increase of 56
	percent over the control mean." */

	display (exp(0.56) - 1)* 100
	
/* Figure "Attrition of SMSes by adoption and treatment status": 
 "Of 955 respondents who completed visit 2, 838 (88 percent) responded correctly
 to at least one SMS over the course of the study. Among these respondents,
 we received correct responses to 44 percent of post-adoption charcoal SMSes.  */


	include "${main}/Do/0. Master.do"

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
	merge m:1 respondent_id using  "`dataclean'/Visit123_E1_analysis_replication.dta", ///
		keepusing(jikokoa  treata_pooled treatc_pooled baseline_date midline_date)
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
	
		
	* Drop pre-baseline SMS dates for EVERYONE:
	drop if (SMS_date < baseline_date)
	
	* Drop pre-midline SMS dates for ATTENTION CONTROL only (matatu SMSes):
	drop if ((SMS_date < midline_date) | (SMS_date < baseline_date+30)) //& treata_pooled==0
	
	* Drop all dates beyond latest day of SMS data (from Elijah): 
	drop if SMS_date > mdy(07,31,2019)-2
	
	* Now, calculate fraction of received_sms, by SMS cycle and treatment group: 
	replace CsinceV2  = CsinceV2 *3

	* Only large enough sample size: 
	
	/*bys CsinceV2: g N = _N
	keep if N > 250
	drop N */
	
	
	/* Number who sent at least one correct SMS (EXCLUDING ATTENTION CONTROL 
	only for pre midline): */
	
	preserve
		collapse (mean) received_sms (count) total =received_sms, by(respondent_id)
		drop if received_sms == 0
		unique respondent_id
		su received_sms /* Number is 835 */
	restore
	
	/* Now, let's compute the % of correct SMSs after midline for those who sent at least one SMS */
	sort respondent_id CsinceV2
	bysort respondent_id: gen positives = sum(received_sms)
	
	preserve
		bysort respondent_id: keep if _n == _N & positives == 0
		levelsof respondent_id, local(levels) 
	restore
	
	foreach respondent of local levels {
		drop if respondent_id == "`respondent'"
	}
	/*% of correct SMSs after midline for those who sent at least one SMS: */
	su received_sms


/* Figure "Attrition of SMSes by adoption and treatment status": 
	"During the SMS survey conducted one year after the main experiment, 
	more than 75 percent of respondents who completed visit 2 responded to at
	least one SMS, and the median respondent responded to six." 
*/
	include "${main}/Do/0. Master.do"
	
	use "`dataclean'/SMS_clean_sms_2020_replication_noPII.dta", clear
	keep respondent_id CsinceV2
	duplicates drop // Only count Max 1 sms per SMS cycle
	
	keep respondent_id
	
	bys respondent_id: g obs = _N
	duplicates drop
	
	merge 1:1 respondent_id using "`dataclean'/Visit123_E1_analysis_replication.dta", keepusing(respondent_id Visit2)
	drop if _merge == 1 // Drop a few people who were disqualified due to nonresponse, lying to field officers, couldn't be contacted, etc. 
	
	replace obs = 0 if missing(obs) & _merge == 2
	drop _merge 
	
	drop if Visit2 != 1
	count 
	local n_visit2 = `r(N)'
	
	
	/* % of those who were in Visit 2 that answered SMSs during the 
	survey conducted one year later */
	count if obs > 0
	local sent_sms = `r(N)'
	display `sent_sms'/`n_visit2' * 100
	
	/*Median number of SMSs responded by those who were in Visit 2 and answered 
	the survey conducted one year later */
	quietly su obs, detail
	display `r(p50)'


	
	
	
	
	
	
	
	
	
	
	
	
	
	

