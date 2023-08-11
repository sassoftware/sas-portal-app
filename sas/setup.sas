/*
 *  Common setup script
 *
 *  NOTE: We try to not do anything before we run the customer's usermods file
 *        to allow them to override things, especially the portalAppDir variable, which 
 *        would allow them to change where the rest of the content is picked up from.
 *        This could be used in testing, having multiple instances running, etc.
 *        Thus, this code may not be as efficient as it could be but we want to keep
 *        the processing here to a minimum.
 */

%if (%symexist(setupLoaded)=0) %then %do;
	%macro setupPortalGen;

		/*
		 *  If the user has specified overrides, include them now.
		 */
		%let userSetup=&SYSINCLUDEFILEDIR./setup_usermods.sas;

		%if %sysfunc(fileexist(&userSetup.)) %then %do;  
		  %inc "&userSetup.";
		  %end;

		%global sasDir sasenvDir filesDir jobsDir stepsDir macroDir;

		%let sasDir=&portalAppDir./sas;
		%let sasenvDir=&sasDir./SASEnvironment;
		%let filesDir=&sasenvDir./Files;
		%let jobsDir=&sasenvDir./SASCode/Jobs;
		%let stepsDir=&sasenvDir./SASCode/Steps;
		%let macroDir=&sasenvDir./SASMacro;

		/*
		 *  Create an encoded version of the application location in metadata
		 */

		%global appLocEncoded;

		%let appLocEncoded=%sysfunc(URLencode(&apploc./));

		/*
		 *  Set an indicator that this setup program has already been done
		 */

		%global setupLoaded;
		%let setupLoaded=1;

	%mend;

	%setupPortalGen;

        %end;

