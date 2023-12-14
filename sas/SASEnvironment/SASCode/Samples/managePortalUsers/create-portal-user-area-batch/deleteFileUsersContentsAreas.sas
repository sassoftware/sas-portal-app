/* 
 *  This program will read the list of users from a file and create the 
 *  portal content area for each one.
 *
 *  NOTE: This program must be executed as an administrator who has the following
 *        permissions:
 *        - is able to list the registered users on the system
 *        - can create subtrees under the SAS Portal Application Tree tree
 *        - can read existing subtrees under the SAS Portal Application Tree tree (to avoid creating duplicate information)
 */

%if (%symexist(peopleFile)=0) %then %do;
   %let peopleFile=Data/people.txt;
   %end;

/*
 *  Build up the program statements to register these users for later execution.
 */

filename tmpcode temp encoding="utf-8";

filename people "&peopleFile." encoding="utf-8";
data _null_;

  infile people truncover;
  
  length name $256;
  input name $256.;
putlog name=;
  
  file tmpcode;
  length codeline $ 1024;

  if _n_=1 then do;
     codeline='%macro deletePortalUsers;';
     put codeline;
     end;
     
  codeline=cats('%put Processing User:',name,';');
  put codeline;
  codeline=cats('%deletePortalUser(name=',name,',rc=deletePortalUserRC);');
  put codeline;
  put '%if (&deletePortalUserRC. = 0) %then %do;';
  put '%let messageLevel=NOTE;';
  put '%end;';
  put '%else %do;';
  put '%let messageLevel=ERROR;';
  put '%end;';
  
  codeline=cats('%put &messageLevel.: deletePortalUser(',name,') returned return code=&deletePortalUserRC.;');
  put codeline;
  
     
run;
data _null_;  
  file tmpcode mod;
  put '%mend;';
  put '%deletePortalUsers;';
run;

/* 
 *  Now run the code just generated.
 */

%inc tmpCode / source2;

/*
 *  Final Cleanup
 */

filename tmpcode;
