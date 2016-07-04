*this takes the 2014 BIS dataset and prepares it for comparison with 2015.  The 2014 data is mapped to the 2015 BIS departmental structure 

clear

*to turn the hierarchy dataset into a mapping of RespondentID to reporting units
*this created "2014 ID to RU.dta"
/*
sort ResponseID Population
gen AAA=cond( ResponseID[_n]== ResponseID[_n-1],0,1) if _n>1
replace AAA=1 if _n==1
keep if AAA==1
drop AAA
*/

*mapping RUs to 2015 structure
*this created "mapping 2014 RU to 2015.dta"

import excel "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\hierarchies 2012 and 2013 and 2014 for 2015.xls", sheet("2014 codes NEW") firstrow allstring clear
save "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\mapping 2014 RU to 2015.dta"


*mapping poststrata to their populations
*this created "mapping 2013 poststrata to 2014.dta"

import excel "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\hierarchies 2012 and 2013 and 2014 for 2015.xls", sheet("2014 strata for 2015") firstrow allstring clear

rename stratum poststratum
destring poststratum, replace
recast int poststratum
save "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\mapping 2014 poststrata to 2015.dta"

*PUTTING IN UNIT LEVEL POPULATIONS AND STRATA

import excel "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\2014 Unit level populations.xls", sheet("Sheet2") firstrow allstring clear
destring Poststratum_Unit, replace
recast int Poststratum_Unit
encode RU, generate (NEWRU)
save "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\2014 Unit level populations.dta"



use "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2014\org2014_BIS.dta", clear
merge 1:1 ResponseID using "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2014\2014 ID to RU.dta", keep (match master)
drop Returns Population _merge
rename DeptCode RU
merge m:1 RU using "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\mapping 2014 RU to 2015.dta"
drop _merge
drop if ResponseID==.


*adding the poststrata codes
*poststrata are generally defined by grade
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

merge m:1 poststratum using "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\mapping 2014 poststrata to 2015.dta"
drop _merge
destring popNEW, replace


sort poststratum
qbys poststratum: egen samplesize = count(ResponseID) /*This puts the number of respondents in each poststratification class in as 'samplesize'*/

gen weight1=popNEW/samplesize /*we could use this for manually postratifying ourselves, but we won't do this*/
gen weight2=1
replace weight2=0 if RU=="BIS0010"|RU=="BIS0011" /*represents that everyone had the same sampling probability of 1; we'll let Stata handle the poststratification by using 'poststrata' and 'postweight' EXCEPT DIGITAL WHICH DONT EXIST ANYMORE*/
gen fpc=2543

encode groupNEW, generate (NEWgroup) /*these encodings are required to turn the groups, directorates into numerical variables*/
encode directorateNEW, generate (NEWdirectorate) /*which we need to do for later analyses where we run estimates over each group or each directorate*/
encode orgNEW, generate (NEWorg)
encode RU, generate (NEWRU)
drop groupNEW directorateNEW orgNEW RU
*svyset _n [pw=weight1], fpc(fpc)
svyset _n [pw=weight2], fpc(fpc) poststrata(poststratum) postweight(popNEW) /*this is the svyset we are generally using*/



/*the next bunch of code works out theme index scores in the same way the Engagement Index
is calculated.  It's all a bit cumbersome because of having to deal with missing values.
I wouldn't be surprised if there is a more elegant way of doing this.  The actual methodology
is to ignore missing values from the count which is equivalent to assuming that missing values
are equal to the average of the non-missing values for the theme.  This might not be true
but it is consistent with how the Engagement Index is officially worked out*/

