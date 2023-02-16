cd "C:\Users\Brock.Smith\Desktop\resource curse\replication

use replication_dataset_main,clear

xtset countrycode year


bysort countrycode: egen minyearpopx=min(year) if pop!=.
bysort countrycode: egen minyearpop=min(minyearpopx)
gen init_popx=ln(pop) if year==minyearpop
bysort country: egen init_pop=min(init_popx)
drop minyearpopx init_popx

gen init_gdpx=lnGDPpc_Madd if year==1950
bysort country: egen init_gdp=min(init_gdpx)
drop init_gdpx

gen lnfrag=ln(fragmentation)

gen init_infx=infant_mortality if year==1955
bysort country: egen init_inf=min(init_infx)
drop init_infx 
gen lninitinf=ln(init_inf)

gen init_educx=yrs_schooling if year==1950
bysort country: egen init_educ=min(init_educx)
drop init_educx 
gen lninited=ln(init_educ)

gen post_gdp=post*init_gdp
gen post_pop=post*init_pop
gen post_lninf=post*lninitinf
gen post_lneduc=post*lninited
gen post_lnfrag=post*lnfrag

replace post_gdp=0 if post_gdp==. & treat==0
replace post_pop=0 if post_pop==. & treat==0
replace post_lnfrag=0 if treat==0
replace post_lneduc=0 if treat==0
replace post_lninf=0 if treat==0


xi: xtreg lnGDPpc_Madd i.region*i.year post post_pop post_gdp post_lnfrag post_lninf post_lneduc, fe vce(cluster countrycode)   //column 1
xi: xtreg lnGDPpc_Madd i.region*i.year post post_pop post_gdp post_lnfrag post_lninf, fe vce(cluster countrycode)   //column 2
xi: xtreg lnGDPpc_Madd i.region*i.year post post_pop post_gdp post_lnfrag post_lninf post_lneduc if oecd==0, fe vce(cluster countrycode)  //column3
xi: xtreg lnGDPpc_Madd i.region*i.year post post_pop post_gdp post_lnfrag post_lninf if oecd==0, fe vce(cluster countrycode)  //column 4





