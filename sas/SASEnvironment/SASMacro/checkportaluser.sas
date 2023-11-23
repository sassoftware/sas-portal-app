/*  Parameters (Macro Variables) 

    name= the name of the user to check whether the portal content exists or not.
    exists = the macro variable name that should indicate whether user's portal content exists. 1=yes, 0=no.
    rc= (optional) the macro variable that contains the return code of the check
*/

%macro checkPortalUser(name=,exists=,rc=);

%let _cpuRC=-1;

%if ("&name" = "") %then %do;

    %put ERROR: Name is required to be non-missing.;
    %let _cpuRC=-1;
    
    %end;

%else %do;

    %let _cpuRC=0;
    
    %end;
    
%if (&_cpuRC. = 0) %then %do;
	
	%let tree=&name. Permissions Tree;
	    
	%objectExists(type=Tree,name=&tree.,existsvar=&exists.);
         
     %let _cpuRC=0;
	
     %end;
     
%if ("&rc." ne "") %then %do;

    %global &rc.;
    
    %let &rc.=&_cpuRC.;
    
    %end;     
%mend;

