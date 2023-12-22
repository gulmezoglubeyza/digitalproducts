clear all
label drop _all
set scheme tab2

local png_stub "output/figures/prolific/atus_3steps/qualitycheck/"

***** Load and prepare
insheet using "data/raw/prolific/atus_3steps/atus-3steps_December 21, 2023_15.06.csv", names clear
count

drop in 1/2
drop if status == "Survey Preview" 	
drop if strpos(consent, "NOT")
destring *, replace

******* RESHAPE DATA AND PREPARE PLOT VARIABLES
drop status ipaddress progress durationinseconds finished recordeddate recipientlastname recipientfirstname recipientemail externalreference locationlatitude locationlongitude distributionchannel userlanguage consent

preserve
	keep intro1 responseid intro1 act_sports act_sports_23_text act_watchsports act_watchsports_8_text act_media act_media_15_text act_social act_social_6_text act_art act_art_6_text act_digital act_digital_31_text phone volunteering religious shopping classes 
	 export excel using "data/temp/atus_3steps_openended/atus_3steps_open_ended_answers.xls", firstrow(variables) replace
restore

tab sports
tab watchsports 
tab media 
tab social
tab art
tab phone
tab volunteering 
tab religious 
tab shopping 
tab classes 
tab digital

// gen age_group = .
// replace age_group = 1 if age >= 18 & age <= 25
// replace age_group = 2 if age >= 26 & age <= 33
// replace age_group = 3 if age >= 34 & age <= 41
// replace age_group = 4 if age >= 42 & age <= 49
// replace age_group = 5 if age >= 50 & age <= 57
// replace age_group = 6 if age >= 58 & age <= 65
// label define age_group_lbl 1 "18-25" 2 "26-33" 3 "34-41" 4 "42-49" 5 "50-57" 6 "58-65"
// label values age_group age_group_lbl
//
// tab age_group
// drop age_group


keep responseid live_without* hours* age gender
drop hours_103_text hours_104_text

rename hours_1 hours_997 // sleep
rename hours_2 hours_998 // work
rename hours_3 hours_999 // hh chores

forvalues i = 1/88 {
	
	local j = `i' + 3	
	rename hours_`j' hours_`i'
	
}

rename hours_97 hours_89
rename hours_98 hours_90
rename hours_99 hours_91
rename hours_100 hours_92
rename hours_101 hours_93
rename hours_102 hours_94

rename hours_105 hours_95 // Running (does not appear in live without)

rename hours_103 hours_995 // Other - 1
rename hours_104 hours_996 // Other - 2

destring hours*, replace
tostring live_without*, replace

generate freetime = 24 - (hours_997 + hours_998 + hours_999)
sum freetime, d

generate freetime2 = 24 - (hours_997 + hours_998)
sum freetime2, d

sum hours_997, d
sum hours_998, d

reshape long hours_ live_without_, i(responseid) j(product) string 

destring product, replace
rename hours_ hours
rename live_without_ live_without

sort responseid product
br responseid product live_without hours 

program label_products
	
		label define productlbl 997 "Sleep" 998 "Work" 999 "HH Chores" ///
		1 "Aerobics" 2 "Baseball" 3 "Basketball" 4 "Billiards" 5 "Biking" ///
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
	87 "XNXX" 88 "Yahoo"  ///
	89 "Text - Sports" 90 "Text - WatchSports" 91 "Text - Media" 92 "Text - Social" 93 "Text - Art" 94 "Text - Digital" /// 
	95 "Running" ///
	995 "Other - 1" 996 "Other - 2"

	label values product productlbl
end

label_products

destring hours, replace


// br responseid product hours live_without quality if !missing(live_without) & hours == 0 & product < 995

preserve 
	keep if !missing(live_without) & hours == 0 & product < 995
	keep responseid product hours live_without
	gen quality = 0 if !missing(live_without) & hours == 0 & product < 995
	keep responseid quality
	duplicates drop // 103 respondents
	tempfile qualitycheck
	save `qualitycheck', replace
restore 

merge m:1 responseid using `qualitycheck'

