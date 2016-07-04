*this takes the 2015 BIS dataset and prepares it for analysis

clear

*to turn the hierarchy dataset into a mapping of RespondentID to reporting units (RUs)
*this creates "2015 ID to RU.dta"
*after it's been run once to create the mapping dataset it doesn't need to be run again so long as the dataset isn't deleted

/*
use "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\org2015_BIS_hierarchy.dta", clear
sort ResponseID Population
gen AAA=cond( ResponseID[_n]== ResponseID[_n-1],0,1) if _n>1
replace AAA=1 if _n==1
keep if AAA==1
drop AAA
save "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\2015 ID to RU.dta"


*mapping RUs to 2015 structure
*this created "mapping 2015 RU.dta" so each RU is assigned to its correct team, directorate and group
*after it's been run once to create the mapping dataset it doesn't need to be run again so long as the dataset isn't deleted


import excel "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\BIS People Survey 2015 hierarchy 2012_2015.xlsx", sheet("2015 codes") firstrow allstring clear
save "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\mapping 2015 RU.dta"

*mapping poststrata to their populations
*this created "2015 poststrata.dta"
*after it's been run once to create the postrata weighting dataset it doesn't need to be run again so long as the dataset isn't deleted


import excel "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\poststrata exploration 2015.xls", sheet("2015 poststrata") firstrow allstring clear
destring poststratum, replace
recast int poststratum
save "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\2015 poststrata.dta"

*PUTTING IN UNIT LEVEL POPULATIONS AND STRATA

import excel "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\Unit level populations.xls", sheet("All units response rates") firstrow allstring clear
destring Poststratum_Unit, replace
recast int Poststratum_Unit
encode RU, generate (NEWRU)
save "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\Unit level populations.dta"

*/

*bringing it all together: the main microdata org2014_BIS.dta will have everyone's directorate etc

use "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\org2015_BIS.dta", clear
merge 1:1 ResponseID using "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\2015 ID to RU.dta", keep (match master)
drop Returns Population _merge
rename DeptCode RU
merge m:1 RU using "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\mapping 2015 RU.dta"
drop _merge
drop if ResponseID==.



*adding the poststrata codes
*poststrata are generally defined as a cross-classification of grade and group
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

merge m:1 poststratum using "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\2015 poststrata.dta"
drop _merge
destring population, replace


sort poststratum
qbys poststratum: egen samplesize = count(ResponseID) /*This puts the number of respondents in each poststratification class in as 'samplesize'*/

gen weight1=population/samplesize	/*we could use this for manually postratifying ourselves, but we won't do this*/
gen weight2=1						/*represents that everyone had the same sampling probability of 1; we'll let Stata handle the poststratification by using 'poststrata' and 'postweight'*/
gen fpc=2543

encode groupNew, generate (NEWgroup)				/*these encodings are required to turn the groups, directorates into numerical variables*/
encode directorateNew, generate (NEWdirectorate)	/*which we need to do for later analyses where we run estimates over each group or each directorate*/
encode orgNew, generate (NEWorg)
encode RU, generate (NEWRU)
drop groupNew directorateNew orgNew RU
*svyset _n [pw=weight1], fpc(fpc)													/*this is the svyset if we were poststratifying manually*/
svyset _n [pw=weight2], fpc(fpc) poststrata(poststratum) postweight(population)		/*this is the svyset we are generally using*/


/*the next bunch of code works out theme index scores in the same way the Engagement Index
is calculated.  It's all a bit cumbersome because of having to deal with missing values.
I wouldn't be surprised if there is a more elegant way of doing this.  The actual methodology
is to ignore missing values from the count which is equivalent to assuming that missing values
are equal to the average of the non-missing values for the theme.  This might not be true
but it is consistent with how the Engagement Index is officially worked out*/

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
drop AAA 
drop B01AAA
drop B02AAA
drop B03AAA 
drop B04AAA 
drop B05AAA								/*non-responses.  The dividing by 4 and subtracting 0.25	*/
																		/*scales the 1-5 score to a 0-1 score						*/

						/*non-responses.  The dividing by 4 and subtracting 0.25	*/
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

*generate Theme 16 - Leadership statement*

gen B63AAA=B63<.
gen B64AAA=B64<.
gen B65AAA=B65<.
gen B66AAA=B66<.
gen B67AAA=B67<.
gen B68AAA=B68<.
gen B69AAA=B69<.
gen B70AAA=B70<.
gen AAA=B63AAA + B64AAA + B65AAA + B66AAA + B67AAA + B68AAA + B69AAA + B70AAA
replace B63AAA=B63
replace B64AAA=B64
replace B65AAA=B65
replace B66AAA=B66
replace B67AAA=B67
replace B68AAA=B68
replace B69AAA=B69
replace B70AAA=B70
replace B63AAA=0 if B63==.
replace B64AAA=0 if B64==.
replace B65AAA=0 if B65==.
replace B66AAA=0 if B66==.
replace B67AAA=0 if B67==.
replace B68AAA=0 if B68==.
replace B69AAA=0 if B69==.
replace B70AAA=0 if B70==.
gen Theme16=((B63AAA + B64AAA + B65AAA + B66AAA + B67AAA + B68AAA + B69AAA + B70AAA)/AAA)/4-0.25
drop AAA B63AAA B64AAA B65AAA B66AAA B67AAA B68AAA B69AAA B70AAA

*Themes 13-15 were made up by me for the 2012 Survey following the then HR Director's interest in the MacLeod Report.
*seems to be no interest in these in HR at the moment though.
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
*the microdata already has pp for the B and W questions
forvalues t=1/9 {
gen ppF0`t'_BIS=.
replace ppF0`t'_BIS=0 if F0`t'_BIS<4
replace ppF0`t'_BIS=1 if F0`t'_BIS==4 | F0`t'_BIS==5
}
gen ppF10_BIS=.
replace ppF10_BIS=0 if F10_BIS<4
replace ppF10_BIS=1 if F10_BIS==4 | F10_BIS==5

gen ppF11_BIS=.
replace ppF11_BIS=0 if F11_BIS<4
replace ppF11_BIS=1 if F11_BIS==4 | F10_BIS==5

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


*the following section of code creates a number of categorical 'demographic' variables
*in some cases we have alternative classifications of the same concept, e.g. age1 has 3 categories, age2 has just 2
*age3 is basically decades
*in all cases, I have set it up so missing values and prefer not to say are conflated

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

gen losrole1=6
replace losrole1=1 if H02<3
replace losrole1=2 if H02==3|H02==4
replace losrole1=3 if H02==5
replace losrole1=4 if H02==6
replace losrole1=5 if H02>6 & H02<.		/*1=less than 1y 2=1-4y 3=5-9y 4=10y-19 5=20+ 6=missing */


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
label define label_losrole1 1 "less than 1 year" 2 "1-5 years" 3 "more than 5 - 10 years"  4 "more than 10 years- 20 years" 5 "more than 20 years" 6 "undeclared"
label values losrole1 label_losrole1
label define label_ftpt 1 "full time" 2 "part time" 3 "job sharer" 4 "undeclared"
label values ftpt label_ftpt
label define label_profcomm 1 "member of a professional community" 2 "not a member of a professional community" 3 "undeclared"
label values profcomm label_profcomm


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

