clear all
label drop _all

log using "code/logs/which_products_count.log", replace name(which_products_count)

insheet using "data/raw/prolific/digital_social_products/digital-social-products_December 8, 2023_10.18.csv", names clear
drop in 1/2
drop if status == "Survey Preview" 	
drop if strpos(consent, "NOT")
destring *, replace

keep responseid any_digital which_digital any_product which_products

tempfile products
save `products', replace

* append categories and products data
insheet using "data/raw/prolific/digital_social_categories/digital-social-categories_December 6, 2023_10.10.csv", names clear
drop in 1/2
drop if status == "Survey Preview" 	
drop if strpos(consent, "NOT")
destring *, replace

keep responseid any_digital which_digital any_product which_products
append using `products'

tab any_digital // 25.65% of respondents use digital products they wish didn't exist
tab any_product // 17.43% of respondents use non-digital products they wish didn't exist

* count number of responses to which_digital which mention social media
gen social_digital = regexm(lower(which_digital), "facebook|pinterest|instagram|linkedin|twitter|snapchat|youtube|whatsapp|reddit|tiktok|nextdoor|dating|media")
replace social_digital = . if missing(which_digital)
tab social_digital // 79.07% of answers indicate social media
* 20% of the total responses

gen social_physical= regexm(lower(which_products), "facebook|pinterest|instagram|linkedin|twitter|snapchat|youtube|whatsapp|reddit|tiktok|nextdoor|dating|media")
replace social_physical = . if missing(which_products)
tab social_physical // 11.49% of answers indicate social media

log close which_products_count
