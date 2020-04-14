* ************************************
* Ahmet Yusuf AYDIN ******************
* EC9C5 - Labour Economics ***********
* Replication Project ****************
* ************************************

clear all
set more off
clear matrix

pause off
set more off
prog drop _all

set maxvar 20000
set matsize 10000

* ************************************
* ****** Additional Programs *********
* ************************************
ssc install _gwtmean

* ************************************
* ********** Define roots ************
* ************************************

/* Uni */
*	global fl "\\brio.ads.warwick.ac.uk\User61\u\u1891663\Desktop\Labour_Replication"
/* Uni Dropbox */
*	global fl "C:\Users\u1891663\Dropbox\Replication"
/* PC Dropbox */
	global fl "C:\Users\ASUS\Dropbox\Replication"

	
* ************************************
* ********** Define paths ************
* ************************************

global Do "$fl\do"
global Data "$fl\data"
*global Data "D:\UK LFS-GHS Data"
global Result "$fl\results"

* ************************************
* ********** Run code ****************
* ************************************

// Clean each survey round
do "$Do\Cleaning_GHS.do"
do "$Do\Cleaning_LFS.do"
do "$Do\Cleaning_QLFS.do"

// Merge survey rounds. Create education groups and indicators for year-age cells
do "$Do\Append_GHS.do"		
do "$Do\Append_LFS.do"		

// CPI deflator for wages
do "$Do\deflator.do"

// Compute Wage Premia and Labour Supply by Cells
do "$Do\Wage_GHS.do"
do "$Do\Supply Weights_GHS.do"
do "$Do\Supply_LFS.do"

// Estimate parameters
do "$Do\Estimation.do"

// Simulation of wage effects
do "$Do\Simulation.do"

// Figures and Tables
do "$Do\figure_tables\Figure 1.do"		// Immigrant share in population
do "$Do\figure_tables\Table 1.do"		// Summary table
do "$Do\figure_tables\Table 2.do"		// Immigrant-native population ratio
do "$Do\figure_tables\Table 3-4.do"		// Native and University wage premia
do "$Do\figure_tables\Table 7.do"		// Estimation
*do "$Do\figure_tables\Table 8.do"		// Simulation
