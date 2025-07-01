set more off                             

import excel "C:\document\data.xlsx", sheet("Sheet1") firstrow
			  
*generate city and county id
encode city, generate(city_id)
encode county, generate(county_id)

*taking logs
generate lnGrain= ln(Grain)
generate lnGDP_primary = ln(GDP_primary_LL )
generate lnIncome = ln(Income)

*based on the appendix, we can create the variable "Policytime"
gen treat=1 if Policytime>0
replace treat=0 if Policytime==.

gen after=1 if year-Policytime>=0 & terat==1
replace after=0 if after==.

gen program= treat*after


*create Pest dummy 
gen Pest=0 if province=="甘肃省"
replace Pest=0 if province=="海南省"
replace Pest=0 if province=="合肥省"
replace Pest=0 if province=="内蒙古自治区"
replace Pest=0 if province=="宁夏回族自治区"
replace Pest=0 if province=="山西省"
replace Pest=0 if province=="新疆维吾尔自治区"
replace Pest=1 if Pest==.


*Table A1
sum Grain GDP_primary Income Program Pest

*Table 1
ttest Grain,by(treat)
ttest GDP_primary,by(treat)
ttest Income,by(treat)
ttest Program,by(treat)
ttest Pest,by(treat)


*Table 2
reghdfe lnGrain Program, absorb(county_id i.city_id#year) vce(cluster county_id) 

reghdfe lnGDP_primary Program, absorb(county_id i.city_id#year) vce(cluster county_id) 

reghdfe lnIncome Program, absorb(county_id i.city_id#year) vce(cluster county_id) 


*Figure 3- Event Study
gen timeToTreat=year-policytime
replace timeToTreat=. if treat==0

eventdd lnGrain, timevar(timeToTreat) method(hdfe, absorb($fe3 county_id city_id#year) vce(cluster county_id)) graph_op(ytitle("lnGrain")) leads(4) lags(4) inrange
estat eventdd


*Table 3- Panel A
reghdfe lnGrain Program if Pest==1, absorb(county_id i.city_id#year) vce(cluster county_id) 

reghdfe lnGDP_primary Program if Pest==1, absorb(county_id i.city_id#year) vce(cluster county_id) 

reghdfe lnIncome Program if Pest==1, absorb(county_id i.city_id#year) vce(cluster county_id) 


*Table 3- Panel B
reghdfe lnGrain Program if Pest==0, absorb(county_id i.city_id#year) vce(cluster county_id) 

reghdfe lnGDP_primary Program if Pest==0, absorb(county_id i.city_id#year) vce(cluster county_id) 

reghdfe lnIncome Program if Pest==0, absorb(county_id i.city_id#year) vce(cluster county_id) 