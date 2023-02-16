
cd "C:\Users\Brock.Smith\Desktop\resource curse\replication

use replication_dataset_main,clear

xtset countrycode year

gen totk=laborforce*capital_perworker_WPD
gen ginc_pw=ln(gdp_perworker_WPD)-ln(l.gdp_perworker_WPD)

******0-8 years after event

gen gkperl8x=ln(capital_perworker_WPD)-ln(l9.capital_perworker_WPD) if event_time==8
replace gkperl8x=ln(capital_perworker_WPD)-ln(l7.capital_perworker_WPD) if event_time==8 & inlist(country,"Algeria","Gabon")
bysort country: egen gkperl8=min(gkperl8x)
sort countrycode year

gen gschool8x=ln(yrs_schooling)-ln(l9.yrs_schooling) if event_time==8
replace gschool8x=ln(yrs_schooling)-ln(l7.yrs_schooling) if event_time==8 & inlist(country,"Algeria","Gabon")
bysort country: egen gschool8=min(gschool8x)
sort countrycode year

gen gtotgdp_perworker_WPD8x=ln(gdp_perworker_WPD)-ln(l9.gdp_perworker_WPD) if event_time==8
replace gtotgdp_perworker_WPD8x=ln(gdp_perworker_WPD)-ln(l7.gdp_perworker_WPD) if event_time==8 & inlist(country,"Algeria","Gabon")
bysort country: egen gtotgdp_perworker_WPD8=min(gtotgdp_perworker_WPD8x)

gen gtfp_educ8= gtotgdp_perworker_WPD8 - ((1/3)*gkperl8) - .07*gschool8

gen YLeduc_pctgrowth_kperl8=((1/3)*gkperl8)/gtotgdp_perworker_WPD8
gen YLeduc_pctgrowth_educ8=.07*gschool8/gtotgdp_perworker_WPD8
gen YLeduc_pctgrowth_tfp8=gtfp_educ8/gtotgdp_perworker_WPD8


******9-17 years after event

sort countrycode year
gen gk17x=ln(totk)-ln(l9.totk) if event_time==17
bysort country: egen gk17=min(gk17x)
sort countrycode year

gen gkperl17x=ln(capital_perworker_WPD)-ln(l9.capital_perworker_WPD) if event_time==17
bysort country: egen gkperl17=min(gkperl17x)
sort countrycode year

gen gl17x=ln(laborforce)-ln(l9.laborforce) if event_time==17
bysort country: egen gl17=min(gl17x)
sort countrycode year

gen gschool17x=ln(yrs_schooling)-ln(l9.yrs_schooling) if event_time==17
bysort country: egen gschool17=min(gschool17x)
sort countrycode year

gen gtotinc_pw17x=ln(gdp_perworker_WPD)-ln(l9.gdp_perworker_WPD) if event_time==17
bysort country: egen gtotinc_pw17=min(gtotinc_pw17x)

gen gtfp_educ17= gtotinc_pw17 - ((1/3)*gkperl17) - .07*gschool17

gen YLeduc_pctgrowth_kperl17=((1/3)*gkperl17)/gtotinc_pw17x
gen YLeduc_pctgrowth_educ17=.07*gschool17/gtotinc_pw17x
gen YLeduc_pctgrowth_tfp17=gtfp_educ17/gtotinc_pw17x

format %12.0g laborforce
format %12.0g gdp_perworker_WPD
format %12.0g totk


******1960-90 for non-treatments
xtset countrycode year

gen gkperl6090x=ln(capital_perworker_WPD)-ln(l30.capital_perworker_WPD) if year==1990
bysort country: egen gkperl6090=min(gkperl6090x)
sort countrycode year

gen gschool6090x=ln(yrs_schooling)-ln(l30.yrs_schooling) if year==1990
bysort country: egen gschool6090=min(gschool6090x)
sort countrycode year

gen gtotinc_pw6090x=ln(gdp_perworker_WPD)-ln(l30.gdp_perworker_WPD) if year==1990
bysort country: egen gtotinc_pw6090=min(gtotinc_pw6090x)

bysort country: egen meangtotinc_pw6090=mean(ginc_pw) if inrange(year,1960,1990)

gen gtfp_educ6090= gtotinc_pw6090 - ((1/3)*gkperl6090) - .07*gschool6090

gen YLeduc_pctgrowth_kperl6090=((1/3)*gkperl6090)/gtotinc_pw6090
gen YLeduc_pctgrowth_educ6090=.07*gschool6090/gtotinc_pw6090
gen YLeduc_pctgrowth_tfp6090=gtfp_educ6090/gtotinc_pw6090


******1970-90 for non-treatments

xtset countrycode year

gen gkperl7090x=ln(capital_perworker_WPD)-ln(l20.capital_perworker_WPD) if year==1990
bysort country: egen gkperl7090=min(gkperl7090x)
sort countrycode year

gen gschool7090x=ln(yrs_schooling)-ln(l20.yrs_schooling) if year==1990
bysort country: egen gschool7090=min(gschool7090x)
sort countrycode year

gen gtotgdp_perworker_WPD7090x=ln(gdp_perworker_WPD)-ln(l20.gdp_perworker_WPD) if year==1990
bysort country: egen gtotgdp_perworker_WPD7090=min(gtotgdp_perworker_WPD7090x)

bysort country: egen meangtotinc_pw7090=mean(ginc_pw) if inrange(year,1970,1990)

gen gtfp_educ7090= gtotgdp_perworker_WPD7090 - ((1/3)*gkperl7090) - .07*gschool7090

gen YLeduc_pctgrowth_kperl7090=((1/3)*gkperl7090)/gtotgdp_perworker_WPD7090
gen YLeduc_pctgrowth_educ7090=.07*gschool7090/gtotgdp_perworker_WPD7090
gen YLeduc_pctgrowth_tfp7090=gtfp_educ7090/gtotgdp_perworker_WPD7090





****the commands below yield the results shown in tables 6 and 7

table country if treat==1 & oecd==0 & inrange(event_t,0,8),c(mean ginc_pw mean YLeduc_pctgrowth_kperl8 mean YLeduc_pctgrowth_educ8 mean YLeduc_pctgrowth_tfp8)
table country if treat==1 & oecd==1 & inrange(event_t,0,8),c(mean ginc_pw mean YLeduc_pctgrowth_kperl8 mean YLeduc_pctgrowth_educ8 mean YLeduc_pctgrowth_tfp8)
table country if treat==1 & oecd==0 & inrange(event_t,9,17),c(mean ginc_pw mean YLeduc_pctgrowth_kperl17 mean YLeduc_pctgrowth_educ17 mean YLeduc_pctgrowth_tfp17)
table country if treat==1 & oecd==1 & inrange(event_t,9,17),c(mean ginc_pw mean YLeduc_pctgrowth_kperl17 mean YLeduc_pctgrowth_educ17 mean YLeduc_pctgrowth_tfp17)

table year if treat==0 & oecd==0 & YLeduc_pctgrowth_educ6090!=. & meangtotinc_pw6090>=.005 & year==1980,c(mean meangtotinc_pw6090 mean YLeduc_pctgrowth_kperl6090 mean YLeduc_pctgrowth_educ6090 mean YLeduc_pctgrowth_tfp6090)
table year if treat==0 & oecd==1 & YLeduc_pctgrowth_educ7090!=. & meangtotinc_pw7090>=.005 & year==1980,c(mean meangtotinc_pw7090 mean YLeduc_pctgrowth_kperl7090 mean YLeduc_pctgrowth_educ7090 mean YLeduc_pctgrowth_tfp7090)


