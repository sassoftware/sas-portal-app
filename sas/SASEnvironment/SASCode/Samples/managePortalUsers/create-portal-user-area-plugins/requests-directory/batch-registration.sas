/*
 *  Loop over the files in the user-registry-requests directory and 
 *  create the portal content area for each user named in those files.
 *
 *  The metadata user who is active when running this code must have
 *  the ability to create new areas (ie. trees) under the Portal Application Tree
 *  and must have the ability to see the existing trees (even those associated to users).
 */

%let requestDirectory=Data/user-registry-requests;

filename tmpcode temp;

/*
 *  Get all of the files in the registry requests directory and process them
 *  Build up the program statements to register these users for later execution.
 */
data _null_;
  length memname $1024;
  
  file tmpcode;
  length codeline $ 1024;

  if _n_=1 then do;
     codeline='%macro registerPortalUsers;';
     put codeline;
     end;
     
  memname=" ";
  infile "&requestDirectory." memvar=memname end=done;
  if (memname ne '') then do;
 
        putlog 'Processing file' memname=;
	    do while (^done);
	    
	     input;
	     codeline=cats('%put Processing User:',_infile_,';');
	     put codeline;
	     codeline=cats('%createPortalUser(name=',_infile_,',rc=createPortalUserRC);');
	     put codeline;
	     put '%if (&createPortalUserRC.=0) %then %do;';
		     codeline=cats('filename userfile "',"&requestDirectory.",'/',memname,'";');
		     put codeline;
		     put '%let deleterc=%sysfunc(fdelete(userfile));';
		     put '%put deleteRC=&deleteRC.;';
		     put 'filename userfile;';
         put '%end;';
         
	     end;
     
     end;
     
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

filename tmpcode;

