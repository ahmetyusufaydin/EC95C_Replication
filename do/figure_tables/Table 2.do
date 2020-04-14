
*use "$Data\cleaned\LFS pool.dta", clear
use "$Data\built\Supply.dta", clear


bys yearg ageg uni (native): gen imm_nat = pop[1]/pop[2]
bys native yearg ageg (uni): gen ratio = imm_nat[2]/imm_nat[1]


*********************** First row (University) *********************************
eststo clear
label var imm_nat "\hspace{0.5cm}1973-1977"
forvalues j=28(5)58 {
   	local a=`j'-2
	local b=`j'+2
	*****************************************************************
	qui estpost tabstat imm_nat if g1975_`j'==1 & uni==1, stat(mean) 
	*****************************************************************
	eststo y1975_`j' , title(`a'-`b')
}
estout using "$Result\table2.tex", replace /// 
	cells(mean(fmt(3))) delimiter(&) end(\\) ///
	prehead("{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{7}{c}} \toprule &\multicolumn{7}{c}{Age}\\ \cmidrule{2-8}") ///  
	posthead("\midrule \textbf{University}\\") ///  
	label collabels(none) style(esttab) ///
	mlabels(, title span prefix(\multicolumn{@span}{c}{) suffix(}))
*********************** Other rows (University) ********************************
forvalues i=1980(5)2005 {
	eststo clear 
	local a=`i'-2
	local b=`i'+2
	label var imm_nat "\hspace{0.5cm}`a'-`b'"
	
	forvalues j=28(5)58 {
		*****************************************************************
		qui estpost tabstat imm_nat if g`i'_`j'==1 & uni==1, stat(mean) 
		*****************************************************************
		eststo y`i'_`j'
	}
	esttab using "$Result\table2.tex", cells(mean(fmt(3))) append f label ///
		nomtitle nonumber collabels(none) booktabs nogaps noline noobs
}

*********************** First row (Secondary) **********************************
eststo clear
label var imm_nat "\hspace{0.5cm}1973-1977"
forvalues j=28(5)58 {
	*****************************************************************
	qui estpost tabstat imm_nat if g1975_`j'==1 & uni==0, stat(mean) 
	*****************************************************************
	eststo y1975_`j'
}
esttab using "$Result\table2.tex", cells(mean(fmt(3))) append f label ///
	refcat(imm_nat "\textbf{Secondary}", nolabel) ///
	nomtitle nonumber collabels(none) booktabs nogaps noline noobs 
*********************** Other rows (Secondary) *********************************
forvalues i=1980(5)2005 {
	eststo clear 
	local a=`i'-2
	local b=`i'+2
	label var imm_nat "\hspace{0.5cm}`a'-`b'"
	
	forvalues j=28(5)58 {
		*****************************************************************
		qui estpost tabstat imm_nat if g`i'_`j'==1 & uni==0, stat(mean) 
		*****************************************************************
		eststo y`i'_`j'
	}
	esttab using "$Result\table2.tex", cells(mean(fmt(3))) append f label ///
		nomtitle nonumber collabels(none) booktabs nogaps noline noobs 
}

*********************** First row (Ratio) **************************************
eststo clear
label var ratio "\hspace{0.5cm}1973-1977"
forvalues j=28(5)58 {
	*****************************************************************
	qui estpost tabstat ratio if g1975_`j'==1 , stat(mean) 
	*****************************************************************
	eststo y1975_`j'
}
esttab using "$Result\table2.tex", cells(mean(fmt(3))) append f label ///
	refcat(ratio "\textbf{Ratio}", nolabel) ///
	nomtitle nonumber collabels(none) booktabs nogaps noline noobs 
*********************** Middle rows (Ratio) ************************************
forvalues i=1980(5)2000{
	eststo clear 
	local a=`i'-2
	local b=`i'+2
	label var ratio "\hspace{0.5cm}`a'-`b'"
	
	forvalues j=28(5)58 {
		*****************************************************************
		qui estpost tabstat ratio if g`i'_`j'==1, stat(mean) 
		*****************************************************************
		eststo y`i'_`j'
	}
	esttab using "$Result\table2.tex", cells(mean(fmt(3))) append f label ///
		nomtitle nonumber collabels(none) booktabs nogaps noline noobs 
}
*********************** Bottom row (Ratio) *************************************
eststo clear
label var ratio "\hspace{0.5cm}2003-2007"
forvalues j=28(5)58 {
	*****************************************************************
	qui estpost tabstat ratio if g2005_`j'==1 , stat(mean) 
	*****************************************************************
	eststo y1975_`j'
}
esttab using "$Result\table2.tex", cells(mean(fmt(3))) append f label ///
	nomtitle nonumber collabels(none) booktabs nogaps noline noobs ///
	postfoot("\bottomrule \multicolumn{8}{l}{\footnotesize Source: LFS}\\ \end{tabular}")

