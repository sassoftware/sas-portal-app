%macro objectExists(type=,name=,existsVar=,filter=,countVar=);

%global &existsVar.;

data _null_;
  length uri $256;
  length rc 8;
  
  call missing(uri);
  
  %if  ("&name."="" and "&filter."="") %then %do;
  
       %end;
       
  %else %if ("&filter."="") %then %do;
     search=catt("omsobj:","&type","?@Name='","&name.","'");
     %end;
  %else %do;
 
     search=catt("omsobj:","&type","?&filter.");
  
     %end;
  
  rc=metadata_getnobj(search,1,uri);
  if (rc>0) then do;
     call symputx("&existsvar.",1);
     
     %if ( "&countVar" ne "") %then %do;
 
         call symputx("&countVar.",rc);
         
     %end;

     end;
  else do;
     call symputx("&existsVar.",0);
     
     %if ( "&countVar" ne "") %then %do;
         %global &countvar.;
         call symputx("&countVar.",0);
         %end;
         
     end;
  run;
  
%mend;
