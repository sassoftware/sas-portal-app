%macro cleanupPortalDebug;

   %if (%symexist(portaldebug)) %then %do;

           proc printto log=log; run;

           filename prtllog;

           options nomprint nomlogic;

           %if (%symexist(showxmlSaved)) %then %do;
               %let showXML=&saveXMLSaved.;
               %symdel showXMLSaved;
               %end;
           %else %do;
               %symdel showxml;
               %end;


       %end;

%mend;

