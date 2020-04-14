

********************************************************************************
******************************** TABLE 1 ***************************************
********************************************************************************


********************************************************************************
*********************** Population Ratios (LFS) ********************************

use "$Data\cleaned\LFS pool.dta", clear

gen uni = educ==3

// Averages across five contiguous years
recode year (1973/1977 = 1975) (1983/1987 = 1985) (1993/1997 = 1995) (2003/2007 = 2005)
*recode year (1983/1987 = 1985) (1993/1997 = 1995) (2003/2006 = 2005)

keep if inlist(year, 1975, 1985, 1995, 2005)

gen immigrant = 1-native


************* Panel 1: Immigrants/natives in population ************************
preserve

collapse (sum) native immigrant [aweight=weight], by(year)
gen ratio = immigrant/native

tempfile total
save `total'
restore

collapse (sum) native immigrant [aweight=weight], by(year uni)
gen ratio = immigrant/native

append using `total'

recode uni .=-1

************* Panel 1 *************
//First row
eststo clear
label var ratio "\hspace{2cm}Total"
forvalues i=1975(10)2005 {
*****************************************************************************
	qui estpost tabstat ratio if year==`i' & uni==-1, stat(mean) 
	eststo y`i' , title(`i')
*****************************************************************************
}
estout using "$Result\table1.tex", replace /// 
	cells(mean(fmt(3))) delimiter(&) end(\\) ///
	prehead("{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{4}{c}} \toprule") ///  
	posthead("\midrule \textbf{Immigrants/natives in population}\\") ///  
	label collabels(none) style(esttab) ///
	mlabels(, title span prefix(\multicolumn{@span}{c}{) suffix(}))
//Other rows
local label1 "University"
local label0 "Secondary or less"
forvalues j=1(-1)0 {
	eststo clear
	label var ratio "\hspace{2cm}`label`j''"
	forvalues i=1975(10)2005 {
*****************************************************************************
		qui estpost tabstat ratio if year==`i' & uni==`j', stat(mean) 
		eststo y`i'
*****************************************************************************
	}
	esttab using "$Result\table1.tex", cells(mean(fmt(3))) append f label ///
		nomtitle nonumber collabels(none) booktabs nogaps noline noobs
}

************* Panel 2: University graduates/secondary in population ************
use "$Data\cleaned\LFS pool.dta", clear

gen uni = educ==3
recode year (1973/1977 = 1975) (1983/1987 = 1985) (1993/1997 = 1995) (2003/2007 = 2005)
*recode year (1983/1987 = 1985) (1993/1997 = 1995) (2003/2006 = 2005)

keep if inlist(year, 1975, 1985, 1995, 2005)

gen secondary = 1-uni

//Panel 2: University graduates/secondary in population
preserve
collapse (sum) uni secondary [aweight=weight], by(year)
gen ratio = uni/secondary

tempfile total2
save `total2'
restore

collapse (sum) uni secondary [aweight=weight], by(year native)
gen ratio = uni/secondary

append using `total2'

recode native .=-1

//First row
eststo clear
label var ratio "\hspace{2cm}Total"
forvalues i=1975(10)2005 {
*****************************************************************************
	qui estpost tabstat ratio if year==`i' & native==-1, stat(mean) 
	eststo y`i'
*****************************************************************************
}
esttab using "$Result\table1.tex", cells(mean(fmt(3))) append f label ///
nomtitle nonumber collabels(none) booktabs nogaps noline noobs ///
posthead("\multicolumn{5}{l}{\textbf{University graduates/secondary in population}}\\") 
//Other rows
local label1 "Native-born"
local label0 "Immigrants"
forvalues j=1(-1)0 {
	eststo clear
	label var ratio "\hspace{2cm}`label`j''"
	forvalues i=1975(10)2005 {
*****************************************************************************
		qui estpost tabstat ratio if year==`i' & native==`j', stat(mean) 
		eststo y`i'
*****************************************************************************
	}
	esttab using "$Result\table1.tex", cells(mean(fmt(3))) append f label ///
		nomtitle nonumber collabels(none) booktabs nogaps noline noobs
}


********************************************************************************
*********************** Wage Differentials (GHS) *******************************

use "$Data\cleaned\GHS pool.dta", clear

// Deflate wages with CPI (1990=1)
merge m:1 year using "$Data\deflator\CPI.dta"
drop _m

replace wage = wage/deflator

// Wages by cell
drop if wage==0 | wage==.
drop if wage<50 | wage>2000

gen lwage = log(wage)
gen agesq = age^2

gen uni = educ==3
replace uni=. if educ==1	// Do not include less than secondary in wage regressions


******** Panel 3: Native-immigrant wage differential ***************************

//First row
eststo clear
label var native "\hspace{2cm}Total"
forvalues i=1975(10)1995 {
*****************************************************************
	qui reg lwage native agesq london if year==`i'
	eststo y`i'
*****************************************************************
}
qui reg lwage native agesq london [aweight=weight] if year==2005
eststo y2005
esttab using "$Result\table1.tex", keep(native) append f label b(3) ///
	not nostar nomtitle nonumber collabels(none) booktabs nogaps noline noobs ///
	posthead("\multicolumn{5}{l}{\textbf{Native-immigrant wage differential}}\\") 
//Other rows
local label1 "\hspace{2cm}University"
local label0 "\hspace{2cm}Secondary"
forvalues j=1(-1)0 {
	eststo clear
	label var native "`label`j''"
	forvalues i=1975(10)1995 {
*****************************************************************
		qui reg lwage native agesq london if year==`i' & uni==`j' 
		eststo y`i'
*****************************************************************
	}
	qui reg lwage native agesq london [aweight=weight] if year==2005 & uni==`j' 
	eststo y2005
	esttab using "$Result\table1.tex", keep(native) append f label b(3) ///
		not nostar nomtitle nonumber collabels(none) booktabs nogaps noline noobs
}


********* Panel 4: Return to university education ******************************
//First row
eststo clear
label var uni "\hspace{2cm}Total"
forvalues i=1975(10)1995 {
**************************************************************
	qui reg lwage uni agesq london if year==`i'
	eststo y`i'
**************************************************************
}
qui reg lwage uni agesq london [aweight=weight] if year==2005
eststo y2005
esttab using "$Result\table1.tex", keep(uni) append f label b(3) ///
	not nostar nomtitle nonumber collabels(none) booktabs nogaps noline noobs ///
	posthead("\multicolumn{5}{l}{\textbf{Return to university education}}\\") 
//Second row
eststo clear
label var uni "\hspace{2cm}Native-born"
forvalues i=1975(10)1995 {
****************************************************************************
	qui reg lwage uni agesq london if year==`i' & native==1
	eststo y`i'
****************************************************************************
}
qui reg lwage uni agesq london [aweight=weight] if year==2005 & native==1
eststo y2005
esttab using "$Result\table1.tex", keep(uni) append f label b(3) ///
	not nostar nomtitle nonumber collabels(none) booktabs nogaps noline noobs
//Last row
eststo clear
label var uni "\hspace{2cm}Immigrants"
forvalues i=1975(10)1995 {
****************************************************************************
	qui reg lwage uni agesq london if year==`i' & native==0
	eststo y`i'
****************************************************************************
}
qui reg lwage uni agesq london [aweight=weight] if year==2005 & native==0
eststo y2005
esttab using "$Result\table1.tex", keep(uni) append f label b(3) ///
	not nostar nomtitle nonumber collabels(none) booktabs nogaps noline noobs ///
	postfoot("\bottomrule \multicolumn{5}{l}{\footnotesize Source: LFS-GHS}\\ \end{tabular}")

		