svy: regress Theme16 i.NEWgroup i.grade i.sex i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losbis4 i.ftpt i.profcomm
estimates store regression16

svy: regress Theme12 i.NEWgroup i.grade i.sex i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losbis4 i.ftpt i.profcomm
estimates store regression12a

estimates table regression12a

*interactions looking into length of time in post and age

svy: regress ees i.NEWgroup i.grade i.sex i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losrole1 i.ftpt i.profcomm
estimates store regressionees

regress ees i.age4 i.losrole1 i.age4#i.losrole1

regress ees i.age4 i.losrole1 i.age4#i.losrole1 i.NEWgroup i.grade i.sex i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.ftpt i.profcomm

*regression4 regression5 regression7 regression8 regression16

estimates table regressionees regression1 regression2 regression3 regression6 regression9,se

svy: mean Theme1 Theme2 Theme3 Theme4 Theme5 Theme6 Theme7 Theme8 Theme9 

svy: mean Theme12, over(age4)

tabulate NEWgroup
tabulate grade
tabulate theme12 sex
tabulate mean Theme12 age4
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
tabulate losrole1

svy: prop C01, over(age4)

tabulate C01 age4




*the following is used for the direct standardisation that are typically used in analyses - 
*the weights are the estimated grade distribution for BIS from the following command
*svy: prop grade



* put similar grades together for standardisation

gen grade_standardised=4 
replace grade_standardised=1 if grade==1|grade==4|grade==8  /* SCS,FS,AA/A0*/
replace grade_standardised=2 if grade==2|grade==3  /*g6/g7*/
replace grade_standardised=3 if grade==5|grade==6|grade==7  /* SEO/HEO/EO*/



* estinated grade distribution

svy: prop grade_standardised

				
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
forvalues t=10/70 {
svy: prop B`t', stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy: prop F0`t'_BIS, stdize(stdgrade) stdweight(stdweight)
}
svy: prop F10_BIS, stdize(stdgrade) stdweight(stdweight)
svy: prop F11_BIS, stdize(stdgrade) stdweight(stdweight)

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
svy: prop F11_BIS, over(NEWgroup) stdize(stdgrade) stdweight(stdweight)

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
svy: prop F11_BIS, over(grade)

*breakdowns for each question (Bxx Fxx_BIS) for each age standardised by grade
forvalues t=1/9 {
svy: prop B0`t', over(age4) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/70 {
svy: prop B`t', over(age4) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy: prop F0`t'_BIS, over(age4) stdize(stdgrade) stdweight(stdweight)
}
svy: prop F10_BIS, over(age4) stdize(stdgrade) stdweight(stdweight)
svy: prop F11_BIS, over(age4) stdize(stdgrade) stdweight(stdweight)

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
svy: prop F11_BIS, over(disability) stdize(stdgrade) stdweight(stdweight)

