/*
Clean each round and obtain consistently coded variables across rounds for 
year, age, sex, nativity, london dummy, year of entry, age left full-time education, and working status.
Generate those variables for lacking rounds as consistently as possible with other rounds.
*/


//------------------------------------------------------------------------------
//--------------- LFS 1975 -----------------------------------------------------
//------------------------------------------------------------------------------	

use "$Data\raw\LFS\lfs75.dta", clear

// Rename Variables
rename var2		region			//7:Greater London, 10:Wales, 11:Scotland, 12:N.Ireland	
rename var25 	sex				//male: 1, female: 2
rename var26 	age
*rename var27 	birthyear
rename var31 	birthplace		//UK:7, 0:not stated
rename var112 	ageleftfteduc	//0:still in educ, 14:not stated, 13:25 and over, others+12
rename var38 	status 			//0:employer, 1:self emp, 2:ft employee, 3:pt employee, 
								//4:status not known-ft, 5:status not knonw-pt, 6:NA
rename var118	weight			

// Recode Variables
recode ageleftfteduc 14=.				//not stated
recode ageleftfteduc 0=.				//still in education
replace ageleftfteduc=ageleftfteduc+12

// Generate and Keep necessary variables
keep region sex age birthplace ageleftfteduc status weight

gen year = 1975				//survey year
gen london = region==7		//London dummy
gen workft = status==2		//dummy for working full-time
gen native = birthplace==7	//native dummy
replace native=. if birthplace==0

drop birthplace status region

save "$Data\cleaned\LFS\lfs1975.dta", replace

//------------------------------------------------------------------------------

use "$Data\raw\LFS\lfs77.dta", clear

// Rename Variables
rename var2		region			//7:Greater London, 10:Wales, 11:Scotland, 12:N.Ireland
rename var7		sex				//male: 0, female: 1
rename var52	age	
*rename var10	birthyear	
rename var54	birthplace		//UK:0, 90:at sea/in the air, 91:not-stated, 92:not-known
rename var67	ageleftfteduc	//5:still in educ, 6:not stated, 7:not known, 4:18 and over, others+14
rename var85	status			//0:employer, 1:self emp, 2:ft employee, 3:pt employee, 4:status not known
rename var34	weight

// Recode Variables
recode sex (1=2) (0=1)

recode ageleftfteduc 5=.				//still in education
recode ageleftfteduc 6=.				//not stated
recode ageleftfteduc 7=.				//not known
replace ageleftfteduc=ageleftfteduc+14

// Generate and Keep necessary variables
keep region sex age birthplace ageleftfteduc status weight

gen year = 1977				//survey year
gen london = region==7		//London dummy
gen workft = status==2		//dummy for working full-time
gen native = birthplace==0	//native dummy
replace native=. if birthplace>89

drop birthplace status region

save "$Data\cleaned\LFS\lfs1977.dta", replace

//------------------------------------------------------------------------------

use "$Data\raw\LFS\lfs79.dta", clear

// Rename Variables
rename VAR1		region			//7:Greater London, 10:Wales, 11:Scotland, 12:N.Ireland
rename VAR22	sex				//male: 0, female: 1
rename VAR87	age	
*rename VAR24	birthyear	
rename VAR28	birthplace		//UK:0, 90:at sea/in the air, 91:not-stated/not-known
rename VAR130	ageleftfteduc	//10:not stated/not known, 11:NA, 9:22 and over, others+13
rename VAR91	status			//0:employer, 1:self emp, 2:ft employee, 3:pt employee, 4:status not known
rename VAR82	weight

// Adjust weight variable (weights are 10 times higher in 1979 compared to other years)
replace weight = weight/10


// Recode Variables
recode sex (1=2) (0=1)

recode ageleftfteduc 10=.				//not stated
recode ageleftfteduc 11=.				//not applicable (students?)
replace ageleftfteduc=ageleftfteduc+13

// Generate and Keep necessary variables
keep region sex age birthplace ageleftfteduc status weight

gen year = 1979				//survey year
gen london = region==7		//London dummy
gen workft = status==2		//dummy for working full-time
gen native = birthplace==0	//native dummy
replace native=. if birthplace>89

drop birthplace status region

save "$Data\cleaned\LFS\lfs1979.dta", replace

//------------------------------------------------------------------------------

use "$Data\raw\LFS\lfs81.dta", clear

// Rename Variables
rename URESREG	region		//5:Greater London, 10:Wales, 11:Scotland, 12:N.Ireland
rename SEX		sex			//male: 1, female: 2
rename AGE		age	
*rename BIRYEAR	birthyear	
rename BIRPER	birthplace		//UK:1, 88:at sea/in the air, 89:not-stated, 90:not-known, 91:NA
rename TEREDAG	ageleftfteduc	//12:still in, 13:not stated, 11:not known, 14:NA, 10:22 and over, others+12
rename FLPT		ftpt			//1:Full-time, 2:Part-time
rename FACTORP	weight	

// Recode Age left full-time education
recode ageleftfteduc 11=.				//not known
recode ageleftfteduc 12=.				//still in education
recode ageleftfteduc 13=.				//not stated
recode ageleftfteduc 14=.				//not applicable
replace ageleftfteduc=ageleftfteduc+12

// Generate and Keep necessary variables
keep region sex age birthplace ageleftfteduc ftpt weight

gen year = 1981				//survey year
gen london = region==5		//London dummy
gen workft = ftpt==1		//dummy for working full-time
gen native = birthplace==1	//native dummy
replace native=. if birthplace>87

drop birthplace ftpt region

save "$Data\cleaned\LFS\lfs1981.dta", replace

//------------------------------------------------------------------------------

use "$Data\raw\LFS\lfs83.dta", clear