*generate theme scores for Theme 1 - My Work
gen B01AAA=B01<.														/*B01, B02 etc are the reponses to the main survey questions*/
gen B02AAA=B02<.														/*these are numerical variables, 1=strongly disagree,		*/
gen B03AAA=B03<.														/*5=strongly agree. They have been labelled with their words*/
gen B04AAA=B04<.
gen B05AAA=B05<.
gen AAA=B01AAA + B02AAA + B03AAA + B04AAA + B05AAA						/*so here AAA is the number of non-missing responses		*/
replace B01AAA=B01														/*to the theme's questions, at an individual level			*/
replace B02AAA=B02
replace B03AAA=B03
replace B04AAA=B04
replace B05AAA=B05
replace B01AAA=0 if B01==.
replace B02AAA=0 if B02==.
replace B03AAA=0 if B03==.
replace B04AAA=0 if B04==.
replace B05AAA=0 if B05==.
gen Theme1=((B01AAA + B02AAA + B03AAA + B04AAA + B05AAA)/AAA)/4-0.25	/*by dividing by AAA we get the correct mean accounting for	*/
drop AAA B01AAA B02AAA B03AAA B04AAA B05AAA								/*non-responses.  The dividing by 4 and subtracting 0.25	*/
																		/*scales the 1-5 score to a 0-1 score						*/

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
*Wellbeing is answered on a 0-10 scale and W04 is reverse-scaled because it asks how anxious you were feeling
*so a high score is 'bad' whereas for the other three W questions a high score is 'good'
gen W01AAA=W01<.
gen W02AAA=W02<.
gen W03AAA=W03<.
gen W04AAA=W04<.
gen AAA=W01AAA + W02AAA + W03AAA + W04AAA
replace W01AAA=W01
replace W02AAA=W02
replace W03AAA=W03
replace W04AAA=10-W04										/*this achieves the reverse-scaling for the anxiety	question	*/
replace W01AAA=0 if W01==.
replace W02AAA=0 if W02==.
replace W03AAA=0 if W03==.
replace W04AAA=0 if W04==.
gen Theme12=((W01AAA + W02AAA + W03AAA + W04AAA)/AAA)/10	/*just need to divide by 10 because the scale is 0-10			*/
drop AAA W01AAA W02AAA W03AAA W04AAA




*generate percentage positive variables for the BIS questions
forvalues t=1/6 {
gen ppF0`t'_BIS=.
replace ppF0`t'_BIS=0 if F0`t'_BIS<4
replace ppF0`t'_BIS=1 if F0`t'_BIS==4 | F0`t'_BIS==5
}

* generate percentage positive values for themes

*generate theme scores for Theme 1 - My Work
gen ppB01AAA=ppB01<.														/*B01, B02 etc are the reponses to the main survey questions*/
gen ppB02AAA=ppB02<.														/*these are numerical variables, 1=strongly disagree,		*/
gen ppB03AAA=ppB03<.														/*5=strongly agree. They have been labelled with their words*/
gen ppB04AAA=ppB04<.
gen ppB05AAA=ppB05<.
gen ppAAA=ppB01AAA + ppB02AAA + ppB03AAA + ppB04AAA + ppB05AAA						/*so here AAA is the number of non-missing responses		*/
replace ppB01AAA=ppB01														/*to the theme's questions, at an individual level			*/
replace ppB02AAA=ppB02
replace ppB03AAA=ppB03
replace ppB04AAA=ppB04
replace ppB05AAA=ppB05
replace ppB01AAA=0 if ppB01==.
replace ppB02AAA=0 if ppB02==.
replace ppB03AAA=0 if ppB03==.
replace ppB04AAA=0 if ppB04==.
replace ppB05AAA=0 if ppB05==.
gen ppTheme1=((ppB01AAA + ppB02AAA + ppB03AAA + ppB04AAA + ppB05AAA)/ppAAA)	/*by dividing by AAA we get the correct mean accounting for	*/
drop ppAAA ppB01AAA ppB02AAA ppB03AAA ppB04AAA ppB05AAA								/*non-responses.  The dividing by 4 and subtracting 0.25	*/
																		/*scales the 1-5 score to a 0-1 score						*/
