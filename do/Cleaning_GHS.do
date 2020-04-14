/*
Clean each round and obtain consistently coded variables across rounds for 
year, age, sex, nativity, london dummy, year of entry, age left full-time education, wage, and working status.
Generate those variables for lacking rounds as consistently as possible with other rounds.
NOTE: There is no weight for GHS rounds before 2000.
*/


/****************
*** education ***
*edtype	 //73(colltype):14-20	74-76:14-20 	77:2to4 	78:1to5   79:2to6	80-82:2to4
*educnow //	73-76:1								77-82:1-2

************
*** wage ***
73-78:incempx/incempw
79-82:payweek
83:paygross/payperd 
84-91:uge 
92-96:geind 
98-06:grearn
*/

//------------------------------------------------------------------------------
//--------------- GHS 1973-1976 ------------------------------------------------
//------------------------------------------------------------------------------		
local ed73 "colltype" 	//type of college last attended f-t (1973)

forvalues i=74/76 {
local ed`i' "edtype"	//type of school,college last attended f-t (1974-76)
}

forvalues i=73/76 {

use "$Data\raw\GHS\19`i'\ghs`i'.dta", clear

// Generate FTPTA (working full-time/part-time) - same structure with later surveys
gen teacher = 1 if occgroup==192 |  occgroup==193 | occgroup==194
gen ftpt = 0
replace ftpt=1 if employed==1 & teacher==1 & workhrs>25 & workhrs<100
replace ftpt=2 if employed==1 & teacher==1 & workhrs>0  & workhrs<26
replace ftpt=1 if employed==1 & teacher!=1 & workhrs>30 & workhrs<100
replace ftpt=2 if employed==1 & teacher!=1 & workhrs>0  & workhrs<31
replace ftpt=3 if employed==1 & workhrs==0 | workhrs==-1 | workhrs==.
replace ftpt=. if employed!=1 

 // Generate terminal education age (TEA) - same structure with later surveys
gen ageleftfteduc = 0
replace ageleftfteduc = agelftc if `ed`i'' >13 & `ed`i'' <21	//uni, polytechnic, other college
replace ageleftfteduc = agelfts	if `ed`i'' <14 | `ed`i'' >20	//elem.or sec.sch, NA
replace ageleftfteduc = . 		if agelfts==99 | educnow==1		//still in ft education
recode ageleftfteduc 0=.

// Generate gross weekly earnings
gen 	wage = incempx/incempw if incemp==1		//(yearly total / #of weeks)
replace wage =. if wage<0	

// Rename Variables
rename region	reg				//7:London
rename whborn	birthplace		//UK:1 to 4
rename arriveuk	yearofentry		//add 1900 or 1800
rename selfemp	status			//1:employee (most recent job if non-working)

// Recode Variables
replace yearofentry=. if yearofentry<0
replace yearofentry=yearofentry+1900 if yearofentry <= `i'
replace yearofentry=yearofentry+1800 if yearofentry > `i'		

// Generate and Keep necessary variables
keep age sex reg birthplace yearofentry ageleftfteduc ftpt status wage

gen year = 19`i'					//survey year
gen london = reg==7					//London dummy
gen native = birthplace>=1 & birthplace<=4
replace native =. if birthplace<0

drop reg birthplace

save "$Data\cleaned\GHS\ghs19`i'.dta", replace
}

//------------------------------------------------------------------------------
//--------------- GHS 1977 -----------------------------------------------------
//------------------------------------------------------------------------------		
								
use "$Data\raw\GHS\1977\ghs77.dta", clear

// Generate FTPTA (working full-time/part-time) - same structure with later surveys
gen teacher = 1 if occgroup==192 |  occgroup==193 | occgroup==194
gen ftpt = 0
replace ftpt=1 if employed==1 & teacher==1 & workhrs>25 & workhrs<100
replace ftpt=2 if employed==1 & teacher==1 & workhrs>0  & workhrs<26
replace ftpt=1 if employed==1 & teacher!=1 & workhrs>30 & workhrs<100
replace ftpt=2 if employed==1 & teacher!=1 & workhrs>0  & workhrs<31
replace ftpt=3 if employed==1 & workhrs==0 | workhrs==-1
replace ftpt=. if employed!=1

