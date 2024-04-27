/*
 *  This macro will initialize the portal information for the passed group
 *  Parameters:
 *    name = the name of the group to create the portal information for
 */

%macro createPortalGroup(name=,rc=);

%let _cgp=-1;

%if ("&name"="") %then %do;
    %put ERROR: Group name must be passed to initialize the portal information.;
    %end;
%else %do;

	%let portalUserType=group;

	%let portalPermissionsTree=&name. Permissions Tree;
	
	%createPermissionsTree(identityType=&portalUserType.,IdentityName=&name.,tree=&portalPermissionsTree.,rc=cptRC);

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