mean ppTheme1
*generate theme scores for Theme 2 - Organisational Objectives and Purpose
gen ppB06AAA=ppB06<.
gen ppB07AAA=ppB07<.
gen ppB08AAA=ppB08<.
gen ppAAA=ppB06AAA + ppB07AAA + ppB08AAA
replace ppB06AAA=ppB06
replace ppB07AAA=ppB07
replace ppB08AAA=ppB08
replace ppB06AAA=0 if ppB06==.
replace ppB07AAA=0 if ppB07==.
replace ppB08AAA=0 if ppB08==.
gen ppTheme2=((ppB06AAA + ppB07AAA + ppB08AAA)/ppAAA)
drop ppAAA ppB06AAA ppB07AAA ppB08AAA

*generate theme scores for Theme 3 - My Manager
gen ppB09AAA=ppB09<.
gen ppB10AAA=ppB10<.
gen ppB11AAA=ppB11<.
gen ppB12AAA=ppB12<.
gen ppB13AAA=ppB13<.
gen ppB14AAA=ppB14<.
gen ppB15AAA=ppB15<.
gen ppB16AAA=ppB16<.
gen ppB17AAA=ppB17<.
gen ppB18AAA=ppB18<.
gen ppAAA=ppB09AAA + ppB10AAA + ppB11AAA + ppB12AAA + ppB13AAA + ppB14AAA + ppB15AAA + ppB16AAA + ppB17AAA + ppB18AAA
replace ppB09AAA=ppB09
replace ppB10AAA=ppB10
replace ppB11AAA=ppB11
replace ppB12AAA=ppB12
replace ppB13AAA=ppB13
replace ppB14AAA=ppB14
replace ppB15AAA=ppB15
replace ppB16AAA=ppB16
replace ppB17AAA=ppB17
replace ppB18AAA=ppB18
replace ppB09AAA=0 if ppB09==.
replace ppB10AAA=0 if ppB10==.
replace ppB11AAA=0 if ppB11==.
replace ppB12AAA=0 if ppB12==.
replace ppB13AAA=0 if ppB13==.
replace ppB14AAA=0 if ppB14==.
replace ppB15AAA=0 if ppB15==.
replace ppB16AAA=0 if ppB16==.
replace ppB17AAA=0 if ppB17==.
replace ppB18AAA=0 if ppB18==.
gen ppTheme3=((ppB09AAA + ppB10AAA + ppB11AAA + ppB12AAA + ppB13AAA + ppB14AAA + ppB15AAA + ppB16AAA + ppB17AAA + ppB18AAA)/ppAAA)
drop ppAAA ppB09AAA ppB10AAA ppB11AAA ppB12AAA ppB13AAA ppB14AAA ppB15AAA ppB16AAA ppB17AAA ppB18AAA

*generate theme scores for Theme 4 - My Team
gen ppB19AAA=ppB19<.
gen ppB20AAA=ppB20<.
gen ppB21AAA=ppB21<.
gen ppAAA=ppB19AAA + ppB20AAA + ppB21AAA
replace ppB19AAA=ppB19
replace ppB20AAA=ppB20
replace ppB21AAA=ppB21
replace ppB19AAA=0 if ppB19==.
replace ppB20AAA=0 if ppB20==.
replace ppB21AAA=0 if ppB21==.
gen ppTheme4=((ppB19AAA + ppB20AAA + ppB21AAA)/ppAAA)
drop ppAAA ppB19AAA ppB20AAA ppB21AAA