*percentage positive for each question for quadrant charts
* group
forvalues t=1/9 {
svy: mean ppB0`t', over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/70 {
svy: mean ppB`t', over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy: mean ppF0`t'_BIS, over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppF10_BIS, over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
svy: mean ppF11_BIS, over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
*directorate

forvalues t=1/9 {
svy: mean ppB0`t', over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/70 {
svy: mean ppB`t', over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy: mean ppF0`t'_BIS, over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppF10_BIS, over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)
svy: mean ppF11_BIS, over(NEWdirectorate) stdize(stdgrade) stdweight(stdweight)

*bis
forvalues t=1/9 {
svy: mean ppB0`t',stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/70 {
svy: mean ppB`t', stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy: mean ppF0`t'_BIS, stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppF10_BIS, stdize(stdgrade) stdweight(stdweight)
svy: mean ppF11_BIS, stdize(stdgrade) stdweight(stdweight)

*age

forvalues t=1/5 {
svy: mean ppB0`t',over(age4) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/70 {
svy: mean ppB`t', over(age4) stdize(stdgrade) stdweight(stdweight)
}
*location

forvalues t=1/9 {
svy: mean ppB0`t', over(location) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/70 {
svy: mean ppB`t', over(location) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy: mean ppF0`t'_BIS, over(location) stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppF10_BIS, over(location) stdize(stdgrade) stdweight(stdweight)
svy: mean ppF11_BIS, over(location) stdize(stdgrade) stdweight(stdweight)

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

* for BIS
forvalues t=1/7 {
svy: mean  ppTheme`t', stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppees, stdize(stdgrade) stdweight(stdweight)
svy: mean ppTheme9, stdize(stdgrade) stdweight(stdweight)

*location
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

merge m:1 NEWRU using "W:\SURVEY-SUPPORT-TEAM\Pulse and People\2015\People Survey 2015\Unit level populations.dta"
drop _merge
destring Poststratum_Unit_Population, replace
drop RU

tabulate Poststratum_Unit_Population


svyset _n [pw=weight2], strata(Poststratum_Unit) fpc(Poststratum_Unit_Population) poststrata(poststratum) postweight(population)	

*here's how to calculate the residuals following a regression:

svy: regress ees i.grade i.sex i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losbis4 i.ftpt i.profcomm
predict ees_predict					/*this calculates the predicted values from your regression	for each person in the dataset															*/
predict ees_resid, residuals		/*this calculates the residual (though presumably now we have ees_predict this is just equivalent to doing 'generate ees_resid=ees_predict-ees')	*/

forvalues t=1/9{
svy: regress Theme`t' i.grade i.sex i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losbis4 i.ftpt i.profcomm
estimates store regression`t'
predict Theme`t'pred					/*this calculates the predicted values from your regression	for each person in the dataset															*/
predict Theme`t'resid, residuals
}

svy: regress Theme16 i.grade i.sex i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losbis4 i.ftpt i.profcomm
predict Theme16_predict					/*this calculates the predicted values from your regression	for each person in the dataset															*/
predict Theme16_resid, residuals		/*this calculates the residual (though presumably now we have ees_predict this is just equivalent to doing 'generate ees_resid=ees_predict-ees')	*/


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

svy: mean Theme16_resid, over(NEWdirectorate)
svy: mean Theme16_resid, over(NEWgroup)
svy: mean Theme16_resid
svy: mean Theme16

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
svy, subpop(ind_legal): mean ees_resid
svy, subpop(ind_legal): mean ees

forvalues t=1/9{
svy, subpop(ind_legal): mean Theme`t'resid, over(grade_legal)
svy, subpop(ind_legal): mean Theme`t'resid
svy, subpop(ind_legal): mean Theme`t'
}


* for normal/raw data (not residuals) to compare
forvalues t=1/7 {
svy, subpop(ind_legal): mean Theme`t', over(grade_legal)
}

svy, subpop(ind_legal): mean ees, over(grade_legal)
svy, subpop(ind_legal): mean Theme8, over(grade_legal) 





*this gives the corrected directorate scores (though I'd prefer to do this using a regression that excludes the NEWgroup variable)
*scores where the confidence intervals contain zero are not significantly different from the BIS average
*the confidence intervals can be used on a caterpillar chart



*here's how to calculate the residuals following a regression:

svy: regress ees i.grade i.sex i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losbis4 i.ftpt i.profcomm
predict ees_predict					/*this calculates the predicted values from your regression	for each person in the dataset															*/
predict ees_resid, residuals		/*this calculates the residual (though presumably now we have ees_predict this is just equivalent to doing 'generate ees_resid=ees_predict-ees')	*/

/*the residuals are available now as Engagement scores for everyone corrected for all the variables in your regression, 
though I guess they'd needed to be added to the BIS average to be more interpretable 
*******i dont get the fundamentals of this*/

*the following lines produce graphs to help assess model fit.  Note that you'll need to run these line by line as Stata seems to overwrite one graph with the next.

*plotting residuals against predicted values.  We want the plots to be 'null plots' - a nice blob centred around the origin, symmetrical, not much structure.
*these plots facet out by various categories and in most cases the subplots look good, as well as the overall plot (which is the 'total' in these charts.
twoway (scatter ees_resid ees_predict, msymbol(smcircle) jitter(5)), by(, title(residual plot) subtitle(unstandardised residuals against fitted values)) by(, legend(off)) by(grade, total)
twoway (scatter ees_resid ees_predict, msymbol(smcircle) jitter(5)), by(, title(residual plot) subtitle(unstandardised residuals against fitted values)) by(, legend(off)) by(sex, total)
twoway (scatter ees_resid ees_predict, msymbol(smcircle) jitter(5)), by(, title(residual plot) subtitle(unstandardised residuals against fitted values)) by(, legend(off)) by(age4, total)
twoway (scatter ees_resid ees_predict, msymbol(smcircle) jitter(5)), by(, title(residual plot) subtitle(unstandardised residuals against fitted values)) by(, legend(off)) by(bme2, total)

*these are simple histograms of the residuals, with a Normal density overlaid
*they look really good too!
histogram ees_resid, normal by(, title(Residuals) subtitle(unstandardised residuals)) by(, legend(off)) by(grade, total)
histogram ees_resid, normal by(, title(Residuals) subtitle(unstandardised residuals)) by(, legend(off)) by(sex, total)
histogram ees_resid, normal by(, title(Residuals) subtitle(unstandardised residuals)) by(, legend(off)) by(age4, total)
histogram ees_resid, normal by(, title(Residuals) subtitle(unstandardised residuals)) by(, legend(off)) by(bme2, total)

*a Normal Q-Q plot which shows that overall the residuals are Normally distributed
qnorm ees_resid

*Basically, the Engagment model looks very good to me.  These plots don't show that the model has great predictive power as such (our R-squared aren't briliant) but
*these dignostics suggest the assumptions we make about residuals do hold, so our p-values and judgments about statistical significance are probably valid


*Now that we have residuals we can estimate Engagment for subpopulations corrected for all these characteristics, e.g.
svy: mean ees_resid, over(NEWdirectorate)
svy: mean ees_resid, over(NEWgroup)
svy: mean ees_resid
svy: mean ees
*this gives the corrected directorate scores (though I'd prefer to do this using a regression that excludes the NEWgroup variable)
*scores where the confidence intervals contain zero are not significantly different from the BIS average
*the confidence intervals can be used on a caterpillar chart









*but we could do corrected scores for other things, e.g. comparing statisticians with economists
generate GES=0
replace GES=1 if H08==21
generate GSS=0
replace GSS=1 if H08==30

svy, subpop(GES):mean ees_resid
svy, subpop(GSS):mean ees_resid

*note no standardisation by grade or anything else required because these corrections are built in to the residuals themselves.  Potentially a very flexible way.













*Exercise: try to create residuals for Engagement in a model with no NEWgroup variable

svy: regress ees i.grade i.sex i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losbis4 i.ftpt i.profcomm
predict ees_nogrouppredict					/*this calculates the predicted values from your regression	for each person in the dataset															*/
predict ees_nogroupresid, residuals		/*this calculates the residual (though presumably now we have ees_predict this is just equivalent to doing 'generate ees_resid=ees_predict-ees')	*/

*the residuals are available now as Engagement scores for everyone corrected for all the variables in your regression, though I guess they'd needed to be added to the BIS average to be more interpretable

*the following lines produce graphs to help assess model fit.  Note that you'll need to run these line by line as Stata seems to overwrite one graph with the next.

*plotting residuals against predicted values.  We want the plots to be 'null plots' - a nice blob centred around the origin, symmetrical, not much structure.
*these plots facet out by various categories and in most cases the subplots look good, as well as the overall plot (which is the 'total' in these charts.
twoway (scatter ees_nogroupresid ees_nogrouppredict, msymbol(smcircle) jitter(5)), by(, title(residual plot) subtitle(unstandardised residuals against fitted values)) by(, legend(off)) by(grade, total)
twoway (scatter ees_nogroupresid ees_nogrouppredict, msymbol(smcircle) jitter(5)), by(, title(residual plot) subtitle(unstandardised residuals against fitted values)) by(, legend(off)) by(sex, total)
twoway (scatter ees_nogroupresid ees_nogrouppredict, msymbol(smcircle) jitter(5)), by(, title(residual plot) subtitle(unstandardised residuals against fitted values)) by(, legend(off)) by(age4, total)
twoway (scatter ees_nogroupresid ees_nogrouppredict, msymbol(smcircle) jitter(5)), by(, title(residual plot) subtitle(unstandardised residuals against fitted values)) by(, legend(off)) by(bme2, total)

*these are simple histograms of the residuals, with a Normal density overlaid
*they look really good too!
histogram ees_nogroupresid, normal by(, title(Residuals) subtitle(unstandardised residuals)) by(, legend(off)) by(grade, total)
histogram ees_nogroupresid, normal by(, title(Residuals) subtitle(unstandardised residuals)) by(, legend(off)) by(sex, total)
histogram ees_nogroupresid, normal by(, title(Residuals) subtitle(unstandardised residuals)) by(, legend(off)) by(age4, total)
histogram ees_nogroupresid, normal by(, title(Residuals) subtitle(unstandardised residuals)) by(, legend(off)) by(bme2, total)

*a Normal Q-Q plot which shows that overall the residuals are Normally distributed
qnorm ees_nogroupresid

*Now that we have residuals we can estimate Engagment for subpopulations corrected for all these characteristics, e.g.
svy: mean ees_nogroupresid, over(NEWdirectorate)

*Exercise: try this with an individual question and assess whether we can use this method to correct questions in the same way as themes.  (I looked at B50.) doesnt look too bad?

gen B50AAA=B50<.
replace B50AAA=B50
replace B50AAA=. if B50==.
gen quesb50=B50AAA/4-0.25


svy: regress quesb50 i.grade i.sex i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losbis4 i.ftpt i.profcomm
predict ees_Q50predict					/*this calculates the predicted values from your regression	for each person in the dataset															*/
predict ees_Q50resid, residuals

/*scatter plots look ok - a little bit more spread out than by theme*/

twoway (scatter ees_Q50resid ees_Q50predict, msymbol(smcircle) ), by(, title(residual plot) subtitle(unstandardised residuals against fitted values)) by(, legend(off)) by(NEWgroup, total)
twoway (scatter ees_Q50resid ees_Q50predict, msymbol(smcircle) jitter(5)), by(, title(residual plot) subtitle(unstandardised residuals against fitted values)) by(, legend(off)) by(grade, total)
twoway (scatter ees_Q50resid ees_Q50predict, msymbol(smcircle) jitter(5)), by(, title(residual plot) subtitle(unstandardised residuals against fitted values)) by(, legend(off)) by(sex, total)
twoway (scatter ees_Q50resid ees_Q50predict, msymbol(smcircle) jitter(5)), by(, title(residual plot) subtitle(unstandardised residuals against fitted values)) by(, legend(off)) by(age4, total)
twoway (scatter ees_Q50resid ees_Q50predict, msymbol(smcircle) jitter(5)), by(, title(residual plot) subtitle(unstandardised residuals against fitted values)) by(, legend(off)) by(bme2, total)

*these are simple histograms of the residuals, with a Normal density overlaid
*some of the breakdowns dont look great - esp grade,age - total looks ok
histogram ees_Q50resid, normal by(, title(Residuals) subtitle(unstandardised residuals)) by(, legend(off)) by(NEWgroup, total)
histogram ees_Q50resid, normal by(, title(Residuals) subtitle(unstandardised residuals)) by(, legend(off)) by(grade, total)
histogram ees_Q50resid, normal by(, title(Residuals) subtitle(unstandardised residuals)) by(, legend(off)) by(sex, total)
histogram ees_Q50resid, normal by(, title(Residuals) subtitle(unstandardised residuals)) by(, legend(off)) by(age4, total)
histogram ees_Q50resid, normal by(, title(Residuals) subtitle(unstandardised residuals)) by(, legend(off)) by(bme2, total)

*a Normal Q-Q plot which shows that overall the residuals are Normally distributed
*not a straight line, not normally distributed??
qnorm ees_Q50resid


*Exercise: try to use a for loop to create residuals for each of the non-Engagement themes

forvalues t=1/12{
svy: regress Theme`t' i.NEWgroup i.grade i.sex i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losbis4 i.ftpt i.profcomm
estimates store regression`t'
predict Theme`t'pred					/*this calculates the predicted values from your regression	for each person in the dataset															*/
predict Theme`t'resid, residuals
}


*test it
histogram Theme2resid, normal by(, title(Residuals) subtitle(unstandardised residuals)) by(, legend(off)) by(NEWgroup, total)



/*Question: If the model fits well, using 'svy: mean ees_predict, over(grade)' 
shows the corrected Engagement scores for each grade is zero - does this mean that there is no difference between the grades?  

no because grade has already been corrected for as it is in the model

How can we show the true difference between grades correcting for the other demographics?  Do we need to fit yet another model with no grade variable?

No - we did this already by looking at the estimates from the model for the grade variable and comparing these to the BIS average'




*/


******************************************************************************
* BHD results using multinomial logitic regression

*already all numeric 1=yes 2=no 3=PNS
* i.NEWgroup i.grade i.sex i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losrole1 i.ftpt i.profcomm


mlogit E01 i.NEWgroup i.grade i.sex i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losbis4 i.ftpt 

mlogit E03 i.NEWgroup i.grade i.sex i.age4 i.bme2 i.disability i.carer i.childcare i.sexuality1 i.religion1 i.location i.losbis4 i.ftpt 

  * predicted probablities for each variable and each out come? it made sense for 1 but not for 2
margins sex, atmeans predict(outcome(1))
margins sex, atmeans predict(outcome(2))

tabulate E01 losbis4

*******************************************************************************************************************************************

*calculations for Pulse 2016 report

*first set new grade distribution for standardisation
*These are the population breakdowns for the 2016 Pulse Survey based on our register info collected in april 2016

* put similar grades together for standardisation

gen grade_standardised=4 
replace grade_standardised=1 if grade==1|grade==4|grade==8  /* SCS,FS,AA/A0*/
replace grade_standardised=2 if grade==2|grade==3  /*g6/g7*/
replace grade_standardised=3 if grade==5|grade==6|grade==7  /* SEO/HEO/EO*/

				
*standardise by grade

gen stdgrade=grade_standardised
gen stdweight=.
replace stdweight=384/2289 if stdgrade==1
replace stdweight=796/2289 if stdgrade==2
replace stdweight=1067/2289 if stdgrade==3
replace stdweight=42/2289 if stdgrade==4


*next create percentage negative variables pn
forvalues t=1/9 {
gen pnF0`t'_BIS=.
replace pnF0`t'_BIS=0 if F0`t'_BIS>2 & F0`t'_BIS<.
replace pnF0`t'_BIS=1 if F0`t'_BIS==1 | F0`t'_BIS==2
}
gen pnF10_BIS=.
replace pnF10_BIS=0 if F10_BIS>2 & F10_BIS<.
replace pnF10_BIS=1 if F10_BIS==1 | F10_BIS==2

gen pnF11_BIS=.
replace pnF11_BIS=0 if F10_BIS>2 & F11_BIS<.
replace pnF11_BIS=1 if F10_BIS==1 | F11_BIS==2

forvalues t=1/9 {
gen pnB0`t'=.
replace pnB0`t'=0 if B0`t'>2 & B0`t'<.
replace pnB0`t'=1 if B0`t'==1 | B0`t'==2
}

forvalues t=10/70 {
gen pnB`t'=.
replace pnB`t'=0 if B`t'>2 & B`t'<.
replace pnB`t'=1 if B`t'==1 | B`t'==2
}

tabulate NEWgroup

*breakdowns for each question (Bxx Fxx_BIS)
forvalues t=1/9 {
svy: prop B0`t', stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/70 {
svy: prop B`t', stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy: prop F0`t'_BIS, stdize(stdgrade) stdweight(stdweight)
}
svy: prop F10_BIS, stdize(stdgrade) stdweight(stdweight)
svy: prop F11_BIS, stdize(stdgrade) stdweight(stdweight)

*percentage positive and negative for each question
forvalues t=1/9 {
svy: mean ppB0`t', stdize(stdgrade) stdweight(stdweight)
svy: mean pnB0`t', stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/70 {
svy: mean ppB`t', stdize(stdgrade) stdweight(stdweight)
svy: mean pnB`t', stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy: mean ppF0`t'_BIS, stdize(stdgrade) stdweight(stdweight)
svy: mean pnF0`t'_BIS, stdize(stdgrade) stdweight(stdweight)
}
svy: mean ppF10_BIS, stdize(stdgrade) stdweight(stdweight)
svy: mean pnF10_BIS, stdize(stdgrade) stdweight(stdweight)

svy: mean ppF11_BIS, stdize(stdgrade) stdweight(stdweight)
svy: mean pnF11_BIS, stdize(stdgrade) stdweight(stdweight)


svy: mean ees,stdize(stdgrade) stdweight(stdweight) over (grade)


****** by location percenatge positive only 

forvalues t=1/9 {
svy: mean ppB0`t', stdize(stdgrade) stdweight(stdweight) over (location)

}
forvalues t=10/70 {
svy: mean ppB`t', stdize(stdgrade) stdweight(stdweight) over (location)

}
forvalues t=1/9 {
svy: mean ppF0`t'_BIS, stdize(stdgrade) stdweight(stdweight) over (location)


}
svy: mean ppF10_BIS, stdize(stdgrade) stdweight(stdweight) over (location)

svy: mean ppF11_BIS, stdize(stdgrade) stdweight(stdweight) over (location)

svy: mean ees,stdize(stdgrade) stdweight(stdweight) over (location)



****** by group percenatge positive only 

forvalues t=1/9 {
svy: mean ppB0`t', stdize(stdgrade) stdweight(stdweight) over (NEWgroup)

}
forvalues t=10/70 {
svy: mean ppB`t', stdize(stdgrade) stdweight(stdweight) over (NEWgroup)

}
forvalues t=1/9 {
svy: mean ppF0`t'_BIS, stdize(stdgrade) stdweight(stdweight) over (NEWgroup)


}
svy: mean ppF10_BIS, stdize(stdgrade) stdweight(stdweight) over (NEWgroup)

svy: mean ppF11_BIS, stdize(stdgrade) stdweight(stdweight) over (NEWgroup)

svy: mean ees,stdize(stdgrade) stdweight(stdweight) over (NEWgroup)

*********** group by location for EM - 2,BS -1,PSHE - 6,SDLG - 8

/*BS*/

forvalues t=1/12 {
gen group_ind`t'=1 if NEWgroup==`t'
}

/*BS*/
forvalues t=1/9 {
svy, subpop(group_ind1): mean ppB0`t', stdize(stdgrade) stdweight(stdweight) over (location)

}
forvalues t=10/70 {
svy, subpop(group_ind1): mean ppB`t', stdize(stdgrade) stdweight(stdweight) over (location)

}
forvalues t=1/9 {
svy, subpop(group_ind1): mean ppF0`t'_BIS, stdize(stdgrade) stdweight(stdweight) over (location)


}
svy, subpop(group_ind1): mean ppF10_BIS, stdize(stdgrade) stdweight(stdweight) over (location)

svy, subpop(group_ind1): mean ppF11_BIS, stdize(stdgrade) stdweight(stdweight) over (location)

svy, subpop(group_ind1): mean ees,stdize(stdgrade) stdweight(stdweight) over (location)

/*EM*/
forvalues t=1/9 {
svy, subpop(group_ind2): mean ppB0`t', stdize(stdgrade) stdweight(stdweight) over (location)

}
forvalues t=10/70 {
svy, subpop(group_ind2): mean ppB`t', stdize(stdgrade) stdweight(stdweight) over (location)

}
forvalues t=1/9 {
svy, subpop(group_ind2): mean ppF0`t'_BIS, stdize(stdgrade) stdweight(stdweight) over (location)


}
svy, subpop(group_ind2): mean ppF10_BIS, stdize(stdgrade) stdweight(stdweight) over (location)

svy, subpop(group_ind2): mean ppF11_BIS, stdize(stdgrade) stdweight(stdweight) over (location)

svy, subpop(group_ind2): mean ees,stdize(stdgrade) stdweight(stdweight) over (location)


/*PSHE*/
forvalues t=1/9 {
svy, subpop(group_ind6): mean ppB0`t', stdize(stdgrade) stdweight(stdweight) over (location)

}
forvalues t=10/70 {
svy, subpop(group_ind6): mean ppB`t', stdize(stdgrade) stdweight(stdweight) over (location)

}
forvalues t=1/9 {
svy, subpop(group_ind6): mean ppF0`t'_BIS, stdize(stdgrade) stdweight(stdweight) over (location)


}
svy, subpop(group_ind6): mean ppF10_BIS, stdize(stdgrade) stdweight(stdweight) over (location)

svy, subpop(group_ind6): mean ppF11_BIS, stdize(stdgrade) stdweight(stdweight) over (location)

svy, subpop(group_ind6): mean ees,stdize(stdgrade) stdweight(stdweight) over (location)


/*SDLG*/
forvalues t=1/9 {
svy, subpop(group_ind8): mean ppB0`t', stdize(stdgrade) stdweight(stdweight) over (location)

}
forvalues t=10/70 {
svy, subpop(group_ind8): mean ppB`t', stdize(stdgrade) stdweight(stdweight) over (location)

}
forvalues t=1/9 {
svy, subpop(group_ind8): mean ppF0`t'_BIS, stdize(stdgrade) stdweight(stdweight) over (location)


}
svy, subpop(group_ind8): mean ppF10_BIS, stdize(stdgrade) stdweight(stdweight) over (location)

svy, subpop(group_ind8): mean ppF11_BIS, stdize(stdgrade) stdweight(stdweight) over (location)

svy, subpop(group_ind8): mean ees,stdize(stdgrade) stdweight(stdweight) over (location)



tabulate NEWgroup location
 























*******************************************************************************************
*For Neil Golbourne's look at G6/7 BIS economists
*Used on 2015 data on 8 Dec 2015

gen nonEcon=0										/*This variable is for analysts who aren't Economists - for Neil's comparator group*/
replace nonEcon=1 if H08==27 | H08==28 | H08==30	/* H08 is 21 for GES, 27 for GORS, 28 for GSR and 30 for GSS*/

gen G67=0											/*Indicator for being a grade 6 or grade 7*/
replace G67=1 if grade==2 | grade==3

mean ees mw_p op_p lm_p mt_p ld_p if_p rw_p pb_p lc_p if nonEcon==1
mean ees mw_p op_p lm_p mt_p ld_p if_p rw_p pb_p lc_p if nonEcon==1 & grade==5
mean ees mw_p op_p lm_p mt_p ld_p if_p rw_p pb_p lc_p if nonEcon==1 & G67==1

mean ees mw_p op_p lm_p mt_p ld_p if_p rw_p pb_p lc_p if H08==21 & G67==1	/*This is for G6/7 Economists */

*extra analysis for Neil G and Sarah Wood's report, run on 18 Dec 2015
gen analyst=(H08==21 | H08==27 | H08==28 | H08==30)
mean ees if analyst*G67==1
mean ees if analyst==1 & grade>=4 & grade <=8

gen policy=(H08==7)
mean ees if policy*G67==1

mean ees if analyst==1 & grade==1

******************************************************************************************** 
*age diversity stuff for Anna Cummins
*using 'decades' age breakdown (age3)
forvalues t=50/54 {
svy: prop B`t', over(age3) stdize(stdgrade) stdweight(stdweight)
}

foreach t of numlist 1/5 9 {
svy: prop B0`t', over(age3) stdize(stdgrade) stdweight(stdweight)
}

foreach t of numlist 10/18 30/36 40 /49 {
svy: prop B`t', over(age3) stdize(stdgrade) stdweight(stdweight)
}

foreach t of numlist 1 3 7 9 {
svy: mean Theme`t', over(age3) stdize(stdgrade) stdweight(stdweight)
}
*******************************
*safe to challenge in PSHE (Tom Ripley)
*B49
*need to put together PSHE directorates in the right way then standardise
*how do we deal woth Fast Streamers or other missing grades?

gen ind_comms=0
gen ind_ced_sg=0
gen ind_he=0
gen ind_hr=0

replace ind_comms=1 if NEWdirectorate==38
replace ind_ced_sg=1 if NEWdirectorate==41|NEWdirectorate==39
replace ind_he=1 if NEWdirectorate==27
replace ind_hr=1 if NEWdirectorate==40

svy, subpop(ind_hr): prop B49, stdize(stdgrade) stdweight(stdweight)

svy, subpop(ind_comms): mean ppB49, stdize(stdgrade) stdweight(stdweight)
svy, subpop(ind_ced_sg): mean ppB49, stdize(stdgrade) stdweight(stdweight)
svy, subpop(ind_he): mean ppB49, stdize(stdgrade) stdweight(stdweight)
svy, subpop(ind_hr): mean ppB49, stdize(stdgrade) stdweight(stdweight)

svy, subpop(ind_comms): mean B49, stdize(stdgrade) stdweight(stdweight)
svy, subpop(ind_ced_sg): mean B49, stdize(stdgrade) stdweight(stdweight)
svy, subpop(ind_he): mean B49, stdize(stdgrade) stdweight(stdweight)
svy, subpop(ind_hr): mean B49, stdize(stdgrade) stdweight(stdweight)


*the next section of code are for getting grade, age and hours breakdowns (grade standardised) for each group
*I think this was in anticipation of extending Hiren's data viz but we didn't do it in the end
*I'm not sure where we ended up using these results - did we do an Excel dashboard?

*create indicator variables for each group
*I've done this because Stata won't let me run 'svy: prop B01, over (grade NEWgroup)' because
*I get the error message 'too many categories'
*I could deal with this by changing matsize but I don't know if this would slow down the program elsewhere:
	/*set matsize 600 											*/
	/*forvalues t=1/9 {svy: prop B0`t', over (grade NEWgroup)}	*/
forvalues t=1/12 {
gen group_ind`t'=1 if NEWgroup==`t'
}

*Grade, age and hours breakdowns for BLG (group_ind1=1)
forvalues t=1/9 {
*svy, subpop(group_ind1): prop B0`t', over(grade)
svy: prop B0`t', over(grade NEWgroup)
}
forvalues t=10/62 {
svy, subpop(group_ind1): prop B`t', over(grade)
}
forvalues t=1/9 {
svy, subpop(group_ind1): prop F0`t'_BIS, over(grade)
}
svy, subpop(group_ind1): prop F10_BIS, over(grade)
forvalues t=1/9 {
svy, subpop(group_ind1): prop B0`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind1): prop B`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind1): prop F0`t'_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind1): prop F10_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)

forvalues t=1/9 {
svy, subpop(group_ind1): prop B0`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind1): prop B`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind1): prop F0`t'_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind1): prop F10_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)


*Grade, age and hours breakdowns for EM (group_ind2=1)
forvalues t=1/9 {
svy, subpop(group_ind2): prop B0`t', over(grade)
}
forvalues t=10/62 {
svy, subpop(group_ind2): prop B`t', over(grade)
}
forvalues t=1/9 {
svy, subpop(group_ind2): prop F0`t'_BIS, over(grade)
}
svy, subpop(group_ind2): prop F10_BIS, over(grade)
forvalues t=1/9 {
svy, subpop(group_ind2): prop B0`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind2): prop B`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind2): prop F0`t'_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind2): prop F10_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)

forvalues t=1/9 {
svy, subpop(group_ind2): prop B0`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind2): prop B`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind2): prop F0`t'_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind2): prop F10_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)


*Grade, age and hours breakdowns for ES (group_ind3=1)
forvalues t=1/9 {
svy, subpop(group_ind3): prop B0`t', over(grade)
}
forvalues t=10/62 {
svy, subpop(group_ind3): prop B`t', over(grade)
}
forvalues t=1/9 {
svy, subpop(group_ind3): prop F0`t'_BIS, over(grade)
}
svy, subpop(group_ind3): prop F10_BIS, over(grade)
forvalues t=1/9 {
svy, subpop(group_ind3): prop B0`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind3): prop B`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind3): prop F0`t'_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind3): prop F10_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)

forvalues t=1/9 {
svy, subpop(group_ind3): prop B0`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind3): prop B`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind3): prop F0`t'_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind3): prop F10_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)


