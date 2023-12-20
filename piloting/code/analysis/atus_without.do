clear all
label drop _all
set scheme tab2

local png_stub "output/figures/prolific/atus_time"

***** Load and prepare
insheet using "/Users/leolab/Downloads/atus-without_December 20, 2023_08.39.csv", names clear

drop in 1/2
// drop if status == "Survey Preview" 	
drop if strpos(consent, "NOT")
destring *, replace

******* RESHAPE DATA AND PREPARE PLOT VARIABLES
drop status ipaddress progress durationinseconds finished recordeddate recipientlastname recipientfirstname recipientemail externalreference locationlatitude locationlongitude distributionchannel userlanguage consent

missings dropvars, force
reshape long usage_ without_media_, i(responseid) j(product) string 

destring product, replace

cap rename usage_ usage
cap rename without_media_ without

program label_products
	
		label define productlbl 1 "Aerobics" 2 "Baseball" 3 "Basketball" 4 "Billiards" 5 "Biking" ///
	6 "Boating" 7 "Bowling" 8 "Dancing" 9 "Fishing" 10 "Football" 11 "Golfing" 12 "Hiking" ///
	13 "Hunting" 14 "Martial arts" 15 "Racquet sports" 16 "Skiing, ice skating, snowboarding" ///
	17 "Soccer" 18 "Using cardiovascular equipment" 19 "Water sports" 20 "Weightlifting/strength training" ///
	21 "Working out at a gym/fitness center" 22 "Yoga" 23 "Baseball games (live or streaming)" ///
	24 "Basketball games (live or streaming)" 25 "Football games (live or streaming)" ///
	26 "Hockey games (live or streaming)" 27 "Racquet sports games (live or streaming)" ///
	28 "Soccer games (live or streaming)" 29 "Volleyball games (live or streaming)" 30 "Movies/cinema" ///
	31 "Performing arts" 32 "Computer/video games" 33 "Musical instruments" 34 "Radio" ///
	35 "Religious broadcasting" 36 "Television and movies" 37 "Netflix" 38 "Spotify" 39 "YouTube" ///
	40 "Disney+" 41 "HBO Max" 42 "Pandora Music" 43 "Hulu" 44 "Gambling establishments" ///
	45 "Meetings for personal interest" 46 "Parties/receptions/ceremonies" 47 "Games" ///
	48 "Tobacco" 49 "Arts and crafts" 50 "Museums" 51 "Books/Magazines" 52 "Writing for personal interest" ///
	53 "Audible" 54 "Telephones" 55 "Volunteering" 56 "Shopping stores (except groceries, food and gas)" ///
	57 "Classes for personal interest" 58 "Religious and spiritual activities" 59 "Amazon" 60 "Bumble App" ///
	61 "Cash App" 62 "CNN" 63 "Discord" 64 "DuckDuckGo" 65 "EBay" 66 "ESPN" 67 "Facebook" ///
	68 "Facebook Messenger" 69 "Google" 70 "iMessage" 71 "Instagram" 72 "LinkedIn" 73 "Microsoft Live" ///
	74 "New York Times" 75 "Nextdoor" 76 "Microsoft Office" 77 "Pinterest" 78 "Reddit" 79 "Skype" ///
	80 "Snapchat" 81 "Telegram" 82 "TikTok" 83 "Tinder" 84 "Twitter/X" 85 "WhatsApp" 86 "Wikipedia" ///
	87 "XNXX" 88 "Yahoo"

	label values product productlbl
end

label_products

* Keep only observations with answers
drop if missing(usage)

* Generate categories: 
* digital vs non-digital
gen digital = 2
replace digital = 1 if inrange(product, 37, 43) | product == 53 | inrange(product, 59, 88)
label define digitallbl 1 "Digital" 2 "Non-Digital"
label values digital digitallbl

* social media vs other digital
gen social_media = 2 if digital == 1
replace social_media = 1 if inlist(product, 67, 71, 72, 75, 77, 78, 80, 82, 84)
label define smlbl 1 "Social media" 2 "Other Digital"
label values social_media smlbl

* other categories
gen category = .
replace category = 1 if inrange(product, 1, 22)
replace category = 2 if inrange(product, 23, 29)
replace category = 3 if inrange(product, 30, 43)
replace category = 4 if inrange(product, 44, 47) // skipped tobacco
replace category = 5 if inrange(product, 49, 53)
replace category = 6 if inrange(product, 54, 58)
replace category = 7 if inrange(product, 59, 88)
label define categorylbl 1 "Sports/Exercise" 2 "Watching sports" 3 "Media&Entertainment" 4 "Social" 5 "Arts&Literature" 6 "Other Activities" 7 "Digital"  
label values category categorylbl

* Usage
gen usage_n = 0 
replace usage_n = 100 if usage == "Yes"
label define userlbl 0 "Non-user" 100 "User"
label values usage_n userlbl

* Live without
gen without_n = 0 
replace without_n = 100 if without == "World without"
label define without_lbl 0 "With" 100 "Without"
label values without_n without_lbl

********** OUTPUT GRAPHS

*** usage	
graph hbar usage_n if digital == 1, over(product, label(labsize(tiny))) ///
	ytitle(Usage (%), size(medium)) ///
	ylabel(0(20)100, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(tiny) format(%9.2f))
graph export "`png_stub'/usage_by_product_digital.png", replace	

graph hbar usage_n if digital == 2, over(product, label(labsize(tiny))) ///
	ytitle(Usage (%), size(medium)) ///
	ylabel(0(20)100, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(tiny) format(%9.2f))
graph export "`png_stub'/usage_by_product_nondigital.png", replace	

cibar usage_n, over(digital) ///
	gr(ytitle(Usage (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/usage_by_digital.png", replace	

cibar usage_n, over(category) ///
	gr(ytitle(Usage (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medium) rows(2))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/usage_by_category.png", replace	
	
*** without
cibar without_n, over(digital) ///
	gr(ytitle(Prefers world without (%), size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/live_without_by_digital.png", replace	

cibar without_n, over(usage_n digital) ///
	gr(ytitle(Prefers world without (%), size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/live_without_by_digital_usage.png", replace	

cibar without_n, over(category) ///
	gr(ytitle(Prefers world without (%), size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medium) rows(2))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/live_without_by_category.png", replace	

cibar without_n, over(usage_n category) ///
	gr(ytitle(Prefers world without (%), size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medium) rows(2))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/live_without_by_category_usage.png", replace	

cibar without_n if digital == 1, over(social_media) ///
	gr(ytitle(Prefers world without (%), size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/live_without_digital_by_sm_usage.png", replace	


cibar without_n if digital == 1, over(usage_n social_media) ///
	gr(ytitle(Prefers world without (%), size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/live_without_digital_by_sm_usage.png", replace	

