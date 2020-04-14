/*
Clean each round and obtain consistently coded variables across rounds for 
year, age, sex, nativity, london dummy, year of entry, age left full-time education, and working status.
Generate those variables for lacking rounds as consistently as possible with other rounds.
*/

//------------------------------------------------------------------------------
//--------------- LFS 1992q2-1999q4 --------------------------------------------
//------------------------------------------------------------------------------	

forvalues i=92/99 {
foreach q in jm aj js od {

capture use "$Data\raw\LFS\qlfs`q'`i'.dta", clear
if _rc continue

// Rename Variables
rename uresmc	reg				//8:Inner London, 9: outer London
rename cry		birthplace		//UK:1
rename cameyr	yearofentry		//missing if negative, 2 digit until 1997
rename edage	ageleftfteduc	//96:still in, 97:no educ, negative:NA,DNA
rename inecac	econact			//1:employee
rename ftptw	ft				//6:ft
rename pwt07	weight

// Recode Variables
recode ageleftfteduc 96=.		//still in education
recode ageleftfteduc 97=0		//no education

replace yearofentry=. if yearofentry<0
replace yearofentry= yearofentry+1900 if yearofentry<100

// Generate and Keep necessary variables
keep sex age reg birthplace yearofentry ageleftfteduc econact ft weight

gen year = 19`i'				//survey year
gen quarter = "`q'"				//survey quarter
gen london = reg==8	| reg==9	//London dummy
gen workft = econact==1 & ft==6	//dummy for working full-time
gen native = birthplace==1		//native dummy
replace native=. if birthplace<0

drop birthplace econact ft reg

save "$Data\cleaned\LFS\lfs19`i'_`q'.dta", replace
}
}

//------------------------------------------------------------------------------
//--------------- LFS 2000q1-2000q4 --------------------------------------------
//------------------------------------------------------------------------------	

foreach q in jm aj js od {

use "$Data\raw\LFS\qlfs`q'00.dta", clear

// Rename Variables
rename uresmc	reg				//8:Inner London, 9: outer London
*rename cry		birthplace		//UK:1
rename cryox	birthplace		//UK:1
rename cameyr	yearofentry		//missing if negative
rename edage	ageleftfteduc	//96:still in, 97:no educ, negative:NA,DNA
rename inecac	econact			//1:employee
rename ftptw	ft				//6:ft
rename pwt07	weight

// Recode Variables
recode ageleftfteduc 96=.		//still in education
recode ageleftfteduc 97=0		//no education

replace yearofentry=. if yearofentry<0

// Generate and Keep necessary variables
keep sex age reg birthplace yearofentry ageleftfteduc econact ft weight

gen year = 2000					//survey year
gen quarter = "`q'"				//survey quarter
gen london = reg==8	| reg==9	//London dummy
gen workft = econact==1 & ft==6	//dummy for working full-time
gen native = birthplace==1		//native dummy
replace native=. if birthplace<0

drop birthplace econact ft reg

save "$Data\cleaned\LFS\lfs2000_`q'.dta", replace
}


//------------------------------------------------------------------------------
//--------------- LFS 2001q1 ---------------------------------------------------
//------------------------------------------------------------------------------	

use "$Data\raw\LFS\qlfsjm01.dta", clear

// Rename Variables
rename uresmc	reg				//8:Inner London, 9: outer London
rename sex		sex				//male: 1, female: 2
rename age		age	
rename cryox	birthplace		//UK:1
rename cameyr	yearofentry		//missing if negative
rename edage	ageleftfteduc	//96:still in, 97:no educ, negative:NA,DNA
rename inecac	econact			//1:employee
rename ftptw	ft				//6:ft
rename pwt07	weight	

// Recode Variables
recode ageleftfteduc 96=.		//still in education
recode ageleftfteduc 97=0		//no education

replace yearofentry=. if yearofentry<0

// Generate and Keep necessary variables
keep reg sex age birthplace yearofentry ageleftfteduc econact ft weight

gen year = 2001						//survey year
gen quarter = "jm"					//survey quarter
gen london = reg==8	| reg==9		//London dummy
gen workft = econact==1 & ft==6		//dummy for working full-time
gen native = birthplace==1			//native dummy
replace native=. if birthplace<0

drop birthplace econact ft reg

save "$Data\cleaned\LFS\lfs2001_jm.dta", replace


