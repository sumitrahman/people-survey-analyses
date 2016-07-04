*this takes the 2013 BIS dataset and prepares it for comparison with 2015.  The 2013 data is mapped to the 2015 BIS departmental structure 

clear

*to turn the hierarchy dataset into a mapping of RespondentID to reporting units
*this created "2013 ID to RU.dta"
/*
sort ResponseID Population
gen AAA=cond( ResponseID[_n]== ResponseID[_n-1],0,1) if _n>1
replace AAA=1 if _n==1
keep if AAA==1
drop AAA
*/
*mapping RUs to 2015 structure
*this created "mapping 2014 RU to 2015.dta"

import excel "S:\Datasets-Working\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\hierarchies 2012 and 2013 and 2014 for 2015.xls", sheet("2013 codes NEW") firstrow allstring clear
save "S:\Datasets-Working\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\mapping 2013 RU to 2015.dta"


*mapping poststrata to their populations
*this created "mapping 2013 poststrata to 2015.dta"

import excel "S:\Datasets-Working\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\hierarchies 2012 and 2013 and 2014 for 2015.xls", sheet("2013 strata for 2015") firstrow allstring clear

rename stratum poststratum
destring poststratum, replace
recast int poststratum
save "S:\Datasets-Working\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\mapping 2013 poststrata to 2015.dta"



use "S:\Datasets-Working\SURVEY-SUPPORT-TEAM\Pulse and People\2013\2013 BIS data.dta", clear
merge 1:1 ResponseID using "S:\Datasets-Working\SURVEY-SUPPORT-TEAM\Pulse and People\2013\2013 ID to RU.dta", keep (match master)
drop Returns Population _merge
rename DeptCode RU
merge m:1 RU using "S:\Datasets-Working\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\mapping 2013 RU to 2015.dta"
drop _merge
drop if ResponseID==.



gen int grade=.
replace grade=K01_BIS
replace grade=8 if K01_BIS==9
replace grade=9 if K01_BIS==.	/*This puts AAs in the same set as AOs and EAs */



gen int poststratum=.
replace poststratum= 9 if grade==9
replace poststratum= 1 if grade==8
replace poststratum= 2 if grade==7
replace poststratum= 3 if grade==6
replace poststratum= 4 if grade==5
replace poststratum= 5 if grade==4
replace poststratum= 6 if grade==3
replace poststratum= 7 if grade==2
replace poststratum= 8 if grade==1
replace poststratum= 9 if grade==9

tabulate poststratum
tabulate grade
tabulate K01_BIS

merge m:1 poststratum using "S:\Datasets-Working\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\mapping 2013 poststrata to 2015.dta"
drop _merge
destring popNEW, replace


sort poststratum
qbys poststratum: egen samplesize = count(ResponseID) /*This puts the number of respondents in each poststratification class in as 'samplesize'*/

gen weight1=popNEW/samplesize /*we could use this for manually postratifying ourselves, but we won't do this*/
gen weight2=1
replace weight2=0 if RU=="BIS0081" /*represents that everyone had the same sampling probability of 1; we'll let Stata handle the poststratification by using 'poststrata' and 'postweight' EXCEPT DIGITAL WHICH DONT EXIST ANYMORE*/
gen fpc=2480

encode groupNEW, generate (NEWgroup) /*these encodings are required to turn the groups, directorates into numerical variables*/
encode directorateNEW, generate (NEWdirectorate) /*which we need to do for later analyses where we run estimates over each group or each directorate*/
encode orgNEW, generate (NEWorg)
encode RU, generate (NEWRU)
drop groupNEW directorateNEW orgNEW RU
*svyset _n [pw=weight1], fpc(fpc)
svyset _n [pw=weight2], fpc(fpc) poststrata(poststratum) postweight(popNEW) /*this is the svyset we are generally using*/


*generate theme scores for Theme 1 - My Work
gen B01AAA=B01<.
gen B02AAA=B02<.
gen B03AAA=B03<.
gen B04AAA=B04<.
gen B05AAA=B05<.
gen AAA=B01AAA + B02AAA + B03AAA + B04AAA + B05AAA
replace B01AAA=B01
replace B02AAA=B02
replace B03AAA=B03
replace B04AAA=B04
replace B05AAA=B05
replace B01AAA=0 if B01==.
replace B02AAA=0 if B02==.
replace B03AAA=0 if B03==.
replace B04AAA=0 if B04==.
replace B05AAA=0 if B05==.
gen Theme1=((B01AAA + B02AAA + B03AAA + B04AAA + B05AAA)/AAA)/4-0.25
drop AAA B01AAA B02AAA B03AAA B04AAA B05AAA

*generate theme scores for Theme 2 - Organisational Objectives and Purpose
gen B06AAA=B06<.
gen B07AAA=B07<.
gen B08AAA=B08<.
gen AAA=B06AAA + B07AAA + B08AAA
replace B06AAA=B06
replace B07AAA=B07
replace B08AAA=B08
replace B06AAA=0 if B06==.
replace B07AAA=0 if B07==.
replace B08AAA=0 if B08==.
gen Theme2=((B06AAA + B07AAA + B08AAA)/AAA)/4-0.25
drop AAA B06AAA B07AAA B08AAA

*generate theme scores for Theme 3 - My Manager
gen B09AAA=B09<.
gen B10AAA=B10<.
gen B11AAA=B11<.
gen B12AAA=B12<.
gen B13AAA=B13<.
gen B14AAA=B14<.
gen B15AAA=B15<.
gen B16AAA=B16<.
gen B17AAA=B17<.
gen B18AAA=B18<.
gen AAA=B09AAA + B10AAA + B11AAA + B12AAA + B13AAA + B14AAA + B15AAA + B16AAA + B17AAA + B18AAA
replace B09AAA=B09
replace B10AAA=B10
replace B11AAA=B11
replace B12AAA=B12
replace B13AAA=B13
replace B14AAA=B14
replace B15AAA=B15
replace B16AAA=B16
replace B17AAA=B17
replace B18AAA=B18
replace B09AAA=0 if B09==.
replace B10AAA=0 if B10==.
replace B11AAA=0 if B11==.
replace B12AAA=0 if B12==.
replace B13AAA=0 if B13==.
replace B14AAA=0 if B14==.
replace B15AAA=0 if B15==.
replace B16AAA=0 if B16==.
replace B17AAA=0 if B17==.
replace B18AAA=0 if B18==.
gen Theme3=((B09AAA + B10AAA + B11AAA + B12AAA + B13AAA + B14AAA + B15AAA + B16AAA + B17AAA + B18AAA)/AAA)/4-0.25
drop AAA B09AAA B10AAA B11AAA B12AAA B13AAA B14AAA B15AAA B16AAA B17AAA B18AAA

