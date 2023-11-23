/*
 *  Common server initialization script
 *
 *  This script should be linked into the autoexec_usermods of the server context.
 *
 */

        /*  The root dir is the root of the server context where this
            code has been installed/linked
         */

        %global portalAppDir;
        %let portalAppDir=./SASPortalApp;

        %global sasDir sasenvDir filesDir jobsDir stepsDir macroDir;

        %let sasDir=&portalAppDir./sas;
        %let sasenvDir=&sasDir./SASEnvironment;
        %let filesDir=&sasenvDir./Files;
        %let jobsDir=&sasenvDir./SASCode/Jobs;
        %let stepsDir=&sasenvDir./SASCode/Steps;
        %let macroDir=&sasenvDir./SASMacro;

        /*
         *  Load the default localization (English)
         */

        %let localizationDir=&filesDir./localization;
        %let englishStrings=&localizationDir./portalstrings_en_US.sas;

        %inc "&englishStrings.";

        /*
         *  Add any autocall macros
         */

        options insert=(sasautos="&macroDir.");

        /*
         *  Include any overrides the admin may have defined.
         *  1) those that are shared across all usage/linkage to the repo directory
         *  2) those that are unique to a usage/linkage to the repo directory
         *
         *  Note: We include these at this point in the process so that the 
         *  admin has the ability to link to different locations in the SAS Content
         *  (via overriding apploc macro variable) or to set a sastheme for each
         *  context.
         */

        %let sharedOverrides=&sasDir./autoexec_usermods.sas;

        %if %sysfunc(fileexist(&sharedOverrides.)) %then %do;
            %inc "&sharedOverrides.";
            %end;

        %let contextOverrides=./SASPortalApp_autoexec_usermods.sas;

        %if %sysfunc(fileexist(&contextOverrides.)) %then %do;
            %inc "&contextOverrides.";
            %end;

        /*
         *  Create an encoded version of the application location in metadata
         */

        %global appLocEncoded;

        %if (%SYMEXIST(apploc)=0) %then %do;
            %global apploc;

            %let apploc=/System/Applications/SAS Portal App;

            %end;

        %let appLocEncoded=%sysfunc(URLencode(&apploc./));

        %if (%SYMEXIST(sastheme)=0) %then %do;
            /*
             *  If a Default Theme was not set in the usermods file, set it now.
             */
            %global sastheme;
            %let sastheme=default;
            %end;