*Grade, age and hours breakdowns for FC (group_ind4=1)
forvalues t=1/9 {
svy, subpop(group_ind4): prop B0`t', over(grade)
}
forvalues t=10/62 {
svy, subpop(group_ind4): prop B`t', over(grade)
}
forvalues t=1/9 {
svy, subpop(group_ind4): prop F0`t'_BIS, over(grade)
}
svy, subpop(group_ind4): prop F10_BIS, over(grade)
forvalues t=1/9 {
svy, subpop(group_ind4): prop B0`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind4): prop B`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind4): prop F0`t'_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind4): prop F10_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)

forvalues t=1/9 {
svy, subpop(group_ind4): prop B0`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind4): prop B`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind4): prop F0`t'_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind4): prop F10_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)


*Grade, age and hours breakdowns for GOS (group_ind5=1)
forvalues t=1/9 {
svy, subpop(group_ind5): prop B0`t', over(grade)
}
forvalues t=10/62 {
svy, subpop(group_ind5): prop B`t', over(grade)
}
forvalues t=1/9 {
svy, subpop(group_ind5): prop F0`t'_BIS, over(grade)
}
svy, subpop(group_ind5): prop F10_BIS, over(grade)
forvalues t=1/9 {
svy, subpop(group_ind5): prop B0`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind5): prop B`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind5): prop F0`t'_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind5): prop F10_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)

forvalues t=1/9 {
svy, subpop(group_ind5): prop B0`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind5): prop B`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind5): prop F0`t'_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind5): prop F10_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)


