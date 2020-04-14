/*
Use equation (4) to derive the different elements of of the decomposition.
Use estimates from equation (11) to compute wage effects for each group with 
increased immigrant labor supply from 1975 to 2005 while keeping native labor
supply constant.
*/

use "$Data\built\Estimation.dta", clear

*gen xI = -0.142
*gen xA = -0.193
*gen xE = -0.203
rename pop S
keep native uni  agegroup yeargroup avwage S xI xA xE

keep if inlist(yearg, 1975, 2005)

egen empshare= pc(S) if yearg==1975, prop


// Column 1 (S_eat)
bys ageg uni native (yearg): gen dlnM = (((S[2])-(S[1]))/S[1])		// d_ln(M_ea)
*bys ageg uni native (yearg): gen dlnM = (log(S[2])-log(S[1]))		// d_ln(M_ea)
replace dlnM=0 if native==1
gen d1= xI*dlnM

drop if yearg==2005
drop yearg

bys uni native (ageg): egen d1m=wtmean(d1), weight(empshare)


// Column 2 (L_eat)
bys ageg uni (native): gen sMea = (avwage[1]/(avwage[1]+avwage[2]))
bys ageg uni (native): gen dlnLea = sMea * dlnM[1]
gen d2 = -(-xA+xI) * dlnLea

bys uni native (ageg): egen d2m=wtmean(d2) //, weight(empshare)

drop sMea

// Column 3 (L_et)
bys uni ageg: egen tavwage = total(avwage)
bys native uni (ageg): egen sea = pc(tavwage), prop
bys native uni (ageg): egen dlnLe = total(sea*dlnLea)
gen d3 = -(-xE+xA)*dlnLe

drop tavwage sea

// Column 4 (Y_t)
sort uni ageg native

bys uni: egen tavwage = total(avwage)
bys native ageg (uni): egen se = pc(tavwage), prop
bys native ageg (uni): egen dlnY = total(se*dlnLe)
gen d4 = -xE * dlnY

collapse (min) d1m d2m d3 d4 , by(native uni)

gen total = d1m + d2m + d3 + d4

save "$Data\built\Simulation.dta", replace