// Generate terminal education age (TEA) - same structure with later surveys
gen ageleftfteduc = 0
replace ageleftfteduc = agelftc if edtype >1 & edtype <5						//uni, other college
replace ageleftfteduc = agelfts	if edtype <2 | edtype >6						//elem.or sec.sch, NA
replace ageleftfteduc =. if educnow==1 | educnow==2 | agelfts==99 | agelftc==99	//still in ft education
replace ageleftfteduc =. if ageleftfteduc<=0

// Generate gross weekly earnings
gen 	wage = incempx/incempw if incemp==1		//(yearly total / #of weeks)
replace wage =. if wage<0	

// Rename Variables
rename region	reg				//7:London
rename whborn	birthplace		//UK:1 to 4
rename arriveuk	yearofentry		//add 1900	
rename selfemp	status			//1: employee (most recent job if non-working)

// Recode Variables
replace yearofentry=. if yearofentry<0
replace yearofentry=yearofentry+1900	

// Generate and Keep necessary variables
keep age sex reg birthplace yearofentry ageleftfteduc ftpt status wage

gen year = 1977						//survey year
gen london = reg==7					//London dummy
gen native = birthplace>=1 & birthplace<=4
replace native =. if birthplace<0

drop reg birthplace

save "$Data\cleaned\GHS\ghs1977.dta", replace


//------------------------------------------------------------------------------
//--------------- GHS 1978 -----------------------------------------------------
//------------------------------------------------------------------------------		
								
use "$Data\raw\GHS\1978\ghs78.dta", clear

// Generate FTPTA (working full-time/part-time) - same structure with later surveys
gen ftpt = 0
replace ftpt=1 if employed==1 & teacher==1 & workhrs>25 & workhrs<100
replace ftpt=2 if employed==1 & teacher==1 & workhrs>0  & workhrs<26
replace ftpt=1 if employed==1 & teacher!=1 & workhrs>30 & workhrs<100
replace ftpt=2 if employed==1 & teacher!=1 & workhrs>0  & workhrs<31
replace ftpt=3 if employed==1 & workhrs==0 | workhrs==-1
replace ftpt=. if employed!=1

// Generate terminal education age (TEA) - same structure with later surveys
gen ageleftfteduc = 0
replace ageleftfteduc = agelftc if edtype <6						//uni, nursing-hosp, other college
replace ageleftfteduc = agelfts	if edtype >5						//elem.or sec.sch, NA
replace ageleftfteduc =. if educnow==1 | educnow==2 | agelfts==99	//still in ft education
replace ageleftfteduc =. if ageleftfteduc<=0

// Generate gross weekly earnings
gen 	wage = incempx/incempw if incemp==1		//(yearly total / #of weeks)
replace wage =. if wage<0	

// Rename Variables
rename region	reg				//7:London
rename whborn	birthplace		//UK:1 to 4
rename arriveuk	yearofentry		//add 1900	
rename selfemp	status			//1: employee (most recent job if non-working)

// Recode Variables
replace yearofentry=. if yearofentry<0
replace yearofentry=yearofentry+1900	

// Generate and Keep necessary variables
keep age sex reg birthplace yearofentry ageleftfteduc ftpt status wage

gen year = 1978						//survey year
gen london = reg==7					//London dummy
gen native = birthplace>=1 & birthplace<=4
replace native =. if birthplace<0

drop reg birthplace

save "$Data\cleaned\GHS\ghs1978.dta", replace


//------------------------------------------------------------------------------
//--------------- GHS 1979-1982 ------------------------------------------------
//------------------------------------------------------------------------------		

