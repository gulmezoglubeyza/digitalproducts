clear all
label drop _all
set scheme tab2

local png_stub "output/figures/prolific/atus_3steps_scrshots/"
use "data/working/prolific/atus_3steps_scrshots.dta", replace

*** usage	

graph hbar usage if digital == 1, ///
	over(product, label(labsize(vsmall)) sort(1)) ///
	ytitle(Usage (%), size(medium)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/usage_digital_by_product.png", width(1000) height(1500) replace	

graph hbar usage if digital == 0, ///
	over(product, label(labsize(vsmall)) sort(1)) ///
	ytitle(Usage (%), size(medium)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/usage_nondigital_by_product.png", width(1000) height(1500) replace	


*Drop tobacco here? 49

********************************************************************************
*-------------------------- HOURS SPENT PER CATEGORY --------------------------*
********************************************************************************

use "data/working/prolific/atus_3steps_scrshots.dta", replace
br responseid product hours without category

* Some hours seem unrealistic, capping at 12 hours
replace hours = 12 if hours > 12

* By product
graph hbar (mean) hours if digital == 1, ///
	over(product, label(labsize(vsmall)) sort(1)) ///
	ytitle(Daily time spent (hrs), size(medium)) ///
	ylabel(0(0.5)2, labsize(medlarge)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/hours_digital_by_product.png", width(1000) height(1500) replace	

graph hbar (mean) hours if digital == 0, ///
	over(product, label(labsize(vsmall)) sort(1)) ///
	ytitle(Daily time spent (hrs), size(medium)) ///
	ylabel(0(0.5)2, labsize(medlarge)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/hours_nondigital_by_product.png", width(1000) height(1500) replace	

* By category
preserve
		
	collapse (sum) hours, by(category responseid age_tercile)

	cibar hours, over(category) ///
		gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
		legend(size(medsmall) rows(2))) ///
		barlabel(on) blposition(12) blsize(medlarge)
	graph export "`png_stub'/hours_by_category.png", replace
	
	cibar hours, over(age_tercile category ) ///
		gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(small) valuelabel nogrid angle(30)) ///
		legend(size(medsmall) rows(1))) ///
		barlabel(on) blposition(12) blsize(tiny)
	graph export "`png_stub'/hours_by_category_age.png", replace

restore

* By digital category
preserve
	
	collapse (sum) hours, by(digital_category responseid age_tercile)
	sort responseid digital_category
		
	cibar hours, over(digital_category) ///
		gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
		legend(size(medlarge))) ///
		barlabel(on) blposition(12) blsize(medlarge)
	graph export "`png_stub'/hours_by_digitalcategory.png", replace
	
	cibar hours, over(age_tercile digital_category) ///
		gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid) ///
		legend(size(medlarge))) ///
		barlabel(on) blposition(12) blsize(small)
	graph export "`png_stub'/hours_by_digitalcategory_age.png", replace

restore


* Hours spent on live without
use "data/working/prolific/atus_3steps_scrshots.dta", replace
* Code below expands dataset to accommpdate long data structure and have 2 entries per respondent (hours for live with & without)

