/*
 *  This macro will create the portal permissions tree for the passed user
 *  Parameters:
 *    name = the person name of the user to create the permission tree for
 */

%macro createPortalUser(name=,rc=);

%let _cpuRC=-1;

%if ("&name"="") %then %do;
    %put ERROR: User name must be passed to initialize the portal information for a user.;
    %end;
%else %do;

        %put Create Portal User &name.;

	%let portalUserType=user;

	%let portalPermissionsTree=&name. Permissions Tree;
	
	%createPermissionsTree(identityType=&portalUserType.,IdentityName=&name.,tree=&portalPermissionsTree.,rc=cptRC);

    %if (&cptRC.=0) %then %do;
				
        %let _cpuRC=0;
			
	    %end;
	%else %do;
	    
	    %let _cpuRC=&cptRC.;
	        
	    %end;
		
    %end;

%if ("&rc." ne "") %then %do;
   %global &rc.;
   %let &rc.=&_cpuRC;
   %end;

%mend;