br responseid product hours live_without quality 
drop if quality == 0

* If no answer, spent 0 time
replace hours = 0 if missing(hours)

tab product

* N per product is 30 on average (median = 12)
preserve
	keep if hours > 0
	contract product, freq(product_frequency)
	tab product
	sum product_frequency, d
restore	

* respondents engaged in 12 activities on average (median = 13)
preserve
	keep if hours > 0
	contract responseid, freq(responseid_freq)
	sum responseid_freq, d
restore	

* Generate categories: 
* digital vs non-digital
gen digital = 2 if product < 89 // leave out sleep,work,chores, other
replace digital = 1 if inrange(product, 37, 43) | product == 53 | inrange(product, 59, 88) | product == 94
replace digital = . if product == 91 // Other media could be digital & non-digital
label define digitallbl 1 "Digital" 2 "Non-Digital"
label values digital digitallbl

* social media vs other digital
gen social_media = 2 if digital == 1
replace social_media = 1 if inlist(product, 67, 71, 72, 75, 77, 78, 80, 82, 84)
label define smlbl 1 "Social media" 2 "Other Digital"
label values social_media smlbl

* other categories
gen category = .
replace category = 1 if inrange(product, 1, 22)  | product == 89 | product == 95
replace category = 2 if inrange(product, 23, 29) | product == 90
replace category = 3 if inrange(product, 30, 36) | product == 91 // skipped streaming services
replace category = 4 if inrange(product, 44, 47) | product == 92 // skipped tobacco
replace category = 5 if inrange(product, 49, 53) | product == 93
replace category = 6 if inrange(product, 54, 58)
replace category = 7 if inrange(product, 37, 43) | product == 53 | inrange(product, 59, 88) | product == 94
label define categorylbl 1 "Sports/Exercise" 2 "Watching sports" 3 "Media&Entertainment" 4 "Social" 5 "Arts&Literature" 6 "Other Activities" 7 "Digital"  
label values category categorylbl

* other digital categories
gen digital_category = 0 if digital == 1
replace digital_category = 1 if inlist(product, 67, 71, 72, 75, 77, 78, 80, 82, 84)
replace digital_category = 2 if inlist(product, 68, 70, 79, 81, 85, 63)
replace digital_category = 3 if inlist(product, 37, 38, 39, 40, 41, 42, 43, 53)
replace digital_category = 4 if digital_category == 0 // everything else
label define digital_category_lbl 1 "Social Media" 2 "Communication" 3 "Media" 4 "Other"
label values digital_category digital_category_lbl

// gen age_group = .
// replace age_group = 1 if age >= 18 & age <= 33
// replace age_group = 2 if age >= 34 & age <= 49
// replace age_group = 3 if age >= 50 & age <= 65
// label define age_group_lbl 1 "18-33" 2 "34-49" 3 "50-65" 
//

gen age_group = .
replace age_group = 1 if age >= 18 & age <= 25
replace age_group = 2 if age >= 26 & age <= 33
replace age_group = 3 if age >= 34 & age <= 41
replace age_group = 4 if age >= 42 & age <= 49
replace age_group = 5 if age >= 50 & age <= 57
replace age_group = 6 if age >= 58 & age <= 65
label define age_group_lbl 1 "18-25" 2 "26-33" 3 "34-41" 4 "42-49" 5 "50-57" 6 "58-65"
label values age_group age_group_lbl

tab age_group

gen usage = 0 if hours == 0
replace usage = 100 if hours > 0

gen without = 0 if live_without == "Live with"
replace without = 100 if live_without == "Live without"
label define withoutlbl 0 "World with" 100 "World without"
label values without withoutlbl

gen phone_apps = .
replace phone_app = 1 if inlist(product, 71, 80, 82, 85)
tab product if phone_app == 1

br responseid product hours if social_media == 1 & hours > 0

********** OUTPUT GRAPHS

*** usage	

