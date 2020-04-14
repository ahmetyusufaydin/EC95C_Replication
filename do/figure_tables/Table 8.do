
use "$Data\built\Simulation.dta", clear

tabstat d1m d2m d3 d4 total if native==0 & uni==0, stat(mean)

*********************** First row (University) *********************************
eststo clear
label var uni "\hspace{0.5cm}"

estpost tabstat d1m d2m d3 d4 total if native==0 & uni==0, stat(mean)
eststo x

estout using "$Result\table8.tex", replace /// 
	cells(mean(fmt(3))) delimiter(&) end(\\) ///
	prehead("{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{5}{c}} \toprule") ///  
	posthead("\midrule \textbf{Migrants}\\") ///  
	label collabels(none) style(esttab) ///
	mlabels(, title span prefix(\multicolumn{@span}{c}{) suffix(}))

eststo clear

estpost tabstat d1m d2m d3 d4 total if native==0 & uni==1, stat(mean)
eststo y

esttab using "$Result\table8.tex", cells(mean(fmt(3))) append f label ///
	nomtitle nonumber collabels(none) booktabs nogaps noline noobs ///
	postfoot("\bottomrule \multicolumn{6}{l}{\footnotesize Source: LFS}\\ \end{tabular}")






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
	prehead("{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{4}{c}} \toprule &\multicolumn{7}{c}{Age}\\ \cmidrule{2-8}") ///  
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