forvalues i=79/82 {
				
use "$Data\raw\GHS\19`i'\ghs`i'.dta", clear

// Generate FTPTA (working full-time/part-time) - same structure with later surveys
gen ftpt = 0
replace ftpt=1 if employed==1 & teacher==1 & workhrs>25 & workhrs<100
replace ftpt=2 if employed==1 & teacher==1 & workhrs>0  & workhrs<26
replace ftpt=1 if employed==1 & teacher!=1 & workhrs>30 & workhrs<100
replace ftpt=2 if employed==1 & teacher!=1 & workhrs>0  & workhrs<31
replace ftpt=3 if employed==1 & workhrs==0 | workhrs==-1
replace ftpt=. if employed!=1

// Generate terminal education age (TEA) - same structure with later surveys
gen ageleftfteduc = 0
replace ageleftfteduc = agelftc if edtype >1 & edtype <7			//uni, nursing-hosp, other college
replace ageleftfteduc = agelfts	if edtype <2 | edtype >6			//elem.or sec.sch, NA
replace ageleftfteduc =. if educnow==1 | educnow==2 | agelfts==99 	//still in ft education
replace ageleftfteduc =. if ageleftfteduc<=0

// Rename Variables
rename region	reg				//7:London
rename whborn	birthplace		//UK:1 to 4
rename arriveuk	yearofentry		//add 1900	
rename selfemp	status			//1: employee (most recent job if non-working)
rename payweek	wage			//gross weakly earnings (£ per wk)

// Recode Variables
replace yearofentry=. if yearofentry<0
replace yearofentry=yearofentry+1900

replace wage=. if wage<0		

// Generate and Keep necessary variables
keep age sex reg birthplace yearofentry ageleftfteduc ftpt status wage

gen year = 19`i'					//survey year
gen london = reg==7					//London dummy
gen native = birthplace>=1 & birthplace<=4
replace native =. if birthplace<0

drop reg birthplace

save "$Data\cleaned\GHS\ghs19`i'.dta", replace
}

//------------------------------------------------------------------------------
//--------------- GHS 1983 -----------------------------------------------------
//------------------------------------------------------------------------------

use "$Data\raw\GHS\1983\person.dta", clear			
merge m:1 hserno using "$Data\raw\GHS\1983\househld.dta"	
drop _m
merge 1:1 hserno persno using "$Data\raw\GHS\1983\income.dta"
drop _m
merge 1:1 hserno persno using "$Data\raw\GHS\1983\indivdl.dta"

*from person.dta
rename cob			birthplace			//UK:1 to 4
rename arruk		yearofentry			//add 1900, 99:NA
*from househld.dta
rename region	 	reg					//7:London
*from income.dta			
recode payperd (-9=.) (5=4.35) (6=13)	//(paying period) 5:month, 6:quarterly
gen wage = paygross/payperd				//(gross earnings) convert to weekly
*from indivdl.dta
rename tea			ageleftfteduc		//100:ft student
rename ftpta		ftpt				//1:ft
rename selfempa		status				//1:working employee	

// Recode Variables
recode ageleftfteduc 100=. 
recode ageleftfteduc -9=. 

replace yearofentry=. if yearofentry<0 | yearofentry==99
replace yearofentry=yearofentry+1900

replace wage=wage/100			//convert to pound

// Generate and Keep necessary variables
keep age sex reg birthplace yearofentry ageleftfteduc ftpt status wage

gen year = 1983					//survey year
gen london = reg==7				//London dummy
gen native = birthplace>=1 & birthplace<=4
replace native =. if birthplace==99

drop reg birthplace

save "$Data\cleaned\GHS\ghs1983.dta", replace


//------------------------------------------------------------------------------
//--------------- GHS 1984 ------------------------------------------------
//------------------------------------------------------------------------------

use "$Data\raw\GHS\1984\person.dta", clear						
merge m:1 hserno using "$Data\raw\GHS\1984\househld.dta"
drop _m
merge 1:1 hserno persno using "$Data\raw\GHS\1984\indivdl.dta"


