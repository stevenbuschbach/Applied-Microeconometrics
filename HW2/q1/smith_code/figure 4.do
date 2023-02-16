
cd "C:\Users\Brock.Smith\Desktop\resource curse\replication

use replication_dataset_main,clear

xtset countrycode year

drop before02 before9m
xi:xtreg lnGDPpc_Madd i.region*i.year before* after* if country!="Equatorial Guinea" & country!="Yemen" & ((event_time>=-9 & event_time<=30) | event_time==.), fe vce(cluster countrycode) 

note: figure 4 is graphical representation of above regression