*generate theme scores for Theme 4 - My Team
gen B19AAA=B19<.
gen B20AAA=B20<.
gen B21AAA=B21<.
gen AAA=B19AAA + B20AAA + B21AAA
replace B19AAA=B19
replace B20AAA=B20
replace B21AAA=B21
replace B19AAA=0 if B19==.
replace B20AAA=0 if B20==.
replace B21AAA=0 if B21==.
gen Theme4=((B19AAA + B20AAA + B21AAA)/AAA)/4-0.25
drop AAA B19AAA B20AAA B21AAA

*generate theme scores for Theme 5 - Learning and Development
gen B22AAA=B22<.
gen B23AAA=B23<.
gen B24AAA=B24<.
gen B25AAA=B25<.
gen AAA=B22AAA + B23AAA + B24AAA + B25AAA
replace B22AAA=B22
replace B23AAA=B23
replace B24AAA=B24
replace B25AAA=B25
replace B22AAA=0 if B22==.
replace B23AAA=0 if B23==.
replace B24AAA=0 if B24==.
replace B25AAA=0 if B25==.
gen Theme5=((B22AAA + B23AAA + B24AAA + B25AAA)/AAA)/4-0.25
drop AAA B22AAA B23AAA B24AAA B25AAA

*generate theme scores for Theme 6 - Inclusion and Fair Treatment
gen B26AAA=B26<.
gen B27AAA=B27<.
gen B28AAA=B28<.
gen B29AAA=B29<.
gen AAA=B26AAA + B27AAA + B28AAA + B29AAA
replace B26AAA=B26
replace B27AAA=B27
replace B28AAA=B28
replace B29AAA=B29
replace B26AAA=0 if B26==.
replace B27AAA=0 if B27==.
replace B28AAA=0 if B28==.
replace B29AAA=0 if B29==.
gen Theme6=((B26AAA + B27AAA + B28AAA + B29AAA)/AAA)/4-0.25
drop AAA B26AAA B27AAA B28AAA B29AAA

*generate theme scores for Theme 7 - Resources and Workload
gen B30AAA=B30<.
gen B31AAA=B31<.
gen B32AAA=B32<.
gen B33AAA=B33<.
gen B34AAA=B34<.
gen B35AAA=B35<.
gen B36AAA=B36<.
gen AAA=B30AAA + B31AAA + B32AAA + B33AAA + B34AAA + B35AAA + B36AAA
replace B30AAA=B30
replace B31AAA=B31
replace B32AAA=B32
replace B33AAA=B33
replace B34AAA=B34
replace B35AAA=B35
replace B36AAA=B36
replace B30AAA=0 if B30==.
replace B31AAA=0 if B31==.
replace B32AAA=0 if B32==.
replace B33AAA=0 if B33==.
replace B34AAA=0 if B34==.
replace B35AAA=0 if B35==.
replace B36AAA=0 if B36==.
gen Theme7=((B30AAA + B31AAA + B32AAA + B33AAA + B34AAA + B35AAA + B36AAA)/AAA)/4-0.25
drop AAA B30AAA B31AAA B32AAA B33AAA B34AAA B35AAA B36AAA

*generate theme scores for Theme 8 - Pay and Benefits
gen B37AAA=B37<.
gen B38AAA=B38<.
gen B39AAA=B39<.
gen AAA=B37AAA + B38AAA + B39AAA
replace B37AAA=B37
replace B38AAA=B38
replace B39AAA=B39
replace B37AAA=0 if B37==.
replace B38AAA=0 if B38==.
replace B39AAA=0 if B39==.
gen Theme8=((B37AAA + B38AAA + B39AAA)/AAA)/4-0.25
drop AAA B37AAA B38AAA B39AAA

*generate theme scores for Theme 9 - Leadership and Managing Change
gen B40AAA=B40<.
gen B41AAA=B41<.
gen B42AAA=B42<.
gen B43AAA=B43<.
gen B44AAA=B44<.
gen B45AAA=B45<.
gen B46AAA=B46<.
gen B47AAA=B47<.
gen B48AAA=B48<.
gen B49AAA=B49<.
gen AAA=B40AAA + B41AAA + B42AAA + B43AAA + B44AAA + B45AAA + B46AAA + B47AAA + B48AAA + B49AAA
replace B40AAA=B40
replace B41AAA=B41
replace B42AAA=B42
replace B43AAA=B43
replace B44AAA=B44
replace B45AAA=B45
replace B46AAA=B46
replace B47AAA=B47
replace B48AAA=B48
replace B49AAA=B49
replace B40AAA=0 if B40==.
replace B41AAA=0 if B41==.
replace B42AAA=0 if B42==.
replace B43AAA=0 if B43==.
replace B44AAA=0 if B44==.
replace B45AAA=0 if B45==.
replace B46AAA=0 if B46==.
replace B47AAA=0 if B47==.
replace B48AAA=0 if B48==.
replace B49AAA=0 if B49==.
gen Theme9=((B40AAA + B41AAA + B42AAA + B43AAA + B44AAA + B45AAA + B46AAA + B47AAA + B48AAA + B49AAA)/AAA)/4-0.25
drop AAA B40AAA B41AAA B42AAA B43AAA B44AAA B45AAA B46AAA B47AAA B48AAA B49AAA

*generate theme scores for Theme 10 - Taking Action
gen B55AAA=B55<.
gen B56AAA=B56<.
gen B57AAA=B57<.
gen AAA=B55AAA + B56AAA + B57AAA
replace B55AAA=B55
replace B56AAA=B56
replace B57AAA=B57
replace B55AAA=0 if B55==.
replace B56AAA=0 if B56==.
replace B57AAA=0 if B57==.
gen Theme10=((B55AAA + B56AAA + B57AAA)/AAA)/4-0.25
drop AAA B55AAA B56AAA B57AAA

*generate theme scores for Theme 11 - Organisational Culture
gen B58AAA=B58<.
gen B59AAA=B59<.
gen B60AAA=B60<.
gen B61AAA=B61<.
gen B62AAA=B62<.
gen AAA=B58AAA + B59AAA + B60AAA + B61AAA + B62AAA
replace B58AAA=B58
replace B59AAA=B59
replace B60AAA=B60
replace B61AAA=B61
replace B62AAA=B62
replace B58AAA=0 if B58==.
replace B59AAA=0 if B59==.
replace B60AAA=0 if B60==.
replace B61AAA=0 if B61==.
replace B62AAA=0 if B62==.
gen Theme11=((B58AAA + B59AAA + B60AAA + B61AAA + B62AAA)/AAA)/4-0.25
drop AAA B58AAA B59AAA B60AAA B61AAA B62AAA

