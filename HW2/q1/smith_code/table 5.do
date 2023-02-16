cd "C:\Users\Brock.Smith\Desktop\resource curse\replication

use replication_dataset_main,clear

xtset countrycode year

gen nopwt=0
replace nopwt=1 if inlist(country,"Oman","Gabon","Libya","Algeria","Yemen")    //this ids T countries without before data in pwt.


gen oilbarrels=barrelsperton*oil_metrictons*1000
gen oilvalue=oilbarrels*current_oil_price

gen gasvalue = current_gas_price*gas_TJ

gen comm_value=oilvalue+gasvalue
replace comm_value=. if year>=2009

gen comm_share=comm_value/(cgdp_pwt*(price_level/100)*pop*1000)
gen realgdp_nores=(1-comm_share)*realgdp_pwt

xi:xtreg ln_nonhydrogdp i.region*i.year post if country!="Botswana" & country!="Equatorial Guinea" & year<2009 & nopwt==0, fe vce(cluster countrycode)
xi:xtreg ln_nonhydrogdp i.region*i.year post if country!="Botswana" & country!="Equatorial Guinea" & year<2009 & nopwt==0 & oecd==0, fe vce(cluster countrycode)
xi:xtreg ln_nonhydrogdp i.region*i.year post if year<2009 & nopwt==0 & oecd==1, fe vce(cluster countrycode)






