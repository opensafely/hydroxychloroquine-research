/*==============================================================================
DO FILE NAME:			14_reviewer_comments
PROJECT:				HCQ in COVID-19 
DATE: 					5 October 2020 
AUTHOR:					C Rentsch
DESCRIPTION OF FILE:	Answers to reviewer comments
DATASETS USED:			$Tempdir\analysis_dataset.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Log file: $Logdir\14_reviewer_comments
USER-INSTALLED ADO: 	-none-
  (place .ado file(s) in analysis folder)								
==============================================================================*/




* Open a log file

capture log close
log using $Logdir\14_reviewer_comments, replace t

* Open Stata dataset
use $Tempdir\analysis_dataset, clear






****** When was first HCQ Rx before index date
tab hcq_first hcq, m

****** Median number of HCQ Rx in exposure window 
summ hcq_count if hcq == 1, detail