*Grade, age and hours breakdowns for KI (group_ind6=1)
forvalues t=1/9 {
svy, subpop(group_ind6): prop B0`t', over(grade)
}
forvalues t=10/62 {
svy, subpop(group_ind6): prop B`t', over(grade)
}
forvalues t=1/9 {
svy, subpop(group_ind6): prop F0`t'_BIS, over(grade)
}
svy, subpop(group_ind6): prop F10_BIS, over(grade)
forvalues t=1/9 {
svy, subpop(group_ind6): prop B0`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind6): prop B`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind6): prop F0`t'_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind6): prop F10_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)

forvalues t=1/9 {
svy, subpop(group_ind6): prop B0`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind6): prop B`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind6): prop F0`t'_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind6): prop F10_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)


*Grade, age and hours breakdowns for LS (group_ind7=1)
forvalues t=1/9 {
svy, subpop(group_ind7): prop B0`t', over(grade)
}
forvalues t=10/62 {
svy, subpop(group_ind7): prop B`t', over(grade)
}
forvalues t=1/9 {
svy, subpop(group_ind7): prop F0`t'_BIS, over(grade)
}
svy, subpop(group_ind7): prop F10_BIS, over(grade)
forvalues t=1/9 {
svy, subpop(group_ind7): prop B0`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind7): prop B`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind7): prop F0`t'_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind7): prop F10_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)

forvalues t=1/9 {
svy, subpop(group_ind7): prop B0`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind7): prop B`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind7): prop F0`t'_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind7): prop F10_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)


