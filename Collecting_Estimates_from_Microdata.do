clear all 
cd "C:\Users\Danielle Wilson\Dropbox\SPM_ASEC_ACS_project\"

/*TITLE: GATHERING SPM ESTIMATES FROM ACS AND CPS-ASEC SPM DATA - POOLED 2016 - 2018. 

DANIELLE WILSON
LAST UPDATED: 01/24/2021

*PURPOSE: The purpose of this code is to get counts and rates of all people who 
are SPM poor at the PUMA and state level. Estimates will be collected from both 
the CPS-ASEC and the ACS. State level estimates will be collected from the CPS-ASEC 
and the ACS. PUMA level estimates will only be collected from the ACS (as the 
CPS-ASEC does not provide identification at this disaggregate level). In this 
variation of the code weighted estimates will be collected from a pooled dataset 
for years 2016, 2017 and 2018. 

*IMPORTNAT NOTE ABOUT YEARS: SPM years correspond to data year not survey data. 
For example, SPM 2018 CPS corresponds to *survey year* 2019, which asks about the
financial status of individuals and their families in the year prior. 

*ACS SPM DATA: 
**2016: https://www2.census.gov/programs-surveys/supplemental-poverty-measure/datasets/spm/spm_2016_pu.dta
**2017: https://www2.census.gov/programs-surveys/supplemental-poverty-measure/datasets/spm/spm_2017_pu.dta
**2018: https://www2.census.gov/programs-surveys/supplemental-poverty-measure/datasets/spm/spm_2018_pu.dta

*CPS SPM DATA: 
**2016 (Research File): https://www.census.gov/data/datasets/2017/demo/income-poverty/2017-cps-asec-research-file.html
**2017 (Bridge - Publication): https://www.census.gov/data/datasets/2018/demo/income-poverty/cps-asec-bridge.html
**2018: https://www.census.gov/data/datasets/time-series/demo/cps/cps-asec.2019.html

*NOTE ABOUT NEW CPS-ASEC MICRO-DATA FILES: "The 2018 CPS ASEC Bridge File and 
the 2017 CPS ASEC Research File provide income, poverty, and health insurance
estimates based on these updated CPS ASEC questions as well as a redesigned pro-
cessing system." FOR MORE INFORMATION: 
https://www.census.gov/data/datasets/time-series/demo/income-poverty/cps-asec-design.html

NOTE ABOUT PREPARING CPS-ASEC FILES:
Starting in 2018, the SPM stopped publishing their own data sets. SPM variables 
were added to the CPS-ASEC micro data sets, where household, family, and person 
files need to be merged. Local location of the do file to combine all levels of
microdata is here: "\SPM_ASEC_ACS_project\CPS_datasets\combiningFiles.do"

NOTE ABOUT RUNNING THE FILE: 
File will run but all "save" commands are commented out. Uncomment save commands 
as needed. 

ATTRIBUTIONS: Code in this program was learned from Liana Fox. 
*/ 

/*******************************************************************************
INDEX
********************************************************************************
Line Number 	Description
________________________________________________________________________________

73 		STEP 1: Extract SPM state estimates from the CPS-ASEC. Will use 
		a pooled data set (micro data from the CPS-ASEC from years 2016,
		2017 & 2018. 
				
143		STEP 2A: Extract SPM state estimates from the ACS (again using 
		pooled data). 
				
202		STEP 2B: Extract SPM PUMA estimates from the ACS (using pooled 
		data). 
				
277		STEP 3: Merge ACS state (STEP 2A) and PUMA (STEP 2B) estimates. 
				
314		STEP 4: Merge ACS (STEP 3) and CPS-ASEC (STEP 1) estimates. 

*/ 

********************************************************************************
*STEP 1: POOLED CPS-ASEC DATA FOR THREE YEAR AVERAGES
********************************************************************************
******* POOL CPS-ASEC SURVEY DATA FROM 2016, 2017 AND 2018 - STATE LEVEL ******* 

use "CPS_datasets\New_processing_system\spm_year2016.dta"
forvalues y = 17(1)18{
append using "CPS_datasets\New_processing_system\spm_year20`y'"
}

