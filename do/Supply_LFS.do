
*******************************************************************************
* Compute labor supply for each cell (age–year-education–immigrant)
* Measure labor supply with population
* 
* Secondary equivalent = exactly secondary + WEIGHT*less than secondary
********************************************************************************


use "$Data\cleaned\LFS pool.dta", clear

// Run this if you want to measure supply as ft working male population instead of whole male population
*keep if workft==1

// Generate age groups to match with supply weight data
// and year groups to use later in estimation
gen agegroup=0
gen yeargroup=0
forvalues i=1975(5)2005 {				//year groups
	forvalues j=28(5)58 {				//age groups
		replace agegroup = `j' if g`i'_`j'==1
		replace yeargroup= `i' if g`i'_`j'==1
	}
}
// Drop those remained outside the cohort groups (eg. age 26-27 in 1977)
drop if agegroup==0

// There is a single code for ageleftfteduc 18 or over; so no way to differentiate university graduates
drop if year==1977

******* Estimate populations by cell ***************************************
replace weight = weight/3 if year==1992		// LFS held in 3 quarters in 1992,
replace weight = weight/4 if year>1992		// every quarters after 1993
// There are two years in yeargroup 1980, 5 years in others 
*replace weight = weight/2 if yeargroup==1975
replace weight = weight/2 if yeargroup==1980
replace weight = weight/5 if yeargroup>1980
// Average estimated population in each cell
collapse (sum) pop=weight, by(yearg ageg native educ g*)


******* Merge supply weights for those with less than secondary education
merge m:1 agegroup native using "$Data\built\Supply Weight.dta"

******* Compute weighted sum for secondary equivalents **********************
// Fix weights to 1 for secondary and university graduates
replace supWeight=1 if educ!=1
// Compute weighted sum of population for those with less than secondary education
replace pop=pop*supWeight
// Generate university dummy
gen uni = educ==3

// Compute population in each age-year-native-education groups (2 educ class)
// Weighted sum for secondary equivalents
collapse (sum) pop, by(native uni agegroup yeargroup g*)


save "$Data\built\Supply.dta", replace
