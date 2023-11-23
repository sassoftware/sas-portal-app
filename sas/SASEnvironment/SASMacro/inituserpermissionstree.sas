/*
 *  This macro will initialize the portal permissions tree for the passed user
 *  Parameters:
 *    name = the person name of the user to create the permission tree for
 */

%macro initUserPermissionsTree(name=,rc=);

%let _iupRC=-1;

%if ("&name"="") %then %do;
    %put ERROR: User name must be passed to initialize the permission tree information.;
    %end;
%else %do;

	%let portalUserType=user;

	%let portalPermissionsTree=&name. Permissions Tree;
	
	%createPermissionsTree(identityType=&portalUserType.,IdentityName=&name.,tree=&portalPermissionsTree.,rc=cptRC);

    %if (&cptRC.=0) %then %do;
				
        %let _iupRC=0;
			
	    %end;
	%else %do;
	    
	    %let _iupRC=&cptRC.;
	        
	    %end;
		
    %end;

%if ("&rc." ne "") %then %do;
   %global &rc.;
   %let &rc.=&_iupRC;
   %end;

%mend;
