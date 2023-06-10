/* loding the dataset */
libname ess "/home/u62972865/logistic regression";

filename csvfile "/home/u62972865/logistic regression/ESS10.csv";

/*Import the csv file*/
proc import datafile=csvfile
    dbms=csv
    out=ess_1
    replace; 
run;

/* PROC CONTENTS data=ess_1; */
/* RUN; */

data ess_1; 
   set ess_1; 
   
   /* Create source_income variable from hincsrca */
   if hincsrca in (1) then source_income = 'Labour Income';
   else if hincsrca in (2, 7) then source_income = 'Capital Income';
   else if hincsrca in (4, 5, 6) then source_income = 'Social Grants/Benefit Income';
   else if hincsrca in (3, 8) then source_income = 'Other Income (inclu farming)';
   
/*    Create total_netincome variable from hinctnta */
/*    if hinctnta in (1, 2, 3) then total_netincome = 'Low Income'; */
/*    else if hinctnta in (4, 5, 6, 7) then total_netincome = 'Medium Income'; */
/*    else if hinctnta in (8, 9, 10) then total_netincome = 'High Income'; */
run;



/*Data Preprocessing*/
PROC FORMAT;
   value $cntry
   'GB' = 'United Kingdom'  
     'BE' = 'Belgium'  
     'DE' = 'Germany'  
     'EE' = 'Estonia'  
     'IE' = 'Ireland'  
     'ME' = 'Montenegro'  
     'SE' = 'Sweden'  
     'BG' = 'Bulgaria'  
     'CH' = 'Switzerland'  
     'FI' = 'Finland'  
     'SI' = 'Slovenia'  
     'DK' = 'Denmark'  
     'SK' = 'Slovakia'  
     'NL' = 'Netherlands'  
     'PL' = 'Poland'  
     'NO' = 'Norway'  
     'FR' = 'France'  
     'HR' = 'Croatia'  
     'ES' = 'Spain'  
     'IS' = 'Iceland'  
     'RS' = 'Serbia'  
     'AT' = 'Austria'  
     'IT' = 'Italy'  
     'LT' = 'Lithuania'  
     'PT' = 'Portugal'  
     'HU' = 'Hungary'  
     'LV' = 'Latvia'  
     'CY' = 'Cyprus' 
     'CZ' = 'Czechia' ;
     
   value stfgov
      0 = 'Extremely dissatisfied'  
      1 = '1'  
      2 = '2'  
      3 = '3'  
      4 = '4'  
      5 = '5'  
      6 = '6'  
      7 = '7'  
      8 = '8'  
      9 = '9'  
      10 = 'Extremely satisfied'  
      77 = 'Other'  
      88 = 'Other'  
      99 = 'Other';
   
   
/*    value hinctnta */
/*       1 = 'J - 1st decile'   */
/*       2 = 'R - 2nd decile'   */
/*       3 = 'C - 3rd decile'   */
/*       4 = 'M - 4th decile'   */
/*       5 = 'F - 5th decile'   */
/*       6 = 'S - 6th decile'   */
/*       7 = 'K - 7th decile'   */
/*       8 = 'P - 8th decile'   */
/*       9 = 'D - 9th decile'   */
/*       10 = 'H - 10th decile'   */
/*       77 = 'Refusal' .b = 'Refusal'   */
/*       88 = 'Don''t know' .c = 'Don''t know'   */
/*       99 = 'No answer' .d = 'No answer' ; */
/*    value total_netincome */
/*       1 = "Low income" */
/*       2 = "Medium income" */
/*       3 = "High income"; */
      
   value agea
      999 = 'Not available' .d = 'Not available' ; 
   
   value hincsrca
      1 = 'Wages or salaries'  
      2 = 'Income from self-employment (excluding farming)'  
      3 = 'Income from farming'  
      4 = 'Pensions'  
      5 = 'Unemployment/redundancy benefit'  
      6 = 'Any other social benefits or grants'  
      7 = 'Income from investments, savings etc.'  
      8 = 'Income from other sources'  
      77 = 'Refusal' .b = 'Refusal'  
      88 = 'Don''t know' .c = 'Don''t know'  
      99 = 'No answer' .d = 'No answer' ;
    value source_income
      1 = 'Labour Income'
      2 = 'Capital Income'
      3 = 'Social Grants/Benefit Income'
      4 = 'Other Income (inclu farming)';
   
   value stfhlth
      0 = 'Extremely dissatisfied'  
      1 = '1'  
      2 = '2'  
      3 = '3'  
      4 = '4'  
      5 = '5'  
      6 = '6'  
      7 = '7'  
      8 = '8'  
      9 = '9'  
      10 = 'Extremely satisfied'  
      77 = 'Other'  
      88 = 'Other'  
      99 = 'Other';

   value stfedu
      0 = 'Extremely dissatisfied'  
      1 = '1'  
      2 = '2'  
      3 = '3'  
      4 = '4'  
      5 = '5'  
      6 = '6'  
      7 = '7'  
      8 = '8'  
      9 = '9'  
      10 = 'Extremely satisfied'  
      77 = 'Other'  
      88 = 'Other'  
      99 = 'Other';
   
   value stfeco
      0 = 'Extremely dissatisfied'  
      1 = '1'  
      2 = '2'  
      3 = '3'  
      4 = '4'  
      5 = '5'  
      6 = '6'  
      7 = '7'  
      8 = '8'  
      9 = '9'  
      10 = 'Extremely satisfied'  
      77 = 'Other'  
      88 = 'Other'  
      99 = 'Other';
