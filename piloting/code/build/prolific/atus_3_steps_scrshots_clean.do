clear all
label drop _all

/*
* Quality checks:
- Dropping all respondents who stated to have engaged in activity but entered 0 hours for said activities in total (main + secondary)
- Dropping all respondents who ever entered same hours (main & secondary) for same activity

- Replacing activity hours exceeding 16 with 16
- Dropping respondents with total hours exceeding 36 hours (1.5 days)
- *Not* dropping 4 respondents that entered 1 hours of sleep or less

Remaining N=142

*/
***** Load and prepare
insheet using "/Users/leolab/Downloads/atus-3steps-scrshots_January 7, 2024_22.17.csv", names clear
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

preserve
	keep intro1 responseid intro1 act_sports act_sports_29_text act_watchsports act_watchsports_8_text act_media act_media_15_text act_social act_social_6_text act_art act_art_6_text act_digital act_digital_48_text phone volunteering religious shopping classes 
	 export excel using "data/temp/atus_3steps_openended/atus_3steps_multitasking_open_ended_answers.xls", firstrow(variables) replace
restore

******* RESHAPE DATA AND PREPARE PLOT VARIABLES

keep responseid live_without* hours* secondary* age gender

drop hours_289_text secondary_290_text //other text categories

rename hours_289 primary_hours_996 // other
rename hours_1 primary_hours_997 // sleep
rename hours_2 primary_hours_998 // work
rename hours_3 primary_hours_999 // hh chores

rename secondary_290 secondary_hours_996 // secondary other

* 89 activities + 6 'other' text boxes
forvalues i = 1/95 {
	
	local j = `i' + 193	
	rename hours_`j' primary_hours_`i'
	
}

forvalues i = 1/95 {
	
	local j = `i' + 193	
	rename secondary_`j' secondary_hours_`i'
	
}

destring primary_hours*, replace
destring secondary_hours*, replace
tostring live_without*, replace

* RESHAPE DATASET
reshape long primary_hours_ secondary_hours_ live_without_, i(responseid) j(product) string 

destring product, replace
rename primary_hours_ primary_hours
rename secondary_hours_ secondary_hours
rename live_without_ live_without

sort responseid product
br responseid product live_without *hours 

program label_products
	
		label define productlbl 996 "Other" 997 "Sleep" 998 "Work" 999 "HH Chores" ///
	1 "Aerobics" ///
	2 "Baseball" ///
	3 "Basketball" ///
	4 "Billiards" ///
	5 "Biking" ///
	6 "Boating" ///
	7 "Bowling" ///
	8 "Dancing" ///
	9 "Fishing" ///
	10 "Football" ///
	11 "Golfing" ///
	12 "Hiking" ///
	13 "Hunting" ///
	14 "Martial arts" ///
	15 "Racquet sports" ///
	16 "Running (as a sport)" ///
	17 "Skiing, ice skating, snowboarding" ///
	18 "Soccer" ///
	19 "Using cardiovascular equipment" ///
	20 "Water sports" ///
	21 "Weightlifting/strength training" ///
	22 "Working out at a gym/fitness center" ///
	23 "Yoga" ///
	24 "Baseball games (live or streaming)" ///
	25 "Basketball games (live or streaming)" ///
	26 "Football games (live or streaming)" ///
	27 "Hockey games (live or streaming)" ///
	28 "Racquet sports games (live or streaming)" ///
	29 "Soccer games (live or streaming)" ///
	30 "Volleyball games (live or streaming)" ///
	31 "Movies/cinema" ///
	32 "Performing arts" ///
	33 "Computer/video games" ///
	34 "Musical instruments" ///
	35 "Radio" ///
	36 "Religious broadcasting" ///
	37 "Television and movies" ///
	38 "Netflix" ///
	39 "Spotify" ///
	40 "YouTube" ///
	41 "Disney+" ///
	42 "HBO Max" ///
	43 "Pandora Music" ///
	44 "Hulu" ///
	45 "Gambling establishments" ///
	46 "Meetings for personal interest (e.g. club meetings, fraternity/sorority meetings)" ///
	47 "Parties/receptions/ceremonies" ///
	48 "Games (e.g. board games, cards, etc.)" ///
	49 "Tobacco" ///
	50 "Arts and crafts" ///
	51 "Museums" ///
	52 "Books/Magazines" ///
	53 "Writing for personal interest" ///
	54 "Audible" ///
	55 "Telephones" ///
	56 "Volunteering" ///
	57 "Shopping stores (except groceries, food and gas) " ///
	58 "Classes for personal interest" ///
	59 "Religious and spiritual activities" ///
	60 "Amazon" ///
	61 "Bumble App" ///
	62 "Cash App" ///
	63 "CNN" ///
	64 "Discord" ///
	65 "DuckDuckGo" ///
	66 "EBay" ///
	67 "ESPN" ///
	68 "Facebook" ///
	69 "Facebook Messenger" ///
	70 "Google" ///
	71 "iMessage" ///
	72 "Instagram" ///
	73 "LinkedIn" ///
	74 "Microsoft Live" ///
	75 "Microsoft Office" ///
	76 "New York Times" ///
	77 "Nextdoor" ///
	78 "Pinterest" ///
	79 "Reddit" ///
	80 "Skype" ///
	81 "Snapchat" ///
	82 "Telegram" ///
	83 "TikTok" ///
	84 "Tinder" ///
	85 "Twitter/X" ///
	86 "WhatsApp" ///
	87 "Wikipedia" ///
	88 "XNXX" ///
	89 "Yahoo" ///
	90 "Other-Sports" ///
	91 "Other-Watch Sports" ///
	92 "Other-Media" ///
	93 "Other-Social" ///
	94 "Other-Art" ///
	95 "Other-Digital"

	label values product productlbl