*generate theme scores for Theme 12 - Wellbeing
gen W01AAA=W01<.
gen W02AAA=W02<.
gen W03AAA=W03<.
gen W04AAA=W04<.
gen AAA=W01AAA + W02AAA + W03AAA + W04AAA
replace W01AAA=W01
replace W02AAA=W02
replace W03AAA=W03
replace W04AAA=10-W04
replace W01AAA=0 if W01==.
replace W02AAA=0 if W02==.
replace W03AAA=0 if W03==.
replace W04AAA=0 if W04==.
gen Theme12=((W01AAA + W02AAA + W03AAA + W04AAA)/AAA)/10
drop AAA W01AAA W02AAA W03AAA W04AAA

*generate theme scores for Theme 13 - Engaging Leadership
gen B06AAA=B06<.
gen B08AAA=B08<.
gen B12AAA=B12<.
gen B43AAA=B43<.
gen AAA=B06AAA + B08AAA + B12AAA + B43AAA
replace B06AAA=B06
replace B08AAA=B08
replace B12AAA=B12
replace B43AAA=B43
replace B06AAA=0 if B06==.
replace B08AAA=0 if B08==.
replace B12AAA=0 if B12==.
replace B43AAA=0 if B43==.
gen Theme13=((B06AAA + B08AAA + B12AAA + B43AAA)/AAA)/4-0.25
drop AAA B06AAA B08AAA B12AAA B43AAA

*generate theme scores for Theme 14 - Employee Voice
gen B04AAA=B04<.
gen B11AAA=B11<.
gen B47AAA=B47<.
gen B48AAA=B48<.
gen B49AAA=B49<.
gen AAA=B04AAA + B11AAA + B47AAA + B48AAA + B49AAA
replace B04AAA=B04
replace B11AAA=B11
replace B47AAA=B47
replace B48AAA=B48
replace B49AAA=B49
replace B04AAA=0 if B04==.
replace B11AAA=0 if B11==.
replace B47AAA=0 if B47==.
replace B48AAA=0 if B48==.
replace B49AAA=0 if B49==.
gen Theme14=((B04AAA + B11AAA + B47AAA + B48AAA + B49AAA)/AAA)/4-0.25
drop AAA B04AAA B11AAA B47AAA B48AAA B49AAA

*generate theme scores for Theme 15 - Engaging Managers
gen B02AAA=B02<.
gen B10AAA=B10<.
gen B14AAA=B14<.
gen B15AAA=B15<.
gen B16AAA=B16<.
gen B17AAA=B17<.
gen B18AAA=B18<.
gen B22AAA=B22<.
gen B23AAA=B23<.
gen B25AAA=B25<.
gen B26AAA=B26<.
gen B27AAA=B27<.
gen B30AAA=B30<.
gen B35AAA=B35<.
gen F03_BISAAA=F03_BIS<.
gen F04_BISAAA=F04_BIS<.
gen AAA=B02AAA + B10AAA + B14AAA + B15AAA + B16AAA + B17AAA + B18AAA + B22AAA + B23AAA + B25AAA + B26AAA + B27AAA + B30AAA + B35AAA + F03_BISAAA + F04_BISAAA
replace B02AAA=B02
replace B10AAA=B10
replace B14AAA=B14
replace B15AAA=B15
replace B16AAA=B16
replace B17AAA=B17
replace B18AAA=B18
replace B22AAA=B22
replace B23AAA=B23
replace B25AAA=B25
replace B26AAA=B26
replace B27AAA=B27
replace B30AAA=B30
replace B35AAA=B35
replace F03_BISAAA=F03_BIS
replace F04_BISAAA=F04_BIS
replace B02AAA=0 if B02==.
replace B10AAA=0 if B10==.
replace B14AAA=0 if B14==.
replace B15AAA=0 if B15==.
replace B16AAA=0 if B16==.
replace B17AAA=0 if B17==.
replace B18AAA=0 if B18==.
replace B22AAA=0 if B22==.
replace B23AAA=0 if B23==.
replace B25AAA=0 if B25==.
replace B26AAA=0 if B26==.
replace B27AAA=0 if B27==.
replace B30AAA=0 if B30==.
replace B35AAA=0 if B35==.
replace F03_BISAAA=0 if F03_BIS==.
replace F04_BISAAA=0 if F04_BIS==.
gen Theme15=((B02AAA + B10AAA + B14AAA + B15AAA + B16AAA + B17AAA + B18AAA + B22AAA + B23AAA + B25AAA + B26AAA + B27AAA + B30AAA + B35AAA + F03_BISAAA + F04_BISAAA)/AAA)/4-0.25
drop AAA B02AAA B10AAA B14AAA B15AAA B16AAA B17AAA B18AAA B22AAA B23AAA B25AAA B26AAA B27AAA B30AAA B35AAA F03_BISAAA F04_BISAAA

*generate percentage positive variables for the BIS questions
forvalues t=1/6 {
gen ppF0`t'_BIS=.
replace ppF0`t'_BIS=0 if F0`t'_BIS<4
replace ppF0`t'_BIS=1 if F0`t'_BIS==4 | F0`t'_BIS==5
}

*****************************************************************************************************************
replace grade=9 if K01_BIS==.			/* 1=SCS 2=G6 3=G7 4=FS 5=SEO */
										/* 6=HEO 7=EO 8=AA/EA/AO 9=unknown */


gen sex=4
replace sex=J01 if J01<3
replace sex=3 if J01==.a			/* 1=male 2=female 3=prefer not say 4=missing */


gen age1=5
replace age1=1 if J02<5
replace age1=2 if J02==5 | J02==6
replace age1=3 if J02>6 & J02<12
replace age1=4 if J02==.a
		/* 1=16-34 2=35-44 3=45+ 4=missing */
gen age2=4
replace age2=1 if J02<6
replace age2=2 if J02>5 & J02<12
replace age2=3 if J02==.a
		/* 1=16-39 2=40+ 3=missing */
gen age3=6
replace age3=1 if J02<4
replace age3=2 if J02==4|J02==5	
replace age3=3 if J02==6|J02==7	
replace age3=4 if J02>7 & J02<12
replace age3=5 if J02==.a		/* 1=16-29 2=30-39 3=40-49 4=50+ 5=missing */


/* try different age cat*/


gen age4=7
replace age4=1 if J02<4
replace age4=2 if J02==4|J02==5	
replace age4=3 if J02==6|J02==7	
replace age4=4 if J02==8|J02==9
replace age4=5 if J02>9 & J02<12
replace age4=6 if J02==.a   /* 1=16-29 2=30-39 3=40-49 4=50-59 5=60+ 6=missing */


gen bme1=4
replace bme1=1 if J03<5
replace bme1=2 if J03>4 & J03<19
replace bme1=3 if J03==.a		/* 1=White British; Irish; Traveller; Other White 2=Other 3=missing */

gen bme2=4
replace bme2=1 if J03==1
replace bme2=2 if J03>1 & J03<19		/* 1=White British 2=other 3=missing */
replace bme2=3 if J03==.a

