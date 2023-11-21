clear all
label drop _all
set scheme tab2

local png_stub "output/figures/prolific/first5"

***** Load and prepare
insheet using "/Users/leolab/Downloads/digital-products_November 21, 2023_10.40.csv", names clear // with columns showing order

drop in 1/2
// drop if status == "Survey Preview" 	
// drop if strpos(consent, "NOT")
destring *, replace

rename _time_digital v119
rename _selfcontrol_digital v120
rename _wta_digital v121
rename _fomo_digital v122

rename _time_physical v419
rename _selfcontrol_physical v420
rename _wta_physical v421
rename _fomo_physical v422

* loop over variable names that are in groups of 4 from 1 to 50,
forvalues i = 1/50 {
	
	local j = 119 + (`i'-1)*4
	local k = `j' + 1
	local l = `j' + 2
	local m = `j' + 3
	
	rename v`j'   time`i'
	rename v`k' selfcontrol`i'
	rename v`l' wta`i'
	rename v`m' fomo`i'	
}

forvalues i = 51/100 {
	
	local j = 419 + (`i'-51)*4
	local k = `j' + 1
	local l = `j' + 2
	local m = `j' + 3
	
	rename v`j' time`i'
	rename v`k' selfcontrol`i'
	rename v`l' wta`i'
	rename v`m' fomo`i'	
}

forvalues i = 1/50 {
	
	rename usage_month_digital_`i' usage`i'
	rename without_digital_`i' without`i'
	
}

forvalues i = 51/100 {
	
	local j = `i' - 50
	rename usage_month_physical_`j' usage`i'
	rename without_physical_`j' without`i'
	
}

// usage* without* time* selfcontrol* wta* fomo*

reshape long usage without time selfcontrol wta fomo, i(responseid) j(platform) string











