// Rename Variables
rename var15	region			//8:Greater London, 16:Wales, 17:Scotland, 18:N.Ireland
rename var28	sex				//male: 1, female: 2
rename var31	age	
*rename var30	birthyear		//add 1900 for 83 or less
rename var35	birthplace		//UK:1
rename var36	yearofentry		//84:no reply, 0:1900 and earlier, add 1900
rename var137	ageleftfteduc	//97:still in, 30:not stated, 99:not known, 98:no educ
rename var166	status			//3,6:Full-time
*rename var155	ftpt			//7:Full-time - includes self-emp or other categories
rename var245	wint	
rename var246	wdec			//divide by 1000 and add wint

// Recode Variables
recode ageleftfteduc 99=.		//not known
recode ageleftfteduc 30=.		//not stated
recode ageleftfteduc 97=.		//still in education
recode ageleftfteduc 98=0		//no education

recode yearofentry 84=.
replace yearofentry = yearofentry +1900

// Reconstruct weight
replace wdec=wdec/1000
gen weight=wint+wdec

// Generate and Keep necessary variables
keep region sex age birthplace yearofentry ageleftfteduc status weight

gen year = 1983							//survey year
gen london = region==8					//London dummy
gen workft = status==3 | status==6		//dummy for working full-time
gen native = birthplace==1				//native dummy
replace native=. if birthplace>93

drop birthplace status region

save "$Data\cleaned\LFS\lfs1983.dta", replace

//------------------------------------------------------------------------------

use "$Data\raw\LFS\lfs1984.dta", clear

// Rename Variables
rename urescomf	reg				//8:GLC
rename sex		sex				//male: 1, female: 2
rename fage		age	
*rename doby	birthyear		//add 1900 for 84 or less
rename country	birthplace		//UK:1, 94:sea/air, 95:NA
rename arrival	yearofentry		//85:no reply, add 1900 for 84 or less
rename ftedage	ageleftfteduc	//96:still in, 97:no educ, 98:not known, 99:not stated
rename econpof	status			//1:Full-time
rename pwt03	weight

// Recode Variables
recode ageleftfteduc 96=.		//still in education
recode ageleftfteduc 98=.		//not known
recode ageleftfteduc 99=.		//not stated
recode ageleftfteduc 97=0		//no education

recode yearofentry 85=.
replace yearofentry = . if yearofentry < 0
replace yearofentry = 0 if yearofentry > 85
replace yearofentry = yearofentry +1900

// Generate and Keep necessary variables
keep reg sex age birthplace yearofentry ageleftfteduc status weight

gen year = 1984				//survey year
gen london = reg==8			//London dummy
gen workft = status==1		//dummy for working full-time
gen native = birthplace==1	//native dummy
replace native=. if birthplace<0 | birthplace>93

drop birthplace status reg

save "$Data\cleaned\LFS\lfs1984.dta", replace

//------------------------------------------------------------------------------

use "$Data\raw\LFS\lfs1985.dta", clear

// Rename Variables
rename urescomg	reg				//8:GLC
rename sex		sex				//male: 1, female: 2
rename age		age	
*rename doby	birthyear		//add 1900
rename country	birthplace		//UK:1, 94:sea/air, -8:NA
rename arrival	yearofentry		//add 1900 for 85 or less
rename ftedage	ageleftfteduc	//98:still in, 99:no educ, negative:NA,DNA
rename econacrg	status			//3:Full-time
rename pwt03	weight	

// Recode Variables
recode ageleftfteduc 98=.		//still in education
recode ageleftfteduc 99=0		//no education
replace ageleftfteduc =. if ageleftfteduc<0

replace yearofentry = . if yearofentry < 0
replace yearofentry = 0 if yearofentry > 85
replace yearofentry = yearofentry +1900

// Generate and Keep necessary variables
keep reg sex age birthplace yearofentry ageleftfteduc status weight

gen year = 1985				//survey year
gen london = reg==8			//London dummy
gen workft = status==3		//dummy for working full-time
gen native = birthplace==1	//native dummy
replace native=. if birthplace<0 | birthplace>93

drop birthplace status reg

save "$Data\cleaned\LFS\lfs1985.dta", replace


//------------------------------------------------------------------------------
//--------------- LFS 1986-1991 ------------------------------------------------
//------------------------------------------------------------------------------	

forvalues i= 1986/1991 {

use "$Data\raw\LFS\lfs`i'.dta", clear

// Rename Variables
rename ures		reg				//8:Inner London, 9: outer London
rename sex		sex				//male: 1, female: 2
rename age		age	
*rename doby	birthyear		//add 1900
rename country	birthplace		//UK:1, 94:sea/air, 95:NA (-8 in 1986)
rename arrival	yearofentry		//add 1900
rename ftedage	ageleftfteduc	//98:still in, 99:no educ, negative:NA,DNA
rename eca		econact			//1:employee
rename ftptwork	ftpt			//1:ft
rename pwt03	weight	

// Recode Variables
recode ageleftfteduc 98=.		//still in education
recode ageleftfteduc 99=0		//no education
replace ageleftfteduc =. if ageleftfteduc<0

replace yearofentry = . if yearofentry < 0
replace yearofentry = 0 if yearofentry > `i'-1900
replace yearofentry = yearofentry +1900

// Generate and Keep necessary variables
keep reg sex age birthplace yearofentry ageleftfteduc econact ftpt weight

gen year = `i'						//survey year
gen london = reg==8	| reg==9		//London dummy
gen workft = econact==1 & ftpt==1	//dummy for working full-time
gen native = birthplace==1			//native dummy
replace native=. if birthplace<0 | birthplace>93

drop birthplace econact ftpt reg

save "$Data\cleaned\LFS\lfs`i'.dta", replace
}
