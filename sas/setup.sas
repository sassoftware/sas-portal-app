/*
 *  If the user has specified overrides, include them now.
 */

%let userSetup=&SYSINCLUDEFILEDIR./setup_usermods.sas;

%if %sysfunc(fileexist(&userSetup.)) %then %do;  
  %inc "&userSetup.";
  %end;

%let sasDir=&portalAppDir./sas;
%let sasenvDir=&sasDir./SASEnvironment;
%let filesDir=&sasenvDir./Files;
%let jobsDir=&sasenvDir./SASCode/Jobs;
%let stepsDir=&sasenvDir./SASCode/Steps;

/*
 *  Create an encoded version of the application location in metadata
 */

%let appLocEncoded=%sysfunc(URLencode(&apploc./));

