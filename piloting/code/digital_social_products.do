clear all
label drop _all
set scheme tab2

local png_stub "output/figures/prolific/digital_social_products"

***** Load and prepare
insheet using "data/raw/prolific/digital_social_products/digital-social-products_December 8, 2023_10.18.csv", names clear

drop in 1/2
drop if status == "Survey Preview" 	
drop if strpos(consent, "NOT")
destring *, replace

rename _interaction_digital_1 v137
rename _selfcontrol_digital v138
rename _minutes_digital v139
rename _time_digital v140
rename _wta_digital v141

rename _interaction_physical_1 v588
rename _selfcontrol_physical v589
rename _time_physical v590
rename _wta_physical v591

* loop over variable names that are in groups of 4 from 1 to 50,
forvalues i = 1/59 {
	
	local j = 137 + (`i'-1)*5
	local k = `j' + 1
	local l = `j' + 2
	local m = `j' + 3
	local n = `j' + 4
	
	rename v`j' interaction`i'
	rename v`k' selfcontrol`i'
	rename v`l' minutes`i'
	rename v`m' time`i'	
	rename v`n' wta`i'	
	
}

* and from 51 to 100
forvalues i = 60/136 {
	
	local j = 588 + (`i'-60)*4
	local k = `j' + 1
	local l = `j' + 2
	local m = `j' + 3
	
	rename v`j' interaction`i'
	rename v`k' selfcontrol`i'
	rename v`l' time`i'	
	rename v`m' wta`i'	
}

forvalues i = 1/59 {
	
	rename usage_month_digital_`i' usage`i'
	rename without_digital_`i' without`i'
	
}

forvalues i = 60/136 {
	
	local j = `i' - 59
	
	rename usage_month_physical_`j' usage`i'
	rename without_physical_`j' without`i'
	
}

******* RESHAPE DATA AND PREPARE PLOT VARIABLES

missings dropvars, force
reshape long usage without interaction selfcontrol minutes time  wta, i(responseid) j(product) string 

destring product, replace
tab product

program label_products
	
	label define productlbl  1 "Facebook" 2 "Pinterest" 3 "Instagram" 4 "LinkedIn" 5 "Twitter" ///
	6 "Snapchat" 7 "YouTube" 8 "WhatsApp" 9 "Reddit" 10 "TikTok" 11 "Nextdoor" 12 "Messenger" ///
	13 "Telegram Messenger" 14 "Amazon Shopping" 15 "eBay" 16 "HBO Max" 17 "CapCut" ///
	18 "Adobe Premiere Rush" 19 "Spotify" 20 "Apple Music" 21 "Cash App" 22 "PayPal" ///
	23 "Microsoft Authenticator" 24 "LastPass" 25 "Clash of Clans" 26 "Candy Crush Saga" ///
	27 "BBC News" 28 "Buzzfeed" 29 "Ticketmaster" 30 "Eventbrite" 31 "DoorDash" 32 "UberEats" ///
	33 "Uber" 34 "Lyft" 35 "Dropbox" 36 "Google Drive" 37 "Google Maps" 38 "Apple Maps" ///
	39 "Microsoft Office" 40 "Slack" 41 "MyFitnessPal" 42 "Strava" 43 "Headspace" 44 "Calm" ///
	45 "Duolingo" 46 "Khan Academy" 47 "Evernote" 48 "Trello" 49 "Airbnb" 50 "Booking.com" ///
	51 "Allrecipes Dinner Spinner" 52 "Yummly" 53 "Temu" 54 "SHEIN" 55 "Tinder" 56 "Bumble" ///
	57 "Indeed" 58 "Kindle" 59 "Audible" 60 "Hugo Boss suits" 61 "Nordstrom suits" 62 "Tiffany & Co. jewelry" ///
	63 "Ray-Ban sunglasses" 64 "Nike sportswear" 65 "Old Navy sportswear" 66 "Nike sneakers" ///
	67 "Timberland boots" 68 "Oxford University Press textbooks" 69 "Britannica encyclopedias" ///
	70 "MacBook computers" 71 "Dell computers" 72 "Marlboro tobacco" 73 "Montecristo cigars" ///
	74 "Pantene shampoos" 75 "GHD hair straighteners" 76 "Oral-B toothbrushes" 77 "Gillette razors" ///
	78 "Nivea deodorants" 79 "Philips electric shavers" 80 "Dyson hair dryers" 81 "MAC lipsticks" ///
	82 "Clinique moisturizers" 83 "Chanel No. 5 perfumes" 84 "Dior Sauvage colognes" 85 "Moleskine notebooks" ///
	86 "Pilot G2 pens" 87 "Samsonite luggages" 88 "Herschel backpacks" 89 "Graco strollers" ///
	90 "Dr. Brown's baby bottles" 91 "Samsung TVs" 92 "LG TVs" 93 "JBL speakers" 94 "Bose speakers" ///
	95 "Purina pet food" 96 "KONG dog toys" 97 "ATV sports vehicles" 98 "Sea-Doo personal watercrafts" ///
	99 "Bayliner boats" 100 "Boston Whaler boats" 101 "Trek bicycles" 102 "E-bicycles" 103 "Wilson tennis racquets" ///
	104 "Callaway golf clubs" 105 "Cabela's hunting gear" 106 "Bass Pro Shops fishing gear" 107 "Kodak films" ///
	108 "Canon cameras" 109 "LEGO toys" 110 "Fisher-Price toys" 111 "Monopoly games" 112 "UNO card games" ///
	113 "Gibson guitars" 114 "Yamaha pianos" 115 "YMCA club memberships" 116 "Planet Fitness gym memberships" ///
	117 "AMC Theatres tickets" 118 "Regal Cinemas tickets" 119 "Broadway musical tickets" ///
	120 "Stand-up comedy show tickets" 121 "Live Nation tickets" 122 "Ticketmaster tickets" ///
	123 "FIFA World Cup events" 124 "Super Bowl events" 125 "The New York Times newspapers" ///
	126 "National Geographic magazines" 127 "novels" 128 "nonfiction books" 129 "Toyota automobiles" ///
	130 "Maserati sports cars" 131 "American Airlines commercial flight tickets" 132 "Business class flight tickets" ///
	133 "Greyhound intercity bus tickets" 134 "Megabus intercity bus tickets" 135 "Amtrak intercity train tickets" ///
	136 "public transportation tickets"
	
	label values product productlbl
	
end

label_products

* Keep only observations with answers
drop if missing(usage)
drop if product == 122

* Generate categories: digital vs physical
gen category = 1 if inrange(product, 1, 59)
replace category = 2 if inrange(product, 60, 136)
label define categorylbl 1 "Digital" 2 "Non-Digital"
label values category categorylbl

* Define social vs non social for digital products
generate social_platform = 0 if category == 1
// replace social_platform = 1 if inlist(product, 1, 2, 3, 4, 5, 6, 8, /// 
// 								9, 10, 11, 12, 13, 19, 20, 21, 22, /// 
// 								25, 26, 29, 30, 33, 34,40, 41, 42, /// 
// 								43, 44, 45, 47, 48, 49, 50, 51, 52, /// 
// 								55, 56, 57, 58, 59) // 

replace social_platform = 1 if inlist(product, 1, 2, 3, 4, 5, 6, 8, /// 
								9, 10, 11, 12, 13, 55, 56, 57) // 

label define socialplatform_lbl 0 "Non-Social" 1 "Social"
label values social_platform socialplatform_lbl 

* Define social media
generate social_media = 0 if social_platform == 1
replace social_media = 1 if inlist(product, 1, 2, 3, 4, 5, 6, 8, ///
								9, 10, 11)

label define socialmedia_lbl 0 "Other social platforms" 1 "Social media"
label values social_media socialmedia_lbl 

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

preserve
	keep if uses_product == 100 & category == 1
	contract product, freq(product_frequency)
	sum product_frequency
restore	

preserve
	keep if uses_product == 100 & category == 2
	contract product, freq(product_frequency)
	sum product_frequency
restore	

preserve
	keep if uses_product == 100 & social_platform == 1 & social_media == 0
	contract product, freq(product_frequency)
	sum product_frequency
restore	

preserve
	keep if uses_product == 100 & social_platform == 1 & social_media == 1
	contract product, freq(product_frequency)
	sum product_frequency
restore	

tab category if uses_product == 100
tab product 
tab product if uses_product == 100

gen count1 = 1
gen count_user = 1 if uses_product == 100

egen freq_var = total(count1), by(product) 
egen user_freq_var = total(count_user), by(product) 
gen user_percent = (user_freq_var / freq_var) 

corr wta minutes // 0.1014
corr wta time // 0.04

gen usage_n = .
replace usage_n = 0 if usage == "Not at all"
replace usage_n = 1 if usage == "Once"
replace usage_n = 2 if usage == "Once a week"
replace usage_n = 3 if usage == "Twice a week"
replace usage_n = 4 if usage == "Every day"

egen sum_usage = total(usage_n), by(product) 

preserve
	keep product user_percent sum_usage
	duplicates drop
	gsort -user_percent
	br product user_percent
	
	gsort -sum_usage
	br product sum_usage
restore



********** OUTPUT GRAPHS

*** usage	
graph hbar uses_product if category == 1, over(product, label(labsize(tiny))) ///
	ytitle(Usage (%), size(medium)) ///
	ylabel(0(20)100, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(tiny) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/usage_by_product_digital.png", width(1000) height(1500) replace	

graph hbar uses_product if category == 2, over(product, label(labsize(tiny))) ///
	ytitle(Usage (%), size(medium)) ///
	ylabel(0(20)100, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(tiny) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/usage_by_product_nondigital.png", width(1000) height(1500) replace	

cibar uses_product, over(category) ///
	gr(ytitle(Usage (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/usage_by_category.png", replace	

cibar uses_product if category == 1, over(social_platform) ///
	gr(ytitle(Usage (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/usage_digital_by_social.png", replace	

cibar uses_product if social_platform == 1, over(social_media) ///
	gr(ytitle(Usage (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/usage_social_by_socialmedia.png", replace	

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

cibar without_n if user_freq_var > 5, over(uses_product category) ///
	gr(ytitle(Prefers world without (%), size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/live_without_by_category_usage_minuser5.png", replace	

cibar without_n if user_freq_var > 10, over(uses_product category) ///
	gr(ytitle(Prefers world without (%), size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/live_without_by_category_usage_minuser10.png", replace	

cibar without_n if category == 1, over(social_platform) ///
	gr(ytitle("Digital Products:" "Prefers world without (%)", size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/live_without_digital_by_social.png", replace	

cibar without_n if category == 1, over(uses_product social_platform) ///
	gr(ytitle("Digital Products:" "Prefers world without (%)", size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/live_without_digital_by_social_usage.png", replace	

cibar without_n if social_platform == 1, over(social_media) ///
	gr(ytitle("Social Platforms:" "Prefers world without (%)", size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/live_without_digital_by_social_socialmedia.png", replace	

cibar without_n if social_platform == 1, over(uses_product social_media) ///
	gr(ytitle("Social Platforms:" "Prefers world without (%)", size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/live_without_digital_by_social_socialmedia_usage.png", replace	

// graph hbar without_n if category == 1, ///
// 	over(uses_product, label(labsize(half_tiny))) ///
// 	over(product, label(labsize(tiny))) ///
// 	ytitle(Prefers world without (%), size(medium)) ///
// 	ylabel(0(20)100, labsize(medsmall)) ///
// 	blabel(bar, position(6) gap(0) size(tiny) format(%9.2f))  ///
// 	xsize(10cm) ysize(20cm) 
// graph export "`png_stub'/live_without_by_product_usage_digital.png",  width(1000) height(1500) replace	

graph hbar without_n if category == 1, over(product, label(labsize(tiny))) ///
	ytitle(Prefers world without (%), size(medium)) ///
	ylabel(0(20)100, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(tiny) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/live_without_digital_byproduct.png", replace	

graph hbar without_n if category == 2, over(product, label(labsize(tiny))) ///
	ytitle(Prefers world without (%), size(medium)) ///
	ylabel(0(20)100, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(tiny) format(%9.2f))  ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/live_without_nondigital_by_product.png",  width(1000) height(1500) replace	

graph hbar without_n if category == 1 & uses_product == 100, over(product, label(labsize(tiny))) ///
	ytitle(Prefers world without (%)- Users, size(medium)) ///
	ylabel(0(20)100, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(tiny) format(%9.2f))  ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/live_without_digital_byproduct_users.png", replace	

graph hbar without_n if category == 2 & uses_product == 100, over(product, label(labsize(tiny))) ///
	ytitle(Prefers world without (%), size(medium)) ///
	ylabel(0(20)100, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(tiny) format(%9.2f))
graph export "`png_stub'/live_without_nondigital_byproduct_users.png", replace	

**** interactions
graph hbar pos_int if category == 1, over(product, label(labsize(tiny))) ///
	ytitle(Positive interactions (%), size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(tiny) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/positivenetwork_by_product_digital.png", width(1000) height(1500) replace	

graph hbar pos_int if category == 2, over(product, label(labsize(tiny))) ///
	ytitle(Positive interactions (%), size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(tiny) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/positivenetwork_by_product_nondigital.png", width(1000) height(1500) replace	

graph hbar pos_int if category == 1 & social_platform == 1, over(product, label(labsize(vsmall))) ///
	ytitle(Positive interactions on 'social' platforms (%), size(medsmall)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/positivenetwork_by_product_socialdigital.png", width(1000) height(1500) replace	

cibar pos_int, over(category) ///
	gr(ytitle(Positive interactions (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on)  blposition(12) blsize(medlarge)		
graph export "`png_stub'/positivenetwork_by_category.png", replace			

cibar pos_int if category == 1, over(social_platform) ///
	gr(ytitle("Digital products:" "Positive interactions (%)", size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on)  blposition(12) blsize(medlarge)		
graph export "`png_stub'/positivenetwork_digital_by_social.png", replace			
			
cibar pos_int if social_platform == 1, over(social_media) ///
	gr(ytitle("Social platforms:" "Positive interactions (%)", size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on)  blposition(12) blsize(medlarge)		
graph export "`png_stub'/positivenetwork_social_by_socialmedia.png", replace									
			
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

cibar minutes if category == 1, over(social_platform) ///
	gr(ytitle("Average usage per day" "(Minutes)", size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)	
graph export "`png_stub'/minutes_by_social.png", replace	

cibar minutes if category == 1, over(without_n social_platform) ///
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
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/selfcontrol_by_product_digital.png", width(1000) height(1500) replace	


graph hbar selfcontrol_n if category == 2, over(product, label(labsize(tiny))) ///
	ytitle(Self control problems (%), size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/selfcontrol_by_product_nondigital.png", width(1000) height(1500) replace	


cibar selfcontrol_n, over(category) ///
	gr(ytitle(Self control problems (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)	
graph export "`png_stub'/selfcontrol_by_category.png", replace		

cibar selfcontrol_n if category == 1, over(social_platform) ///
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
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/wta_by_product_digital.png", width(1000) height(1500) replace	

graph hbar wta if category == 2, over(product, label(labsize(tiny))) ///
	ytitle(WTA to deactivate (USD), size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/wta_by_product_nondigital.png", width(1000) height(1500) replace	

cibar wta, over(category) ///
	gr(ytitle(WTA to deactivate (USD), size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on)  blposition(12) blsize(medlarge)		
graph export "`png_stub'/wta_by_category.png", replace			
