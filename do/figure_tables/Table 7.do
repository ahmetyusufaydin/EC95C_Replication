
use "$Data\built\Estimation.dta", clear

// eq 8
****************************************************************************
reg nativewp relsupNM uni i.ageg i.yearg [aweight=nativeW]			//eq 8
****************************************************************************

// eq 9
****************************************************************************
reg uniwp  native i.ageg i.yearg relLaborUS I2 [aweight=uniW]		//eq 9
****************************************************************************


// eq 11
*drop if uni==1	// elements of the regression are same across education groups
****************************************************************************
reg uniwp  yearg i.age native E A I  [aweight=uniW]					//eq 11
****************************************************************************


eststo clear
*********** Equation 8 *****************************************************
preserve
drop I
rename relsupNM I
eststo: qui reg nativewp  I uni i.ageg i.yearg [aweight=nativeW]
estadd local educ "Yes"
estadd local time "Yes"
estadd local age  "Yes"
estadd local imm  " "
restore
****************************************************************************


*********** Equation 9 *****************************************************
preserve
drop I A
rename relLaborUS A
rename I2 I
eststo: qui reg uniwp  native i.ageg i.yearg A I [aweight=uniW]
estadd local educ " "
estadd local time "Yes"
estadd local age  "Yes"
estadd local imm  "Yes"
restore
****************************************************************************


*********** Equation 11 *****************************************************
preserve
drop if uni==1	// elements of the regression are same across education groups
rename yearg time
eststo: qui reg uniwp  i.age native E A I time [aweight=uniW]	
estadd local educ " "
estadd local time " "
estadd local age  "Yes"
estadd local imm  "Yes"
restore
****************************************************************************

esttab using "$Result//table7.tex", replace title(\hypertarget{Table7}{Estimated elasticities of substitution}) ///
	keep(I A E time) label b(3) se(3) booktabs noobs ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	mtitles("\shortstack{Native/\\immigrant\\ \\(Step 1)}" ///
			"\shortstack{University/\\secondary\\(by age)\\(Step 2)}" ///
			"\shortstack{University/\\secondary\\(aggregate)\\(Step 3)}") ///
	coeflabels(I "$-1/\sigma_{I}$" ///
			A "$-1/\sigma_{A}$" ///
			E "$-1/\sigma_{E}$" ///
			time "Time trend") ///
	substitute(\_ _)	///
	indicate("Education dummy = uni" "Time dummies= *yearg*" "Age dummies = *ageg*" "Immigrant dummy = native", labels(Yes  )) ///
	addnote("Notes: The table reports OLS estimates of equations (8) (9) and (11) in the text." "Sample size, 98." "All regressions weighted by inverse of estimated variance of dependent variable." "Source GHS and LFS.")