tabulate bme2


gen disability=J04
replace disability=3 if J04==.a
replace disability=4 if J04==.			/* 1=Yes 2=No 3=missing */
tabulate disability 

gen carer=J05
replace carer=3 if J05==.a	
replace carer=4 if J05==.				/* 1=Yes 2=No 3=missing */

gen childcare=J06
replace childcare=3 if J06==.a	
replace childcare=4 if J06==.		/* 1=Yes 2=No 3=missing */

gen sexuality1=4
replace sexuality1=1 if J07==1
replace sexuality1=2 if J07>1 & J07<5
replace sexuality1=3 if J07==.a	/*1=straight 2=other 3=missing */


gen religion1=5
replace religion1=J08 if J08<3
replace religion1=3 if J08>2 & J08<9
replace religion1=4 if J08==.a	/*1=none 2=Christian 3=other 4=missing */

gen religion2=4
replace religion2=1 if J08==1
replace religion2=2 if J08>1 & J08<9
replace religion2=3 if J08==.a     	/*1=none 2=religious 3=missing */

gen location=4
replace location=3 if H01<.				/*1=London 2=Yorks&Humb 3=other 4=missing */
replace location=1 if H1A==3
replace location=2 if H1A==9

gen losbis1=5
replace losbis1=1 if H03<3
replace losbis1=2 if H03==3
replace losbis1=3 if H03==4
replace losbis1=4 if H03>4 & H03<.		/*1=less than 1y 2=1-5y 3=5-10y 4=10y+ 5=missing */

gen losbis2=4
replace losbis2=1 if H03<3
replace losbis2=2 if H03>2 & H03<6
replace losbis2=3 if H03>5 & H03<.		/*1=less than 1y 2=1-10y 3=10y+ 4=missing */

gen losbis4=6
replace losbis4=1 if H03<3
replace losbis4=2 if H03==3|H03==4
replace losbis4=3 if H03==5
replace losbis4=4 if H03==6
replace losbis4=5 if H03>6 & H03<.		/*1=less than 1y 2=1-4y 3=5-9y 4=10y-19 5=20+ 6=missing */


gen ftpt=H06
replace ftpt=4 if H06==.				/*1=full-time 2=part-time 3=job sharer 4=missing */
gen profcomm=H8A
replace profcomm=3 if H8A==.			/*1=part of a cross-government professional community 2=not 3=missing */



*set up labels for the classifications defined by me
*not all my classifications are getting labelled, mostly the ones I make regular use of
label define label_sex 1 "male" 2 "female" 3 "PNS" 4 "undeclared"
label values sex label_sex
label define label_grade 1 "SCS" 2 "G6" 3 "G7" 4 "FS" 5 "SEO" 6 "HEO" 7 "EO" 8 "AA/EA/AO" 9 "undeclared"
label values grade label_grade
label define label_group 1 "BS" 2 "EM" 3 "FC" 4 "Legal" 5 "MPST" 6 "PSHE" 7 "SHEX" 8 "Skills" 9 "GOS" 10 "OME" 11 "UKSA" 
label values NEWgroup label_group
label define label_age1 1 "16-34" 2 "35-44" 3 "45+" 4 "PNS" 5 "undeclared"
label values age1 label_age1
label define label_age3 1 "16-29" 2 "30-39" 3 "40-49" 4 "50+" 5 "PNS" 6 "undeclared"
label values age3 label_age3
label define label_age4 1 "16-29" 2 "30-39" 3 "40-49" 4 "50-59" 5 "60+" 6 "PNS" 7 "undeclared"
label values age4 label_age4
label define label_bme2 1 "White British" 2 "BME" 3 "PNS" 4 "undeclared"
label values bme2 label_bme2
label define label_disability 1 "disabled" 2 "not disabled" 3 "PNS" 4 "undeclared"
label values disability label_disability
label define label_carer 1 "carer" 2 "not a carer" 3 "PNS" 4 "undeclared"
label values carer label_carer
label define label_childcare 1 "childcarer" 2 "not a childcarer" 3 "PNS" 4 "undeclared"
label values childcare label_childcare
label define label_sexuality1 1 "straight" 2 "not straight" 3 "PNS" 4 "undeclared"
label values sexuality1 label_sexuality1
label define label_religion1 1 "no religion" 2 "Christian" 3 "other religion" 4 "PNS" 5 "undeclared"
label values religion1 label_religion1
label define label_location 1 "London" 2 "Sheffield" 3 "Other" 4 "undeclared"
label values location label_location
label define label_losbis2 1 "less than 1 year" 2 "1-10 years" 3 "more than 10 years" 4 "undeclared"
label values losbis2 label_losbis2
label define label_losbis4 1 "less than 1 year" 2 "1-5 years" 3 "more than 5 - 10 years"  4 "more than 10 years- 20 years" 5 "more than 20 years" 6 "undeclared"
label values losbis4 label_losbis4
label define label_ftpt 1 "full time" 2 "part time" 3 "job sharer" 4 "undeclared"
label values ftpt label_ftpt
label define label_profcomm 1 "member of a professional community" 2 "not a member of a professional community" 3 "undeclared"
label values profcomm label_profcomm

tabulate sexuality1



