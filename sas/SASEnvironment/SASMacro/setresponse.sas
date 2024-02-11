%macro setResponse(responseRC);

%if (&responseRC.=0) %then %do;

    data _null_;
      file _webout;
      put "<p>Succeeded</p>";
   run;

%end;
%else %do;

    data _null_;
      file _webout;
      put "<p>Failed, rc=&responseRC.</p>";
   run;
%end;

%mend;
