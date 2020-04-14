

********************************************************************************
******************************** TABLE 1 ***************************************
********************************************************************************


********************************************************************************
*********************** Population Ratios (LFS) ********************************

use "$Data\built\Supply.dta", clear
drop g*

keep if inlist(yeargroup, 1975, 1985, 1995, 2005)

collapse (sum) pop, by(yearg uni native)

******* Panel 1: Immigrants/natives in population ***********
bys yearg uni (native): gen imm_nat = pop[1]/pop[2]
preserve
	collapse (sum) pop, by(yearg native)
	bys yearg (native): gen tot_imm_nat = pop[1]/pop[2]
	tempfile tot_imm_nat
	save `tot_imm_nat'
restore
merge m:1 yearg native using `tot_imm_nat'
drop _m

******* Panel 2: University graduates/secondary in population *********
bys yearg native (uni): gen uni_sec = pop[2]/pop[1]
preserve
	collapse (sum) pop, by(yearg uni)
	bys yearg (uni): gen tot_uni_sec = pop[2]/pop[1]
	tempfile tot_uni_sec
	save `tot_uni_sec'
restore
merge m:1 yearg uni using `tot_uni_sec'
drop _m


************* Panel 1: Immigrants/natives in population ************************
//First row
eststo clear
label var tot_imm_nat "\hspace{2cm}Total"
forvalues i=1975(10)2005 {
*****************************************************************************
	qui estpost tabstat tot_imm_nat if year==`i', stat(mean) 
	eststo y`i' , title(`i')
*****************************************************************************
}
estout using "$Result\table1.tex", replace /// 
	cells(mean(fmt(3))) delimiter(&) end(\\) ///
	prehead("{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{4}{c}} \toprule") ///  
	posthead("\midrule \textbf{Immigrants/natives in population}\\") ///  
	label collabels(none) style(esttab) modelwidth(20) ///
	mlabels(, title span prefix(\multicolumn{@span}{c}{) suffix(}))
//Other rows
local label1 "University"
local label0 "Secondary or less"
forvalues j=1(-1)0 {
	eststo clear
	label var imm_nat "\hspace{2cm}`label`j''"
	forvalues i=1975(10)2005 {
*****************************************************************************
		qui estpost tabstat imm_nat if year==`i' & uni==`j', stat(mean) 
		eststo y`i'
*****************************************************************************
	}
	esttab using "$Result\table1.tex", cells(mean(fmt(3))) append f label ///
		nomtitle nonumber collabels(none) booktabs nogaps noline noobs width(\hsize) modelwidth(20) 
}

************* Panel 2: University graduates/secondary in population ************

//First row
eststo clear
label var tot_uni_sec "\hspace{2cm}Total"
forvalues i=1975(10)2005 {
*****************************************************************************
	qui estpost tabstat tot_uni_sec if year==`i', stat(mean) 
	eststo y`i'
*****************************************************************************
}
esttab using "$Result\table1.tex", cells(mean(fmt(3))) append f label ///
nomtitle nonumber collabels(none) booktabs nogaps noline noobs width(\hsize) modelwidth(20) ///
posthead("\multicolumn{5}{l}{\textbf{University graduates/secondary in population}}\\") 
//Other rows
local label1 "Native-born"
local label0 "Immigrants"
forvalues j=1(-1)0 {
	eststo clear
	label var uni_sec "\hspace{2cm}`label`j''"
	forvalues i=1975(10)2005 {
*****************************************************************************
		qui estpost tabstat uni_sec if year==`i' & native==`j', stat(mean) 
		eststo y`i'
*****************************************************************************
	}
	esttab using "$Result\table1.tex", cells(mean(fmt(3))) append f label ///
		nomtitle nonumber collabels(none) booktabs nogaps noline noobs width(\hsize) modelwidth(20) 
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
drop if educ==1	// Do not include less than secondary in wage regressions


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
esttab using "$Result\table1.tex", keep(native) append f label b(3) width(\hsize) modelwidth(20) ///
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
	esttab using "$Result\table1.tex", keep(native) append f label b(3) width(\hsize) modelwidth(20) ///
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
esttab using "$Result\table1.tex", keep(uni) append f label b(3) width(\hsize) modelwidth(20) ///
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
esttab using "$Result\table1.tex", keep(uni) append f label b(3) width(\hsize) modelwidth(20) ///
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
esttab using "$Result\table1.tex", keep(uni) append f label b(3) width(\hsize) modelwidth(20) ///
	not nostar nomtitle nonumber collabels(none) booktabs nogaps noline noobs ///
	postfoot("\bottomrule \multicolumn{5}{p{0.75\linewidth}}{\footnotesize Source: LFS-GHS. The top part of the table shows population ratios between immigrants and natives and university and secondary school workers. The bottom part gives wage differentials across the same groups of workers. Returns to education are computed as a regression of log wages on a university dummy, a quadratic in age and a dummy for London. The native–immigrants wage differentials are computed similarly as a regression of logwages on a native dummy, a quadratic in age and a dummy for London. Regressions include only those with a university degree or a secondary qualification}\\ \end{tabular}")

		





