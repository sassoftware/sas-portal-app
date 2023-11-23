/*
 *  This macro will terminate the portal content for a new user
 *  Parameters:
 *    name = the person name of the user to delete the portal information for
 */

%macro termPortalUser(name=,rc=);

%let _tpuRC=-1;

%if ("&name"="") %then %do;
    %put ERROR: User name must be passed to terminate the portal user information.;
    %end;
%else %do;

	%let portalUserType=user;

	/*
	 *  Delete Permissions Tree if it doesn't exist.
	 */
	
	%let portalPermissionsTree=&name. Permissions Tree;

	%deletePermissionsTree(tree=&portalPermissionsTree.,rc=dptRC);

    %if (&dptRC.=0) %then %do;

	    /*
	     *  Delete Profile areas
	     */
	    
	    %deleteUserProfile(name=&name.,rc=dupRC);
    
        %let _tpuRC=&dupRC.;
        
        %end;
    %else %do;
    
        %let _tpuRC=&dptRC.;
        
        %end;

	%end;        

%if ("&rc." ne "") %then %do;
   %global &rc.;
   %let &rc.=&_tpuRC;
   %end;

%mend;