run;


*Check the distribution of the target variable;
*We have 1.61% of Other Income category within this variable
*Since this category has no information, we may decide to drop it later;

proc freq data=ess_1;
 tables hincsrca / out=freq_y;
run;

proc sgplot data=ess_1;
 vbar hincsrca;
run;



/*Data preprocessing*/
/*1)Select only variables we will use for analysis*/
data ess_2;
set ess_1;
format cntry source_income hincsrca stfhlth stfedu stfeco agea stfgov;
keep cntry source_income hincsrca stfhlth stfedu stfeco agea stfgov;
run;


*Check the distribution of explanatory variables which require grouping levels;

proc freq data=ess_2;
 tables stfhlth / out=freq_stfhlth;
run;
proc sgplot data=ess_2;
 vbar stfhlth;
run;

proc freq data=ess_2;
 tables stfedu / out=freq_stfedu;
run;
proc sgplot data=ess_2;
 vbar stfedu;
run;

proc freq data=ess_2;
 tables stfeco / out=freq_stfeco;
run;
proc sgplot data=ess_2;
 vbar stfeco;
run;

/* proc freq data=ess_2; */
/*  tables total_netincome / out=freq_total_netincome; */
/* run; */
/* proc sgplot data=ess_2; */
/*  vbar total_netincome; */
/* run; */

proc freq data=ess_2;
 tables source_income / out=freq_source_income;
run;
proc sgplot data=ess_2;
 vbar source_income;
run;

proc freq data=ess_2;
 tables agea / out=freq_agea;
run;
proc sgplot data=ess_2;
 vbar agea;
run;

proc freq data=ess_2;
 tables stfgov / out=freq_stfgov;
run;
proc sgplot data=ess_2;
 vbar stfgov;
run;


/* proc freq data=ess_2; */
/*  tables hinctnta / out=freq_hinctnta; */
/* run; */
/* proc sgplot data=ess_2; */
/*  vbar hinctnta; */
run;

/*After checking the distribution of those two variables,  
we decided to group the levels inside those variables into 3 group.
Low satisfaction(1) / Mid satisfaction(2) / High satisfaction(3)
we will transform it after checking missing data pattern*/

*preprocessing required to check the missing data pattern;
data ess_22;
set ess_2;
format Y source_income.;
if ^missing(hincsrca) then do;
    if hincsrca=1 then Y=1;
    else if hincsrca in (2, 7) then Y=2;
    else if hincsrca in (4, 5, 6) then Y=3;
    else if hincsrca in (3, 8) then Y=4;
