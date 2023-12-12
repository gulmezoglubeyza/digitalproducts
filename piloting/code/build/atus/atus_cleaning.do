clear all

use "data/raw/atus/atus2022_original.dta", clear

/*
 Summary:
 - Remove redundant variables
 - Rename s.t. only activities begin with t
 - Reshape
 - Generate categories
 - Calculate weighted sum of each activity
 - Sort & save
 
Note on weights: https://www.bls.gov/tus/atususersguide.pdf#nameddest=CHAPTER%207:%20WEIGHTS,%20LINKING,%20AND%20ESTIMATION: The ATUS final weights indicate the number of person-days the respondent represents. 
 */
 
rename tucaseid atus_id 
rename tufinlwgt atus_weight

rename tryhhchild dem_yhhchild
rename teage dem_age
rename tesex dem_sex
rename peeduca dem_educa
rename ptdtrace dem_race
rename pehspnon dem_hspnon
rename gtmetsta dem_metsta
rename telfs dem_lfs
rename temjot dem_mjob
rename trdpftpt dem_ftpt
rename teschenr dem_schenr
rename teschlvl dem_schlvl
rename trsppres dem_sppres
rename tespempnot dem_spempnot
rename trernwa dem_ernwa
rename trchildnum dem_childnum
rename trspftpt dem_spftpt
rename tehruslt dem_hruslt

rename tudiaryday dairy_day
rename trholiday dairy_holiday 

drop  trtec trthh

reshape long t, i(atus_id) j(activity) string 
rename t minutes

gen category = 0
replace category = 1 if substr(activity, 1, 2) == "01"
replace category = 2 if substr(activity, 1, 2) == "02"
replace category = 3 if substr(activity, 1, 2) == "03"
replace category = 4 if substr(activity, 1, 2) == "04"
replace category = 5 if substr(activity, 1, 2) == "05"
replace category = 6 if substr(activity, 1, 2) == "06"
replace category = 7 if substr(activity, 1, 2) == "07"
replace category = 8 if substr(activity, 1, 2) == "08"
replace category = 9 if substr(activity, 1, 2) == "09"
replace category = 10 if substr(activity, 1, 2) == "10"
replace category = 11 if substr(activity, 1, 2) == "11"
replace category = 12 if substr(activity, 1, 2) == "12"
replace category = 13 if substr(activity, 1, 2) == "13"
replace category = 14 if substr(activity, 1, 2) == "14"
replace category = 15 if substr(activity, 1, 2) == "15"
replace category = 16 if substr(activity, 1, 2) == "16"
replace category = 18 if substr(activity, 1, 2) == "18"
replace category = 50 if substr(activity, 1, 2) == "50"

collapse (mean) minutes (first) category [pw=atus_weight], by(activity)
destring activity, replace

do "code/build/atus/helper_labels.do"
label values category category_lbl
label values activity activity_lbl

gsort category -minutes activity

save "data/working/atus/atus2022.dta", replace
