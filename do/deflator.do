/*
Import CPI deflators dowloaded from WB (1990=1)
*/


clear
import excel using "$Data\deflator\CPI.xls", firstrow

destring year, replace

save "$Data\deflator\CPI.dta", replace