end;
else if missing(hincsrca) or hincsrca>8 then Y=.;
/* if ^missing(hinctnta) then do; */
/*     if 1<=hinctnta<=3 then inc=1; */
/*     else if 4<=hinctnta<=7 then inc=2; */
/*     else if 8<=hinctnta<=10 then inc=3; */
/* end; */
/* else if missing(hinctnta) or hinctnta>10 then inc=.; */
if ^missing(stfhlth) then do;
	if 0<=stfhlth<=3 then _stfhlth=1;
	else if 4<=stfhlth<=6 then _stfhlth=2;
	else if 7<=stfhlth<=10 then _stfhlth=3;
end;
else if missing(stfhlth) or stfhlth>10 then _stfhlth=.;
if ^missing(stfedu) then do;
	if 0<=stfedu<=3 then _stfedu=1;
	else if 4<=stfedu<=6 then _stfedu=2;
	else if 7<=stfedu<=10 then _stfedu=3;
end;
else if missing(stfedu) or stfedu>10 then _stfedu=.;
if ^missing(stfeco) then do;
	if 0<=stfeco<=3 then _stfeco=1;
	else if 4<=stfeco<=6 then _stfeco=2;
	else if 7<=stfeco<=10 then _stfeco=3;
end;
else if missing(stfeco) or stfeco>10 then _stfeco=.;
if ^missing(agea) then do;
	if 0<=agea<=24 then _agea=1;
	else if 25<=agea<=54 then _agea=2;
	else if 55<=agea then _agea=3;
end;
else if missing(agea) then _agea=.;
if ^missing(stfgov) then do;
	if 0<=stfgov<=3 then _stfgov=1;
	else if 4<=stfgov<=6 then _stfgov=2;
	else if 7<=stfgov<=10 then _stfgov=3;
end;
else if missing(stfgov) or stfgov>10 then _stfgov=.;
run;

/*2)Drop not useful, not meaningful category of the variables 
(Refusal, Don't know, No answer, Not available, Not applicable)
Most of them only accounts less than 5% for each variable (except for HINCTNTA)*/

/*Before dropping those missing values, Inspect the missing data pattern*/
proc mi data=ess_22 nimpute=0;
 var Y _stfhlth _stfedu _stfeco _agea _stfgov;
run;


data ess_3;
set ess_2;
if hincsrca in (77,88,99) then delete;
if stfhlth in (77,88,99) then delete; 
if stfedu in (77,88,99) then delete;
if stfeco in (77,88,99) then delete;
if agea = 999 then delete;
if stfgov in (77,88,99) then delete;
run;

/*3) Final Missing Value Check (Count)*/
proc means data=ess_3 n nmiss;
var hincsrca stfhlth stfedu stfeco agea stfgov;
run;

/*4) Check some variable's distribution again 
(since we dropped some levels, categories of some variables)*/
proc freq data=ess_3;
    table hincsrca;
run;
proc sgplot data=ess_3;
 vbar hincsrca;
run;

proc freq data=ess_3;
 tables stfhlth / out=freq_stfhlth;
run;
proc sgplot data=ess_3;
 vbar stfhlth;
run;

proc freq data=ess_3;
 tables stfedu / out=freq_stfedu;
run;
proc sgplot data=ess_3;
 vbar stfedu;
run;

proc freq data=ess_3;
 tables stfeco / out=freq_stfeco;
run;
proc sgplot data=ess_3;
 vbar stfeco;
run;

proc freq data=ess_3;
 tables agea / out=freq_agea;
run;
proc sgplot data=ess_3;
 vbar agea;
run;

proc freq data=ess_3;
 tables stfgov / out=freq_stfgov;
run;
proc sgplot data=ess_3;
 vbar stfgov;
run;

/*5)Grouping levels(categories) of target variable and some explanatory variables which are required*/

/*Grouped categories in the target variable hincsrca:
1 = Labour Income
2 = Capital Income
3 = Social Grants/Benefit Income
4 = Other Income (including farming)*/

/*Grouped categories in the stfeco, stfgov
1 = Low satisfaction
2 = Medium satisfaction
3 = High satisfaction*/

data ess_4 (drop=hincsrca);
set ess_3;
if hincsrca=1 then Y=1;
else if hincsrca in (2, 7) then Y=2;
else if hincsrca in (4, 5, 6) then Y=3;
else if hincsrca in (3, 8) then Y=4;
else Y=.;

