clear all
label drop _all
set scheme tab2

local png_stub "output/figures/prolific/atus_time"

***** Load and prepare
insheet using "/Users/leolab/Downloads/atus-time_December 21, 2023_02.38.csv", names clear
count

drop in 1/2
drop if status == "Survey Preview" 	
drop if strpos(consent, "NOT")
destring *, replace

// gen age_range_group = .
// replace age_range_group = 1 if age >= 18 & age <= 29
// replace age_range_group = 2 if age >= 30 & age <= 41
// replace age_range_group = 3 if age >= 42 & age <= 53
// replace age_range_group = 4 if age >= 54 & age <= 65
// label define age_range_lbl 1 "18-29" 2 "30-41" 3 "42-53" 4 "54-65"
// label values age_range_group age_range_lbl

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

******* RESHAPE DATA AND PREPARE PLOT VARIABLES
drop status ipaddress progress durationinseconds finished recordeddate recipientlastname recipientfirstname recipientemail externalreference locationlatitude locationlongitude distributionchannel userlanguage consent

tab cat_sports
tab cat_watch_sports 
tab cat_media 
tab cat_social
tab cat_arts 
tab cat_phone_calls
tab cat_volunteering 
tab cat_religous 
tab cat_shopping 
tab cat_classes 
tab cat_digital

keep responseid hours* age gender moment
drop hours_369_text hours_370_text hours_371_text

program renamehours

	rename hours_177 hours_1
	rename hours_178 hours_2
	rename hours_179 hours_3
	rename hours_93 hours_4
	rename hours_94 hours_5
	rename hours_95 hours_6
	rename hours_96 hours_7
	rename hours_97 hours_8
	rename hours_98 hours_9
	rename hours_100 hours_10
	rename hours_103 hours_11
	rename hours_104 hours_12
	rename hours_105 hours_13
	rename hours_107 hours_14
	rename hours_108 hours_15
	rename hours_109 hours_16
	rename hours_110 hours_17
	rename hours_113 hours_18
	rename hours_114 hours_19
	rename hours_116 hours_20
	rename hours_119 hours_21
	rename hours_120 hours_22
	rename hours_121 hours_23
	rename hours_122 hours_24
	rename hours_123 hours_25
	rename hours_124 hours_26
	rename hours_128 hours_27
	rename hours_129 hours_28
	rename hours_130 hours_29
	rename hours_133 hours_30
	rename hours_136 hours_31
	rename hours_138 hours_32
	rename hours_139 hours_33
	rename hours_140 hours_34
	rename hours_141 hours_35
	rename hours_142 hours_36
	rename hours_143 hours_37
	rename hours_144 hours_38
	rename hours_203 hours_39
	rename hours_212 hours_40
	rename hours_213 hours_41
	rename hours_214 hours_42
	rename hours_215 hours_43
	rename hours_216 hours_44
	rename hours_217 hours_45
	rename hours_145 hours_46
	rename hours_146 hours_47
	rename hours_147 hours_48
	rename hours_148 hours_49
	rename hours_149 hours_50
	rename hours_150 hours_51
	rename hours_151 hours_52
	rename hours_153 hours_53
	rename hours_154 hours_54
	rename hours_219 hours_55
	rename hours_155 hours_56
	rename hours_156 hours_57
	rename hours_157 hours_58
	rename hours_158 hours_59
	rename hours_275 hours_60
	rename hours_276 hours_61
	rename hours_332 hours_62
	rename hours_333 hours_63
	rename hours_334 hours_64
	rename hours_335 hours_65
	rename hours_336 hours_66
	rename hours_337 hours_67
	rename hours_338 hours_68
	rename hours_339 hours_69
	rename hours_340 hours_70
	rename hours_341 hours_71
	rename hours_342 hours_72
	rename hours_343 hours_73
	rename hours_344 hours_74
	rename hours_345 hours_75
	rename hours_347 hours_76
	rename hours_348 hours_77
	rename hours_349 hours_78
	rename hours_350 hours_79
	rename hours_351 hours_80
	rename hours_352 hours_81
	rename hours_353 hours_82
	rename hours_354 hours_83
	rename hours_355 hours_84
	rename hours_356 hours_85
	rename hours_357 hours_86
	rename hours_358 hours_87
	rename hours_359 hours_88
	rename hours_360 hours_89
	rename hours_361 hours_90
	rename hours_363 hours_91
	rename hours_364 hours_92
	rename hours_365 hours_93
	rename hours_366 hours_94
	rename hours_367 hours_95
	rename hours_368 hours_96
	rename hours_369 hours_97
	rename hours_370 hours_98
	rename hours_371 hours_99