*regressions to get at the pure theme scores for each demographic categorisation
*I think regressions are robust because we are using pweights
*this particular list of explanatory variables was arrived at after some stepwise procedures, future regressions might
*need to revisit others (but there's rather a lot here already)
forvalues t=1/12{
svy: regress Theme`t' i.NEWgroup i.grade i.sex i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losbis4 i.ftpt i.profcomm
estimates store regression`t'
}

svy: regress ees i.NEWgroup i.grade i.sex i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losbis4 i.ftpt i.profcomm
estimates store regressionees

estimates table regression4 regression5 regression7 regression8 
estimates table regressionees regression1 regression2 regression3 regression6 regression9
estimates table regression4 regression5 regression7 regression8 
estimates table regression10 regression11 regression12

svy: mean ees Theme1 Theme2 Theme3 Theme6 Theme9


tabulate NEWgroup
tabulate grade
tabulate sex
tabulate age4
tabulate bme2
tabulate disability
tabulate carer
tabulate childcare
tabulate sexuality1
tabulate religion1
tabulate location
tabulate losbis4
tabulate ftpt
tabulate profcomm

/* GOT TO HERE - KP*/

*the following is used for the direct standardisation that I typically use in my analyses
*the weights are the estimated grade distribution for BIS from the following command

* put similar grades together for standardisation

gen grade_standardised=4 
replace grade_standardised=1 if grade==1|grade==4|grade==8  /* SCS,FS,AA/A0*/
replace grade_standardised=2 if grade==2|grade==3  /*g6/g7*/
replace grade_standardised=3 if grade==5|grade==6|grade==7  /* SEO/HEO/EO*/

tabulate grade_standardised 
tabulate grade

* estinated grade distribution for 2015



				
*standardise by grade

gen stdgrade=grade_standardised
gen stdweight=.
replace stdweight=.15685483 if stdgrade==1
replace stdweight=.3834677 if stdgrade==2
replace stdweight=.458871 if stdgrade==3
replace stdweight=.0008065 if stdgrade==4


*the next few bits produce grade-standardised breakdowns for BIS, and some demographics such as age,
*group, working hours.  This was used in the People Survey 2015 data viz written by Hiren.

*standardised breakdowns for each question (Bxx Fxx_BIS) for BIS
forvalues t=1/9 {
svy: prop B0`t', stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy: prop B`t', stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/6 {
svy: prop F0`t'_BIS, stdize(stdgrade) stdweight(stdweight)
}



*breakdowns for each question (Bxx Fxx_BIS) for each group standardised by grade
forvalues t=1/9 {
svy: prop B0`t', over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/70 {
svy: prop B`t', over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy: prop F0`t'_BIS, over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
}
svy: prop F10_BIS, over(NEWgroup) stdize(stdgrade) stdweight(stdweight)


*breakdowns for each question (Bxx Fxx_BIS) for each grade in BIS
*note that standardisation is not required here as the standardisation is by grade only!
forvalues t=1/9 {
svy: prop B0`t', over(grade)
}
forvalues t=10/70 {
svy: prop B`t', over(grade)
}
forvalues t=1/9 {
svy: prop F0`t'_BIS, over(grade)
}
svy: prop F10_BIS, over(grade)


*breakdowns for each question (Bxx Fxx_BIS) for each age standardised by grade
forvalues t=1/9 {
svy: prop B0`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy: prop B`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy: prop F0`t'_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)
}
svy: prop F10_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)


*breakdowns for each question (Bxx Fxx_BIS) for each hours pattern standardised by grade
forvalues t=1/9 {
svy: prop B0`t', over(disability) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/70 {
svy: prop B`t', over(disability) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy: prop F0`t'_BIS, over(disability) stdize(stdgrade) stdweight(stdweight)
}
svy: prop F10_BIS, over(disability) stdize(stdgrade) stdweight(stdweight)



/*for segmentation distribution
svy: prop Z07
svy: prop Z07, over(NEWgroup)
estimates store segmentation_BIS

forvalues t=1/6{
gen AAA=0
replace AAA=1 if grade==`t'
svy, subpop(AAA): prop Z07, over(NEWgroup)
estimates store segmentation_grade`t'
drop AAA
}
*/
/*
*to generate estimates for themes
svy: mean ees
estimates store BIS_ees
svy: mean ees, over(NEWgroup)
estimates store groups_ees

forvalues t=1/15 {
svy: mean Theme`t'
estimates store BIS_Theme`t'
svy: mean Theme`t', over(NEWgroup)
estimates store groups_Theme`t'
}
*/
/*to generate estimates for themes %+ve

svy: mean mw_p
estimates store BIS_mw_p
svy: mean mw_p, over(NEWgroup)
estimates store groups_mw_p

svy: mean op_p
estimates store BIS_op_p
svy: mean op_p, over(NEWgroup)
estimates store groups_op_p

svy: mean lm_p
estimates store BIS_lm_p
svy: mean lm_p, over(NEWgroup)
estimates store groups_lm_p

svy: mean mt_p
estimates store BIS_mt_p
svy: mean mt_p, over(NEWgroup)
estimates store groups_mt_p


svy: mean ld_p
estimates store BIS_ld_p
svy: mean ld_p, over(NEWgroup)
estimates store groups_ld_p


svy: mean if_p
estimates store BIS_if_p
svy: mean if_p, over(NEWgroup)
estimates store groups_if_p

svy: mean rw_p
estimates store BIS_rw_p
svy: mean rw_p, over(NEWgroup)
estimates store groups_rw_p

svy: mean pb_p
estimates store BIS_pb_p
svy: mean pb_p, over(NEWgroup)
estimates store groups_pb_p

svy: mean lc_p
estimates store BIS_lc_p
svy: mean lc_p, over(NEWgroup)
estimates store groups_lc_p

*/
/*
estimates table BIS_ees BIS_Theme1 BIS_Theme2 BIS_Theme3 BIS_Theme4 BIS_Theme5 BIS_Theme6 BIS_Theme7 BIS_Theme8 BIS_Theme9 BIS_Theme10 BIS_Theme11 BIS_Theme12 BIS_Theme13 BIS_Theme14 BIS_Theme15, se
estimates table groups_ees groups_Theme1 groups_Theme2 groups_Theme3 groups_Theme4 groups_Theme5 groups_Theme6 groups_Theme7, se
estimates table groups_Theme8 groups_Theme9 groups_Theme10 groups_Theme11 groups_Theme12 groups_Theme13 groups_Theme14 groups_Theme15, se
*/