*RENAME VAR (TO BE CONSISTENT WITH PRIOR CODE)
rename spm_poor spmu_poor 

	*SET SURVEY (WILL NOT USE REPLICATE WEIGHTS)
	*svyset [pweight=marsupwt], brrweight(pwwgt0 - pwwgt160) vce(brr) fay(0.5) mse
	svyset [pweight=marsupwt]
	
	*AT THE STATE LEVEL: 
	
		*FOR (WEIGHTED) COUNTS OF ALL PEOPLE 
		gen count = (spmu_poor == 1 | spmu_poor == 0)
		levelsof gestfips, local(state)
		svy: total count, over(gestfips) 
		foreach i of local state {
			lincom count#`i'.gestfips
			gen w_count_Ns`i' = r(estimate)
		}
		
		*FOR (WEIGHTED) COUNTS OF SPM POOR 
		levelsof gestfips, local(state)
		svy: total spmu_poor, over(gestfips) 
		foreach i of local state {
			lincom spmu_poor#`i'.gestfips
			gen w_spmu_poor_Ns`i' = r(estimate)
		}
		
		*FOR (WEIGHTED) PERCENTAGE OF SPM POOR 
		levelsof gestfips, local(state)
		svy: mean spmu_poor, over(gestfips) 
		foreach i of local state {
			lincom spmu_poor#`i'.gestfips
			gen w_spmu_poor_ms`i' = r(estimate) 
		}
		
			levelsof gestfips, local(state)
			foreach i of local state {
				sum w_spmu_poor_ms`i' 
			}
			
			levelsof gestfips, local(state)
			foreach i of local state {
				sum spmu_poor if gestfips == `i' [aw=marsupwt]
			}
		
		*FORMAT THE ESTIMATES INTO A SMALLER DATASET FOR OUTPUT
		keep in 1 
		keep w_count_Ns* w_spmu_poor_Ns* w_spmu_poor_ms*   
	
		gen id = 1 

		reshape long ///
				w_count_Ns w_spmu_poor_Ns w_spmu_poor_ms ///
			    , i(i) j(state_gestfips)
				
		drop id 

		//save "CPS_datasets\New_processing_system\cps_state_spm2016_18.dta"

********************************************************************************
*STEP 2: POOLED ACS DATA FOR THREE YEAR AVERAGES
********************************************************************************		
**** STEP 2A: POOL ACS SURVEY DATA FROM 2016, 2017 AND 2018 - STATE LEVEL ******
clear all 
use "ACS_datasets\spm_2016_pu"
forvalues y = 17(1)18{
append using "ACS_datasets\spm_20`y'_pu"
}

	*KEEP ONLY NEEDED VARIABLES 
	keep spm_id wt spm_poor st puma
	
	*RENAME VARIABLES TO BE CONSISTENT WITH CPS-ASEC DATA SET 
	rename spm_poor spmu_poor 
	rename st gestfips  
	
	*SET SURVEY 
	svyset [pweight=wt]
	
	*AT THE STATE LEVEL: 
	
		*FOR (WEIGHTED) COUNTS OF ALL PEOPLE 
		gen count = (spmu_poor == 1 | spmu_poor == 0)
		levelsof gestfips, local(state)
		svy: total count, over(gestfips) 
		foreach i of local state {
			lincom count#`i'.gestfips
			gen w_count_Ns`i' = r(estimate)
		}
		
		*FOR (WEIGHTED) COUNTS OF SPM POOR 
		levelsof gestfips, local(state)
		svy: total spmu_poor, over(gestfips) 
		foreach i of local state {
			lincom spmu_poor#`i'.gestfips
			gen w_spmu_poor_Ns`i' = r(estimate)
		}
		
		*FOR (WEIGHTED) PERCENTAGE OF SPM POOR 
		levelsof gestfips, local(state)
		svy: mean spmu_poor, over(gestfips) 
		foreach i of local state {
			lincom spmu_poor#`i'.gestfips
			gen w_spmu_poor_ms`i' = r(estimate) 
		}
		
			
		*FORMAT THE ESTIMATES INTO A SMALLER DATASET FOR OUTPUT
		keep in 1 
		keep 	w_count_Ns* w_spmu_poor_Ns* w_spmu_poor_ms*   
	
		gen id = 1 

		reshape long ///
				w_count_Ns w_spmu_poor_Ns w_spmu_poor_ms ///
			    , i(i) j(state_gestfips)
				
		drop id 

		//save acs_state_spm2016_18

**** STEP 2B: POOL ACS SURVEY DATA FROM 2016, 2017 AND 2018 - PUMA LEVEL *******
clear all 
use "ACS_datasets\spm_2016_pu"
forvalues y = 17(1)18{
append using "ACS_datasets\spm_20`y'_pu"
}

