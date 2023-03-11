clear all
set more off

pause off
 
/*1. Set root path for the project */ /*Change to the root in your computer */
global main "C:/Users/steve/OneDrive/Winter 2023/+Metrics 2 - Applied Microeconometrics/Homework/Applied Microeconometrics/HW3/q1/berkouwer_dean_replication"

/*2. Create folders */
cap mkdir "${main}/Data/Med/"
cap mkdir "${main}/Data/Clean/"
cap mkdir "${main}/Results/Figures/"
cap mkdir "${main}/Results/Tables/"

/*3. Install Stata packages */
sysdir set PLUS  "${main}/Packages/"

/*4. Run .do files */
do "${main}/Do/CleanPilot.do"
/* do "${main}/Do/MedV1.do" */ /*This code does not run. */
/* do "${main}/Do/CleanSMSpreV1.do" */ /*This code does not run, as it relies on PII that is not available in this public repository. */
/* do "${main}/Do/CleanV1.do" */ /*The output of this script is not used because it does not replicate values of randomized variables due to edits in the original code at the time of the experiment. Randomization occured in batches over several weeks, and the code was edited by the field team every week, so the earlier randomizations cannot be replicated. */
pause
do "${main}/Do/CleanV2.do"
/* do "${main}/Do/CleanAllSMS - 1.do" */   /*This code does not run, as it relies on PII that is not available in this public repository. */
pause
do "${main}/Do/CleanAllSMS - 2.do" 
pause
do "${main}/Do/CleanV3.do"
pause
do "${main}/Do/AnalysisData.do"
pause
do "${main}/Do/PrepForMLTrain.do"
pause
do "${main}/Do/CleanE1.do"
/*do "${main}/Do/CleanSMSdataE1 - 1.do"*/  /*This code does not run, as it relies on PII that is not available in this public repository. */
pause
do "${main}/Do/CleanSMSdataE1 - 2.do"
pause
do "${main}/Do/AnalysisDataE1.do"
/*do "${main}/Do/PaymentsData.do"*/  /*This code does not run, as it relies on PII that is not available in this public repository. */
pause
do "${main}/Do/Tables.do"
pause
do "${main}/Do/Figures.do"
pause
do "${main}/Do/Facts.do"
