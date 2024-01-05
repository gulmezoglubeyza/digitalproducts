clear all
local png_stub "output/figures/atus"

use "data/working/atus/atus2022.dta", clear

gsort -minutes
br if category == 12
br if category == 13

graph hbar minutes if category == 1, over(activity, sort(1)) ///
	title("Personal Care") ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) format(%9.3f))
graph export "`png_stub'/minutes_personalcare.png", replace	

graph hbar minutes if category == 2, ///
	over(activity, sort(1) label(labsize(vsmall))) ///
	title("Household activities") ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.3f))
graph export "`png_stub'/minutes_hhactivities.png", replace	
	
graph hbar minutes if category == 3, ///
	over(activity, sort(1) label(labsize(vsmall))) ///
	title("Caring for and helping household members") ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.3f))
graph export "`png_stub'/minutes_caringhh.png", replace	
	
graph hbar minutes if category == 4,  ///
	over(activity, sort(1) label(labsize(vsmall))) ///
	title("Caring for and helping those who are not household members", size(medsmall)) ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.3f))
graph export "`png_stub'/minutes_caringnothh.png", replace	

graph hbar minutes if category == 5,  ///
	over(activity, sort(1) label(labsize(vsmall))) ///
	title("Work and work-related activities") ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.3f))
graph export "`png_stub'/minutes_work.png", replace	

graph hbar minutes if category == 6, over(activity, sort(1)) ///
	title("Education") ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) format(%9.3f))
graph export "`png_stub'/minutes_education.png", replace

graph hbar minutes if category == 7, over(activity, sort(1)) ///
	title( "Consumer purchases") ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) format(%9.3f))
graph export "`png_stub'/minutes_consumerpurch.png", replace	

graph hbar minutes if category == 8, over(activity, sort(1)) ///
	title("Professional and personal care services") ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) format(%9.3f))
graph export "`png_stub'/minutes_profperscare.png", replace	

graph hbar minutes if category == 9, over(activity, sort(1)) ///
	title("Household services") ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) format(%9.3f))
graph export "`png_stub'/minutes_hhservices.png", replace	

graph hbar minutes if category == 10, over(activity, sort(1)) ///
	title("Government services and civic obligations") ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) format(%9.3f))
graph export "`png_stub'/minutes_govcivicoblg.png", replace	

graph hbar minutes if category == 11, over(activity, sort(1)) ///
	title("Eating and drinking" ) ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) format(%9.3f))
graph export "`png_stub'/minutes_eatingdrinking.png", replace	

graph hbar minutes if category == 12, ///
	over(activity, sort(1) label(labsize(vsmall))) ///
	title("Socializing, relaxing, and leisure") ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.3f))
graph export "`png_stub'/minutes_socialrelaxleisure.png", replace	
		
graph hbar minutes if category == 13, ///
	over(activity, sort(1) label(labsize(tiny))) ///
	title("Sports, exercise, and recreation") ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(tiny) format(%9.3f))
graph export "`png_stub'/minutes_sports.png", replace			

graph hbar minutes if category == 14, over(activity, sort(1)) ///
	title("Religious and spiritual activities") ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) format(%9.3f))
graph export "`png_stub'/minutes_religios.png", replace			
				
graph hbar minutes if category == 15, ///
	over(activity, sort(1) label(labsize(vsmall))) ///
	title("Volunteer activities") ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.3f))
graph export "`png_stub'/minutes_volunteer.png", replace			
				
graph hbar minutes if category == 16, over(activity, sort(1)) ///
	title("Telephone calls") ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) format(%9.3f))
graph export "`png_stub'/minutes_telephone.png", replace			

graph hbar minutes if category == 18, ///
	over(activity, sort(1) label(labsize(tiny))) ///
	title("Traveling") ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) size(tiny) format(%9.3f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/minutes_traveling.png", width(1000) height(1500) replace			

gsort -minutes
keep if _n < 21

graph hbar minutes, over(activity, sort(1)) ///
	title("Top 20 Activities") ///
	ytitle(Average minutes per day, size(medium)) ///
	ylabel(, labsize(medsmall)) ///
	blabel(bar, position(6) gap(0) format(%9.3f))
graph export "`png_stub'/minutes_top20.png", replace	