*Grade, age and hours breakdowns for MPST (group_ind8=1)
forvalues t=1/9 {
svy, subpop(group_ind8): prop B0`t', over(grade)
}
forvalues t=10/62 {
svy, subpop(group_ind8): prop B`t', over(grade)
}
forvalues t=1/9 {
svy, subpop(group_ind8): prop F0`t'_BIS, over(grade)
}
svy, subpop(group_ind8): prop F10_BIS, over(grade)
forvalues t=1/9 {
svy, subpop(group_ind8): prop B0`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind8): prop B`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind8): prop F0`t'_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind8): prop F10_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)

forvalues t=1/9 {
svy, subpop(group_ind8): prop B0`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind8): prop B`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind8): prop F0`t'_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind8): prop F10_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)


*Grade, age and hours breakdowns for OME (group_ind9=1)
forvalues t=1/9 {
svy, subpop(group_ind9): prop B0`t', over(grade)
}
forvalues t=10/62 {
svy, subpop(group_ind9): prop B`t', over(grade)
}
forvalues t=1/9 {
svy, subpop(group_ind9): prop F0`t'_BIS, over(grade)
}
svy, subpop(group_ind9): prop F10_BIS, over(grade)
forvalues t=1/9 {
svy, subpop(group_ind9): prop B0`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind9): prop B`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind9): prop F0`t'_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind9): prop F10_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)

forvalues t=1/9 {
svy, subpop(group_ind9): prop B0`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind9): prop B`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind9): prop F0`t'_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind9): prop F10_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)


