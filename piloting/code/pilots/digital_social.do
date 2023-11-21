clear all
label drop _all
set scheme tab2

cd "/Users/leolab/Dropbox/normal_lab/projects/digitaltraps"
local png_stub "output/figures/pilots/digital_social/first5"

***** Load and prepare
// insheet using "data/raw/prolific/digital_social/digital-social_November 9, 2023_08.10.csv", names clear
insheet using "data/raw/prolific/digital_social/digital-social_November 9, 2023_13.22.csv", names clear // with columns showing order

drop in 1/2
drop if status == "Survey Preview" 	
drop if strpos(consent, "NOT")
destring *, replace

// br monthly_do without_do
	
program rename_vars	

	rename _time time1
	rename _selfcontrol selfcontrol1
	rename _wta wta1

	rename v64 time2
	rename v65 selfcontrol2
	rename v66 wta2

	rename v67 time3
	rename v68 selfcontrol3
	rename v69 wta3

	rename v70 time4
	rename v71 selfcontrol4
	rename v72 wta4

	rename v73 time5
	rename v74 selfcontrol5
	rename v75 wta5

	rename v76 time6
	rename v77 selfcontrol6
	rename v78 wta6

	rename v79 time7
	rename v80 selfcontrol7
	rename v81 wta7

	rename v82 time8
	rename v83 selfcontrol8
	rename v84 wta8

	rename v85 time9
	rename v86 selfcontrol9
	rename v87 wta9

	rename v88 time10
	rename v89 selfcontrol10
	rename v90 wta10

	rename v91 time11
	rename v92 selfcontrol11
	rename v93 wta11

	rename v94 time12
	rename v95 selfcontrol12
	rename v96 wta12

	rename v97 time13
	rename v98 selfcontrol13
	rename v99 wta13

	rename v100 time14
	rename v101 selfcontrol14
	rename v102 wta14

	rename v103 time15
	rename v104 selfcontrol15
	rename v105 wta15

	rename v106 time16
	rename v107 selfcontrol16
	rename v108 wta16

	rename v109 time17
	rename v110 selfcontrol17
	rename v111 wta17

	rename v112 time18
	rename v113 selfcontrol18
	rename v114 wta18

	rename v115 time19
	rename v116 selfcontrol19
	rename v117 wta19

	rename v118 time20
	rename v119 selfcontrol20
	rename v120 wta20

	rename v121 time21
	rename v122 selfcontrol21
	rename v123 wta21

end

program rename_vars2

	rename v66 time2
	rename v67 selfcontrol2
	rename v68 wta2

	rename v69 time3
	rename v70 selfcontrol3
	rename v71 wta3

	rename v72 time4
	rename v73 selfcontrol4
	rename v74 wta4

	rename v75 time5
	rename v76 selfcontrol5
	rename v77 wta5

	rename v78 time6
	rename v79 selfcontrol6
	rename v80 wta6

	rename v81 time7
	rename v82 selfcontrol7
	rename v83 wta7

	rename v84 time8
	rename v85 selfcontrol8
	rename v86 wta8

	rename v87 time9
	rename v88 selfcontrol9
	rename v89 wta9

	rename v90 time10
	rename v91 selfcontrol10
	rename v92 wta10

	rename v93 time11
	rename v94 selfcontrol11
	rename v95 wta11

	rename v96 time12
	rename v97 selfcontrol12
	rename v98 wta12

	rename v99 time13
	rename v100 selfcontrol13
	rename v101 wta13

	rename v102 time14
	rename v103 selfcontrol14
	rename v104 wta14

	rename v105 time15
	rename v106 selfcontrol15
	rename v107 wta15

	rename v108 time16
	rename v109 selfcontrol16
	rename v110 wta16

	rename v111 time17
	rename v112 selfcontrol17
	rename v113 wta17

	rename v114 time18
	rename v115 selfcontrol18
	rename v116 wta18

	rename v117 time19
	rename v118 selfcontrol19
	rename v119 wta19

	rename v120 time20
	rename v121 selfcontrol20
	rename v122 wta20

	rename v123 time21
	rename v124 selfcontrol21
	rename v125 wta21

