%macro cleanupPortalDebug;

   %if (%symexist(portaldebug)) %then %do;

           %if (%sysfunc(fileref(prtllst))<=0) %then %do;
               proc printto print=print; run;
               filename prtllst;
               %end;

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

