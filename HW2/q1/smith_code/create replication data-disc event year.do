
use "C:\Users\Brock.Smith\Desktop\resource curse\dtas\final data-disc event yr.dta",clear

drop if droprich==1 |soviet==1 

rename area land_area
rename Mlngdp lnGDPpc_Madd
rename pop population
rename democ democracy_score
rename yr_sch yrs_schooling
rename ci investment_to_gdp
rename country1 countrycode
rename frag fragmentation
rename disc discovery_dummy

keep country land_area lnGDPpc_Madd population democracy_score region yrs_schooling investment_to_gdp countrycode fragmentation year discovery_dummy first_disc_year


save "C:\Users\Brock.Smith\Desktop\resource curse\replication\replication_dataset_tableA1.dta",replace
