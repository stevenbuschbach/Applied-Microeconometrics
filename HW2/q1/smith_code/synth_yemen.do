

cd "C:\Users\Brock.Smith\Desktop\resource curse\replication

use replication_dataset_main,clear

drop if country=="Cote d`Ivoire"
xtset countrycode year

encode region,g(regioncode)

sum countrycode if country=="Yemen"
local cty=r(mean)

sum regioncode if country=="Yemen"
local reg=r(mean)

sum event_year if country=="Yemen"
local year=r(mean)


drop if country=="Puerto Rico" //for ecuador

local t1=`year'-1
local t2=`year'-2
local t3=`year'-3
local t4=`year'-4
local t5=`year'-5
local t6=`year'-6
local t7=`year'-7
local t8=`year'-8
local t9=`year'-9
local t10=`year'-10

drop if regioncode!=`reg'
drop if GDPpc_Madd==.
drop if treat==1 & countrycode!=`cty'
xtset countrycode year
label var GDPpc_Madd "GDP per capita"
rename GDPpc_Madd GDP_per_capita

synth GDP_per_capita GDP_per_capita(`t1') GDP_per_capita(`t3') GDP_per_capita(`t5') GDP_per_capita(`t7') pop(`t1') frag(`t1'), ///
trunit(`cty') trperiod(`year') figure 




