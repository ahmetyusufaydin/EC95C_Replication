/*
Compute weight for less than secondary to estimate labor supply for secondary equivalent

Weights are given by the relative wages of secondary school dropouts relative to 
those with completed secondary education by age, time, and immigrant status. 
These weights are time invariant, since they are averages by cell over time.

To derive the weights we only take the sample of those with
secondary education or less. We run regressions of log wages by cell on a dummy for
less than secondary (left full-time education before age 16) over the entire time period
(1977 to 2006). In the regressions we also condition for year dummies, a dummy for
London and a linear term in age. Regressions are run separately for immigrants and
natives. In this way we compute average (over the entire period) wage differentials
while controlling for potential compositional effects due the business cycle, life-cycle
effects and workers’ residential location. 

see Appendix A of the article
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


// Compute weight for less than secondary to estimate labor supply for secondary equivalent
drop if educ==3			//Drop university graduates
gen less = educ==1		//Dummy for less then secondary education

gen agegroup=0
forvalues i=1975(5)2005 {				//year groups
	forvalues j=28(5)58 {				//age groups
		replace agegroup = `j' if g`i'_`j'==1
	}
}

gen coef=0
	forvalues j=28(5)58 {				//age groups
		qui reg lwage less age i.year london 	if agegroup==`j' & native==1
		replace coef=_b[less] 			 		if agegroup==`j' & native==1
		qui reg lwage less age i.year london 	if agegroup==`j' & native==0
		replace coef=_b[less] 			 		if agegroup==`j' & native==0
	}
gen relativewage = exp(coef)
rename relativewage supWeight

collapse (min) supWeight, by(agegroup native)

save "$Data\built\Supply Weight.dta", replace



/*
gen coef=0
gen agegroup=0
forvalues i=1975(5)2005 {				//year groups
	forvalues j=28(5)58 {				//age groups
		qui reg lwage less age i.year london if g`i'_`j'==1 & native==1
		replace coef=_b[less] 			 if g`i'_`j'==1 & native==1
		qui reg lwage less age i.year london if g`i'_`j'==1 & native==0
		replace coef=_b[less] 			 if g`i'_`j'==1 & native==0
		replace agegroup = `j' if g`i'_`j'==1
	}
}
gen relativewage = exp(coef)
collapse (mean) supWeight = relativewage, by(agegroup native)

save "$Data\built\Supply Weight.dta", replace