/*
*to generate estimates for individual questions
forvalues t=1/9 {
svy: mean B0`t'
estimates store BIS_B0`t'
svy: mean B0`t', over(NEWgroup)
estimates store groups_B0`t'
}
forvalues t=10/62 {
svy: mean B`t'
estimates store BIS_B`t'
svy: mean B`t', over(NEWgroup)
estimates store groups_B`t'
}
forvalues t=1/6 {
svy: mean F0`t'_BIS
estimates store BIS_F0`t'_BIS
svy: mean F0`t'_BIS, over(NEWgroup)
estimates store groups_F0`t'_BIS
}

forvalues t=1/4 {
svy: mean W0`t'
estimates store BIS_W0`t'
svy: mean W0`t', over(NEWgroup)
estimates store groups_W0`t'
}

estimates table BIS_B01 BIS_B02 BIS_B03 BIS_B04 BIS_B05 BIS_B06 BIS_B07 BIS_B08 BIS_B09, se
estimates table BIS_B10 BIS_B11 BIS_B12 BIS_B13 BIS_B14 BIS_B15 BIS_B16 BIS_B17 BIS_B18 BIS_B19, se
estimates table BIS_B20 BIS_B21 BIS_B22 BIS_B23 BIS_B24 BIS_B25 BIS_B26 BIS_B27 BIS_B28 BIS_B29, se
estimates table BIS_B30 BIS_B31 BIS_B32 BIS_B33 BIS_B34 BIS_B35 BIS_B36 BIS_B37 BIS_B38 BIS_B39, se
estimates table BIS_B40 BIS_B41 BIS_B42 BIS_B43 BIS_B44 BIS_B45 BIS_B46 BIS_B47 BIS_B48 BIS_B49, se
*estimates table BIS_B50 BIS_B51 BIS_B52 BIS_B53 BIS_B54 BIS_B55 BIS_B56 BIS_B57, se
estimates table BIS_B50 BIS_B51 BIS_B52 BIS_B53 BIS_B54 BIS_B55 BIS_B56 BIS_B57 BIS_B58 BIS_B59, se
estimates table BIS_B60 BIS_B61 BIS_B62, se
estimates table BIS_F01_BIS BIS_F02_BIS BIS_F03_BIS BIS_F04_BIS BIS_F05_BIS BIS_F06_BIS, se
estimates table BIS_W01 BIS_W02 BIS_W03 BIS_W04, se


estimates table groups_B01 groups_B02 groups_B03 groups_B04 groups_B05 groups_B06 groups_B07 groups_B08 groups_B09, se
estimates table groups_B10 groups_B11 groups_B12 groups_B13 groups_B14 groups_B15 groups_B16 groups_B17 groups_B18 groups_B19, se
estimates table groups_B20 groups_B21 groups_B22 groups_B23 groups_B24 groups_B25 groups_B26 groups_B27 groups_B28 groups_B29, se
estimates table groups_B30 groups_B31 groups_B32 groups_B33 groups_B34 groups_B35 groups_B36 groups_B37 groups_B38 groups_B39, se
estimates table groups_B40 groups_B41 groups_B42 groups_B43 groups_B44 groups_B45 groups_B46 groups_B47 groups_B48 groups_B49, se
*estimates table groups_B50 groups_B51 groups_B52 groups_B53 groups_B54 groups_B55 groups_B56 groups_B57, se
estimates table groups_B50 groups_B51 groups_B52 groups_B53 groups_B54 groups_B55 groups_B56 groups_B57 groups_B58 groups_B59, se
estimates table groups_B60 groups_B61 groups_B62, se
estimates table groups_F01_BIS groups_F02_BIS groups_F03_BIS groups_F04_BIS groups_F05_BIS groups_F06_BIS, se
estimates table groups_W01 groups_W02 groups_W03 groups_W04, se
*/

/*to generate estimates for individual questions for grade 6/7
gen grade67=0
replace grade67=1 if grade==3

forvalues t=1/9 {
svy, subpop(grade67): mean ppB0`t'
estimates store ppG67_B0`t'
svy, subpop(grade67): mean B0`t'
estimates store G67_B0`t'
}
forvalues t=10/62 {
svy, subpop(grade67): mean ppB`t'
estimates store ppG67_B`t'
svy, subpop(grade67): mean B`t'
estimates store G67_B`t'
}
forvalues t=1/6 {
svy, subpop(grade67): mean ppF0`t'_BIS
estimates store ppG67_F0`t'_BIS
svy, subpop(grade67): mean F0`t'_BIS
estimates store G67_F0`t'_BIS
}

estimates table G67_B01 G67_B02 G67_B03 G67_B04 G67_B05
estimates table G67_B06 G67_B07 G67_B08 G67_B09 G67_B10
estimates table G67_B11 G67_B12 G67_B13 G67_B14 G67_B15
estimates table G67_B16 G67_B17 G67_B18 G67_B19 G67_B20
estimates table G67_B21 G67_B22 G67_B23 G67_B24 G67_B25 
estimates table G67_B26 G67_B27 G67_B28 G67_B29 G67_B30 
estimates table G67_B31 G67_B32 G67_B33 G67_B34 G67_B35 
estimates table G67_B36 G67_B37 G67_B38 G67_B39 G67_B40
estimates table G67_B41 G67_B42 G67_B43 G67_B44 G67_B45 
estimates table G67_B46 G67_B47 G67_B48 G67_B49 G67_B50
estimates table G67_B51 G67_B52 G67_B53 G67_B54 G67_B55
estimates table G67_B56 G67_B57 G67_B58 G67_B59 G67_B60
estimates table G67_B61 G67_B62 G67_F01_BIS G67_F02_BIS G67_F03_BIS
estimates table G67_F04_BIS G67_F05_BIS G67_F06_BIS

estimates table ppG67_B01 ppG67_B02 ppG67_B03 ppG67_B04 ppG67_B05
estimates table ppG67_B06 ppG67_B07 ppG67_B08 ppG67_B09 ppG67_B10
estimates table ppG67_B11 ppG67_B12 ppG67_B13 ppG67_B14 ppG67_B15
estimates table ppG67_B16 ppG67_B17 ppG67_B18 ppG67_B19 ppG67_B20
estimates table ppG67_B21 ppG67_B22 ppG67_B23 ppG67_B24 ppG67_B25 
estimates table ppG67_B26 ppG67_B27 ppG67_B28 ppG67_B29 ppG67_B30 
estimates table ppG67_B31 ppG67_B32 ppG67_B33 ppG67_B34 ppG67_B35 
estimates table ppG67_B36 ppG67_B37 ppG67_B38 ppG67_B39 ppG67_B40
estimates table ppG67_B41 ppG67_B42 ppG67_B43 ppG67_B44 ppG67_B45 
estimates table ppG67_B46 ppG67_B47 ppG67_B48 ppG67_B49 ppG67_B50
estimates table ppG67_B51 ppG67_B52 ppG67_B53 ppG67_B54 ppG67_B55
estimates table ppG67_B56 ppG67_B57 ppG67_B58 ppG67_B59 ppG67_B60
estimates table ppG67_B61 ppG67_B62 ppG67_F01_BIS ppG67_F02_BIS ppG67_F03_BIS
estimates table ppG67_F04_BIS ppG67_F05_BIS ppG67_F06_BIS
*/

*****************************************************************************************************************

replace grade=K01_BIS				/* 1=SCS 2=G6 3=G7 4=FS 5=SEO */
replace grade=8 if K01_BIS==9		/* 6=HEO 7=EO 8=AA/EA/AO 9=unknown */
replace grade=9 if K01_BIS==.