*generate theme scores for Theme 5 - Learning and Development
gen ppB22AAA=ppB22<.
gen ppB23AAA=ppB23<.
gen ppB24AAA=ppB24<.
gen ppB25AAA=ppB25<.
gen ppAAA=ppB22AAA + ppB23AAA + ppB24AAA + ppB25AAA
replace ppB22AAA=ppB22
replace ppB23AAA=ppB23
replace ppB24AAA=ppB24
replace ppB25AAA=ppB25
replace ppB22AAA=0 if ppB22==.
replace ppB23AAA=0 if ppB23==.
replace ppB24AAA=0 if ppB24==.
replace ppB25AAA=0 if ppB25==.
gen ppTheme5=((ppB22AAA + ppB23AAA + ppB24AAA + ppB25AAA)/ppAAA)
drop ppAAA ppB22AAA ppB23AAA ppB24AAA ppB25AAA
mean ppTheme3
*generate theme scores for Theme 6 - Inclusion and Fair Treatment
gen ppB26AAA=ppB26<.
gen ppB27AAA=ppB27<.
gen ppB28AAA=ppB28<.
gen ppB29AAA=ppB29<.
gen ppAAA=ppB26AAA + ppB27AAA + ppB28AAA + ppB29AAA
replace ppB26AAA=ppB26
replace ppB27AAA=ppB27
replace ppB28AAA=ppB28
replace ppB29AAA=ppB29
replace ppB26AAA=0 if ppB26==.
replace ppB27AAA=0 if ppB27==.
replace ppB28AAA=0 if ppB28==.
replace ppB29AAA=0 if ppB29==.
gen ppTheme6=((ppB26AAA + ppB27AAA + ppB28AAA + ppB29AAA)/ppAAA)
drop ppAAA ppB26AAA ppB27AAA ppB28AAA ppB29AAA

*generate theme scores for Theme 7 - Resources and Workload
gen ppB30AAA=ppB30<.
gen ppB31AAA=ppB31<.
gen ppB32AAA=ppB32<.
gen ppB33AAA=ppB33<.
gen ppB34AAA=ppB34<.
gen ppB35AAA=ppB35<.
gen ppB36AAA=ppB36<.
gen ppAAA=ppB30AAA + ppB31AAA + ppB32AAA + ppB33AAA + ppB34AAA + ppB35AAA + ppB36AAA
replace ppB30AAA=ppB30
replace ppB31AAA=ppB31
replace ppB32AAA=ppB32
replace ppB33AAA=ppB33
replace ppB34AAA=ppB34
replace ppB35AAA=ppB35
replace ppB36AAA=ppB36
replace ppB30AAA=0 if ppB30==.
replace ppB31AAA=0 if ppB31==.
replace ppB32AAA=0 if ppB32==.
replace ppB33AAA=0 if ppB33==.
replace ppB34AAA=0 if ppB34==.
replace ppB35AAA=0 if ppB35==.
replace ppB36AAA=0 if ppB36==.
gen ppTheme7=((ppB30AAA + ppB31AAA + ppB32AAA + ppB33AAA + ppB34AAA + ppB35AAA + ppB36AAA)/ppAAA)
drop ppAAA ppB30AAA ppB31AAA ppB32AAA ppB33AAA ppB34AAA ppB35AAA ppB36AAA

*generate theme scores for Engagement
gen ppB50AAA=ppB50<.
gen ppB51AAA=ppB51<.
gen ppB52AAA=ppB52<.
gen ppB53AAA=ppB53<.
gen ppB54AAA=ppB54<.
gen ppAAA=ppB50AAA + ppB51AAA + ppB52AAA + ppB53AAA + ppB54AAA
replace ppB50AAA=ppB50
replace ppB51AAA=ppB51
replace ppB52AAA=ppB52
replace ppB53AAA=ppB53
replace ppB54AAA=ppB54
replace ppB50AAA=0 if ppB50==.
replace ppB51AAA=0 if ppB51==.
replace ppB52AAA=0 if ppB52==.
replace ppB53AAA=0 if ppB53==.
replace ppB54AAA=0 if ppB54==.
gen ppees=((ppB50AAA + ppB51AAA + ppB52AAA + ppB53AAA + ppB54AAA)/ppAAA)
drop ppAAA ppB50AAA ppB51AAA ppB52AAA ppB53AAA ppB54AAA
mean ppees
*generate theme scores for Theme 9 - Leadership and Managing Change
gen ppB40AAA=ppB40<.
gen ppB41AAA=ppB41<.
gen ppB42AAA=ppB42<.
gen ppB43AAA=ppB43<.
gen ppB44AAA=ppB44<.
gen ppB45AAA=ppB45<.
gen ppB46AAA=ppB46<.
gen ppB47AAA=ppB47<.
gen ppB48AAA=ppB48<.
gen ppB49AAA=ppB49<.
gen ppAAA=ppB40AAA + ppB41AAA + ppB42AAA + ppB43AAA + ppB44AAA + ppB45AAA + ppB46AAA + ppB47AAA + ppB48AAA + ppB49AAA
replace ppB40AAA=ppB40
replace ppB41AAA=ppB41
replace ppB42AAA=ppB42
replace ppB43AAA=ppB43
replace ppB44AAA=ppB44
replace ppB45AAA=ppB45
replace ppB46AAA=ppB46
replace ppB47AAA=ppB47
replace ppB48AAA=ppB48
replace ppB49AAA=ppB49
replace ppB40AAA=0 if ppB40==.
replace ppB41AAA=0 if ppB41==.
replace ppB42AAA=0 if ppB42==.
replace ppB43AAA=0 if ppB43==.
replace ppB44AAA=0 if ppB44==.
replace ppB45AAA=0 if ppB45==.
replace ppB46AAA=0 if ppB46==.
replace ppB47AAA=0 if ppB47==.
replace ppB48AAA=0 if ppB48==.
replace ppB49AAA=0 if ppB49==.
gen ppTheme9=((ppB40AAA + ppB41AAA + ppB42AAA + ppB43AAA + ppB44AAA + ppB45AAA + ppB46AAA + ppB47AAA + ppB48AAA + ppB49AAA)/ppAAA)