if 0<=stfeco<=3 then stfeco=1;
else if 4<=stfeco<=6 then stfeco=2;
else if 7<=stfeco<=10 then stfeco=3;
else stfeco=.;

if 0<=stfhlth<=3 then stfhlth=1;
else if 4<=stfhlth<=6 then stfhlth=2;
else if 7<=stfhlth<=10 then stfhlth=3;
else stfhlth=.;

if 0<=stfgov<=3 then stfgov=1;
else if 4<=stfgov<=6 then stfgov=2;
else if 7<=stfgov<=10 then stfgov=3;
else stfgov=.;

if 0<=stfedu<=3 then stfedu=1;
else if 4<=stfedu<=6 then stfedu=2;
else if 7<=stfedu<=10 then stfedu=3;
else stfedu=.;
run;


/*6)EDA*/
/*6-1) Check the distribution of all variables using freq and sgplot (Univariate EDA)*/
/*used this same code for each variable*/
/*check the distribution after the previous grouping preprocess*/
proc freq data=ess_4;
    table Y;
run;
proc sgplot data=ess_4;
 vbar Y;
run;

proc freq data=ess_4;
    table stfhlth;
run;
proc sgplot data=ess_4;
 vbar stfhlth;
run;

proc freq data=ess_4;
    table stfedu;
run;
proc sgplot data=ess_4;
 vbar stfedu;
run;

proc freq data=ess_4;
    table stfeco;
run;
proc sgplot data=ess_4;
 vbar stfeco;
run;

proc freq data=ess_4;
    table agea;
run;
proc sgplot data=ess_4;
 vbar agea;
run;

proc freq data=ess_4;
    table stfgov;
run;
proc sgplot data=ess_4;
 vbar stfgov;
run;


/*6-2) Discriminatory Performance Analysis*/ 
/*6-2.1) Categorical variables*/
%macro Frequency(Var);
    proc freq data=ess_4;
        tables &Var.*Y;
        ods output CrossTabFreqs=pct01;
    run;
    proc sgplot data=pct01(where=(^missing(RowPercent)));
        vbar &Var. / group=Y groupdisplay=cluster response=RowPercent datalabel;
    run;
%mend;
%Frequency(stfhlth);
%Frequency(stfedu);
%Frequency(stfeco);
%Frequency(stfgov);

/*6-2.2) Continuous(numeric) variables*/
*Continuous predictors;
%macro Continuous(Var);
    proc sgplot data=ess_4; 
    vbar &Var. / group=Y;
    run;
%mend;
%Continuous(agea);


/*6-2.3) EDA by our main X variables stfhlth, stfedu, stfeco, stfgov (JUST TO CHECK)*/
%macro Frequency(Var, GroupVar);
	proc freq data=ess_4;
		tables &Var.*&GroupVar;
		ods output CrossTabFreqs=pct01;
	run;
	proc sgplot data=pct01(where=(^missing(RowPercent)));
		vbar &Var. / group=&GroupVar groupdisplay=cluster response=RowPercent datalabel;
	run;
%mend;

/* Use the macro for each of main explanatory variables */
%Frequency(stfhlth, stfeco);
%Frequency(stfhlth, stfedu);
%Frequency(stfhlth, stfhlth);
%Frequency(stfhlth, stfgov);

%Frequency(stfedu, stfeco);
%Frequency(stfedu, stfedu);
%Frequency(stfedu, stfhlth);
%Frequency(stfedu, stfgov);

%Frequency(stfeco, stfeco);
%Frequency(stfeco, stfedu);
%Frequency(stfeco, stfhlth);
%Frequency(stfeco, stfgov);

%Frequency(stfgov, stfeco);
%Frequency(stfgov, stfedu);
%Frequency(stfgov, stfhlth);
%Frequency(stfgov, stfgov);

%macro Continuous(Var, GroupVar);
	proc sgplot data=ess_4; 
	vbar &Var. / group=&GroupVar;
	run;
%mend;

/* Use the macro for each of main explanatory variables with the continuous variables */
%Continuous(agea, stfeco);
%Continuous(agea, stfedu);
%Continuous(agea, stfhlth);
%Continuous(agea, stfgov);


