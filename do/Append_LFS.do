/*
Append each round
Keep the sample used for main analysis: males aged 26-60.
Create education groups and year-age cells
*/

use "$Data\cleaned\LFS\lfs1975.dta", clear

append using "$Data\cleaned\LFS\lfs1977.dta"
append using "$Data\cleaned\LFS\lfs1979.dta"
append using "$Data\cleaned\LFS\lfs1981.dta"
forvalues i= 1983/1991 {
	append using "$Data\cleaned\LFS\lfs`i'.dta"
}
forvalues i= 1992/2007 {
foreach q in jm aj js od {
	capture append using "$Data\cleaned\LFS\lfs`i'_`q'.dta"
	if _rc continue
}
}

// SAMPLE: men, aged 26-60, exclude students, unknown education and nativity
keep if sex==1
keep if age>=26 & age<=60
drop if missing(native)
drop if missing(ageleftfteduc)
*keep if workft==1

drop sex

*****************************************************************
*********** LFS - List of Variables *****************************
*****************************************************************
label var age			"age"
label var ageleftfteduc	"age left full time education"
label var london		"dummy for london"
label var native		"dummy for born in UK"
label var yearofentry	"year of arrival UK for immigrants"
label var year			"survey year"
label var quarter		"survey quarter"
label var weight		"person level weight"
*****************************************************************


// Education Groups
gen educ=2								//secondary equivalents (16-20)
replace educ=1 if ageleftfteduc<=15		//less than secondary  (15-)
replace educ=3 if ageleftfteduc>=21		//university graduates (21+)

gen uni = educ==3						//university dummy

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

save "$Data\cleaned\LFS pool.dta", replace
