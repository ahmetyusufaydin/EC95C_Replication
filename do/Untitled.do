
*ssc install _gwtmean

use "$Data\built\Estimation.dta", clear

gen xI = -0.142
gen xA = -0.193
gen xE = -0.203
rename pop S
keep native uni  agegroup yeargroup avwage S xI xA xE

keep if inlist(year, 1975, 2005)
drop if native ==1

egen empshare= pc(S) if year==1975, prop


sort ageg uni native yearg



// Column 1 (S_eat)
bys ageg uni native (yearg): gen dif = (S[2]-S[1])/30	
bys ageg uni native (yearg): gen dlnM = (log(S[2])-log(S[1]))		// d_ln(M_ea)

gen d1= xI*dlnM

drop if yearg==2005
drop yearg
sort uni

bys uni native (ageg): egen d1m=wtmean(d1), weight(empshare)
