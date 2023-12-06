clear all
label drop _all
set scheme tab2

local png_stub "output/figures/prolific/digital_social_categories"

***** Load and prepare
insheet using "data/raw/prolific/digital_social_categories/digital-social-categories_December 6, 2023_10.11_ORDERED.csv", names clear // with rankings

drop in 1/2
drop if status == "Survey Preview" 	
drop if strpos(consent, "NOT")
destring *, replace

rename _network_digital_1 v72
rename _interaction_digital_1 v73
rename _selfcontrol_digital v74
rename _minutes_digital v75
rename _time_digital v76
rename _wta_digital v77

rename _network_physical_1 v311
rename _interaction_physical_1 v312
rename _selfcontrol_physical v313
rename _time_physical v314
rename _wta_physical v315

* loop over variable names that are in groups of 4 from 1 to 50,
forvalues i = 1/26 {
	
	local j = 72 + (`i'-1)*6
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
	
	local j = 311 + (`i'-27)*5
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

tab any_digital // N=26, 18% yes
br which_digital if !missing(which_digital)
tab any_product // N=38, 19% yes
br which_products if !missing(which_products)

**** Identify first 5 products by order

rename usage_month_digital_do  order_digital
rename usage_month_physical_do order_physical

keep responseid usage* without* network* interaction*  selfcontrol* minutes* time* wta* gender age order_*
reshape long usage without network interaction selfcontrol minutes time wta, i(responseid) j(product) string 
missings dropvars, force

split order_digital, parse("|") gen(part_) // split into new variables for each platform
egen first5platforms = concat(part_1 part_2 part_3 part_4 part_5), punct("|") // create new variable containing the first 5
drop part_*
split order_physical, parse("|") gen(part_) // split into new variables for each platform
egen first5products = concat(part_1 part_2 part_3 part_4 part_5), punct("|") // create new variable containing the first 5
drop part_*

	
program label_products
	
	destring product, replace

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
drop if product == 56 //"Club dues/fees", incorrect phrasing (Club memberships)

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

label define networklbl 0 "No network effects" 100 "Network effects"
label values social networklbl

* Interactions
gen interactions_n = .
replace interactions_n = 0 if interaction == "Neutral"
replace interactions_n = 1 if interaction == "Very negative" | interaction == "Negative"
replace interactions_n = 2 if interaction == "Positive" | interaction == "Very positive"

label define interactionslbl 0 "Neutral" 1 "Negative" 2 "Positive"
label values interactions_n interactionslbl

generate pos_int = cond(regexm(interaction, "ositive"), 100, 0)
replace pos_int = . if missing(interaction)
label define positivelbl 0 "Not positive" 100 "Positive"
label values pos_int positivelbl
tab pos_int
tab interaction

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

corr without_n social if category == 1
corr without_n social if category == 2

********** OUTPUT GRAPHS

program figures
syntax, png_stub(string)

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
		barlabel(on) blposition(12) blsize(medlarge)
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

	cibar without_n, over(social category) ///
		gr(ytitle(Prefers world without (%), size(large)) ///
		ylabel(0(20)100, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid) ///
		legend(size(medlarge))) ///
		barlabel(on) blposition(12) blsize(medium)
	graph export "`png_stub'/live_without_by_category_social.png", replace	

	graph hbar without_n if category == 1, over(product, label(labsize(tiny))) ///
		ytitle(Prefers world without (%), size(medium)) ///
		ylabel(0(20)100, labsize(medsmall)) ///
		blabel(bar, position(6) gap(0) size(tiny) format(%9.2f))
	graph export "`png_stub'/live_without_by_product_digital.png", replace	

	graph hbar without_n if category == 2, over(product, label(labsize(tiny))) ///
		ytitle(Prefers world without (%), size(medium)) ///
		ylabel(0(20)100, labsize(medsmall)) ///
		blabel(bar, position(6) gap(0) size(tiny) format(%9.2f))
	graph export "`png_stub'/live_without_by_product_nondigital.png", replace	

	**** network
	graph hbar social if category == 1, over(product, label(labsize(vsmall))) ///
		ytitle(Network Effects (%), size(medium)) ///
		ylabel(, labsize(medsmall)) ///
		blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
	graph export "`png_stub'/network_by_product_digital.png", replace	

	graph hbar social if category == 2, over(product, label(labsize(tiny))) ///
		ytitle(Network Effects (%), size(medium)) ///
		ylabel(, labsize(medsmall)) ///
		blabel(bar, position(6) gap(0) size(tiny) format(%9.2f))
	graph export "`png_stub'/network_by_product_nondigital.png", replace	

	cibar social, over(category) ///
		gr(ytitle(Network Effects (%), size(medlarge)) ///
		ylabel(0(20)100, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
		legend(size(medlarge))) ///
		barlabel(on)  blposition(12) blsize(medlarge)		
	graph export "`png_stub'/network_by_category.png", replace			

	**** interactions

	graph hbar pos_int if category == 1, over(product, label(labsize(vsmall))) ///
		ytitle(Positive interactions on 'social' platforms (%), size(medium)) ///
		ylabel(, labsize(medsmall)) ///
		blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
	graph export "`png_stub'/positivenetwork_by_product_digital.png", replace	

	graph hbar pos_int if category == 2, over(product, label(labsize(tiny))) ///
		ytitle(Positive interactions (%), size(medium)) ///
		ylabel(, labsize(medsmall)) ///
		blabel(bar, position(6) gap(0) size(tiny) format(%9.2f))
	graph export "`png_stub'/positivenetwork_by_product_nondigital.png", replace	

	graph hbar pos_int if category == 1 & social == 100, over(product, label(labsize(vsmall))) ///
		ytitle(Positive interactions on 'social' platforms (%), size(medium)) ///
		ylabel(, labsize(medsmall)) ///
		blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
	graph export "`png_stub'/positivenetwork_by_product_socialdigital.png", replace	

	graph hbar pos_int if category == 2 & social == 100, over(product, label(labsize(tiny))) ///
		ytitle(Positive interactions (%), size(medium)) ///
		ylabel(, labsize(medsmall)) ///
		blabel(bar, position(6) gap(0) size(tiny) format(%9.2f))
	graph export "`png_stub'/positivenetwork_by_product_socialnondigital.png", replace	

	cibar pos_int, over(category) ///
		gr(ytitle(Positive interactions (%), size(medlarge)) ///
		ylabel(0(20)100, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid) ///
		legend(size(medlarge))) ///
		barlabel(on)  blposition(12) blsize(medlarge)		
	graph export "`png_stub'/positivenetwork_by_category.png", replace			

	cibar pos_int, over(social category) ///
		gr(ytitle(Positive interactions (%), size(medlarge)) ///
		ylabel(0(20)100, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid) ///
		legend(size(medlarge))) ///
		barlabel(on)  blposition(12) blsize(medlarge)		
	graph export "`png_stub'/positivenetwork_by_category.png", replace			

	**** time
	graph hbar time if category == 1, over(product, label(labsize(tiny))) ///
		ytitle("Average usage per month" "(Days)", size(medium)) ///
		ylabel(, labsize(medsmall)) ///
		blabel(bar, position(6) gap(0) size(tiny) format(%9.2f))
	graph export "`png_stub'/time_by_product_digital.png", replace		

	graph hbar time if category == 2, over(product, label(labsize(tiny))) ///
		ytitle("Average usage per month" "(Days)", size(medium)) ///
		ylabel(, labsize(medsmall)) ///
		blabel(bar, position(6) gap(0) size(tiny) format(%9.2f))
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
		ytitle(WTA to deactivate (USD), size(medium)) ///
		ylabel(, labsize(medsmall)) ///
		blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
	graph export "`png_stub'/wta_by_product_digital.png", replace	

	graph hbar wta if category == 2, over(product, label(labsize(tiny))) ///
		ytitle(WTA to deactivate (USD), size(medium)) ///
		ylabel(, labsize(medsmall)) ///
		blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
	graph export "`png_stub'/wta_by_product_nondigital.png", replace	

	cibar wta, over(category) ///
		gr(ytitle(WTA to deactivate (USD), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
		legend(size(medlarge))) ///
		barlabel(on)  blposition(12) blsize(medlarge)		
	graph export "`png_stub'/wta_by_category.png", replace			

end

figures, png_stub("`png_stub'")

* Keep only first 5
decode product, generate(product_name)
drop if strpos(first5platforms, product_name) == 0 & category == 1
drop if strpos(first5products, product_name) == 0  & category == 2

local png_stub "output/figures/prolific/digital_social_categories/first5"
figures, png_stub("`png_stub'")
