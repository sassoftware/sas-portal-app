%macro objectExists(type=,name=,existsVar=);

%global &existsVar.;

data _null_;
  length uri $256;
  length rc 8;
  
  call missing(uri);
  search=catt("omsobj:","&type","?@Name='","&name.","'");

  rc=metadata_getnobj(search,1,uri);

  if (rc>0) then do;
     call symputx("&existsvar.",1);
     end;
  else do;
     call symputx("&existsVar.",0);
     end;
  run;
  
%mend;
