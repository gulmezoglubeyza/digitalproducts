ssc install missings

clear all
label drop _all
set scheme tab2

local png_stub "output/figures/prolific/digital_social_category"

***** Load and prepare
// insheet using "/Users/leolab/Downloads/digital-products_November 22, 2023_08.05.csv", names clear // first round of collection

insheet using "/Users/leolab/Downloads/digital-social-categories_December 5, 2023_10.43.csv", names clear

drop in 1/2
drop if status == "Survey Preview" 	
drop if strpos(consent, "NOT")
destring *, replace

rename _network_digital_1 v71
rename _interaction_digital_1 v72
rename _selfcontrol_digital v73
rename _minutes_digital v74
rename _time_digital v75
rename _wta_digital v76

rename _network_physical_1 v309
rename _interaction_physical_1 v310
rename _selfcontrol_physical v311
rename _time_physical v312
rename _wta_physical v313

* loop over variable names that are in groups of 4 from 1 to 50,
forvalues i = 1/26 {
	
	local j = 71 + (`i'-1)*6
	local k = `j' + 1
	local l = `j' + 2
	local m = `j' + 3
	local n = `j' + 4
	local o = `j' + 5
	
	rename v`j' network`i'
	rename v`k' interaction`i'
	rename v`l' selfcontrol`i'
	rename v`m' minutes`i'
	rename v`n' time`i'	
	rename v`o' wta`i'	
}

* and from 51 to 100
forvalues i = 27/66 {
	
	local j = 309 + (`i'-27)*5
	local k = `j' + 1
	local l = `j' + 2
	local m = `j' + 3
	local n = `j' + 4
	
	rename v`j' network`i'
	rename v`k' interaction`i'
	rename v`l' selfcontrol`i'
	rename v`m' time`i'	
	rename v`n' wta`i'	
}

forvalues i = 1/26 {
	
	rename usage_month_digital_`i' usage`i'
	rename without_digital_`i' without`i'
	
}

forvalues i = 27/66 {
	
	local j = `i' - 26
	
	rename usage_month_physical_`j' usage`i'
	rename without_physical_`j' without`i'
	
}

******* RESHAPE DATA AND PREPARE PLOT VARIABLES

missings dropvars, force
reshape long usage without network interaction selfcontrol minutes time  wta, i(responseid) j(product) string 

destring product, replace
tab product

program label_products
	
	label define productlbl  1 "E-commerce Platforms" 2 "Social Media Platforms" 3 "Streaming Platforms" ///
	4 "Messaging and Communication Platforms" 5 "Video and Photo Editing Apps" 6 "Music and Audio Streaming Platforms" ///
	7 "Financial Service Platforms" 8 "Digital Security Tools" 9 "Mobile and Video Games" 10 "Online News Platforms" ///
	11 "Event Tickets and Resale Platforms" 12 "Online Food Delivery Apps" 13 "Ride-sharing Apps" 14 "Cloud Storage Services" ///
	15 "Navigation Apps" 16 "Work-Related Apps" 17 "Fitness Apps" 18 "Meditation Apps" 19 "Online Education Platforms" ///
	20 "Personal Productivity Apps" 21 "Travel and Tourism Apps" 22 "Food and Cooking Apps" 23 "Shopping and Fashion Apps" ///
	24 "Dating and Relationship Apps" 25 "Professional Networking and Career Apps" 26 "Book Reading Apps" 27 "Suits" ///
	28 "Watches" 29 "Jewelry" 30 "Sportswear" 31 "Footwear" 32 "Textbooks and Encyclopedias" 33 "Computers" ///
	34 "Tobacco products" 35 "Hair products" 36 "Dental and shaving products" 37 "Deodorant and sanitary products" ///
	38 "Electric personal care appliances" 39 "Cosmetic products" 40 "Cologne/Perfume" 41 "Stationary products" ///
	42 "Luggage" 43 "Infants' equipment" 44 "Televisions" 45 "Audio recorders and speakers" 46 "Pet supplies" ///
	47 "Sports vehicles" 48 "Boats" 49 "Bicycles" 50 "Sports equipment" 51 "Hunting, fishing and camping gear" ///
	52 "Film and photographic supplies" 53 "Toys" 54 "Tabletop games" 55 "Music instruments" 56 "Club dues/fees" ///
	57 "Movie theaters" 58 "Theater plays" 59 "Concerts" 60 "Sporting events" 61 "Newspapers and magazines" ///
	62 "Books" 63 "Automobiles" 64 "Commercial flights" 65 "Intercity bus travel" 66 "Intercity train travel"


	label values product productlbl
end

label_products

* Keep only observations with answers
drop if missing(usage)

* Generate categories: digital vs physical
gen category = 1 if inrange(product, 1, 26)
replace category = 2 if inrange(product, 27, 66)
label define categorylbl 1 "Digital" 2 "Non-Digital"
label values category categorylbl

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

* Network
gen network_n = .
replace network_n = 1 if network == "Strongly disagree"
replace network_n = 2 if network == "Somewhat disagree"
replace network_n = 3 if network == "Neither agree nor disagree"
replace network_n = 4 if network == "Somewhat agree"
replace network_n = 5 if network == "Strongly agree"

sum network_n, d
local median = r(p50)
generate social = cond(network_n > `median', 100, 0)
replace social = . if missing(network_n)

label define networklbl 0 "Network Effects" 100 "Network Effects"
label values social networklbl

* Self control
gen selfcontrol_n = .
replace selfcontrol_n = 0 if regexm(selfcontrol, "including")
replace selfcontrol_n = 100 if regexm(selfcontrol, "except")
label define selfcontrol_lbl 0 "Self control" 100 "No self control"
label values selfcontrol_n selfcontrol_lbl


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
