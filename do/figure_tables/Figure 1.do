
********************************************************************************
*********************** Figure 1 (Immigrant Shares) ****************************
********************************************************************************

//Note: Age left full time education is coded as "18 or more" in 1977, so it is impossible to differentiate university graduates

use "$Data\cleaned\LFS pool.dta", clear

// Run this if you want to show ft working male population instead of whole male population
*keep if workft==1

******* Estimate populations by cell ***************************************
replace weight = weight/3 if year==1992		// LFS held in 3 quarters in 1992,
replace weight = weight/4 if year>1992		// every quarters after 1993

// Average estimated population in each cell
collapse (sum) pop=weight, by(year native uni)


***** Compute immigrant shares for University/Secondary/All and merge them
// University
preserve
	keep if uni==1
	drop if year==1977
	bys year (native): egen immShareUni= pc(pop), prop
	drop if native==1
	tempfile immShareUni
	save `immShareUni'
restore

// Secondary
preserve
	keep if uni==0
	drop if year==1977
	bys year (native): egen immShareSec= pc(pop), prop
	drop if native==1
	tempfile immShareSec
	save `immShareSec'
restore

// All
	collapse (sum) pop, by(year native)
	bys year (native): egen immShareAll= pc(pop), prop
	drop if native==1

merge 1:1 year using `immShareUni'
drop _m
merge 1:1 year using `immShareSec'
drop _m
drop native uni pop

// Compute 3-year moving averages
sort year
gen immUniMA = (immShareUni+immShareUni[_n-1]+immShareUni[_n-2])/3
gen immSecMA = (immShareSec+immShareSec[_n-1]+immShareSec[_n-2])/3
gen immAllMA = (immShareAll+immShareAll[_n-1]+immShareAll[_n-2])/3

replace immSecMA = (immShareSec+immShareSec[_n-2])/2	if year==1979
replace immUniMA = (immShareUni+immShareUni[_n-2])/2	if year==1979

replace immSecMA = (immShareSec+immShareSec[_n-1])/2	if year==1981
replace immUniMA = (immShareUni+immShareUni[_n-1])/2	if year==1981

/* 
replace immAllMA = (immShareAll+immShareAll[_n-1])/2	if year<=1984
replace immUniMA = (immShareUni+immShareUni[_n-1])/2 	if year<=1984
replace immSecMA = (immShareSec+immShareSec[_n-1])/2	if year<=1984
*/

drop if year==1975 //| year==2007
twoway connected immAllMA immUniMA immSecMA year, ///
	ytitle("") xtitle("year") msymbol(s d t) ///
	xlab(1977(3)2007) ///
	ylab(,labs(small) angle(0)) ///
	legend(size(3) label(1 "All") label(2 "University") label(3 "Secondary education or less"))
graph export "$Result/figure1.png", replace

