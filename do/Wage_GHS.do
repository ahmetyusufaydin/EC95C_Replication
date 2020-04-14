/*
Deflate wages
Drop outliers and missing wages
Generate a university dummy
Compute average wage by cells (dependent var in eq 10)
Estimate native wage premia (eq8-Table4) 
and return to university education (eq9,11-Table3) for each cell; 
and store inverse of estimated variances to use them as weights for the main regressions.
*/

use "$Data\cleaned\GHS pool.dta", clear

// Deflate wages with CPI (1990=1)
merge m:1 year using "$Data\deflator\CPI.dta"
drop _m
replace wage = wage/deflator

// Drop outliers and missings
drop if wage==0 | wage==.
drop if wage<50 | wage>2000

gen lwage = log(wage)

// Generate university dummy
gen uni = educ==3
drop if educ==1		// Do not include less than secondary in wage regressions

********************************************************************************
// Compute average wage by cells (dependent var in eq 10)
bys native uni g*: egen avwage = mean(wage)


******* Native wage premia (eq 8) **********************************************
gen nativewp=0
gen nativeVar=0

forvalues i=1975(5)2005 {				//year groups
	forvalues j=28(5)58 {				//age groups
		forvalues l=0/1 {				//education groups
			qui reg lwage native age i.year london  if g`i'_`j'==1 & uni==`l'
			replace nativewp = _b[native] 			if g`i'_`j'==1 & uni==`l'
			replace nativeVar=e(V)[1,1]				if g`i'_`j'==1 & uni==`l'
		}
	}
}

****** Return to education (eq 9 and 11) ***************************************
gen uniwp=0
gen uniVar=0

forvalues i=1975(5)2005 {				//year groups
	forvalues j=28(5)58 {				//age groups
		forvalues l=0/1 {				//nativity groups
			qui reg lwage uni age i.year london if g`i'_`j'==1 & native==`l'
			replace uniwp = _b[uni] 			if g`i'_`j'==1 & native==`l'
			replace uniVar=e(V)[1,1]			if g`i'_`j'==1 & native==`l'
		}
	}
}

// Compute weights for dependent variables for each cell as the inverse of estimated variances
gen nativeW = 1/nativeVar
gen uniW = 1/uniVar

// Keep needed var.s for each cell 
collapse (min) nativewp nativeW uniwp uniW avwage, by(native uni g*)


save "$Data\built\Wage.dta", replace





