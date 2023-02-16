
cd "C:\Users\Brock.Smith\Desktop\resource curse\replication

use replication_dataset_main,clear

xtset countrycode year

****Table 2

xi:xtreg lnGDPpc_Madd i.region*i.year post, fe vce(cluster countrycode)  //column 1
xi:xtreg lnGDPpc_Madd i.region*i.year post if oecd==0, fe vce(cluster countrycode)  //column 2
xi:xtreg lnGDPpc_Madd i.region*i.year post if oecd==1, fe vce(cluster countrycode)  //column 3


****Table 3

drop before02 before9m after19_21 after19_21 after22_24 after25_27 after28_31

xi:xtreg lnGDPpc_Madd i.region*i.year before* after* if (event_time>=-9 & event_time<=17) | event_time==., fe vce(cluster countrycode)  //column 1
xi:xtreg lnGDPpc_Madd i.region*i.year before* after* if oecd==0 & ((event_time>=-9 & event_time<=17) | event_time==.), fe vce(cluster countrycode)   //column 2
xi:xtreg lnGDPpc_Madd i.region*i.year before* after* if oecd==1 & ((event_time>=-9 & event_time<=17) | event_time==.), fe vce(cluster countrycode)   //column 3


//note: figure 4 is graphical representation of table 3.














