clear all
label drop _all
set scheme tab2

local png_stub "output/figures/prolific/atus_3steps/corrected/"

***** Load and prepare
insheet using "data/raw/prolific/atus_3steps/atus-3steps_December 21, 2023_15.06.csv", names clear
count

drop in 1/2
drop if status == "Survey Preview" 	
drop if strpos(consent, "NOT")
destring *, replace
count

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

******* RESHAPE DATA AND PREPARE PLOT VARIABLES
preserve
	keep intro1 responseid intro1 act_sports act_sports_23_text act_watchsports act_watchsports_8_text act_media act_media_15_text act_social act_social_6_text act_art act_art_6_text act_digital act_digital_31_text phone volunteering religious shopping classes 
	 export excel using "data/temp/atus_3steps_openended/atus_3steps_open_ended_answers.xls", firstrow(variables) replace
restore

keep responseid live_without* hours* age gender
drop hours_103_text hours_104_text //other text categories

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

generate freetime_w_chores = 24 - (hours_997 + hours_998 + hours_999)
sum freetime_w_chores, d

generate freetime_wo_chores = 24 - (hours_997 + hours_998)
sum freetime_wo_chores, d

replace hours_20 = 0 if missing(hours_20)
replace hours_95 = 0 if missing(hours_95)
replace hours_995 = 0 if missing(hours_995)
replace hours_996 = 0 if missing(hours_996)

generate freetime_w_others = 24 - (hours_20 + hours_95 + hours_995 + hours_996 + hours_997 + hours_998 + hours_999) // remove activities that don't appear in live without
sum freetime_w_others, d

sum hours_997, d
sum hours_998, d

* RESHAPE DATASET
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

* Check if survey logic worked properly:
* Nothing should show up instead of running
br responseid product live_without hours if missing(live_without) & !missing(hours) & product < 995 // WEIGHTLIFTING MISCODED IN QUALTRICS

preserve 
	* Low quality if they answered live without (meaning they engaged in activity) but entered 0 hours for activities other than the 'other' text boxes
	keep if !missing(live_without) & hours == 0 & product < 995 
	keep responseid product hours live_without
	gen quality = 0 
	keep responseid quality
	duplicates drop // 103 respondents
	tempfile qualitycheck
	save `qualitycheck', replace
restore 

merge m:1 responseid using `qualitycheck', nogen

preserve
	keep responseid
	duplicates drop
	count
restore

br responseid product hours live_without quality 
drop if quality == 0

* If no answer, spent 0 time
replace hours = 0 if missing(hours)

* N per product is .. on average (median = ..)
preserve
	keep if hours > 0
	contract product, freq(product_frequency)
	tab product
	sum product_frequency, d
restore	

* respondents engaged in .. activities on average (median = ..)
preserve
	keep if hours > 0
	contract responseid, freq(responseid_freq)
	sum responseid_freq, d
restore	

tempfile tempdta
save `tempdta', replace

* Remove inconsistent answers from handcoded data
import excel "data/temp/atus_3steps_openended/atus_3steps_open_ended_answers_handcoded.xls", sheet("Sheet1") firstrow clear
keep responseid quality digitalmedia
merge 1:m responseid using `tempdta', nogen keep(3)
drop if quality == 0
drop quality

preserve
	keep responseid
	duplicates drop
	count
restore

sort responseid product
br


* GENERATE CATEGORIES
* digital vs non-digital
gen digital = 2 if product < 94 // leave out sleep,work,chores, other
replace digital = 1 if inrange(product, 37, 43) | product == 53 | inrange(product, 59, 88) | product == 94
replace digital = 2 if product == 95 // running
replace digital = 1 if product == 91 & digitalmedia == 1 // text for other media
drop digitalmedia
label define digitallbl 1 "Digital" 2 "Non-Digital"
label values digital digitallbl

* categories
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

* digital categories
gen digital_category = 0 if digital == 1
replace digital_category = 1 if inlist(product, 67, 71, 72, 75, 77, 78, 80, 82, 84)
replace digital_category = 2 if inlist(product, 68, 70, 79, 81, 85, 63)
replace digital_category = 3 if inlist(product, 37, 38, 39, 40, 41, 42, 43, 53)
replace digital_category = 4 if digital_category == 0 // everything else
label define digital_category_lbl 1 "Social Media" 2 "Communication" 3 "Media" 4 "Other"
label values digital_category digital_category_lbl

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

