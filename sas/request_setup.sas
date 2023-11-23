/*
 *  Request setup script
 *
 *  This script is run on each request to set any values that may be unique to this
 *  request.
 *
 *  Please do not modify this script! Insted, put your overrides into request_setup_usermods.sas
 *  in this same directory (using the request_setup_usermods.sas.template as a guide).
 */

%if (%symexist(setupLoaded)=0) %then %do;
   %macro setupPortalGen;

       %let requestOverrides=&sasDir./request_setup_usermods.sas;

       %if %sysfunc(fileexist(&requestOverrides.)) %then %do;
           %inc "&requestOverrides.";
           %end;

       /*  
        *  Check for any localizations based on this specific user's locale
        */

       %if (%symexist(_userlocale)=0) %then %do;
       
           %let _userlocale=en;
           %end;
       /* Find the correct localization files to use */
      
       %getLocalization;
       
       /*
        *  Set an indicator that this setup program has already been done
        */

       %global setupLoaded;
       %let setupLoaded=1;

   %mend;

   %setupPortalGen;

   %end;

