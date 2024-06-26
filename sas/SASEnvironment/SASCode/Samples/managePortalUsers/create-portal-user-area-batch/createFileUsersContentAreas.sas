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

%let peopleFile=Data/people.txt;

/*
 *  Build up the program statements to register these users for later execution.
 */

filename tmpcode temp encoding="utf-8";

data _null_;

  infile peopleFile encoding="utf-8";
  
  length name $256;
  input name $;
putlog name=;
  
  file tmpcode;
  length codeline $ 1024;

  if _n_=1 then do;
     codeline='%macro registerPortalUsers;';
     put codeline;
     end;
     
  codeline=cats('%put Processing User:',name,';');
  put codeline;
  codeline=cats('%createPortalUser(name=',name,',rc=createPortalUserRC);');
  put codeline;
  codeline=cats('%put createPortalUser returned return code=',"&createPortalUserRC.",';');
  put codeline;
     
run;
data _null_;  
  file tmpcode mod;
  put '%mend;';
  put '%registerPortalUsers;';
run;

/* 
 *  Now run the code just generated.
 */

%inc tmpCode / source2;

/*
 *  Final Cleanup
 */

filename tmpcode;