drop ppB40AAA ppB41AAA ppB42AAA ppB43AAA ppB44AAA ppB45AAA ppB46AAA ppB47AAA ppB48AAA ppB49AAA


*****************************************************************************************************************

*the following section of code creates a number of categorical 'demographic' variables
*in some cases we have alternative classifications of the same concept, e.g. age1 has 3 categories, age2 has just 2,
*age3 is basically decades
*in all cases, I have set it up so missing values and prefer not to say are conflated

replace grade=9 if K01_BIS==.			/* 1=SCS 2=G6 3=G7 4=FS 5=SEO */
										/* 6=HEO 7=EO 8=AA/EA/AO 9=unknown */


gen sex1=4
replace sex1=J01 if J01<3
replace sex1=3 if J01==3

			/* 1=male 2=female 3=prefer not say 4=missing */


gen age1=5
replace age1=1 if J02<5
replace age1=2 if J02==5 | J02==6
replace age1=3 if J02>6 & J02<12
replace age1=4 if J02==12
		/* 1=16-34 2=35-44 3=45+ 4=missing */
gen age2=4
replace age2=1 if J02<6
replace age2=2 if J02>5 & J02<12
replace age2=3 if J02==12
		/* 1=16-39 2=40+ 3=missing */
gen age3=6
replace age3=1 if J02<4
replace age3=2 if J02==4|J02==5	
replace age3=3 if J02==6|J02==7	
replace age3=4 if J02>7 & J02<12
replace age3=5 if J02==12	/* 1=16-29 2=30-39 3=40-49 4=50+ 5=missing */


/* try different age cat*/


gen age4=7
replace age4=1 if J02<4
replace age4=2 if J02==4|J02==5	
replace age4=3 if J02==6|J02==7	
replace age4=4 if J02==8|J02==9
replace age4=5 if J02>9 & J02<12
replace age4=6 if J02==12   /* 1=16-29 2=30-39 3=40-49 4=50-59 5=60+ 6=missing */


gen bme1=4
replace bme1=1 if J03<5
replace bme1=2 if J03>4 & J03<19
replace bme1=3 if J03==19		/* 1=White British; Irish; Traveller; Other White 2=Other 3=missing */

gen bme2=4
replace bme2=1 if J03==1
replace bme2=2 if J03>1 & J03<19		/* 1=White British 2=other 3=missing */
replace bme2=3 if J03==19

tabulate bme2


gen disability=J04
replace disability=3 if J04==3
replace disability=4 if J04==.			/* 1=Yes 2=No 3=missing */
tabulate disability 

