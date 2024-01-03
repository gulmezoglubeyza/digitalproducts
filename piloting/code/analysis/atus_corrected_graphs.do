clear all
label drop _all
set scheme tab2

local png_stub "output/figures/prolific/atus_3steps/corrected/"

use "data/temp/atus_3steps_corrected.dta", clear
* dataset is on the product x respondent level (92 X 182)
*** HOURS SPENT

* By product
graph hbar (mean) hours if digital == 1, ///
	over(product, label(labsize(vsmall)) sort(1)) ///
	ytitle(Daily time spent (hrs), size(medium)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/hours_digital_by_product.png", width(1000) height(1500) replace	

graph hbar (mean) hours if digital == 2, ///
	over(product, label(labsize(vsmall)) sort(1)) ///
	ytitle(Daily time spent (hrs), size(medium)) ///
	ylabel(0(1)6, labsize(medlarge)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/hours_nondigital_by_product.png", width(1000) height(1500) replace	

* By category
preserve
	
	collapse (sum) hours, by(category responseid age_group)

	cibar hours, over(category) ///
		gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
		legend(size(medsmall) rows(2))) ///
		barlabel(on) blposition(12) blsize(medlarge)
	graph export "`png_stub'/hours_by_category.png", replace
	
	cibar hours, over(category age_group) ///
		gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid) ///
		legend(size(medsmall) rows(2))) ///
		barlabel(on) blposition(12) blsize(small)
	graph export "`png_stub'/hours_by_category.png", replace

restore

* By digital category
preserve
	
	collapse (sum) hours, by(digital_category responseid age_group)

	cibar hours, over(digital_category) ///
		gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
		legend(size(medsmall) rows(2))) ///
		barlabel(on) blposition(12) blsize(medlarge)
	graph export "`png_stub'/hours_by_category.png", replace
	
	cibar hours, over(age_group digital_category) ///
		gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid) ///
		legend(size(medlarge))) ///
		barlabel(on) blposition(12) blsize(small)
	graph export "`png_stub'/hours_by_category_age.png", replace

restore


* LIVE WITHOUT
use "data/temp/atus_3steps_corrected.dta", clear

preserve

	keep responseid
	duplicates drop
	expand 2
	bys responseid: gen without= _n
	replace without = 0 if without == 1
	replace without = 100 if without == 2

	tempfile balcat
	save `balcat'

restore

// preserve 
	
	collapse (sum) hours if !missing(without), by(responseid without age_group) 

	merge 1:1 without responseid using `balcat'
	assert missing(hours) if _merge == 2
	drop _merge

	sort responseid
	duplicates report responseid
	tab without

	replace hours = 0 if missing(hours)

	bys responseid (age_group): replace age_group = age_group[_n-1] if missing(age_group)
	
	* hours spent on live with vs without
	
	cibar hours, over(without) ///
		gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
		legend(size(large))) ///
		barlabel(on) blposition(12) blsize(medlarge)
	graph export "`png_stub'/hours_by_without.png", replace	
	
	cibar hours, over(without age_group) ///
		gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid) ///
		legend(size(large))) ///
		barlabel(on) blposition(12) blsize(medlarge)
	graph export "`png_stub'/hours_by_without.png", replace	
	
	cibar hours if hours > 0, over(without) ///
		gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
		legend(size(medlarge))) ///
		barlabel(on) blposition(12) blsize(medlarge)
	
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

	cibar timeshare, over(without age_group) ///
		gr(ytitle(Daily time spent (%), size(medlarge)) ///
		ylabel(, labsize(medlarge)) ///
		xlabel(, labsize(medlarge) valuelabel nogrid) ///
		legend(size(medlarge))) ///
		barlabel(on) blposition(12) blsize(medsmall)
	graph export "`png_stub'/fraction_by_without_age.png", replace	


// restore 

* Previous graph was overweighting those who used more products they wish did not exist
use "data/temp/atus_3steps_corrected.dta", clear
drop if missing(without)
egen h_without = sum(hours), by(without responseid)

cibar h_without, over(without) ///
	gr(ytitle(Daily time spent (hrs), size(medlarge)) ///
	ylabel(, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid angle(45)) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(medlarge)
	

use "data/temp/atus_3steps_corrected.dta", clear

* WITHOUT
drop if missing(without)
egen product_count = count(responseid), by(product)
drop if product_count < 20

keep responseid age_group product without category digital_category

* By product
graph hbar (mean)  without if digital == 1, ///
	over(product, label(labsize(vsmall)) sort(1)) ///
	ytitle(Prefers world without (%), size(medium)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	blabel(bar, position(6) gap(0) size(vsmall) format(%9.2f)) ///
	xsize(10cm) ysize(15cm)
graph export "`png_stub'/without_digital_by_product.png", width(1000) height(1500) replace	

graph hbar (mean) without if digital == 2, ///
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
graph export "`png_stub'/without_by_category.png", replace

cibar without, over(age_group digital_category) ///
	gr(ytitle(Prefers world without (%), size(medlarge)) ///
	ylabel(0(20)100, labsize(medlarge)) ///
	xlabel(, labsize(medlarge) valuelabel nogrid) ///
	legend(size(medlarge))) ///
	barlabel(on) blposition(12) blsize(small)
graph export "`png_stub'/without_by_category.png", replace			

* HOURS AMONG WITHOUT

use "data/temp/atus_3steps_corrected.dta", clear
keep if without == 100
egen count_product = count(responseid), by(product)
drop if count_product < 20
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
