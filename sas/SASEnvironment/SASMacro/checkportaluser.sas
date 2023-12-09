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
	
	/*
	 *  What we really want to know is if the portal content has been initialized or not, as quickly as possible.
	 *  While here we could distinguish betwen the Permissions tree existing and whether the content exists in the tree,
	 *  what we care about at this point is if there is any content, so just check that.
	 */
	
	/* The order of the query here is important, it should be faster to find a tree with a specific name and
	 * then seeing if it has the main portal group. 
	 */
	
	%let tree=&name. Permissions Tree;
	
    %let filter=*[@Name=%str(%')&tree.%str(%')][Members/Group[@Name=%str(%')DESKTOP_PORTALPAGES_GROUP%str(%')]];
	
 	 %objectExists(type=Tree,existsvar=&exists.,filter=&filter.);
         
     %let _cpuRC=0;
	
     %end;
     
%if ("&rc." ne "") %then %do;

    %global &rc.;
    
    %let &rc.=&_cpuRC.;
    
    %end;     
%mend;

