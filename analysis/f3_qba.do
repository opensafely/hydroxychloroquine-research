/*==============================================================================
DO FILE NAME:			f3_qba
PROJECT:				HCQ in COVID-19 
DATE: 					11 August 2020 
AUTHOR:					Jeremy Brown, adapted by Christopher Rentsch
DESCRIPTION OF FILE:	read in saved datasets 
						generate e-value plots 
DATASETS USED:			dta saved as 'temp' in each tempdata directory created
DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
						graph and csv, printed to $Tabfigdir
							
==============================================================================*/

cap log close
log using $Logdir\f3_qba, replace t
clear


*read in datasets 
*covid death
*need to do some acrobatics to get tempdata out of multiple folders (one for each outcome)
cd  "$Dodir"
cd ..

*pull DAG-Informed model for COVID-19 death as outcome
use `c(pwd)'/output/tempdata/parmest_multivar2_mi_onscoviddeath.dta

* Keep relevant rows 
keep if parm == "1.exposure"

glob hr = estimate
glob lci = min95
glob uci = max95

di $hr
di $lci
di $uci


**************************
/* Create e-value plots */
**************************
*NB. Level of unmeasured confounding to explain results
/* Note from Jeremy
For e-value $hr should be the adjusted HR between HCQ and Covid-19 mortality, $lcI and $uci should be the lower and upper bounds of the confidence interval respectively. 
True refers to the hypothesised true effect. In our instance this is 0.8 so you would put true(0.8). 
*/

*protective effect of 0.8
evalue hr $hr, lcl($lci) ucl($uci) true(0.8) figure(scheme("s1color") aspect(1.01) ytitle(,size(small) margin(medium)) xtitle(,size(small) margin(medium)))
graph save "$Tabfigdir/evalue_protect.gph", replace
graph export "$Tabfigdir/evalue_protect.svg", replace 








**************************
/* Bias-adjusted hazard ratios */
**************************
*How would biologics have impacted results


** Define program for bias-adjusted HR
capture program drop bias_adjusted_hr
program define bias_adjusted_hr, rclass
syntax,  prev_exp(real) prev_unexp(real) hr_outcome(real) obshr(real)
	local numerator = 1 + ((`hr_outcome' - 1) * `prev_exp') 
	local denominator = 1 + ((`hr_outcome' - 1) * `prev_unexp') 
	return scalar adj_hr = `obshr'/(`numerator'/`denominator')
end

** Write bias-adjusted hazard ratios
capture file close textfile 
file open textfile using "$Tabfigdir/bias_adjusted_hr.csv", write text replace
file write textfile "sep=;" _n
file write textfile "Biologics prevalence HCQ exposed;Biologics prevalence HCQ unexposed;Biologics/COVID-19 HR" _n
file write textfile ";;HR 0.80;HR 0.90;HR 1.10;HR 1.20" _n

capture program drop write_bias_adjusted
program define write_bias_adjusted
syntax, prev_exp(real) prev_unexp(real)
	file write textfile "`prev_exp';`prev_unexp';"
	foreach hr of numlist 0.8 0.9 1.1 1.2 {
		bias_adjusted_hr, prev_exp(`prev_exp') prev_unexp(`prev_unexp') hr_outcome(`hr') obshr($hr)
		file write textfile %3.2f (r(adj_hr)) 
		bias_adjusted_hr, prev_exp(`prev_exp') prev_unexp(`prev_unexp') hr_outcome(`hr') obshr($lci)
		file write textfile " (" %3.2f (r(adj_hr)) "-"
		bias_adjusted_hr, prev_exp(`prev_exp') prev_unexp(`prev_unexp') hr_outcome(`hr') obshr($uci)
		file write textfile %3.2f (r(adj_hr)) ");" 
	}
	file write textfile _n
end 

write_bias_adjusted, prev_exp(0.18) prev_unexp(0.21)
write_bias_adjusted, prev_exp(0.3) prev_unexp(0.3)
write_bias_adjusted, prev_exp(0.1) prev_unexp(0.1)
write_bias_adjusted, prev_exp(0.1) prev_unexp(0.3)
write_bias_adjusted, prev_exp(0.3) prev_unexp(0.1)
file close textfile






*close log
log close 