//------------------------------------------------------------------------------
//--------------- LFS 2001q2 ---------------------------------------------------
//------------------------------------------------------------------------------	

use "$Data\raw\LFS\qlfsaj01.dta", clear

// Rename Variables
rename uresmc	reg				//8:Inner London, 9: outer London
rename sex		sex				//male: 1, female: 2
rename age		age	
*rename cry01	birthplace		//UK:1 to 5
rename cryox	birthplace		//UK:1
rename cameyr	yearofentry		//missing if negative
rename edage	ageleftfteduc	//96:still in, 97:no educ, negative:NA,DNA
rename inecac	econact			//1:employee
rename ftptw	ft				//6:ft
rename pwt07	weight	

// Recode Variables
recode ageleftfteduc 96=.		//still in education
recode ageleftfteduc 97=0		//no education

replace yearofentry=. if yearofentry<0

// Generate and Keep necessary variables
keep reg sex age birthplace yearofentry ageleftfteduc econact ft weight

gen year = 2001						//survey year
gen quarter = "aj"					//survey quarter
gen london = reg==8	| reg==9		//London dummy
gen workft = econact==1 & ft==6		//dummy for working full-time
gen native = birthplace==1			//native dummy
replace native=. if birthplace<0

drop birthplace econact ft reg

save "$Data\cleaned\LFS\lfs2001_aj.dta", replace


//------------------------------------------------------------------------------
//--------------- LFS 2001q3-2006q4 --------------------------------------------
//------------------------------------------------------------------------------	

forvalues i=1/6 {
foreach q in jm aj js od {

capture use "$Data\raw\LFS\lfsp_`q'0`i'_end_user.dta", clear
if _rc continue

// Rename Variables
rename URESMC	reg				//8:Inner London, 9: outer London
rename SEX		sex				//male: 1, female: 2
rename AGE		age	
*rename CRY01	birthplace		//UK:1 to 5
rename CRYOX	birthplace		//UK:1
rename CAMEYR	yearofentry		//missing if negative
rename EDAGE	ageleftfteduc	//96:still in, 97:no educ, negative:NA,DNA
rename INECAC	econact			//1:employee
rename FTPTW	ftpt			//6:ft
rename PWT14	weight

// Recode Variables
recode ageleftfteduc 96=.		//still in education
recode ageleftfteduc 97=0		//no education

replace yearofentry=. if yearofentry<0

// Generate and Keep necessary variables
keep reg sex age birthplace yearofentry ageleftfteduc econact ftpt weight

gen year = 200`i'					//survey year
gen quarter = "`q'"					//survey quarter
gen london = reg==8	| reg==9		//London dummy
gen workft = econact==1 & ft==6		//dummy for working full-time
gen native = birthplace==1			//native dummy
replace native=. if birthplace<0

drop birthplace econact ft reg

save "$Data\cleaned\LFS\lfs200`i'_`q'.dta", replace
}
}


//------------------------------------------------------------------------------
//--------------- LFS 2007q1-2007q4 --------------------------------------------
//------------------------------------------------------------------------------	

foreach q in jm aj js od {

use "$Data\raw\LFS\lfsp_`q'07_end_user.dta", clear

// Rename Variables
rename URESMC	reg				//8:Inner London, 9: outer London
rename SEX		sex				//male: 1, female: 2
rename AGE		age	
*rename CRY01	birthplace		//UK:921 to 926
rename CRYOX	birthplace		//UK:926
rename CAMEYR	yearofentry		//missing if negative
rename EDAGE	ageleftfteduc	//96:still in, 97:no educ, negative:NA,DNA
rename INECAC	econact			//1:employee
rename FTPTW	ftpt			//6:ft
rename PWT14	weight

// Recode Variables
recode ageleftfteduc 96=.		//still in education
recode ageleftfteduc 97=0		//no education

replace yearofentry=. if yearofentry<0

// Generate and Keep necessary variables
keep reg sex age birthplace yearofentry ageleftfteduc econact ftpt weight

gen year = 2007						//survey year
gen quarter = "`q'"					//survey quarter
gen london = reg==8	| reg==9		//London dummy
gen workft = econact==1 & ft==6		//dummy for working full-time
gen native = birthplace==926		//native dummy
replace native=. if birthplace<0

drop birthplace econact ft reg

save "$Data\cleaned\LFS\lfs2007_`q'.dta", replace
}
