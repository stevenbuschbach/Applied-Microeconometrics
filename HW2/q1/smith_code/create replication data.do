
use "C:\Users\Brock.Smith\Desktop\resource curse\dtas\final data set 8 yrs included",clear
drop if year<1950

rename treat treat_dummy
rename pop population
rename ppp ppp_deflator_pwt
rename rgdpch realgdp_pwt
rename cgdp cgdp_pwt
rename p price_level
rename lngdp lngdp_pwt
rename Mgdp GDPpc_Madd
rename Mlngdp lnGDPpc_Madd
rename lncgdppercap_2000usd lnCGDPpc_2000usd
rename country1 countrycode
rename frag fragmentation
rename inf infant_mortality
rename yr_sch yrs_schooling
rename lnrealgdp_nores ln_nonhydrogdp
rename LF laborforce
rename inc_pw gdp_perworker_WPD
rename k06_pw capital_perworker_WPD
rename first_disc discovery_year
rename first_prod first_production_year
rename resource_valueoil oil_metrictons
rename resource_valueNG gas_TJ
rename area land_area
rename democ democracy_score
rename ci investment_to_gdp
rename ng_price current_gas_price
rename currentoilprice current_oil_price
rename oilprice real_oil_price
rename barrels_totalpc total_barrels

drop if droprich==1
drop if soviet==1


keep country year event_year event_time population ppp_deflator_pwt realgdp_pwt GDPpc_Madd lnGDPpc_Madd countrycode lnCGDPpc_2000usd region post oecd before* after* ///
ln_nonhydrogdp yrs_schooling infant_mortality fragmentation fragmentation laborforce gdp_perworker_WPD capital_perworker_WPD tfp discovery_year first_production_year gas_TJ ///
land_area democracy_score investment_to_gdp real_oil_price current_oil_price current_gas_price total_barrels treat_dummy cgdp_pwt price_level oil_metrictons barrelsperton lngdp_pwt
 

save "C:\Users\Brock.Smith\Desktop\resource curse\replication\replication_dataset_main.dta",replace



