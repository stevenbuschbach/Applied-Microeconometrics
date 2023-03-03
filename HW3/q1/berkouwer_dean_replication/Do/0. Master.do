set more off
version 12.0 

local dofiles "${main}/Do"

local raw 	"${main}/Data/Raw/"
local raw2020 	"${main}/Data/Raw/2020"
local datamed "${main}/Data/Med/"
local dataclean "${main}/Data/Clean"
local raw_confidential "${main}/Data/Raw/From Confidential"

local tables "${main}/Results/Tables"
local graphs "${main}/Results/Figures"

* Universal graph settings
local white 	plotregion(color(white)) graphregion(color(white)) bgcolor(white)