gen sex=3
replace sex=J01 if J01<3			/* 1=male 2=female 3=missing */
gen age1=4
replace age1=1 if J02<5
replace age1=2 if J02==5 | J02==6
replace age1=3 if J02>6 & J02<12	/* 1=16-34 2=35-44 3=45+ 4=missing */
gen age2=3
replace age2=1 if J02<6
replace age2=2 if J02>5 & J02<12	/* 1=16-39 2=40+ 3=missing */
gen bme1=3
replace bme1=1 if J03<5
replace bme1=2 if J03>4 & J03<19	/* 1=White British; Irish; Traveller; Other White 2=Other 3=missing */
gen bme2=3
replace bme2=1 if J03==1
replace bme2=2 if J03>1 & J03<19	/* 1=White British 2=other 3=missing */
gen disability=J04
replace disability=3 if J04>=.		/* 1=Yes 2=No 3=missing */
gen carer=J05
replace carer=3 if J05>=.			/* 1=Yes 2=No 3=missing */
gen childcare=J06
replace childcare=3 if J06>=.		/* 1=Yes 2=No 3=missing */
gen sexuality=3
replace sexuality=1 if J07==1
replace sexuality=2 if J07>1 & J07<5	/*1=straight 2=other 3=missing */
gen religion1=4
replace religion1=J08 if J08<3
replace religion1=3 if J08>2 & J08<9	/*1=none 2=Christian 3=other 4=missing */
gen religion2=3
replace religion2=1 if J08==1
replace religion2=2 if J08>1 & J08<9	/*1=none 2=religious 3=missing */
gen location=4
replace location=3 if H01<.			/*1=London 2=Yorks&Humb 3=other 4=missing */
replace location=1 if H1A==3
replace location=2 if H1A==9
gen losbis1=5
replace losbis1=1 if H03<3
replace losbis1=2 if H03==3
replace losbis1=3 if H03==4
replace losbis1=4 if H03>4 & H03<.	/*1=less than 1y 2=1-5y 3=5-10y 4=10y+ 5=missing */
gen losbis2=4
replace losbis2=1 if H03<3
replace losbis2=2 if H03>2 & H03<6
replace losbis2=3 if H03>5 & H03<.	/*1=less than 1y 2=1-10y 3=10y+ 4=missing */
gen ftpt=H06
replace ftpt=4 if H06==.			/*1=full-time 2=part-time 3=job sharer 4=missing */
gen profcomm=H8A
replace profcomm=3 if H8A==.		/*1=part of a cross-government professional community 2=not 3=missing */


label define label_sex 1 "male" 2 "female" 3 "unknown"
label values sex label_sex
label define label_grade 1 "SCS" 2 "G6" 3 "G7" 4 "FS" 5 "SEO" 6 "HEO" 7 "EO" 8 "AA/EA/AO" 9 "undeclared"
label values grade label_grade
label define label_group 1 "ES" 2 "FC" 3 "KI" 4 "LS" 5 "BLG" 6 "MPST" 7 "PS" 8 "ShEx" 9 "EM" 10 "GOS" 11 "OME" 12 "UKSA"
label values NEWgroup label_group
label define label_age1 1 "16-34" 2 "35-44" 3 "45+" 4 "undeclared"
label values age1 label_age1
label define label_bme2 1 "White British" 2 "BME" 3 "undeclared"
label values bme2 label_bme2
label define label_disability 1 "disabled" 2 "not disabled" 3 "undeclared"
label values disability label_disability
label define label_carer 1 "carer" 2 "not a carer" 3 "undeclared"
label values carer label_carer
label define label_childcare 1 "childcarer" 2 "not a childcarer" 3 "undeclared"
label values childcare label_childcare
label define label_sexuality 1 "straight" 2 "not straight" 3 "undeclared"
label values sexuality label_sexuality
label define label_religion1 1 "no religion" 2 "Christian" 3 "other religion" 4 "undeclared"
label values religion1 label_religion1
label define label_location 1 "London" 2 "Sheffield" 3 "Other" 4 "undeclared"
label values location label_location
label define label_losbis2 1 "less than 1 year" 2 "1-10 years" 3 "more than 10 years" 4 "undeclared"
label values losbis2 label_losbis2
label define label_ftpt 1 "full time" 2 "part time" 3 "job sharer" 4 "undeclared"
label values ftpt label_ftpt
label define label_profcomm 1 "member of a professional community" 2 "not a member of a professional community" 3 "undeclared"
label values profcomm label_profcomm

gen stdgrade=grade
gen stdweight=.
replace stdweight=.0749595 if stdgrade==1
replace stdweight=.1049433 if stdgrade==2
replace stdweight=.2653971 if stdgrade==3
replace stdweight=.0324149 if stdgrade==4
replace stdweight=.1353323 if stdgrade==5
replace stdweight=.1831442 if stdgrade==6
replace stdweight=.1268233 if stdgrade==7
replace stdweight=.0486224 if stdgrade==8
replace stdweight=.0283630 if stdgrade==9



/*
forvalues t=1/15{

regress Theme`t' i.NEWgroup i.grade i.sex i.age1 i.bme2 i.disability i.carer i.childcare i.sexuality i.religion1 i.location i.losbis2 i.ftpt i.profcomm [pw=weight1], vce(robust)
estimates store regression`t'
}
*/

/*
forvalues t=1/12{

svy: regress Theme`t' i.NEWgroup i.grade i.sex i.age1 i.bme2 i.disability i.carer i.childcare i.sexuality i.religion1 i.location i.losbis2 i.ftpt i.profcomm
estimates store regression`t'
}


svy: regress ees i.NEWgroup i.grade i.sex i.age1 i.bme2 i.disability i.carer i.childcare i.sexuality i.religion1 i.location i.losbis2 i.ftpt i.profcomm
estimates store regressionees

estimates table regressionees regression1 regression2 regression3 regression4
estimates table regression5 regression6 regression7 regression8 regression9
estimates table regression10 regression11 regression12
*/


*percentage positive estimates for each question (Bxx Fxx_BIS Wxx E01 and E03) for BIS
forvalues t=1/9 {
svy: mean ppB0`t'
}
forvalues t=10/62 {
svy: mean ppB`t'
}
forvalues t=1/6 {
svy: mean ppF0`t'_BIS
}
forvalues t=1/4 {
svy: mean ppW0`t'
}
svy: mean ppE01
svy: mean ppE03

*percentage positive estimates for each question (Bxx Fxx_BIS Wxx E01 and E03) for each grade
forvalues t=1/9 {
svy: mean ppB0`t', over(grade)
}
forvalues t=10/62 {
svy: mean ppB`t', over(grade) 
}
forvalues t=1/6 {
svy: mean ppF0`t'_BIS, over(grade)
}
forvalues t=1/4 {
svy: mean ppW0`t', over(grade) 
}
svy: mean ppE01, over(grade) 
svy: mean ppE03, over(grade) 