*Grade, age and hours breakdowns for PS (group_ind10=1)
forvalues t=1/9 {
svy, subpop(group_ind10): prop B0`t', over(grade)
}
forvalues t=10/62 {
svy, subpop(group_ind10): prop B`t', over(grade)
}
forvalues t=1/9 {
svy, subpop(group_ind10): prop F0`t'_BIS, over(grade)
}
svy, subpop(group_ind10): prop F10_BIS, over(grade)
forvalues t=1/9 {
svy, subpop(group_ind10): prop B0`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind10): prop B`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind10): prop F0`t'_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind10): prop F10_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)

forvalues t=1/9 {
svy, subpop(group_ind10): prop B0`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind10): prop B`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind10): prop F0`t'_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind10): prop F10_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)


*Grade, age and hours breakdowns for ShEx (group_ind11=1)
forvalues t=1/9 {
svy, subpop(group_ind11): prop B0`t', over(grade)
}
forvalues t=10/62 {
svy, subpop(group_ind11): prop B`t', over(grade)
}
forvalues t=1/9 {
svy, subpop(group_ind11): prop F0`t'_BIS, over(grade)
}
svy, subpop(group_ind11): prop F10_BIS, over(grade)
forvalues t=1/9 {
svy, subpop(group_ind11): prop B0`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind11): prop B`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind11): prop F0`t'_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind11): prop F10_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)

forvalues t=1/9 {
svy, subpop(group_ind11): prop B0`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind11): prop B`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind11): prop F0`t'_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind11): prop F10_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)


*Grade, age and hours breakdowns for UKSA (group_ind12=1)
forvalues t=1/9 {
svy, subpop(group_ind12): prop B0`t', over(grade)
}
forvalues t=10/62 {
svy, subpop(group_ind12): prop B`t', over(grade)
}
forvalues t=1/9 {
svy, subpop(group_ind12): prop F0`t'_BIS, over(grade)
}
svy, subpop(group_ind12): prop F10_BIS, over(grade)
forvalues t=1/9 {
svy, subpop(group_ind12): prop B0`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind12): prop B`t', over(age1) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind12): prop F0`t'_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind12): prop F10_BIS, over(age1) stdize(stdgrade) stdweight(stdweight)

forvalues t=1/9 {
svy, subpop(group_ind12): prop B0`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_ind12): prop B`t', over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_ind12): prop F0`t'_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_ind12): prop F10_BIS, over(ftpt) stdize(stdgrade) stdweight(stdweight)



*to generate estimates for themes index scores
*the estimates store code is for putting results in one place, using 'estimates table'
*but for lots of themes in one go it's not necessarily all that convenient
svy: mean ees
*estimates store BIS_ees
svy: mean ees, over(NEWdirectorate)
*estimates store groups_ees

forvalues t=1/15 {
svy: mean Theme`t'
*estimates store BIS_Theme`t'
svy: mean Theme`t', over(NEWdirectorate)
*estimates store groups_Theme`t'
}
*estimates table groups_Theme1 groups_Theme2 groups_Theme3 groups_Theme4

svy: mean ppB09
svy: mean ppB09, over(NEWgroup)
forvalues t=0/8{
svy: mean ppB1`t'
svy: mean ppB1`t', over(NEWgroup)
}

/* For Kunjal Jan 2015
Drilling down to know more about SEO story and how it differs by grade and group
Big interest in directorates too but grade by directorate becomes disclosive in most cases
She has asked for unweighted results - I am reluctantly doing this because they would only be
using the Reporting Tool for this data usually and the focus is on grade by group breakdowns
*/

mean ees, over(grade)
forvalues t=1/12{
mean Theme`t', over(grade)
}

mean ees if grade==1, over(NEWgroup)
forvalues t=1/12{
mean Theme`t' if grade==1, over(NEWgroup)
}

mean ees if grade==2, over(NEWgroup)
forvalues t=1/12{
mean Theme`t' if grade==2, over(NEWgroup)
}

mean ees if grade==3, over(NEWgroup)
forvalues t=1/12{
mean Theme`t' if grade==3, over(NEWgroup)
}

mean ees if grade==4, over(NEWgroup)
forvalues t=1/12{
mean Theme`t' if grade==4, over(NEWgroup)
}

mean ees if grade==5, over(NEWgroup)
forvalues t=1/12{
mean Theme`t' if grade==5, over(NEWgroup)
}

mean ees if grade==6, over(NEWgroup)
forvalues t=1/12{
mean Theme`t' if grade==6, over(NEWgroup)
}

mean ees if grade==7, over(NEWgroup)
forvalues t=1/12{
mean Theme`t' if grade==7, over(NEWgroup)
}

mean ees if grade==8, over(NEWgroup)
forvalues t=1/12{
mean Theme`t' if grade==8, over(NEWgroup)
}

*SEO by directorates for each theme
tab NEWdirectorate if grade==5
mean ees if grade==5, over(NEWdirectorate)
forvalues t=1/12{
mean Theme`t' if grade==5, over(NEWdirectorate)
}

*group scores for each theme
svy: mean ees
svy:mean ees, over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
forvalues t=1/12{
svy: mean Theme`t'
svy: mean Theme`t', over(NEWgroup) stdize(stdgrade) stdweight(stdweight)
}



*For Patrick to add SA to the dashboard for the team meeting
gen SA=0
replace SA=1 if NEWRU==23	/*NEWRU=23 for Statistical Analysis*/

