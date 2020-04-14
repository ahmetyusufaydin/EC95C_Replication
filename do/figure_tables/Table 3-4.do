
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
*********************** TABLE 3 (Return to education) **************************

*********************** First row of the table *********************************
eststo clear
label var uni "1973-1977"
forvalues j=28(5)58 {
	local a=`j'-2
	local b=`j'+2
	*****************************************************************
	qui reg lwage uni age i.year london if g1975_`j'==1 & native==1	//UK born
	*****************************************************************
	eststo y1975_`j' , title(`a'-`b')
}
 estout using "$Result\table3.tex", replace ///  
		cells(b(fmt(a3)) se(fmt(3) par)) ///
		varwidth(15) modelwidth(15) delimiter(&) end(\\) /// 
		prehead("{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{7}{c}} \toprule  &\multicolumn{7}{c}{Age}\\ \cmidrule{2-8}") ///  
		posthead("\midrule \textbf{UK born}\\") ///  
		label ///  
		varlabels(_cons Constant, end("" \addlinespace) nolast) ///  
		mlabels(, title span prefix(\multicolumn{@span}{c}{) suffix(})) ///  
		collabels(none) ///  
		eqlabels(, begin("\midrule" "") nofirst) /// 
		substitute(_ \_ "\_cons " \_cons) ///  
		interaction(" $\times$ ") /// 
		notype level(95) ///  
		style(esttab) /// 
		keep(uni)  
*********************** Middle rows (UK born) **********************************
forvalues i=1980(5)2005 {
	eststo clear 
	local a=`i'-2
	local b=`i'+2
	label var uni "`a'-`b'"
	
	forvalues j=28(5)58 {
		*****************************************************************
		qui reg lwage uni age i.year london if g`i'_`j'==1 & native==1
		*****************************************************************
		eststo y`i'_`j'
	}
	esttab using "$Result\table3.tex", keep(uni) append f label b(3) se(3) ///
	nostar nomtitle nonumber collabels(none) booktabs nogaps noline noobs 
}
*********************** First row (Foreign born) *******************************
eststo clear 
label var native "1973-1977"
forvalues j=28(5)58 {
	*****************************************************************
	qui reg lwage uni age i.year london if g1975_`j'==1 & native==0
	*****************************************************************
	eststo y1975_`j'
}
esttab using "$Result\table3.tex", keep(uni) append f label b(3) se(3) ///
	refcat(uni "\textbf{Foreign born}", nolabel) ///
	nostar nomtitle nonumber collabels(none) booktabs nogaps noline noobs 
	
*********************** Middle rows (Foreign born) *****************************
forvalues i=1980(5)2000 {
	eststo clear 
	local a=`i'-2
	local b=`i'+2
	label var uni "`a'-`b'"
	
	forvalues j=28(5)58 {
		*****************************************************************
		qui reg lwage uni age i.year london if g`i'_`j'==1 & native==0	//Foreign born
		*****************************************************************
		eststo y`i'_`j'
	}
	esttab using "$Result\table3.tex", keep(uni) append f label b(3) se(3) ///
	nostar nomtitle nonumber collabels(none) booktabs nogaps noline noobs 
}
*********************** Bottom row of the table *******************************
eststo clear 
label var uni "2003-2007"
forvalues j=28(5)58 {
	*****************************************************************
	qui reg lwage uni age i.year london if g2005_`j'==1 & native==0
	*****************************************************************
	eststo y2005_`j'
}
esttab using "$Result\table3.tex", keep(uni) append f label b(3) se(3) ///
	nostar nomtitle nonumber collabels(none) booktabs nogaps noline noobs ///     
	postfoot("\bottomrule \multicolumn{8}{l}{\footnotesize Notes: Standard errors of the estimated coefficients in parantheses. Source: GHS}\\ \end{tabular}")
********************************************************************************
********************************************************************************



********************************************************************************
*********************** TABLE 4 (Native wage premia) ***************************

*********************** First row of the table *********************************
eststo clear
label var native "1973-1977"
forvalues j=28(5)58 {
	local a=`j'-2
	local b=`j'+2
	*****************************************************************
	qui reg lwage native age i.year london if g1975_`j'==1 & uni==1	//University
	*****************************************************************
	eststo y1975_`j' , title(`a'-`b')
}
 estout using "$Result\table4.tex", replace ///  
		cells(b(fmt(3)) se(fmt(3) par)) ///
		varwidth(15) modelwidth(15) delimiter(&) end(\\) /// 
		prehead("{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{7}{c}} \toprule  &\multicolumn{7}{c}{Age}\\ \cmidrule{2-8}") ///  
		posthead("\midrule \textbf{University}\\") ///  
		label ///  
		varlabels(_cons Constant, end("" \addlinespace) nolast) ///  
		mlabels(, title span prefix(\multicolumn{@span}{c}{) suffix(})) ///  
		collabels(none) ///  
		eqlabels(, begin("\midrule" "") nofirst) /// 
		substitute(_ \_ "\_cons " \_cons) ///  
		interaction(" $\times$ ") /// 
		notype level(95) ///  
		style(esttab) /// 
		keep(native)  
*********************** Middle rows (University) *******************************
forvalues i=1980(5)2005 {
	eststo clear 
	local a=`i'-2
	local b=`i'+2
	label var native "`a'-`b'"
	
	forvalues j=28(5)58 {
		*****************************************************************
		qui reg lwage native age i.year london if g`i'_`j'==1 & uni==1
		*****************************************************************
		eststo y`i'_`j'
	}
	esttab using "$Result\table4.tex", keep(native) append f label b(3) se(3) ///
		nostar nomtitle nonumber collabels(none) booktabs nogaps noline noobs 
}
*********************** First row (Secondary) *********************************
eststo clear 
label var native "1973-1977"
forvalues j=28(5)58 {
	*****************************************************************
	qui reg lwage native age i.year london if g1975_`j'==1 & uni==0
	*****************************************************************
	eststo y1975_`j'
}
esttab using "$Result\table4.tex", keep(native) append f label b(3) se(3) ///
	refcat(native "\textbf{Secondary}", nolabel) ///
	nostar nomtitle nonumber collabels(none) booktabs nogaps noline noobs 
	
*********************** Middle rows (Secondary) ********************************
forvalues i=1980(5)2000 {
	eststo clear 
	local a=`i'-2
	local b=`i'+2
	label var native "`a'-`b'"
	
	forvalues j=28(5)58 {
		*****************************************************************
		qui reg lwage native age i.year london if g`i'_`j'==1 & uni==0
		*****************************************************************
		eststo y`i'_`j'
	}
	esttab using "$Result\table4.tex", keep(native) append f label b(3) se(3) ///
		nostar nomtitle nonumber collabels(none) booktabs nogaps noline noobs 
}
*********************** Bottom row of the table *******************************
eststo clear 
label var native "2003-2007"
forvalues j=28(5)58 {
	*****************************************************************
	qui reg lwage native age i.year london if g2005_`j'==1 & uni==1
	*****************************************************************
	eststo y2005_`j'
}
esttab using "$Result\table4.tex", keep(native) append f label b(3) se(3) ///
	nostar nomtitle nonumber collabels(none) booktabs nogaps noline noobs ///     
	postfoot("\bottomrule \multicolumn{8}{l}{\footnotesize Notes: Standard errors of the estimated coefficients in parantheses. Source: GHS}\\ \end{tabular}")
********************************************************************************
********************************************************************************