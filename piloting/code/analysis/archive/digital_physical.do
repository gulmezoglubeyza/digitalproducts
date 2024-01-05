ssc install missings

clear all
label drop _all
set scheme tab2

local png_stub "output/figures/prolific/digital_physical"

***** Load and prepare
// insheet using "/Users/leolab/Downloads/digital-products_November 22, 2023_08.05.csv", names clear // first round of collection

insheet using "/Users/leolab/Downloads/digital-products_November 27, 2023_08.24.csv", names clear

drop in 1/2
drop if status == "Survey Preview" 	
drop if strpos(consent, "NOT")
destring *, replace
drop minutes_per_day

rename _minutes_digital v119
rename _time_digital v120
rename _selfcontrol_digital v121
rename _wta_digital v122
rename _fomo_digital v123
rename _network_digital v124

rename _time_physical v519
rename _selfcontrol_physical v520
rename _wta_physical v521
rename _fomo_physical v522
rename _network_physical v523

* loop over variable names that are in groups of 4 from 1 to 50,
forvalues i = 1/50 {
	
	local j = 119 + (`i'-1)*6
	local k = `j' + 1
	local l = `j' + 2
	local m = `j' + 3
	local n = `j' + 4
	local o = `j' + 5
	
	rename v`j' minutes`i'
	rename v`k' time`i'
	rename v`l' selfcontrol`i'
	rename v`m' wta`i'
	rename v`n' fomo`i'	
	rename v`o' network`i'	
}

* and from 51 to 100
forvalues i = 51/100 {
	
	local j = 519 + (`i'-51)*5
	local k = `j' + 1
	local l = `j' + 2
	local m = `j' + 3
	local n = `j' + 4
	
	rename v`j' time`i'
	rename v`k' selfcontrol`i'
	rename v`l' wta`i'
	rename v`m' fomo`i'	
	rename v`n' network`i'	
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

******* RESHAPE DATA AND PREPARE PLOT VARIABLES

missings dropvars, force
reshape long usage without minutes time selfcontrol wta fomo network, i(responseid) j(product) string 

destring product, replace
tab product

program label_products
	
	label define productlbl  1 "Temu" 2 "ReelShort" 3 "Lapse" ///
	4 "TikTok" 5 "ChatGPT" 6 "Google" 7 "CapCut" 8 "YouTube" 9 "Instagram" ///
	10 "SHEIN" 11 "HBO Max" 12 "Gmail" 13 "WhatsApp" 14 "Facebook" ///
	15 "Google Maps" 16 "Walmart" 17 "Peacock TV" 18 "Telegram Messenger" ///
	19 "Snapchat" 20 "Threads" 21 "Amazon Shopping" 22 "Spotify" ///
	23 "Cash App" 24 "Netflix" 25 "Google Chrome" 26 "Impulse" ///
	27 "starmatch" 28 "Microsoft Authenticator" 29 "Pinterest" 30 "Uber" ///
	31 "Target" 32 "Messenger" 33 "McDonald's" 34 "Capital One Shopping" ///
	35 "DoorDash" 36 "Reddit" 37 "The Roku App" 38 "Shop" ///
	39 "Amazon Prime Video" 40 "Ticketmaster" 41 "Discord" 42 "Nike" ///
	43 "Duolingo" 44 "GoWish" 45 "Google Photos" 46 "PayPal" ///
	47 "Life360" 48 "Lemon8" 49 "Disney+" 50 "Domino's Pizza USA" ///
	51 "Petroleum Products" 52 "Automobiles" 53 "Smartphones" ///
	54 "Pharmaceuticals" 55 "Consumer Electronics" ///
	56 "Fashion Apparel" 57 "Health Supplements" ///
	58 "Cosmetics" 59 "Air Travel" ///
	60 "Plastic Products" 61 "Furniture" ///
	62 "Games" 63 "Agricultural Products" ///
	64 "Medical Devices" 65 "Electric Kitchen Appliances" ///
	66 "Sportswear" 67 "Home Appliances" ///
	68 "Jewelry" 69 "Hairstyling Tools" ///
	70 "Footwear" 71 "Books" ///
	72 "Sports Equipment" 73 "Musical Instruments" ///
	74 "Baby Products" 75 "Power Tools" ///
	76 "Office Supplies" 77 "Tobacco Products" ///
	78 "Fine Art" 79 "Paints and Coatings" ///
	80 "Bicycles" 81 "Luxury Goods" ///
	82 "Gardening Equipment" 83 "Stationery Products" ///
	84 "Leather Goods" 85 "Pet Products" ///
	86 "Watches" 87 "Cleaning Products" ///
	88 "Glass Products" 89 "Party Supplies" ///
	90 "Bedding and Linens" 91 "Camping Gear" ///
	92 "Perfumes and Fragrances" 93 "Batteries" 94 "Mattresses" ///
	95 "Fitness Equipment" 96 "Photographic Equipment" ///
	97 "Natural Gas" 98 "Towels" ///
	99 "Kitchenware" 100 "Firearms and Ammunition"

	label values product productlbl
end

label_products

* Keep only observations with answers
drop if missing(usage)

* Generate categories: digital vs physical
gen category = 1 if inrange(product, 1, 50)
replace category = 2 if inrange(product, 51, 100)
label define categorylbl 1 "Digital" 2 "Non-Digital"
label values category categorylbl

* Distinguish between social and individual digital platforms
generate social = 2 if category == 1 // values are reversed to keep labeling consistent with previous code
replace social = 1 if inlist(product, 2, 4, 9, 13, 14, 18, 19, 20, 29, 32, 36, 41, 48)
label define sociallbl 1 "Social" 2 "Individual" 
label values social sociallbl 

* Usage
gen uses_product = 0 
replace uses_product = 100 if usage != "Not at all"
label define userlbl 0 "Non-user" 100 "User"
label values uses_product userlbl

* Live without
gen without_n = 0 
replace without_n = 100 if without == "World  without"
label define without_lbl 0 "With" 100 "Without"
label values without_n without_lbl

* Self control
gen selfcontrol_n = .
replace selfcontrol_n = 0 if regexm(selfcontrol, "including")
replace selfcontrol_n = 100 if regexm(selfcontrol, "except")
label define selfcontrol_lbl 0 "Self control" 100 "No self control"
label values selfcontrol_n selfcontrol_lbl

* Fomo
gen fomo_n = .
replace fomo_n = 100 if regexm(fomo, "worse")
replace fomo_n = 0 if !regexm(fomo, "worse")
label define fomolbl 0 "No FOMO" 100 "FOMO"
label values fomo_n fomolbl

* Network
gen network_n = .
replace network_n = 0 if network == "Yes"
replace network_n = 100 if network == "No"
label define networklbl 0 "Network Effects" 100 "Network Effects"
label values network_n networklbl

preserve
	contract product, freq(product_frequency)
	sum product_frequency
restore	

preserve
	keep if uses_product == 100
	contract product, freq(product_frequency)
	sum product_frequency
restore	

tab category if uses_product == 100

********** OUTPUT GRAPHS

*** usage	
graph hbar uses_product if category == 1, over(product, label(labsize(tiny))) ///
	ytitle(Platform usage (%), size(medium)) ///
	ylabel(0(20)100, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(tiny) format(%9.2f))
graph export "`png_stub'/usage_by_product_digital.png", replace	

graph hbar uses_product if category == 2, over(product, label(labsize(tiny))) ///
	ytitle(Platform usage (%), size(medium)) ///
	ylabel(0(20)100, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(tiny) format(%9.2f))
graph export "`png_stub'/usage_by_product_nondigital.png", replace	

cibar uses_product, over(category) ///
	gr(ytitle(Platform usage (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(6) blsize(medlarge)
graph export "`png_stub'/usage_by_category.png", replace	

*** without

cibar without_n, over(category) ///
	gr(ytitle(Prefers world without (%), size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/live_without_by_category.png", replace	

cibar without_n, over(uses_product category) ///
	gr(ytitle(Prefers world without (%), size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/live_without_by_category_usage.png", replace	

cibar without_n if category == 1, over(uses_product social) ///
	gr(ytitle(Prefers world without (%), size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/live_without_digital_by_social_usage.png", replace	

graph hbar without_n if category == 1, over(product, label(labsize(tiny))) ///
	ytitle("Live without (%)", size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))

cibar without_n if category == 1, over(product uses_product) ///
	gr(ytitle(Prefers world without (%), size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)

**** time
graph hbar time if category == 1, over(product, label(labsize(tiny))) ///
	ytitle("Average usage per month" "(Days)", size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
graph export "`png_stub'/time_by_product_digital.png", replace		

graph hbar time if category == 2, over(product, label(labsize(tiny))) ///
	ytitle("Average usage per month" "(Days)", size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
graph export "`png_stub'/time_by_product_nondigital.png", replace		
	
cibar time, over(category) ///
	gr(ytitle("Average usage per month" "(Days)", size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)	
graph export "`png_stub'/time_by_category.png", replace	

* minutes
graph hbar minutes if category == 1, over(product, label(labsize(tiny))) ///
	ytitle("Average usage per day" "(Minutes)", size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
graph export "`png_stub'/minutes_by_product_digital.png", replace	

cibar minutes if category == 1, over(social) ///
	gr(ytitle("Average usage per day" "(Minutes)", size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)	
graph export "`png_stub'/minutes_by_social.png", replace	

cibar minutes if category == 1, over(without_n social) ///
	gr(ytitle("Average usage per day" "(Minutes)", size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)	
graph export "`png_stub'/minutes_by_social_livewithout.png", replace
	
**** self control
graph hbar selfcontrol_n if category == 1, over(product, label(labsize(tiny))) ///
	ytitle(Self control problems (%), size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
graph export "`png_stub'/selfcontrol_by_product_digital.png", replace	

graph hbar selfcontrol_n if category == 2, over(product, label(labsize(tiny))) ///
	ytitle(Self control problems (%), size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
graph export "`png_stub'/selfcontrol_by_product_nondigital.png", replace		
	
cibar selfcontrol_n, over(category) ///
	gr(ytitle(Self control problems (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)	
graph export "`png_stub'/selfcontrol_by_category.png", replace		

cibar selfcontrol_n if category == 1, over(social) ///
	gr(ytitle(Self control problems (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)	
graph export "`png_stub'/selfcontrol_digital_by_social.png", replace		
		
*** wta
replace wta = 1000 if wta > 1000

graph hbar wta if category == 1, over(product, label(labsize(tiny))) ///
	ytitle(Self control problems (%), size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
graph export "`png_stub'/wta_by_product_digital.png", replace	

graph hbar wta if category == 2, over(product, label(labsize(tiny))) ///
	ytitle(Self control problems (%), size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
graph export "`png_stub'/wta_nondigital.png", replace	

cibar wta, over(category) ///
	gr(ytitle(WTA to deactivate (USD), size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on)  blposition(12) blsize(medlarge)		
graph export "`png_stub'/wta_by_category.png", replace			

**** fomo
graph hbar fomo_n if category == 1, over(product, label(labsize(tiny))) ///
	ytitle(FOMO (%), size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
graph export "`png_stub'/fomo_by_product_digital.png", replace	

graph hbar fomo_n if category == 2, over(product, label(labsize(tiny))) ///
	ytitle(FOMO (%), size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
graph export "`png_stub'/fomo_by_product_nondigital.png", replace	

cibar fomo_n, over(category) ///
	gr(ytitle(FOMO (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on)  blposition(12) blsize(medlarge)		
graph export "`png_stub'/fomo_by_category.png", replace	

cibar fomo_n if category == 1, over(social) ///
	gr(ytitle(FOMO (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on)  blposition(12) blsize(medlarge)		
graph export "`png_stub'/fomo_digital_by_social.png", replace			
	
**** network
graph hbar network_n if category == 1, over(product, label(labsize(tiny))) ///
	ytitle(Network Effects (%), size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
graph export "`png_stub'/network_by_product_digital.png", replace	

graph hbar network_n if category == 2, over(product, label(labsize(tiny))) ///
	ytitle(Network Effects (%), size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
graph export "`png_stub'/network_by_product_nondigital.png", replace	

cibar network_n, over(category) ///
	gr(ytitle(Network Effects (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on)  blposition(12) blsize(medlarge)		
graph export "`png_stub'/network_by_category.png", replace			
	
cibar network_n if category == 1, over(social) ///
	gr(ytitle(Network Effects (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on)  blposition(12) blsize(medlarge)		
graph export "`png_stub'/network_by_social.png", replace	