end	

// rename_vars
rename_vars2

**** Step 1: Keep only observations that appeared in the first 5 in the loop

rename monthly_do order_platform
rename without_do order_without

keep responseid monthly_* without_* time* selfcontrol* wta* gender age order_*
reshape long monthly_ without_ time selfcontrol wta, i(responseid) j(platform) string

// br responseid platform order_platform
split order_platform, parse("|") gen(order_) // split into new variables for each platform
egen first5platforms = concat(order_1 order_2 order_3 order_4 order_5), punct("|") // create new variable containing the first 5
replace first5platforms = subinstr(first5platforms, "Facebook Messenger", "Messenger", .)

drop order_*

rename monthly_ monthly
rename without_ without

destring platform, replace
label define platformlbl 1 "Facebook" 2 "Instagram" 3 "WhatsApp" 4 "Messenger" ///
5 "Twitter" 6 "Snapchat" 7 "TikTok" 8 "Discord" 9 "LinkedIn" 10 "Telegram" ///
11 "Tinder" 12 "Bumble" 13 "Candy Crush Saga" 14 "Netflix" 15 "Spotify" ///
16 "Google Maps" 17 "Youtube" 18 "Amazon" 19 "Duolingo" 20 "Uber" 21 "MyFitnessPal"
label values platform platformlbl

decode platform, generate(platform_names)
drop if strpos(first5platforms, platform_names) == 0 // drop all observations where the platform is not in the first five

gen category = 1 if inrange(platform, 1, 12)
replace category = 2 if inrange(platform, 13, 21)
label define categorylbl 1 "Social" 2 "Individual"
label values category categorylbl

gen uses_platform = 0 
replace uses_platform = 1 if monthly != "Not at all"

// br responseid uses_platform platform 
bysort responseid: egen total_platform = total(uses_platform)
sum total_platform, d // mean = 11.82, median = 12

replace uses_platform = uses_platform * 100

label define userlbl 0 "Non-user" 100 "User"
label values uses_platform userlbl

gen selfcontrol_n = 0 if uses_platform == 100 & regexm(selfcontrol, "including")
replace selfcontrol_n = 100 if uses_platform == 100 & regexm(selfcontrol, "except")
label define selfcontrol_lbl 0 "Self control" 100 "No self control"