gen carer=J05
replace carer=3 if J05==3
replace carer=4 if J05==.				/* 1=Yes 2=No 3=missing */

gen childcare=J06
replace childcare=3 if J06==3
replace childcare=4 if J06==.		/* 1=Yes 2=No 3=missing */

gen sexuality1=4
replace sexuality1=1 if J07==1
replace sexuality1=2 if J07>1 & J07<5
replace sexuality1=3 if J07==5	/*1=straight 2=other 3=missing */


gen religion1=5
replace religion1=J08 if J08<3
replace religion1=3 if J08>2 & J08<9
replace religion1=4 if J08==9	/*1=none 2=Christian 3=other 4=missing */

gen religion2=4
replace religion2=1 if J08==1
replace religion2=2 if J08>1 & J08<9
replace religion2=3 if J08==9   	/*1=none 2=religious 3=missing */

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
label define label_sex1 1 "male" 2 "female" 3 "PNS" 4 "undeclared"
label values sex1 label_sex1
label define label_grade 1 "SCS" 2 "G6" 3 "G7" 4 "FS" 5 "SEO" 6 "HEO" 7 "EO" 8 "AA/EA/AO" 9 "undeclared"
label values grade label_grade
label define label_group 1 "BS" 2 "EM" 3 "FC" 4 "Legal" 5 "MPST" 6 "PSHE" 7 "SHEX" 8 "Skills" 9 "BLG" 10 "GOS" 11 "OME" 12 "UKSA"
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





