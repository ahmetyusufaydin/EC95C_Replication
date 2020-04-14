/*
Merge wage and supply estimations for each cell.
Estimate equations 8, 9, 10, 11; and store necessary parameters for simulation.
*/

use "$Data\built\Wage.dta", clear

merge 1:1 native uni g* using "$Data\built\Supply.dta"
drop _m

// Drop those remained outside the cohort groups (eg. age 26-27 in 1977)
drop if agegroup==0


********************************************************************************
********** Step 1: Estimating sigmaI, beta_eat, and L_eat **********************
********************************************************************************

// Compute relative supply of natives to immigrants for each cell
bys yearg ageg uni (native): gen relsupNM = log(pop/pop[_n-1])

//--------- Equation 8 ---------
preserve
****************************************************************************
statsby, clear: reg nativewp relsupNM uni i.ageg i.yearg [aweight=nativeW]		//eq 8
****************************************************************************
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
tempfile coef
save `coef'
restore

merge 1:1 _n using `coef'
drop _m

// sigmaI: Elasticity of substituton btw immigrant and native workers
gen sigmaI = -1/_b_relsupNM[1]
gen delta = 1 - 1/sigmaI

//--------- Equation 7 ---------
gen nlnbeta=.
forvalues i=1975(5)2005 {				//year groups
	forvalues j=28(5)58 {				//age groups
		replace nlnbeta = _b__cons[1] + _b_`i'[1] + _b_`j'[1] 				if g`i'_`j'==1 & uni==0
		replace nlnbeta = _b__cons[1] + _b_`i'[1] + _b_`j'[1] +	_b_uni[1]	if g`i'_`j'==1 & uni==1
	}
}
drop _b*
drop g*

// beta: Relative efficiency parameter on the native and immigrants
gen beta = exp(-nlnbeta)
replace beta = 1 if native==1		//by normalization
drop nlnbeta

//--------- Equation 3 ---------
// L_eat: education-age-time specific labor input
bys yearg ageg uni (native): gen Leat = (pop[2]^delta + beta[1]*(pop[1]^delta))^(1/delta)



********************************************************************************
********** Step 2: Estimating sigmaA, alpha_ea, and L_et ***********************
********************************************************************************

// Compute cell-specific relative labor input of graduates to secondary workers
bys yearg ageg (uni): gen relLaborUS = log(Leat[4]/Leat[2])

// Compute relative supply of graduates to secondary workers within each age-year-nativity cell
bys yearg ageg native (uni): gen relsupUS = log(pop/pop[_n-1])

//--------- Equation 9 ---------
gen I2 = relsupUS-relLaborUS

preserve
****************************************************************************
statsby, clear: reg uniwp native i.ageg i.yearg relLaborUS I2 [aweight=uniW]	//eq 9
****************************************************************************
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
tempfile coef
save `coef'
restore

merge 1:1 _n using `coef'
drop _m

// sigmaA: Elasticity of substituton across age groups
gen sigmaA = -1/_b_relLaborUS[1]
gen eta = 1 - 1/sigmaA
gen sigmaI2 = -1/_b_I2[1]

drop _b*

//--------- Equation 10 --------- (typo in the article: sign of the last term of x is + in the text)
preserve
gen lnwage = log(avwage)
gen lnLeat = log(Leat)
gen x = log(pop) - log(Leat) - sigmaI*log(beta)
****************************************************************************
statsby, clear: reg lnwage uni#i.ageg uni#i.yearg lnLeat x						//eq 10
****************************************************************************
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
tempfile coef
save `coef'
restore

merge 1:1 _n using `coef'
drop _m

// Recover alpha_ea parameters
gen lnalpha=.
forvalues j=28(5)58 {	//age groups
	replace lnalpha = _b__cons[1] + _b_0b_uni_`j'[1] 	if agegroup==`j' & uni==0
	replace lnalpha = _b__cons[1] + _b_1_uni_`j'[1] 	if agegroup==`j' & uni==1
}
drop _b*

// alpha: Relative efficiency of different age inputs for each education group
gen alpha = exp(lnalpha)
// Normalize alpha_e_1=1
gen alpha28_0 = alpha[1]
replace alpha = alpha/alpha28_0 if uni==0
gen alpha28_1 = alpha[2]
replace alpha = alpha/alpha28_1 if uni==1
drop lnalpha alpha28*

//--------- Equation 2 ---------
// L_et: Skill-specific labor inputs
bys native yearg uni (ageg): egen Let = total(alpha*(Leat^eta))
replace Let = Let^(1/eta)



********************************************************************************
********** Step 3: Estimating sigmaE, theta_t, and L_et ***********************
********************************************************************************

gen SoverL = pop/Leat
bys yearg ageg native (uni): gen I = log(SoverL[2]/SoverL[1])
bys yearg ageg native (uni): gen E = log(Let[2]/Let[1])
gen A = relLaborUS - E

preserve
drop if uni==1	// elements of the regression are same across education groups
****************************************************************************
statsby, clear: reg uniwp  yearg i.age native E A I  [aweight=uniW]			//eq 11
****************************************************************************
foreach v of var * {
    local lbl : var label `v'
    local lbl = strtoname("`lbl'")
    rename `v' `lbl'
}
tempfile coef
save `coef'
restore

merge 1:1 _n using `coef'
drop _m

// Store negative inverse elasticities
gen xI = _b_I[1]	//-1/sigma_I
gen xA = _b_A[1]	//-1/sigma_A
gen xE = _b_E[1]	//-1/sigma_E

drop _b*


save "$Data\built\Estimation.dta", replace