********** OUTPUT GRAPHS

*** usage	

graph hbar usage if digital == 1 & product < 89, ///
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

****** hours

// keep if hours > 0

// egen product_freq = count(responseid), by(product)
// keep if product_freq > 20

drop if product > 994 // sleep, work, hh chores, other
drop if product == 95 // we don't ask live without for running
drop if product == 20 // weighlifting accidentally skipped in live without question
drop if product == 48 // tobacco not categorized

keep responseid product hours freetime* without category digital digital_category age_group 
sort responseid product

preserve
	keep responseid
	duplicates drop
	count
restore

save "data/temp/atus_3steps_corrected.dta", replace

/*
*** HOURS SPENT

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

* Those with more products appear more times, weight by inverse of frequency to equalize (?)
// egen total_count = count(responseid), by(responseid)
// gen weights = 1 / total_count 

cibar h_without [pweight=weights], over(without) ///
	gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/hours_by_without.png", replace	

cibar h_without_frac , over(without) ///
	gr(ytitle(Daily time spent (%), size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)

// preserve
// 	keep responseid h_category category
// 	duplicates drop
// 	cibar h_category, over(category) ///
// 		gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
// 		ylabel(, labsize(medlarge)) ///
// 		xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
// 		legend(size(medsmall) rows(2))) ///
// 		barlabel(on) blposition(12) blsize(medlarge)
// 	graph export "hours_by_category.png", replace
// restore 

cibar h_category [pweight=weights], over(category) ///
	gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medsmall) rows(2))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/hours_by_category.png", replace

cibar h_dig_cat [pweight=weights], over(digital_category) ///
	gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medium))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/hours_by_digital_category.png", replace

cibar h_dig_cat [pweight=weights], over(age_group digital_category) ///
	gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medium))) ///
	barlabel(on) blposition(12) blsize(small)
graph export "`png_stub'/hours_by_digital_category_age.png", replace

cibar h_without [pweight=weights], over(age_group without) ///
	gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medium))) ///
	barlabel(on) blposition(12) blsize(small)
graph export "`png_stub'/hours_by_without_age.png", replace	

* WITHOUT

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

* HOURS AMONG WITHOUT
preserve

	keep if without == 100
	drop h_category h_dig_cat h_dig_sm
	egen h_category = sum(hours), by(category responseid)
	egen h_dig_cat = sum(hours) if digital == 1, by(digital_category responseid)
	egen h_dig_sm = sum(hours) if digital == 1, by(social_media responseid)

	cibar h_dig_cat [pweight=weights], over(age_group digital_category) ///
		gr(ytitle("Daily time spent (hrs)" "among prefers world without", size(medlarge)) ///
		ylabel(, labsize(medsmall)) ///
		xlabel(, labsize(small) valuelabel nogrid) ///
		legend(size(medium))) ///
		barlabel(on) blposition(12) blsize(vsmall)
	graph export "`png_stub'/hours_amongwithout_by_age_digitalcategory.png", replace	

restore

*FRACTION WITHOUT
keep if !missing(without)
keep responseid without h_without_frac age_group
duplicates drop

* Add 0 hours to those with missing
preserve	
	egen count_response = count(responseid), by(responseid)
	keep if count_response == 1
	replace without = 1 if without == 0
	replace without = 0 if without == 100
	replace without = 100 if without == 1
	replace h_without_frac = 0
	
	tempfile zerohours
	save `zerohours'
restore

append using `zerohours'	
sort responseid
br

drop count_response
egen count_response = count(responseid), by(responseid)
tab count_response, m // check if each response has N=2

cibar h_without_frac, over(without) ///
	gr(ytitle(Daily time spent (%), size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/hours_by_without_fraction.png", replace	

cibar h_without_frac, over(without age_group) ///
	gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medsmall)
graph export "`png_stub'/hours_by_without_age_fraction.png", replace	