graph hbar usage if digital == 1, ///
	over(product, label(labsize(vsmall)) sort(1)) ///
	ytitle(Usage (%), size(medium)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/usage_digital_by_product.png", width(1000) height(1500) replace	

graph hbar usage if digital == 2, ///
	over(product, label(labsize(vsmall)) sort(1)) ///
	ytitle(Usage (%), size(medium)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/usage_nondigital_by_product.png", width(1000) height(1500) replace	

****** HOURS

keep if hours > 0
egen product_freq = count(responseid), by(product)
keep if product_freq > 20

graph hbar hours if digital == 1, ///
	over(product, label(labsize(vsmall)) sort(1)) ///
	ytitle(Daily time spent (hrs), size(medium)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/hours_digital_by_product.png", width(1000) height(1500) replace	

graph hbar hours if digital == 2, ///
	over(product, label(labsize(vsmall)) sort(1)) ///
	ytitle(Daily time spent (hrs), size(medium)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/hours_nondigital_by_product.png", width(1000) height(1500) replace	

cibar hours, over(digital) ///
	gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/hours_by_digital.png", replace	

cibar hours, over(category) ///
	gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge) rows(2))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/hours_by_category.png", replace	
	
cibar hours if digital == 1, over(social_media) ///
	gr(ytitle(Daily time spent (hrs), size(large)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/hours_digital_by_sm.png", replace	

cibar hours if digital == 1, over(digital_category) ///
	gr(ytitle(Daily time spent (hrs), size(large)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/hours_digital_by_digitalcategory.png", replace

cibar hours, over(age_group digital) ///
	gr(ytitle(Daily time spent (hrs), size(large)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/hours_by_digital_age.png", replace

cibar hours if digital == 1, over(age_group social_media) ///
	gr(ytitle(Daily time spent (hrs), size(large)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/hours_by_sm_age.png", replace	
	
cibar hours if digital == 1, over(age_group digital_category) ///
	gr(ytitle(Daily time spent (hrs), size(large)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(vsmall)	
graph export "`png_stub'/hours_by_digitalcategory_age.png", replace	

cibar hours, over(age_group category) ///
	gr(ytitle(Daily time spent (hrs), size(large)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	xlabel(, labsize(medsmall) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(vsmall)	
graph export "`png_stub'/hours_by_category_age.png", replace		

* LIVE WITHOUT

graph hbar without if digital == 1, ///
	over(product, label(labsize(vsmall)) sort(1)) ///
	ytitle(Prefers world without (%), size(medium)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/without_digital_by_product.png", width(1000) height(1500) replace	

graph hbar without if digital == 2, ///
	over(product, label(labsize(vsmall)) sort(1)) ///
	ytitle(Prefers world without (%), size(medium)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/without_nondigital_by_product.png", width(1000) height(1500) replace	

cibar without, over(digital) ///
	gr(ytitle(Prefers world without (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/without_by_digital.png", replace	

cibar without, over(category) ///
	gr(ytitle(Prefers world without (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge) rows(2))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/without_by_category.png", replace	
	
cibar without if digital == 1, over(social_media) ///
	gr(ytitle(Prefers world without (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/without_digital_by_sm.png", replace	

cibar without if digital == 1, over(digital_category) ///
	gr(ytitle(Prefers world without (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/without_digital_by_digitalcategory.png", replace

cibar without, over(age_group digital) ///
	gr(ytitle(Prefers world without (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medsmall)
graph export "`png_stub'/without_by_digital_age.png", replace

cibar without if digital == 1, over(age_group social_media) ///
	gr(ytitle(Prefers world without (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medium)
graph export "`png_stub'/without_by_sm_age.png", replace	
	
cibar without if digital == 1, over(age_group digital_category) ///
	gr(ytitle(Prefers world without (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(vsmall)	
graph export "`png_stub'/without_by_digitalcategory_age.png", replace	

cibar without, over(age_group category) ///
	gr(ytitle(Prefers world without (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(small) angle(30) valuelabel nogrid) ///
	legend(size(medsmall))) ///
	barlabel(on) blposition(12) blsize(vsmall)	
graph export "`png_stub'/without_by_category_age.png", replace		

** BOTH
cibar hours, over(digital without) ///
	gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	xlabel(, labsize(medium) valuelabel nogrid) ///
	legend(size(medium))) ///
	barlabel(on) blposition(12) blsize(medsmall)	
graph export "`png_stub'/hours_by_without_digital.png", replace	

cibar hours, over(category without) ///
	gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	xlabel(, labsize(medium) valuelabel nogrid) ///
	legend(size(medsmall) rows(2))) ///
	barlabel(on) blposition(12) blsize(medsmall)	
graph export "`png_stub'/hours_by_without_category.png", replace		

cibar hours, over(digital_category without) ///
	gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	xlabel(, labsize(medium) valuelabel nogrid) ///
	legend(size(medium))) ///
	barlabel(on) blposition(12) blsize(medsmall)	
graph export "`png_stub'/hours_by_without_digitalcategory.png", replace

cibar hours, over(age_group without) ///
	gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	xlabel(, labsize(medium) valuelabel nogrid) ///
	legend(size(medium))) ///
	barlabel(on) blposition(12) blsize(medsmall)	
graph export "`png_stub'/hours_by_without_agegroup.png", replace

cibar hours, over(age_group without digital) ///
	gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	xlabel(, labsize(medium) valuelabel nogrid) ///
	legend(size(medium))) ///
	barlabel(on) blposition(12) blsize(vsmall)	
graph export "`png_stub'/hours_by_without_agegroup_digital.png", replace

cibar hours if without == 100, over(age_group digital) ///
	gr(ytitle("Daily time spent (hrs)" "among prefers world without", size(medlarge)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	xlabel(, labsize(medium) valuelabel nogrid) ///
	legend(size(medium))) ///
	barlabel(on) blposition(12) blsize(medsmall)	
graph export "`png_stub'/hours_by_amongwithout_agegroup_digital.png", replace

cibar hours if without == 100, over(age_group digital_category) ///
	gr(ytitle("Daily time spent (hrs)" "among prefers world without", size(medlarge)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	xlabel(, labsize(medsmall) valuelabel nogrid) ///
	legend(size(medium))) ///
	barlabel(on) blposition(12) blsize(vsmall)	
graph export "`png_stub'/hours_amongwithout_by_agegroup_digitalcategory.png", replace

cibar hours if phone_app == 1, over(age_group) ///
	gr(ytitle("Daily time spent (hrs) on" "IG, Snapchat, TikTok, WhatsApp", size(medium)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	xlabel(, labsize(medsmall) valuelabel nogrid) ///
	legend(size(medium))) ///
	barlabel(on) blposition(12) blsize(medium)	
graph export "`png_stub'/hours_phoneapps_by_age.png", replace

cibar hours if product == 998, over(age_group) ///
	gr(ytitle(Work (hrs), size(medlarge)) ///
	ylabel(0(1)8, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/hours_work_byage.png", replace

// cibar hours if without == 100, over(age_group digital_category) ///
// 	gr(ytitle("Daily time spent (hrs)" "for prefers without", size(medlarge)) ///
// 	ylabel(0(1)6, labsize(medlarge)) ///
// 	xlabel(, labsize(medium) valuelabel nogrid) ///
// 	legend(size(medium))) ///
// 	barlabel(on) blposition(12) blsize(medsmall)	
// graph export "`png_stub'/hours_by_without_agegroup_digital.png", replace



/*
gsort -hours
br hours age product if social_media == 1


*/
************* Save excel for quality checks

***** Load and prepare
insheet using "data/raw/prolific/atus_3steps/atus-3steps_December 21, 2023_15.06.csv", names clear
count

drop in 1/2
drop if status == "Survey Preview" 	
drop if strpos(consent, "NOT")
destring *, replace

keep intro1 responseid intro1 act_sports act_sports_23_text act_watchsports act_watchsports_8_text act_media act_media_15_text act_social act_social_6_text act_art act_art_6_text act_digital act_digital_31_text phone volunteering religious shopping classes 

merge m:1 responseid using `qualitycheck'
drop if quality == 0
	 
export excel using "data/temp/atus_3steps_openended/atus_3steps_open_ended_answers.xls", firstrow(variables) replace



// br responseid product hours live_without quality 
// 
//