preserve

	keep responseid age_tercile
	duplicates drop
	expand 2
	bys responseid: gen without= _n
	replace without = 0 if without == 1
	replace without = 100 if without == 2

	tempfile balcat
	save `balcat'

restore

preserve 
	br responseid hours product without if hours > 0
	
	collapse (sum) hours if !missing(without), by(responseid without age_tercile) 
	gsort -hours

	merge 1:1 without responseid using `balcat', update
	assert missing(hours) if _merge == 2
	drop _merge

	sort responseid without
	duplicates report responseid
	tab without

	replace hours = 0 if missing(hours)	
	
	hist hours if without == 100 & hours > 0, ///
		percent ylabel(,grid) xlabel(0(1)16) ///
		width(0.5)
	graph export "`png_stub'/hist_without_hours.png", replace
	
	* hours spent on live with vs without
	cibar hours, over(without) ///
		gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
		legend(size(large))) ///
		barlabel(on) blposition(12) blsize(medlarge)
	graph export "`png_stub'/hours_by_without.png", replace	
	
	cibar hours, over(without age_tercile) ///
		gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid) ///
		legend(size(large))) ///
		barlabel(on) blposition(12) blsize(medlarge)
	graph export "`png_stub'/hours_by_without_age.png", replace	
		
	cibar hours if hours > 0, over(without) ///
		gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
		legend(size(medlarge))) ///
		barlabel(on) blposition(12) blsize(medlarge)
	graph export "`png_stub'/hours_by_without_nozero.png", replace	

	cibar hours if hours > 0, over(without age_tercile) ///
		gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid) ///
		legend(size(medlarge))) ///
		barlabel(on) blposition(12) blsize(medlarge)
	graph export "`png_stub'/hours_by_without_age_nozero.png", replace		
	
	* fraction of time spent on live with vs without
	bys responseid: egen resp_hours = total(hours)
	gen timeshare = hours/resp_hours * 100

	cibar timeshare, over(without) ///
		gr(ytitle(Daily time spent (%), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
		legend(size(medlarge))) ///
		barlabel(on) blposition(12) blsize(medlarge)
	graph export "`png_stub'/fraction_by_without.png", replace	

	cibar timeshare, over(without age_tercile) ///
		gr(ytitle(Daily time spent (%), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid) ///
		legend(size(medlarge))) ///
		barlabel(on) blposition(12) blsize(medsmall)
	graph export "`png_stub'/fraction_by_without_age.png", replace	
	

	* Fraction that 'wastes time'
	gen wastes_time = 0
	replace wastes_time = 100 if without == 100 & hours > 0

	keep responseid age_tercile wastes_time
	bysort responseid: egen waste_dummy = total(wastes_time)
	keep responseid age_tercile waste_dummy
	duplicates drop
	
	cibar waste_dummy, over(age_tercile) ///
		gr(ytitle(Wastes time (%), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid) ///
		legend(size(medlarge))) ///
		barlabel(on) blposition(12) blsize(medsmall)
	graph export "`png_stub'/fraction_wastestime_agegroup.png", replace		
		
restore 

* Explaining difference between previous version: Previous code was overweighting those who used more products they wish did not exist & not adding 0 for respondents that did not engage in any live with/without activities

// use "data/working/prolific/atus_3steps_scrshots.dta", replace
// drop if missing(without)
// egen h_without = sum(hours), by(without responseid)
// br responseid product without h_without
// sort responseid without
//
// cibar h_without, over(without) ///
// 	gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
// 	ylabel(, labsize(medlarge)) ///
// 	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
// 	legend(size(medlarge))) ///
// 	barlabel(on) blposition(12) blsize(medlarge)
// graph export "`png_stub'/hours_by_without_weight_prod_freq.png", replace	

********************************************************************************
*--------------------- LIVE WITHOUT (%) PER CATEGORY --------------------------*
********************************************************************************

* Only reports %s per product/category for live without question

use "data/working/prolific/atus_3steps_scrshots.dta", replace

drop if missing(without)
egen product_count = count(responseid), by(product)
drop if product_count < 20

keep responseid age_tercile product without category digital digital_category

* By product
graph hbar (mean) without if digital == 1, ///
	over(product, label(labsize(vsmall)) sort(1)) ///
	ytitle(Prefers world without (%), size(medium)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/without_digital_by_product.png", width(1000) height(1500) replace	

graph hbar (mean) without if digital == 0, ///
	over(product, label(labsize(vsmall)) sort(1)) ///
	ytitle(Prefers world without (%), size(medium)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/without_nondigital_by_product.png", width(1000) height(1500) replace	

* By category
sort category product

cibar without, over(category) ///
	gr(ytitle(Prefers world without (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge) rows (2))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/without_by_category.png", replace	

cibar without, over(digital_category) ///
	gr(ytitle(Prefers world without (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/without_by_digitalcategory.png", replace

cibar without, over(age_tercile digital_category) ///
	gr(ytitle(Prefers world without (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(vsmall)
graph export "`png_stub'/without_by_digitalcategory_age.png", replace			


use "data/working/prolific/atus_3steps_scrshots.dta", replace

keep responseid age_tercile product without
keep if !missing(without)
bys responseid: egen wastes_time = total(without)
keep responseid age_tercile wastes_time
replace wastes_time = 100 if wastes_time > 100
duplicates drop

cibar wastes_time, over(age_tercile) ///
	gr(ytitle(Wastes time (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/atleast1without_age.png", replace		


*TBD
* Hours spent conditional on preferring world without

use "data/working/prolific/atus_3steps_scrshots.dta", replace
br responseid product without hours category digital_category
tab without, m
tab without

keep if without == 100
tab digital 
tab digital_category

// bys responseid: egen resp_hours = total(hours)
// bys responseid digital_category: egen digital_hours = total(hours) 

collapse (sum) hours, by(responseid age_tercile digital_category)

bys responseid: egen resp_hours = total(hours)
sum resp_hours
gen timeshare = hours/resp_hours * 100
		
egen total_hours = total(hours)
bys digital_category: egen total_hours_category = total(hours) if !missing(digital_category)
gen share_hours_digcat = total_hours_category / total_hours *100

cibar share_hours_digcat, over(digital_category) ///
	gr(ytitle(Daily time spent (%), size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)
graph export "`png_stub'/conditionalwithout_total_timeshare_digitalcategory.png", replace		

// egen count_product = count(responseid), by(product)
// drop if count_product < 20
* Not enough data yet
/*
// preserve

	collapse (sum) hours if without == 100, by(responseid age_group category)

	cibar hours, over(category) ///
		gr(ytitle("Daily time spent (hrs)" "among prefers world without", size(medlarge)) ///
		ylabel(, labsize(medsmall)) ///
		xlabel(, labsize(small) valuelabel nogrid) ///
		legend(size(medium) rows(2))) ///
		barlabel(on) blposition(12) blsize(medium)
	graph export "`png_stub'/hours_amongwithout_by_age_digitalcategory.png", replace	

restore
*/