end

label_products

// br *hours
gen hours = primary_hours
replace hours = hours + secondary_hours if !missing(secondary_hours)

sum primary_hours, d
sum secondary_hours, d
sum hours, d

// drop primary_hours secondary_hours

* Check if survey logic worked properly: Nothing should show up other than 'other'
tab product if missing(live_without) & !missing(hours) & product < 996 

preserve
	
	* Low quality if they stated to engage in activity but entered 0 hours in total
	keep if hours == 0
	drop if product > 995 // does not count for other, sleep, work, hh chores
	keep responseid
	duplicates drop
	gen quality = 0
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

preserve
	keep responseid
	duplicates drop
	count // N=192
restore


drop if product > 995 // remove other, sleep, work, hh chores
tab product
tab responseid

* Data structure = responseid x product (192 x 95)

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

* Remove inconsistent answers from handcoded data

// tempfile tempdta
// save `tempdta', replace

// import excel "data/temp/atus_3steps_openended/atus_3steps_open_ended_answers_handcoded.xls", sheet("Sheet1") firstrow clear
// keep responseid quality digitalmedia
// merge 1:m responseid using `tempdta', nogen keep(3)
// drop if quality == 0
// drop quality

* GENERATE CATEGORIES

program generate_categories
	* broad categories
	gen category = .
	replace category = 1 if inrange(product, 1, 23)  | product == 90 | product == 95
	replace category = 2 if inrange(product, 24, 30) | product == 91
	replace category = 3 if inrange(product, 31, 37) | product == 92 // skipped streaming services
	replace category = 4 if inrange(product, 45, 48) | product == 93 // skipped tobacco
	replace category = 5 if inrange(product, 50, 53) | product == 94
	replace category = 6 if inrange(product, 55, 59)
	replace category = 7 if inrange(product, 38, 44) | product == 54 | inrange(product, 60, 89) | product == 95
	label define categorylbl 1 "Sports/Exercise" 2 "Watching sports" 3 "Media&Entertainment" 4 "Social" 5 "Arts&Literature" 6 "Other Activities" 7 "Digital"  
	label values category categorylbl

	* digital categories
	gen digital_category = 0 if category == 7
	replace digital_category = 1 if inlist(product, 68, 72, 73, 77, 78, 79, 81, 83, 85)
	replace digital_category = 2 if inlist(product, 64, 69, 71, 80, 82, 86)
	replace digital_category = 3 if inlist(product, 38, 39, 40, 41, 42, 43, 44, 54)
	replace digital_category = 4 if digital_category == 0 // everything else
	label define digital_category_lbl 1 "Social Media" 2 "Communication" 3 "Media" 4 "Other"
	label values digital_category digital_category_lbl

	xtile age_tercile = age, nq(3)
	tab age age_tercile
	label define age_tercile_lbl 1 "19-30" 2 "31-40" 3 "41-65"
	label values age_tercile age_tercile_lbl
	tab age_tercile

	* age group
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

	* graphing variables

	gen usage = hours > 0
	replace usage = 100 if usage == 1

	gen without = 0 if live_without == "Live with"
	replace without = 100 if live_without == "Live without"
	label define withoutlbl 0 "World with" 100 "World without"
	label values without withoutlbl

	gen digital = category == 7
	label define digitallbl 1 "Digital" 0 "Non-Digital"
	label values digital digitallbl

end

generate_categories


*** Check if hours are sensical

* Cap hours belonging to single activity to 16 ??
br responseid product hours secondary_hours primary_hours

preserve
	keep responseid
	duplicates drop
	count
restore

* If respondent re-entered same number of hours for same activity across the two questions, drop all observations from respondent due to indication of misunderstanding

preserve 
	gen equal_hours = 0 if !missing(secondary_hours)
	replace equal_hours = 1 if secondary_hours == primary_hours & !missing(secondary_hours)
	bys responseid: egen misunderstood = total(equal_hours)
	replace misunderstood = 1 if misunderstood > 0
	keep responseid misunderstood
	duplicates drop
	tab misunderstood // 49 respondents
	
	tempfile misunderstood
	save `misunderstood', replace
	
restore

merge m:1 responseid using `misunderstood', nogen
drop if misunderstood == 1

preserve
	keep responseid
	duplicates drop
	count // 149 respondents
restore

* Check daily total hours

bys responseid: egen daily_total = sum(hours)
br responseid product hours daily_total if hours > 0
gsort -daily_total

preserve
	* Drop if hours add up to more than 1.5 days
	keep if daily_total > 36 
	keep responseid
	duplicates drop
	count 

	tempfile overhours
	save `overhours', replace
restore

merge m:1 responseid using `overhours', keep(1) nogen

preserve
	keep responseid
	duplicates drop
	count // 142 respondents
restore

save "data/working/prolific/atus_3steps_scrshots.dta", replace
