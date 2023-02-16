
use "C:\Users\Brock.smith\Desktop\resource curse\dtas\final data set mortality only.dta", clear

drop if year<1950
drop if droprich==1
drop if soviet==1

replace schoolvar=yr_sch
rename yr_sch yrs_schooling
rename country1 countrycode

keep country year event_year event_time before* after* oecd yrs_schooling countrycode

save "C:\Users\Brock.Smith\Desktop\resource curse\replication\replication_dataset_education.dta",replace