*from person.dta
rename cob			birthplace		//UK:1 to 4
rename arruk		yearofentry		//add 1900, 99:NA
*from househld.dta
rename region	 	reg				//11,12:London
*from indivdl.dta	
rename tea			ageleftfteduc	//100:ft student	
rename uge			wage			//gross weakly earnings (pence per wk)
rename ftpta		ftpt			//1:ft
rename selfempa		status			//1:working employee	

// Recode Variables
recode ageleftfteduc 100=. 
recode ageleftfteduc -9=. 

replace yearofentry=. if yearofentry<0 | yearofentry==99
replace yearofentry=yearofentry+1900

replace wage=. if wage<0		
replace wage=wage/100			//convert to pound

// Generate and Keep necessary variables
keep age sex reg birthplace yearofentry ageleftfteduc ftpt status wage

gen year = 1984						//survey year
gen london = reg==11 | reg==12		//London dummy
gen native = birthplace>=1 & birthplace<=4
replace native =. if birthplace==99

// SAMPLE: men, aged 26-60, exclude students/unknown educ, full-time workers
keep if sex==1
keep if age>=26 & age<=60
drop if ageleftfteduc==. | ageleftfteduc<0
keep if status==1 & ftpt==1

drop reg birthplace

save "$Data\cleaned\GHS\ghs1984.dta", replace


//------------------------------------------------------------------------------
//--------------- GHS 1985-1986 ------------------------------------------------
//------------------------------------------------------------------------------

forvalues i=85/86 {									

use "$Data\raw\GHS\19`i'\person.dta", clear							
merge m:1 hserno using "$Data\raw\GHS\19`i'\househld.dta"
drop _m
merge 1:1 hserno persno using "$Data\raw\GHS\19`i'\housing1.dta"


*from person.dta
rename cob			birthplace		//UK:1 to 4
rename arruk		yearofentry		//add 1900, 99:NA
*from househld.dta
rename region	 	reg				//11,12:London
*from housing1.dta		
rename tea			ageleftfteduc	//100:ft student	
rename uge			wage			//gross weakly earnings (pence per wk)
rename ftpta		ftpt			//1:ft
rename selfempa		status			//1:working employee

// Recode Variables
recode ageleftfteduc 100=. 
recode ageleftfteduc -9=. 

replace yearofentry=. if yearofentry<0 | yearofentry==99
replace yearofentry=yearofentry+1900

replace wage=. if wage<0		
replace wage=wage/100			//convert to pound

// Generate and Keep necessary variables
keep age sex reg birthplace yearofentry ageleftfteduc ftpt status wage

gen year = 19`i'					//survey year
gen london = reg==11 | reg==12		//London dummy
gen native = birthplace>=1 & birthplace<=4
replace native =. if birthplace==99

drop reg birthplace

save "$Data\cleaned\GHS\ghs19`i'.dta", replace
}

//------------------------------------------------------------------------------
//--------------- GHS 1987-1996 ------------------------------------------------
//------------------------------------------------------------------------------

forvalues i=87/88 {
	local ft`i' 	"ftpta"		//full-time/part-time (from 1987 to 1988)
	local emp`i' 	"selfempa"	//selfemploy/employee (from 1987 to 1988)
}
forvalues i=89/96 {
	local ft`i' 	"ftpte"		//full-time/part-time (from 1989 to 1996)
	local emp`i' 	"selfempe"	//selfemploy/employee (from 1989 to 1996)
}
forvalues i=87/91 {
	local earn`i' 	"uge"		//gross weakly earnings (from 1987 to 1991)
}
forvalues i=92/96 {
	local earn`i' 	"geind"		//gross weakly earnings (from 1992 to 1996)
}

