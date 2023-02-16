

cd "C:\Users\Brock.Smith\Desktop\resource curse\replication

use replication_dataset_main,clear

xtset countrycode year

gen totk=laborforce*capital_perworker_WPD
gen lnk=ln(totk)

gen lntfp=ln(tfp)
gen lnlf=ln(laborforce)


drop before02 before9m after19_21 after19_21 after22_24 after25_27 after28_31 


xi:xtreg lnk i.region*i.year before* after* if ((event_time>=-9 & event_time<=17) | event_time==.) & oecd==0, fe vce(cluster countrycode)   //capital stock
xi:xtreg lntfp i.region*i.year before* after* if ((event_time>=-9 & event_time<=17) | event_time==.) & oecd==0, fe vce(cluster countrycode) //tfp
xi:xtreg lnlf i.region*i.year before* after* if ((event_time>=-9 & event_time<=17) | event_time==.)  & oecd==0, fe vce(cluster countrycode) //labor force



use replication_dataset_education,clear

xtset countrycode year

drop before10m before05 after25p

xi:xtreg yrs_schooling i.year before* after* if ((event_time>=-10 & event_time<=24) | event_time==.) & oecd==0, fe vce(cluster countrycode)  //years schooling



//note: figure 6 is the graphical representation of the four regressions executed here. 