/*7) Multicollinearity Check*/
/*Tried to do it in SAS code as below, but we did in Python (please refer to Appendix in our report)*/
/*Correlation matrix numerical variables*/
proc corr data=ess_4;
    var agea stfhlth stfedu stfeco stfgov;
run;

/*Chi-square test categorical variables (not sure)*/
proc freq data=ess_4;
    tables stfhlth*stfedu*stfeco*stfgov / chisq;
run;

/* Export our final dataset into csv to use it in Python*/
proc export data=ess_4
            outfile=_dataout
            dbms=csv replace;
run;

%let _DATAOUT_MIME_TYPE=text/csv;
%let _DATAOUT_NAME=ess_final.csv;

/*8) Logistic Regression - Multinomial model*/
*Variable selection procedure for our second multinomial LR model (STEPWISE);
proc logistic data=ess_4;
	class stfhlth (param=ref ref='1') stfedu (param=ref ref='2')
	stfeco (param=ref ref='2') stfgov (param=ref ref='2');
	model Y (ref='1') = stfhlth stfedu stfeco stfgov agea /
	link=glogit selection=stepwise expb clodds=pl lackfit rsq ctable aggregate scale=none;
	output out=out2 predicted=p;
	ods output Classification=c02;
run;

/*Logistic Regression - Multinomial model with Full Variables based on Stepwise result*/
/*Since we didn't need to drop any variables, the result is same as the first one*/
proc logistic data=ess_4 plots(only)=(effect oddsratio roc);
class stfhlth (param=ref ref='1') stfedu (param=ref ref='1') 
stfeco (param=ref ref='1');
model Y (ref='1') = stfhlth stfedu stfeco agea / 
link=glogit corrb expb lackfit rsq ctable aggregate scale=none;
output out=out predicted=p;
ods output Classification=c01;
run;


proc sgplot data=out1;
scatter x=stfeco y=p / group=_LEVEL_;
run;

/*1. Divide data into different age groups*/
data ess_young;
    set ess_4;
    where agea between 18 and 30;
run;

data ess_middle;
    set ess_4;
    where agea between 31 and 50;
run;

data ess_senior;
    set ess_4;
    where agea between 51 and 65;
run;

data ess_old;
    set ess_4;
    where agea > 65;
run;

/*2. Apply logistic regression models to each age group*/
*Young age group (18-30);
proc logistic data=ess_young;
    class stfeco (param=ref ref='1') stfhlth (param=ref ref='1') 
    stfedu (param=ref ref='1');
    model Y (ref='1') = stfeco stfhlth stfedu /
    link=glogit selection=stepwise expb clodds=pl lackfit rsq ctable aggregate scale=none;
    output out=out_young predicted=p;
    ods output Classification=c_young;
run;

*Middle age group (31-50);
proc logistic data=ess_middle;
    class stfeco (param=ref ref='1') stfhlth (param=ref ref='1') 
    stfedu (param=ref ref='1');
    model Y (ref='1') = stfeco stfhlth stfedu /
    link=glogit selection=stepwise expb clodds=pl lackfit rsq ctable aggregate scale=none;
    output out=out_middle predicted=p;
    ods output Classification=c_middle;
run;

*Senior age group (51-65);
proc logistic data=ess_senior;
    class stfeco (param=ref ref='1') stfhlth (param=ref ref='1') 
    stfedu (param=ref ref='1');
    model Y (ref='1') = stfeco stfhlth stfedu /
    link=glogit selection=stepwise expb clodds=pl lackfit rsq ctable aggregate scale=none;
    output out=out_senior predicted=p;
    ods output Classification=c_senior;
run;

*Old age group (Above 65);
proc logistic data=ess_old;
    class stfeco (param=ref ref='1') stfhlth (param=ref ref='1') 
    stfedu (param=ref ref='1');
    model Y (ref='1') = stfeco stfhlth stfedu /
    link=glogit selection=stepwise expb clodds=pl lackfit rsq ctable aggregate scale=none;
    output out=out_old predicted=p;
    ods output Classification=c_old;
run;