forvalues i=87/96 {

use "$Data\raw\GHS\19`i'\person.dta", clear
merge 1:1 persno hserno using "$Data\raw\GHS\19`i'\educmast.dta"
drop _m
merge m:1 hserno using "$Data\raw\GHS\19`i'\househld.dta"

*from person.dta
rename cob			birthplace		//UK:1 to 4
rename arruk		yearofentry		//add 1900, 99:NA
rename `ft`i''		ftpt			//1:ft
rename `emp`i''		status			//1:working employee
rename `earn`i''	wage			//gross weakly earnings (pence per wk)

*from educmast.dta
rename tea			ageleftfteduc	//100:ft student
*from househld.dta
rename region 		reg				//11,12:London

// Recode Variables
recode ageleftfteduc 100=. 
replace ageleftfteduc =. if ageleftfteduc<=0

replace yearofentry=. if yearofentry<0 | yearofentry==99
replace yearofentry=yearofentry+1900

replace wage=. if wage<0		
replace wage=wage/100				//convert to pound

gen sampyear = hyear + 1900			//sample year

// Generate and Keep necessary variables
keep age sex reg birthplace yearofentry ageleftfteduc ftpt status wage sampyear

gen year = 19`i'					//survey year
gen london = reg==11 | reg==12		//London dummy
gen native = birthplace>=1 & birthplace<=4
replace native =. if birthplace<0 | birthplace>90

drop reg birthplace

save "$Data\cleaned\GHS\ghs19`i'.dta", replace
}

//------------------------------------------------------------------------------
//--------------- GHS 1998 -----------------------------------------------------
//------------------------------------------------------------------------------

use "$Data\raw\GHS\1998\ghs98ind2.dta", clear

// Rename Variables
rename govreggb	reg				//8:London
rename cob1		birthplace		//UK:1
rename arruk	yearofentry
rename tea		ageleftfteduc	//100:ft student
rename ftpte	ftpt			//1:ft
rename selfempe	status			//1:working employee
rename grearn	wage			//gross weakly earnings (pence per wk)

// Recode Variables
recode ageleftfteduc 100=.
replace ageleftfteduc =. if ageleftfteduc<=0

replace yearofentry=. if yearofentry<0
replace wage=. if wage<0		
replace wage=wage/100			//convert to pound

replace sampyear = year(startdat)		//interview year

// Generate and Keep necessary variables
keep age sex reg birthplace yearofentry ageleftfteduc ftpt status wage sampyear

gen year = 1998				//survey year
gen london = reg==8			//London dummy
gen native = birthplace==1	
replace native =. if birthplace<0

drop reg birthplace

save "$Data\cleaned\GHS\ghs1998.dta", replace


//------------------------------------------------------------------------------
//--------------- GHS 2000-2006 ------------------------------------------------
//------------------------------------------------------------------------------

forvalues i=0/6 {

use "$Data\raw\GHS\200`i'\ghs0`i'client.dta", clear

// Rename Variables
rename govreggb	reg				//8:London
rename cob1		birthplace		//UK:1
rename arruk	yearofentry
rename edage	ageleftfteduc	//96:still in, 97:no educ
rename ftpte	ftpt			//1:ft	*checked ecstatus, wkstilo, ftptwk
rename selfempe	status			//1: working employee
rename grearn	wage			//gross weakly earnings (pence per wk)
rename weight	weight

// Recode Variables
recode ageleftfteduc (96=.) (97=0)
replace ageleftfteduc =. if ageleftfteduc<=0

replace yearofentry=. if yearofentry<0
replace wage=. if wage<0	
replace wage=wage/100			//convert to pound

// Generate and Keep necessary variables
keep age sex reg birthplace yearofentry ageleftfteduc ftpt status wage weight sampyear

gen year = 200`i'			//survey year
gen london = reg==8			//London dummy
gen native = birthplace==1	
replace native =. if birthplace==97

drop reg birthplace

save "$Data\cleaned\GHS\ghs200`i'.dta", replace
}
//------------------------------------------------------------------------------
