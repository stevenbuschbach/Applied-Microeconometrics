
cd "C:\Users\Brock.Smith\Desktop\resource curse\replication

use replication_dataset_main,clear

xtset countrycode year

gen droplag=0
replace droplag=1 if inrange(year,discovery_year,first_production_year) & event_year!=. & country!="Botswana" & country!="Netherlands"

gen droplag2=0
replace droplag2=1 if inrange(year,discovery_year,event_year) & event_year!=. & country!="Botswana" & country!="Netherlands"



****Table A3, panel B

drop if inlist(country,"Ecuador", "New Zealand", "Nigeria", "Syria", "Yemen")
xi:xtreg lnGDPpc_Madd i.region*i.year post, fe vce(cluster countrycode)   //panel A column 1

preserve
use replication_dataset_increased_Tgroup,clear
xtset countrycode year
xi:xtreg lnGDPpc_Madd i.region*i.year post, fe vce(cluster countrycode)   //panel A column 2
restore 



xi:xtreg lnGDPpc_Madd i.region*i.year post if droplag==0, fe vce(cluster countrycode)     //panel A column 3
xi:xtreg lnGDPpc_Madd i.region*i.year post if droplag2==0, fe vce(cluster countrycode)    //panel A column 4



****Table A3, panel B

qui xi:xtreg lnGDPpc_Madd i.region*i.year post, fe vce(cluster countrycode)    //just to set e(sample)
qui xi:xtreg lngdp_pwt post if e(sample)==1, fe vce(cluster countrycode)         
qui xi:xtreg lnGDPpc_Madd post if e(sample)==1, fe vce(cluster countrycode)
xi:xtreg lngdp_pwt i.region*i.year post if e(sample)==1, fe vce(cluster countrycode)     //panel B column 1
xi:xtreg lnGDPpc_Madd i.region*i.year post if e(sample)==1, fe vce(cluster countrycode)    //panel B column 2


qui xi:xtreg lnGDPpc_Madd i.region*i.year post, fe vce(cluster countrycode)    //just to set e(sample)
qui xi:xtreg lnCGDPpc_2000usd post if e(sample)==1, fe vce(cluster countrycode)   
qui xi:xtreg lnGDPpc_Madd post if e(sample)==1, fe vce(cluster countrycode) 
xi:xtreg lnCGDPpc_2000usd i.region*i.year post if e(sample)==1, fe vce(cluster countrycode)  //panel B column 3
xi:xtreg lnGDPpc_Madd i.region*i.year post if e(sample)==1, fe vce(cluster countrycode)    //panel B column 4



****Table A4

gen Mlngrowth=lnGDPpc_Madd-l.lnGDPpc_Madd

xi:xtreg lnGDPpc_Madd i.region*i.year i.countrycode|year post, fe vce(cluster countrycode)
xi:xtreg Mlngrowth i.region*i.year post l.lnGDPpc_Madd, fe vce(cluster countrycode)

