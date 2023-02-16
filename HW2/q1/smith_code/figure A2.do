
cd "C:\Users\Brock.Smith\Desktop\resource curse\replication

use replication_dataset_main,clear

xtset countrycode year

gen Mlngrowth=lnGDPpc_Madd-l.lnGDPpc_Madd

preserve

drop before02 before9m after19_21 after19_21 after22_24 after25_27 after28_31 
xi:xtreg Mlngrowth l.lnGDPpc_Madd i.region*i.year before* after* if (event_time>=-9 & event_time<=17) | event_time==., fe vce(cluster countrycode)   

restore

drop before02 before9m
xi:xtreg Mlngrowth l.lnGDPpc_Madd i.region*i.year before* after* if country!="Equatorial Guinea" & country!="Yemen" & ((event_time>=-9 & event_time<=30) | event_time==.), fe vce(cluster countrycode) 


//note: Figure A2 is the graphical representation of the regressions above.
