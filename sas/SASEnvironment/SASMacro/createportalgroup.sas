/*
 *  This macro will initialize the portal information for the passed group
 *  Parameters:
 *    name = (required) the name of the group to create the portal information for
 *    rc   = (optional) a macro variable into which to place the return code
 *    setOwner = (optional) either 1 (default) or 0 to indicate whether the owner of the created permissions tree should
 *               be set.  This variable should only be used if you have an alternate process in place for setting 
 *               tree ownership!
 */

%macro createPortalGroup(name=,rc=,setOwner=1);

%let _cgp=-1;

%if ("&name"="") %then %do;
    %put ERROR: Group name must be passed to initialize the portal information.;
    %end;
%else %do;

	%let portalUserType=group;

	%let portalPermissionsTree=&name. Permissions Tree;
	
	%createPermissionsTree(identityType=&portalUserType.,IdentityName=&name.,tree=&portalPermissionsTree.,setOwner=&setOwner.,rc=cptRC);

        %if (&cptRC.=0) %then %do;
				
		%let _cgp=0;
			
		%end;

	    %else %do;
	    
	        %let _cgp=&cptRC.;
	        
		%end;
        %end;

%if ("&rc." ne "") %then %do;
   %global &rc.;
   %let &rc.=&_cgp;
   %end;

%mend;
