 set more off  
 *-----------------FIRST YEAR I.E. TOP PART OF THE TABLE 
 eststo clear     
 label var T "T 2002"                  
 qui reg Y1 T `x_prop' ///
				if year==2002        
 eststo y1_2002               
 qui reg Y2 T `x_prop' ///   
				if year==2002     
 eststo y2_2002               
 qui reg Y3 T `x_prop' ///       
				if year==2002     
 eststo y3_2002              
 qui reg Y4 T `x_prop' ///        
				if year==2002       
 eststo y4_2002  
 qui cap erase "C:\Users\...\tabz.tex"   // the replace option did not seem to work, so I used this way instead 
 estout using `"C:\Users\...\tabz.tex"' , ///  
		cells(b(fmt(a3) star) t(fmt(2) par)) ///
		starlevels(* 0.1 ** 0.05 *** 0.001) /// 
		varwidth(20) ///  
		modelwidth(12) /// 
		delimiter(&) /// 
		end(\\) /// 
		prehead("{\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{4}{c}} \toprule  &\multicolumn{1}{c}{(5)}&\multicolumn{1}{c}{(6)}&\multicolumn{1}{c}{(7)}&\multicolumn{1}{c}{(8)}\\") ///  
		posthead("\midrule") ///  
		label ///  
		varlabels(_cons Constant, end("" \addlinespace) nolast) ///  
		mlabels(, depvar span prefix(\multicolumn{@span}{c}{) suffix(})) ///  
		collabels(none) ///  eqlabels(, begin("\midrule" "") nofirst) /// 
		substitute(_ \_ "\_cons " \_cons) ///  
		interaction(" $\times$ ") /// 
		notype ///  level(95) ///  
		style(esttab) /// 
		keep(T)  
		
*-----------------OTHER YEARS I.E. MID PART OF THE TABLE 
forval i=2003/2015 {  
	eststo clear      
	label var T "T `i'"                 
	qui reg Y1 T `x_prop' ///                 
		if year==`i'                 
	eststo y1_`i'                  
	qui reg Y2 T `x_prop' ///                
		if year==`i'                
	eststo y2_`i'                  
	qui reg Y3 T `x_prop' ///                
		if year==`i'                 
	eststo y3_`i'                  
	qui reg Y4 T `x_prop' ///                
		if year==`i'                
	eststo y4_`i'  
	esttab using "C:\Users\...\tabz.tex\tabz.tex", keep(T) append f label nomtitle nonumber collabels(none) /// 
		starlevels(* 0.1 ** 0.05 *** 0.001) booktabs gaps noline ///     
		notes addnotes("t-statistics in parentheses" "*** p{$<$}0.01; ** p{$<$}0.05; * p{$<$}0.10.") ///     
		noobs 
}   
*-----------------OTHER YEARS I.E. BOTTOM PART OF THE TABLE  
eststo clear      
label var T "T 2016"                 
qui reg Y1 T `x_prop' ///                 
	if year==2016 & violat_2016==0                 
eststo y1_2016                  
qui reg Y2 T `x_prop' ///                
	if year==2016 & violat_2016==0                
eststo y2_2016                 
qui reg Y3 T `x_prop' ///            
	if year==2016 & violat_2016==0            
eststo y3_2016                  
qui reg Y4 T `x_prop' ///                 
	if year==2016 & violat_2016==0                 
eststo y4_2016  
esttab using "C:\Users\...\tabz.tex", keep(T) append f label nomtitle nonumber collabels(none) /// 
	starlevels(* 0.1 ** 0.05 *** 0.001) booktabs gaps noline ///     
	notes addnotes("t-statistics in parentheses" "*** p{$<$}0.01; ** p{$<$}0.05; * p{$<$}0.10.") ///      
	prefoot("\midrule") ///      
	postfoot("\bottomrule \multicolumn{5}{l}{\footnotesize t-statistics in parentheses}\\ \multicolumn{5}{l}{\footnotesize *** p{$<$}0.01; ** p{$<$}0.05; * p{$<$}0.10.}\\ \end{tabular}")