*** usage	
graph bar uses_platform, over(platform, label(angle(45))) ///11
	ytitle(Platform usage (%), size(medium)) ///
	ylabel(0(20)100, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
graph export "`png_stub'/usage_by_platform.png", replace	

cibar uses_platform, over(category) ///
	gr(ytitle(Platform usage (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blgap(5) blposition(6) blsize(medlarge)
graph export "`png_stub'/usage_by_category.png", replace	

**** time
graph bar time, over(platform, label(angle(45))) ///
	ytitle("Average time spent per day" "(in minutes)", size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
graph export "`png_stub'/time_by_platform.png", replace		
	
cibar time, over(category) ///
	gr(ytitle("Average time spent per day" "(in minutes)", size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blgap(2) blposition(6) blsize(medlarge)	
graph export "`png_stub'/time_by_category.png", replace		
	
**** self control
graph bar selfcontrol_n, over(platform, label(angle(45))) ///
	ytitle(Self control problems (%), size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f))
graph export "`png_stub'/selfcontrol_by_platform.png", replace		
	
cibar selfcontrol_n, over(category) ///
	gr(ytitle(Self control problems (%), size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blgap(1) blposition(6) blsize(medlarge)	
graph export "`png_stub'/selfcontrol_by_category.png", replace		
		
	
*** wta

replace wta = 1000 if wta > 1000

graph bar wta, over(platform, label(angle(45))) ///
	ytitle(WTA to deactivate (USD), size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.0f))
graph export "`png_stub'/wta_by_platform.png", replace		

cibar wta, over(category) ///
	gr(ytitle(WTA to deactivate (USD), size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on)  blposition(12) blsize(medlarge)		
graph export "`png_stub'/wta_by_category.png", replace			
	
	
	
*** Step 2: keep only variables that appeared in the first 5 in the 'without' question order	
	
// insheet using "data/raw/prolific/digital_social/digital-social_November 9, 2023_08.10.csv", names clear
insheet using "data/raw/prolific/digital_social/digital-social_November 9, 2023_13.22.csv", names clear

drop in 1/2
drop if status == "Survey Preview" 	
drop if strpos(consent, "NOT")
destring *, replace

rename_vars2
	
rename monthly_do order_platform
rename without_do order_without

keep responseid monthly_* without_* time* selfcontrol* wta* gender age order_*
reshape long monthly_ without_ time selfcontrol wta, i(responseid) j(platform) string

// br responseid platform order_without
split order_platform, parse("|") gen(order_) // split into new variables for each platform
egen first5platforms = concat(order_1 order_2 order_3 order_4 order_5), punct("|") // create new variable containing the first 5
replace first5platforms = subinstr(first5platforms, "Facebook Messenger", "Messenger", .)

drop order_*

rename monthly_ monthly
rename without_ without

destring platform, replace
label values platform platformlbl
	
gen category = 1 if inrange(platform, 1, 12)
replace category = 2 if inrange(platform, 13, 21)
label values category categorylbl

gen uses_platform = 0 
replace uses_platform = 100 if monthly != "Not at all"
label values uses_platform userlbl

gen without_n = 0 
replace without_n = 100 if without == "World  without platform"
label values without_n without_lbl

gen selfcontrol_n = 0 if uses_platform == 100 & regexm(selfcontrol, "including")
replace selfcontrol_n = 100 if uses_platform == 100 & regexm(selfcontrol, "except")
label values selfcontrol_n selfcontrol_lbl

cibar without_n, over(selfcontrol_n category) ///
	gr(ytitle(Prefers world without (%), size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blgap(0.5) blposition(12) blsize(medium)
graph export "output/figures/pilots/digital_social/livewithout_by_category_selfcontrol.png", replace	

decode platform, generate(platform_names)
drop if strpos(first5platforms, platform_names) == 0 // drop all observations where the platform is not in the first five
	
*** live without	

graph bar without_n, over(platform, label(angle(45))) ///
	ytitle(Prefers world without (%), size(medium)) ///
	ylabel(0(20)100, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall))
graph export "`png_stub'/livewithout_by_platform.png", replace	

cibar without_n, over(uses_platform platform) ///
	ciopts(lwidth(0)) ///	
	gr(ytitle(Prefers world without (%), size(medium)) ///
	ylabel(0(20)100, labsize(medsmall)) ///
	xlabel(, labsize(vsmall) valuelabel nogrid angle(45)) ///
	legend(size(medium))) ///
	barlabel(on) blgap(0.5) blposition(12) blsize(tiny)
graph export "`png_stub'/livewithout_by_platform_usage.png", replace	

cibar without_n, over(category) ///
	gr(ytitle(Prefers world without (%), size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blgap(0.5) blposition(12) blsize(medium)
graph export "`png_stub'/livewithout_by_category.png", replace	

cibar without_n, over(uses_platform category) ///
	gr(ytitle(Prefers world without (%), size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blgap(0.5) blposition(12) blsize(medium)
graph export "`png_stub'/livewithout_by_category_usage.png", replace	

cibar without_n, over(selfcontrol_n category) ///
	gr(ytitle(Prefers world without (%), size(large)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blgap(0.5) blposition(12) blsize(medium)
graph export "`png_stub'/livewithout_by_category_selfcontrol.png", replace	

