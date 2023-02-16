
use "C:\Users\Brock.Smith\Desktop\resource curse\dtas\final data set-extra Ts",clear

drop if droprich==1 |soviet==1 

rename country1 countrycode
rename Mlngdp lnGDPpc_Madd


keep post country countrycode region year lnGDPpc_Madd


save "C:\Users\Brock.Smith\Desktop\resource curse\replication\replication_dataset_increased_Tgroup.dta",replace