end

renamehours
br
// drop hours_91 hours_92 hours_93 hours_94 hours_95 hours_96 hours_97 hours_98 hours_99
reshape long hours_, i(responseid) j(product) string 

destring product, replace

sort responseid product
replace product = product - 2

program label_products
	
		label define productlbl -1 "Sleep" 0 "Work" ///
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
	87 "XNXX" 88 "Yahoo" ///
	89 "Text - Sports" 90 "Text - WatchSports" 91 "Text - Media" 92 "Text - Social" 93 "Text - Art" 94 "Text - Digital" 95 "Other - 1" 96 "Other - 2" 97 "Other - 3"

	label values product productlbl
end

label_products
rename hours_ hours
destring hours, replace
* If no answer, spent 0 time
replace hours = 0 if missing(hours)

* N per product is on average (median = )
preserve
	keep if hours > 0
	contract product, freq(product_frequency)
	tab product
	sum product_frequency, d
restore	

* respondents engaged in activities on average (median = )
preserve
	keep if hours > 0
	contract responseid, freq(responseid_freq)
	sum responseid_freq, d
restore	

* Generate categories: 
* digital vs non-digital
gen digital = 2 if product > 0
replace digital = 1 if inrange(product, 37, 43) | product == 53 | inrange(product, 59, 88) | product == 94
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
replace category = 3 if inrange(product, 30, 36) // skipped streaming services
replace category = 4 if inrange(product, 44, 47) // skipped tobacco
replace category = 5 if inrange(product, 49, 53)
replace category = 6 if inrange(product, 54, 58)
replace category = 7 if inrange(product, 37, 43) | product == 53 | inrange(product, 59, 88)
label define categorylbl 1 "Sports/Exercise" 2 "Watching sports" 3 "Media&Entertainment" 4 "Social" 5 "Arts&Literature" 6 "Other Activities" 7 "Digital"  
label values category categorylbl

* other digital categories
gen digital_category = 0 if digital == 1
replace digital_category = 1 if inlist(product, 67, 71, 72, 75, 77, 78, 80, 82, 84)
replace digital_category = 2 if inlist(product, 68, 70, 79, 81, 85, 63)
replace digital_category = 3 if inlist(product, 37, 38, 39, 40, 41, 42, 43, 53)
replace digital_category = 4 if digital_category == 0
label define digital_category_lbl 1 "Social Media" 2 "Communication" 3 "Media" 4 "Other"
label values digital_category digital_category_lbl

gen age_group = .
replace age_group = 1 if age >= 18 & age <= 33
replace age_group = 2 if age >= 34 & age <= 49
replace age_group = 3 if age >= 50 & age <= 65
label define age_group_lbl 1 "18-33" 2 "34-49" 3 "50-65" 


// gen age_group = .
// replace age_group = 1 if age >= 18 & age <= 25
// replace age_group = 2 if age >= 26 & age <= 33
// replace age_group = 3 if age >= 34 & age <= 41
// replace age_group = 4 if age >= 42 & age <= 49
// replace age_group = 5 if age >= 50 & age <= 57
// replace age_group = 6 if age >= 58 & age <= 65
// label define age_group_lbl 1 "18-25" 2 "26-33" 3 "34-41" 4 "42-49" 5 "50-57" 6 "58-65"
label values age_group age_group_lbl

tab age_group

gen usage = 0 if hours == 0
replace usage = 100 if hours > 0

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
// egen product_freq = count(responseid), by(product)
// keep if product_freq > 20

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
	xlabel(, labsize(small) angle(30) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(vsmall)	
graph export "`png_stub'/hours_by_category_age.png", replace		


gsort -hours

br hours age product if social_media == 1
