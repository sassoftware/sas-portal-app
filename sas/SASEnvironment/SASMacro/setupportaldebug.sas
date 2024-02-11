/*
 *  This macro is intended to turn on some debugging aids
 *  The intent is that in normal processing, this code doesn't do 
 *  anything substantial as to not slow down processing, but providing
 *  a centralized space for debugging info to be setup if need be.
 */

%macro setupPortalDebug(entryPoint);

   %if (%symexist(portaldebug)) %then %do;

       /*
        *  See what users it is turned on for 
        */

       /* Portaldebug can be set to 1, meaning all users, or a list of users that should have their
        * requests debugged.
        */

       %if (("&portalDebug."="1") or (%index(&portalDebug.,&_metauser.))) %then %do;

           %if (%symexist(portaldebugdir)) %then %do;

               %let debugLogsDir=&portalDebugDir.;

               %end;
           %else %do;

               %let debugLogsDir=StoredProcessServer/Logs;

               %end;

           %let debugLog=&debugLogsDir./debug_&_metauser._&entrypoint._&syshostname..log;
           %let debugLst=&debugLogsDir./debug_&_metauser._&entrypoint._&syshostname..lst;

           filename prtllog "&debugLog.";
           proc printto log=prtllog new;
           run;

           filename prtllst "&debugLst.";
           proc printto print=prtllst new;
           run;

           options mprint mlogic;

           %if (%symexist(showmacros)) %then %do;

               %let debugLst=&debugLogsDir./debug_&_metauser._&entrypoint._&syshostname..lst;

               filename prtllog "&debugLog.";
               proc printto log=prtllog new;
               run;

               proc print data=sashelp.vmacro;
               run;
               %end;

           %if (%symexist(showxml)) %then %do;
               %let saveShowXML=&showxml.;
               %let showXMLSaved=1;
               %end;
           %else %do;
               %global showxml;
               %end;

           %let showxml=1;

           %end;

       %end;

%mend;