svy, subpop(SA): mean ees, stdize(stdgrade) stdweight(stdweight)
forvalues t=1/12{
svy, subpop(SA): mean Theme`t', stdize(stdgrade) stdweight(stdweight)
}

svy, subpop(SA): mean ees Theme1 Theme2 Theme3 Theme4 Theme5 Theme6 Theme7 Theme8 Theme9 Theme10 Theme11 Theme12, stdize(stdgrade) stdweight(stdweight)
mean ees Theme1 Theme2 Theme3 Theme4 Theme5 Theme6 Theme7 Theme8 Theme9 Theme10 Theme11 Theme12 if SA==1


*for Dorothy Deacon - diversity rates
*using People Survey estimates in the absence of decent quality HR info
gen losbis_dorothy=5
replace losbis_dorothy=1 if H03<4
replace losbis_dorothy=2 if H03==4 | H03==5
replace losbis_dorothy=3 if H03==6
replace losbis_dorothy=4 if H03==7						/*1=less than 3y 2=3-10y 3=10-20y 4=20y+ 5=missing 	*/

gen losjob_dorothy=5
replace losjob_dorothy=1 if H02<3
replace losjob_dorothy=2 if H02==3
replace losjob_dorothy=3 if H02==4
replace losjob_dorothy=4 if H02==5 | H02==6 | H02==7	/*1=less than 1y 2=1-3y 3=3-5y 4=5y+ 5=missing 		*/

gen loscs_dorothy=5
replace loscs_dorothy=1 if H04<5
replace loscs_dorothy=2 if H04==5
replace loscs_dorothy=3 if H04==6
replace loscs_dorothy=4 if H04==7						/*1=less than 5y 2=5-10y 3=10-20y 4=20y+ 5=missing 	*/

label define label_losbis_dorothy 1 "less than 3 years" 2 "3-10 years" 3 "10-20 years" 4 "more than 20 years" 5 "undeclared"
label define label_losjob_dorothy 1 "less than 1 year" 2 "1-3 years" 3 "3-5 years" 4 "more than 5 years" 5 "undeclared"
label define label_loscs_dorothy 1 "less than 5 years" 2 "5-10 years" 3 "10-20 years" 4 "more than 20 years" 5 "undeclared"
label values losbis_dorothy label_losbis_dorothy
label values losjob_dorothy label_losjob_dorothy
label values loscs_dorothy label_loscs_dorothy

svy: prop grade, miss
svy: prop location, miss
svy: prop losjob_dorothy, miss
svy: prop losbis_dorothy, miss
svy: prop loscs_dorothy, miss
svy: prop H05, miss
svy: prop H06, miss
svy: prop J02, miss
svy: prop J03, miss
svy: prop bme2, miss
svy: prop J04, miss
svy: prop J05, miss
svy: prop J06, miss
svy: prop J07, miss
svy: prop J08, miss
svy: prop J01, miss

svy: tab age1 grade, miss
svy: tab location grade, miss
svy: tab sex grade, miss
svy: tab bme2 grade, miss
svy: tab losjob_dorothy grade, miss
svy: tab losbis_dorothy grade, miss
svy: tab loscs_dorothy grade, miss
svy: tab H05 grade, miss
svy: tab ftpt grade, miss
svy: tab disability grade, miss
svy: tab carer grade, miss
svy: tab childcare grade, miss
svy: tab sexuality grade, miss
svy: tab religion1 grade, miss

svy: tab grade location, miss
svy: tab age1 location, miss
svy: tab sex location, miss
svy: tab bme2 location, miss
svy: tab losjob_dorothy location, miss
svy: tab losbis_dorothy location, miss
svy: tab loscs_dorothy location, miss
svy: tab H05 location, miss
svy: tab ftpt location, miss
svy: tab disability location, miss
svy: tab carer location, miss
svy: tab childcare location, miss
svy: tab sexuality location, miss
svy: tab religion1 location, miss

svy: tab grade age1, miss
svy: tab location age1, miss
svy: tab sex age1, miss
svy: tab bme2 age1, miss
svy: tab losjob_dorothy age1, miss
svy: tab losbis_dorothy age1, miss
svy: tab loscs_dorothy age1, miss
svy: tab H05 age1, miss
svy: tab ftpt age1, miss
svy: tab disability age1, miss
svy: tab carer age1, miss
svy: tab childcare age1, miss
svy: tab sexuality age1, miss
svy: tab religion1 age1, miss


*using bme1 for the breakdown for Martin's note to Jeremy Heywood
svy: prop bme1, miss
svy: tab bme1 grade, miss
svy: tab bme1 location, miss
svy: tab bme1 age1, miss


********************************************************************
*moving HE directorate from KI group to PS group, which happened in Feb 2015
*HE directorate corresponds to NEWdirectorate=27
*KI group corresponds to NEWgroup=6
*PS group corresponds to NEWgroup=10
*breakdowns for each question (Bxx Fxx_BIS)
forvalues t=1/9 {
prop B0`t' if NEWgroup==10|NEWdirectorate==27
}
forvalues t=10/62 {
prop B`t' if NEWgroup==10|NEWdirectorate==27
}
forvalues t=1/9 {
prop F0`t'_BIS if NEWgroup==10|NEWdirectorate==27
}
prop F10_BIS if NEWgroup==10|NEWdirectorate==27


forvalues t=1/9 {
prop B0`t' if NEWgroup==6&NEWdirectorate!=27
}
forvalues t=10/62 {
prop B`t' if NEWgroup==6&NEWdirectorate!=27
}
forvalues t=1/9 {
prop F0`t'_BIS if NEWgroup==6&NEWdirectorate!=27
}
prop F10_BIS if NEWgroup==6&NEWdirectorate!=27

*original groups on same basis for comparison
forvalues t=1/9 {
prop B0`t' if NEWgroup==10
}
forvalues t=10/62 {
prop B`t' if NEWgroup==10
}
forvalues t=1/9 {
prop F0`t'_BIS if NEWgroup==10
}
prop F10_BIS if NEWgroup==10


forvalues t=1/9 {
prop B0`t' if NEWgroup==6
}
forvalues t=10/62 {
prop B`t' if NEWgroup==6
}
forvalues t=1/9 {
prop F0`t'_BIS if NEWgroup==6
}
prop F10_BIS if NEWgroup==6
********************************************************************

*for grade breakdowns for KI-HE (Knowledge and Innovation group excluding HE directorate) and PSHE
gen group_indKI_noHE=0
replace group_indKI_noHE=1 if NEWgroup==6&NEWdirectorate!=27
gen group_indPSHE=0
replace group_indPSHE=1 if NEWgroup==10|NEWdirectorate==27

mean ees if group_indKI_noHE==1
mean ees if group_indPSHE==1
forvalues t=1/12{
mean Theme`t' if group_indKI_noHE==1
mean Theme`t' if group_indPSHE==1
}

mean ees if group_indKI_noHE==1, over(grade) 
forvalues t=1/12{
mean Theme`t' if group_indKI_noHE==1, over(grade)
}
mean ees if group_indPSHE==1, over(grade) 
forvalues t=1/12{
mean Theme`t' if group_indPSHE==1, over(grade)
}

*breakdowns for each question (Bxx Fxx_BIS) for the two new groups (after the HE move in Feb 2015) standardised by grade
*this is to update Hiren's visualisation with the new groups
*if we do the grade breakdown in groups we MUST SURPRESS GRADES/LOCATIONS/FTPT DATA WHERE HE HAS FEWER THAN 10 RESPONDENTS OTHERWISE RISK OF DISCLOSURE BY DIFFERENCING OLD GROUPS AND NEW GROUPS
forvalues t=1/9 {
svy, subpop(group_indKI_noHE): prop B0`t', stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_indKI_noHE): prop B`t', stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_indKI_noHE): prop F0`t'_BIS, stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_indKI_noHE): prop F10_BIS, stdize(stdgrade) stdweight(stdweight)

forvalues t=1/9 {
svy, subpop(group_indPSHE): prop B0`t', stdize(stdgrade) stdweight(stdweight)
}
forvalues t=10/62 {
svy, subpop(group_indPSHE): prop B`t', stdize(stdgrade) stdweight(stdweight)
}
forvalues t=1/9 {
svy, subpop(group_indPSHE): prop F0`t'_BIS, stdize(stdgrade) stdweight(stdweight)
}
svy, subpop(group_indPSHE): prop F10_BIS, stdize(stdgrade) stdweight(stdweight)






