*KEEP ONLY NEEDED VARIABLES 
	keep spm_id wt spm_poor st puma
	
	*RENAME VARIABLES TO BE CONSISTENT WITH CPS-ASEC DATA SET 
	rename spm_poor spmu_poor 
	rename st gestfips  
	
	*SET SURVEY 
	svyset [pweight=wt]
	
	levelsof gestfips, local(state)
	foreach j of local state {
		preserve 
		
		keep if gestfips == `j'
		
		*SET SURVEY 
		svyset [pweight=wt]
		
		*AT THE PUMA LEVEL 
			
			*FOR (WEIGHTED) COUNTS OF ALL PEOPLE 
			gen count = (spmu_poor == 1 | spmu_poor == 0)
			levelsof puma, local(npuma)
			svy: total count, over(puma) 
			foreach i of local npuma {
				lincom count#`i'.puma
				gen w_count_Ns`j'_p`i' = r(estimate)
			}
	
			*FOR (WEIGHTED) COUNTS OF SPM POOR 
			levelsof puma, local(npuma)
			svy: total spmu_poor, over(puma) 
			foreach i of local npuma {
				lincom spmu_poor#`i'.puma
				gen w_spmu_poor_Ns`j'_p`i' = r(estimate)
			}
			
			*FOR (WEIGHTED) PERCENTAGE OF SPM POOR 
			levelsof puma, local(npuma)
			svy: mean spmu_poor, over(puma)		
			foreach i of local npuma {
				lincom spmu_poor#`i'.puma
				gen w_spmu_poor_ms`j'_p`i' = r(estimate) * 100 
				gen w_spmu_poor_ses`j'_p`i' = r(se) * 100 
			}
			

			*FORMAT THE ESTIMATES INTO A SMALLER DATASET FOR OUTPUT
			keep in 1 
			keep 	w_count_Ns`j'_p* w_spmu_poor_Ns`j'_p* ///
					w_spmu_poor_ms`j'_p* w_spmu_poor_ses`j'_p*
			
			gen id =`j'

			reshape long ///
					w_count_Ns`j'_p w_spmu_poor_Ns`j'_p ///
					w_spmu_poor_ms`j'_p w_spmu_poor_ses`j'_p, ///
					i(id) j(puma)
					
			rename id state_gestfips

			//save new_acs_puma_s`j'_spm2016_18, replace
			
			restore
	}
	
********************************************************************************
* STEP 3: MERGE POOLED ACS PUMA AND STATE SURVEY DATA
********************************************************************************	
*CONTINUE USING FINAL PUMA DATASET (AS PRODUCED IN THE PREVIOUS SECTION)...

*RENAME VARIABLES IN ACS PUMA DATASETS TO BE CONSISTENT WITH CORRESPONDING STATE
*DATESET (PREVIOUSLY NAMED VARIABLES WITH FIPS # IN THEM FOR "KEEPING TRACK" PURPOSES). 
foreach i in 1 2 4 5 6 8 9 10 11 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 99 {
	clear all 
	use new_acs_puma_s`i'_spm2016_18
	rename w_spmu_poor_Ns`i'_p w_spmu_poor_Ns_p 
	rename w_spmu_poor_ms`i'_p w_spmu_poor_ms_p 
	rename w_spmu_poor_ses`i'_p w_spmu_poor_ses_p
	rename w_count_Ns`i'_p w_count_Ns_p 
	save new_acs_puma_s`i'_spm2016_18, replace 
} 

*MERGE WITH STATE ACS ESITMATES 
clear all 
use acs_state_spm2016_18

keep state_gestfips
	levelsof state_gestfips, local(nstate)
	foreach i of local nstate{
		append using "Working_data_files\Three_year_avg_data_files\new_acs_puma_s`i'_spm2016_18"
	}

	*CLEAN DATASETS 
	drop if puma == . 

*MERGE BACK CORRESPONDING ACS STATE VARIABLES 
merge m:1 state_gestfips using acs_state_spm2016_18
drop _merge 

*SAVE FINAL STATE AND PUMA ACS DATASETS 
//save acs_state_and_puma_spm2016_18

********************************************************************************
*STEP 4: MERGE POOLED ACS PUMA AND STATE SURVEY DATA W/ CPS STATE DATA 
********************************************************************************	
clear all 
use "CPS_datasets\New_processing_system\cps_state_spm2016_18.dta"

*PREP VARIABLES - RENAME TO DISTINGUISH FROM ACS COUNTERPARTS 
rename * cps_*
rename cps_state_gestfips state_gestfips

*MERGE WITH ACS DATA 
merge 1:m state_gestfips using acs_state_and_puma_spm2016_18

*CLEANING 
drop if state_gestfips == 99 
drop _merge 
order 	state_gestfips puma ///
		cps_w_count_Ns cps_w_spmu_poor_Ns cps_w_spmu_poor_ms ///
		w_count_Ns   w_spmu_poor_Ns   w_spmu_poor_ms ///
		w_count_Ns_p w_spmu_poor_Ns_p w_spmu_poor_ms_p w_spmu_poor_ses_p ///
		, first 
	
	*TRANSFORM RATES BACK INTO DECIMAL FORM (FROM ACS PUMA LEVEL)
	gen nw_spmu_poor_ms_p = w_spmu_poor_ms_p / 100 
	gen nw_spmu_poor_ses_p = w_spmu_poor_ses_p / 100 
	
	drop w_spmu_poor_ms_p w_spmu_poor_ses_p
	rename nw_spmu_poor_ms_p w_spmu_poor_ms_p
	rename nw_spmu_poor_ses_p w_spmu_poor_ses_p

*SAVE POOLELD DATASET 
sort state_gestfips puma
//save acs_cps_pooled_spm_2016_18, replace 
//export excel using "acs_cps_pooled_spm_2016_18.xlsx", firstrow(variables) replace 















