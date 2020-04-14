/*
Append each round
Keep the sample used for main analysis: full-time working males aged 26-60.
Create education groups and year-age cells
*/

use "$Data\cleaned\GHS\ghs1973.dta", clear

forvalues i= 1974/2006 {
	capture append using "$Data\cleaned\GHS\ghs`i'.dta"
	if _rc continue
}

********************************************************************************
// SAMPLE: men, aged 26-60, exclude students/unknown educ, full-time workers
keep if sex==1
keep if age>=26 & age<=60
drop if missing(native)
drop if missing(ageleftfteduc)
keep if status==1 & ftpt==1
********************************************************************************

// Drop unnecessary variables
drop sex status ftpt


*****************************************************************
*********** GHS - List of Variables *****************************
*****************************************************************
label var age			"age"
label var ageleftfteduc	"age left full time education"
label var london		"dummy for london"
label var native		"dummy for born in UK"
label var yearofentry	"year of arrival UK - born elsewhere"
label var year			"survey year"
label var sampyear		"sample year - for those held in two years"
label var wage			"gross weekly earnings"
*****************************************************************

// Correct years for surveys conducted in two consecutive years
replace year=sampyear if year!=sampyear & sampyear!=.

// Education Groups
gen educ=2								//secondary equivalents (16-20)
replace educ=1 if ageleftfteduc<=15		//less than secondary  (15-)
replace educ=3 if ageleftfteduc>=21		//university graduates (21+)

// Year-Age Cells
forvalues i=1975(5)2005 {				//year groups
	forvalues j=28(5)58 {				//age groups
	
	gen g`i'_`j'=0
		replace g`i'_`j'=1 if age>=`j'-4 & age<=`j'   & year==`i'-2
		replace g`i'_`j'=1 if age>=`j'-3 & age<=`j'+1 & year==`i'-1
		replace g`i'_`j'=1 if age>=`j'-2 & age<=`j'+2 & year==`i' 
		replace g`i'_`j'=1 if age>=`j'-1 & age<=`j'+3 & year==`i'+1 
		replace g`i'_`j'=1 if age>=`j'   & age<=`j'+4 & year==`i'+2 
	}
}

save "$Data\cleaned\GHS pool.dta", replace