*percentage positive estimates for each question (Bxx Fxx_BIS Wxx E01 and E03) for each group, standardised by grade
forvalues t=1/9 {
svy: mean ppB0`t', over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy: mean ppB`t', over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/6 {
svy: mean ppF0`t'_BIS, over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/4 {
svy: mean ppW0`t', over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppE01, over(NEWgroup) stdize(stdgrade) stdweight(stdweight) 
svy: mean ppE03, over(NEWgroup) stdize(stdgrade) stdweight(stdweight)

*percentage positive estimates for each question (Bxx Fxx_BIS Wxx E01 and E03) for each age, standardised by grade
forvalues t=1/9 {
svy: mean ppB0`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy: mean ppB`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/6 {
svy: mean ppF0`t'_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/4 {
svy: mean ppW0`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppE01, over(age1) stdize(stdgrade) stdweight(stdweight) 
svy: mean ppE03, over(age1) stdize(stdgrade) stdweight(stdweight)

*percentage positive estimates for each question (Bxx Fxx_BIS Wxx E01 and E03) for each ethnicity, standardised by grade
forvalues t=1/9 {
svy: mean ppB0`t', over(bme2) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy: mean ppB`t', over(bme2) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/6 {
svy: mean ppF0`t'_BIS, over(bme2) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/4 {
svy: mean ppW0`t', over(bme2) stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppE01, over(bme2) stdize(stdgrade) stdweight(stdweight) 
svy: mean ppE03, over(bme2) stdize(stdgrade) stdweight(stdweight)

*percentage positive estimates for each question (Bxx Fxx_BIS Wxx E01 and E03) for each disability status, standardised by grade
forvalues t=1/9 {
svy: mean ppB0`t', over(disability) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy: mean ppB`t', over(disability) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/6 {
svy: mean ppF0`t'_BIS, over(disability) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/4 {
svy: mean ppW0`t', over(disability) stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppE01, over(disability) stdize(stdgrade) stdweight(stdweight) 
svy: mean ppE03, over(disability) stdize(stdgrade) stdweight(stdweight)

*percentage positive estimates for each question (Bxx Fxx_BIS Wxx E01 and E03) for each gender, standardised by grade
forvalues t=1/9 {
svy: mean ppB0`t', over(sex) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy: mean ppB`t', over(sex) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/6 {
svy: mean ppF0`t'_BIS, over(sex) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/4 {
svy: mean ppW0`t', over(sex) stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppE01, over(sex) stdize(stdgrade) stdweight(stdweight) 
svy: mean ppE03, over(sex) stdize(stdgrade) stdweight(stdweight)

*percentage positive estimates for each question (Bxx Fxx_BIS Wxx E01 and E03) for each sexuality, standardised by grade
forvalues t=1/9 {
svy: mean ppB0`t', over(sexuality) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy: mean ppB`t', over(sexuality) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/6 {
svy: mean ppF0`t'_BIS, over(sexuality) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/4 {
svy: mean ppW0`t', over(sexuality) stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppE01, over(sexuality) stdize(stdgrade) stdweight(stdweight) 
svy: mean ppE03, over(sexuality) stdize(stdgrade) stdweight(stdweight)

*percentage positive estimates for each question (Bxx Fxx_BIS Wxx E01 and E03) for each length of service in BIS, standardised by grade
forvalues t=1/9 {
svy: mean ppB0`t', over(losbis2) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy: mean ppB`t', over(losbis2) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/6 {
svy: mean ppF0`t'_BIS, over(losbis2) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/4 {
svy: mean ppW0`t', over(losbis2) stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppE01, over(losbis2) stdize(stdgrade) stdweight(stdweight) 
svy: mean ppE03, over(losbis2) stdize(stdgrade) stdweight(stdweight)

*percentage positive estimates for each question (Bxx Fxx_BIS Wxx E01 and E03) for each religion, standardised by grade
forvalues t=1/9 {
svy: mean ppB0`t', over(religion1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy: mean ppB`t', over(religion1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/6 {
svy: mean ppF0`t'_BIS, over(religion1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/4 {
svy: mean ppW0`t', over(religion1) stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppE01, over(religion1) stdize(stdgrade) stdweight(stdweight) 
svy: mean ppE03, over(religion1) stdize(stdgrade) stdweight(stdweight)

*percentage positive estimates for each question (Bxx Fxx_BIS Wxx E01 and E03) for each location, standardised by grade
forvalues t=1/9 {
svy: mean ppB0`t', over(location) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy: mean ppB`t', over(location) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/6 {
svy: mean ppF0`t'_BIS, over(location) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/4 {
svy: mean ppW0`t', over(location) stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppE01, over(location) stdize(stdgrade) stdweight(stdweight) 
svy: mean ppE03, over(location) stdize(stdgrade) stdweight(stdweight)

*percentage positive estimates for each question (Bxx Fxx_BIS Wxx E01 and E03) for each working hours status, standardised by grade
forvalues t=1/9 {
svy: mean ppB0`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy: mean ppB`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/6 {
svy: mean ppF0`t'_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/4 {
svy: mean ppW0`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppE01, over(ftpt) stdize(stdgrade) stdweight(stdweight) 
svy: mean ppE03, over(ftpt) stdize(stdgrade) stdweight(stdweight)

/*

gen E01_SR=0
replace E01_SR=1 if E01==1 | E01==3
gen E03_SR=0
replace E03_SR=1 if E03==1 | E03==3

label define label_yesnopns_SR 1 "yes or prefer not to say" 2 "no"
label values E01_SR label_yesnopns_SR
label values E03_SR label_yesnopns_SR

logistic ppE01 i.sex i.grade i.NEWgroup i.age1 i.bme2 i.disability i.carer i.childcare i.sexuality i.religion1 i.location i.losbis2 i.ftpt
logistic ppE01  i.age1 i.bme2 ib2.disability i.location

logistic E01_SR i.sex i.grade i.NEWgroup i.age1 i.bme2 i.disability i.carer i.childcare i.sexuality i.religion1 i.location i.losbis2 i.ftpt
logistic E01_SR  i.age1 i.bme2 ib2.disability i.location

logistic ppE03 i.sex i.grade i.NEWgroup i.age1 i.bme2 i.disability i.carer i.childcare i.sexuality i.religion1 i.location i.losbis2 i.ftpt
logistic ppE03 i.bme2 i.disability  i.ftpt

logistic E03_SR i.sex i.grade i.NEWgroup i.age1 i.bme2 i.disability i.carer i.childcare i.sexuality i.religion1 i.location i.losbis2 i.ftpt
logistic E03_SR i.grade i.age1 i.bme2 i.disability i.ftpt
*/

*percentage positive estimates for each question (Bxx Fxx_BIS Wxx E01 and E03) for each directorate in EM, standardised by grade
gen EM_ind=0
replace EM_ind=1 if NEWgroup==9

forvalues t=1/9 {
svy, subpop(EM_ind): mean ppB0`t', over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(EM_ind): mean ppB`t', over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/6 {
svy, subpop(EM_ind): mean ppF0`t'_BIS, over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)
}

forvalues t=1/4 {
svy, subpop(EM_ind): mean ppW0`t', over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)
}

*breakdowns for each question (Bxx Fxx_BIS Wxx E01 and E03) for each directorate in EM, standardised by grade
forvalues t=1/9 {
svy, subpop(EM_ind): prop B0`t', over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(EM_ind): prop B`t', over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/6 {
svy, subpop(EM_ind): prop F0`t'_BIS, over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)
}

forvalues t=1/4 {
svy, subpop(EM_ind): prop W0`t', over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(EM_ind): prop E01, over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight) 
svy, subpop(EM_ind): prop E03, over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)