*regressions to get at the pure theme scores for each demographic categorisation
*I think regressions are robust because we are using pweights
*this particular list of explanatory variables was arrived at after some stepwise procedures, future regressions might
*need to revisit others (but there's rather a lot here already)
forvalues t=1/12{
svy: regress Theme`t' i.NEWgroup i.grade i.sex1 i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losbis4 i.ftpt i.profcomm
estimates store regression`t'
}

svy: regress ees i.NEWgroup i.grade i.sex1 i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losbis4 i.ftpt i.profcomm
estimates store regressionees



estimates table regression4 regression5 regression7 regression8, se
estimates table regressionees regression1 regression2 regression3 regression6 regression9, se
estimates table regression10 regression11 regression12

svy: mean ees Theme4 Theme5 Theme7 Theme8



*the next few bits produce grade-standardised breakdowns for BIS, and some demographics such as age,
*group, working hours.  This was used in the People Survey 2015 data viz written by Hiren.

*the following is used for the direct standardisation that I typically use in my analyses
*the weights are the estimated grade distribution for BIS from the following command

* put similar grades together for standardisation

gen grade_standardised=4 
replace grade_standardised=1 if grade==1|grade==4|grade==8  /* SCS,FS,AA/A0*/
replace grade_standardised=2 if grade==2|grade==3  /*g6/g7*/
replace grade_standardised=3 if grade==5|grade==6|grade==7  /* SEO/HEO/EO*/



* estinated grade distribution for 2015

				
*standardise by grade

gen stdgrade=grade_standardised
gen stdweight=.
replace stdweight=.15685483 if stdgrade==1
replace stdweight=.3834677 if stdgrade==2
replace stdweight=.458871 if stdgrade==3
replace stdweight=.0008065 if stdgrade==4

forvalues t=1/5 {
svy: mean ppB0`t',over(age4) stdize(stdgrade) stdweight(stdweight)
}

*standardised breakdowns for each question (Bxx Fxx_BIS) for BIS
forvalues t=1/9 {
svy: prop B0`t', stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy: prop B`t', stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy: prop F0`t'_BIS, stdize(stdgrade) stdweight(stdweight)
}
svy: prop , stdize(stdgrade) stdweight(stdweight)



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

tabulate location
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


*percentage positive for each theme for quadrant charts
* group
forvalues t=1/7 {
svy: mean ppTheme`t', over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
}

svy: mean ppees, over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
svy: mean ppTheme9, over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
*directorate

forvalues t=1/7 {
svy: mean  ppTheme`t', over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppees, over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)
svy: mean ppTheme9, over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)

*bis

forvalues t=1/7 {
svy: mean  ppTheme`t', stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppees, stdize(stdgrade) stdweight(stdweight)
svy: mean ppTheme9, stdize(stdgrade) stdweight(stdweight)

* location 

forvalues t=1/7 {
svy: mean ppTheme`t', over(location) stdize(stdgrade) stdweight(stdweight)
}

svy: mean ppees, over(location) stdize(stdgrade) stdweight(stdweight)
svy: mean ppTheme9, over(location) stdize(stdgrade) stdweight(stdweight)

*******************************
*residuals
*unit level popoulations and stratum
* Poststratum_Unit  are the strata and Poststratum_Unit_Population is the population size

tabulate NEWRU

merge m:1 NEWRU using "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\2014 Unit level populations.dta"
drop _merge
destring Poststratum_Unit_Population, replace
drop RU

tabulate Poststratum_Unit


svyset _n [pw=weight2], strata(Poststratum_Unit) fpc(Poststratum_Unit_Population) poststrata(poststratum) postweight(popNEW)	

*here's how to calculate the residuals following a regression:

svy: regress ees i.grade i.sex1 i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losbis4 i.ftpt i.profcomm
predict ees_predict					/*this calculates the predicted values from your regression	for each person in the dataset															*/
predict ees_resid, residuals		/*this calculates the residual (though presumably now we have ees_predict this is just equivalent to doing 'generate ees_resid=ees_predict-ees')	*/

forvalues t=1/9{
svy: regress Theme`t' i.grade i.sex1 i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losbis4 i.ftpt i.profcomm
estimates store regression`t'
predict Theme`t'pred					/*this calculates the predicted values from your regression	for each person in the dataset															*/
predict Theme`t'resid, residuals
}


*Now that we have residuals we can estimate Engagment for subpopulations corrected for all these characteristics, e.g.
svy: mean ees_resid, over(NEWdirectorate)
svy: mean ees_resid, over(NEWgroup)
svy: mean ees_resid
svy: mean ees

forvalues t=1/9{
svy: mean Theme`t'resid, over(NEWdirectorate)
svy: mean Theme`t'resid, over(NEWgroup)
svy: mean Theme`t'resid
svy: mean Theme`t'
}


* ad hoc on Legal Services by Grade

*need to group some grades that dont have enough responses

gen grade_legal=0 
replace grade_legal=1 if grade==1/* SCS,*/
replace grade_legal=2 if grade==2 /*g6*/
replace grade_legal=3 if grade==3 /*g7*/
replace grade_legal=4 if grade==4 /*FS*/
replace grade_legal=5 if grade==5|grade==6 /* SEO/HEO*/
replace grade_legal=6 if grade==7|grade==8  /*aa/ea/ao/EO*/


*generate an indicator for Legal

gen ind_legal=0

replace ind_legal=1 if NEWgroup==4

* for residual model get resiudals for legal and grade

svy, subpop(ind_legal): mean ees_resid, over(grade_legal)

forvalues t=1/9{
svy, subpop(ind_legal): mean Theme`t'resid, over(grade_legal)

}


* for normal/raw data (not residuals) to compare
forvalues t=1/7 {
svy, subpop(ind_legal): mean Theme`t', over(grade_legal)
}

svy, subpop(ind_legal): mean ees, over(grade_legal)
svy, subpop(ind_legal): mean Theme1, over(grade_legal) 


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


*percentage positive for each question for quadrant charts
* group
forvalues t=1/9 {
svy: mean ppB0`t', over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy: mean ppB`t', over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
}


*directorate

forvalues t=1/9 {
svy: mean ppB0`t', over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy: mean ppB`t', over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)
}



*bis
forvalues t=1/9 {
svy: mean ppB0`t',stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy: mean ppB`t', stdize(stdgrade) stdweight(stdweight)
}

*LOCATION

forvalues t=1/9 {
svy: mean ppB0`t', over(location) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy: mean ppB`t', over(location) stdize(stdgrade) stdweight(stdweight)
}


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
