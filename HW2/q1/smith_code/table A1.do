
cd "C:\Users\Brock.Smith\Desktop\resource curse\replication

use replication_dataset_tableA1,clear

drop if first_disc_year<1950  

gen lnarea=ln(land_area)
gen lnpop=ln(pop)

xi: reg discovery_dummy i.region lnpop if year==1950,r     //column 1
xi: reg discovery_dummy i.region lnpop lnarea if year==1950,r     //column 2
xi: reg discovery_dummy i.region lnGDPpc_Madd if year==1950,r     //column 3 
xi: reg discovery_dummy i.region democracy_score if year==1960 & (first_disc>=1960 | first_disc==.) & democ>=0,r     //column 4
xi: reg discovery_dummy i.region yrs_schooling if year==1950,r     //column 5   
xi: reg discovery_dummy i.region investment_to_gdp if year==1960 & (first_disc>=1960 | first_disc==.),r   //column 6 
xi: reg discovery_dummy i.region fragmentation if year==1990,r     //column 7
xi: reg discovery_dummy i.region lnpop lnarea lnGDPpc_Madd democracy_score yrs_schooling investment_to_gdp fragmentation if year==1960 & (first_disc>=1960 | first_disc==.) & democ>=0,r     //column 8


