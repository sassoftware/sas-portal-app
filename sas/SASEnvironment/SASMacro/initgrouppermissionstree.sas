/*
 *  This macro will initialize the portal permissions tree for the passed group
 *  Parameters:
 *    name = the name of the group to create the permission tree for
 */

%macro initGroupPermissionsTree(name=,rc=);

%let _igp=-1;

%if ("&name"="") %then %do;
    %put ERROR: Group name must be passed to initialize the permission tree information.;
    %end;
%else %do;

	%let portalUserType=group;

	%let portalPermissionsTree=&name. Permissions Tree;
	
	%createPermissionsTree(identityType=&portalUserType.,IdentityName=&name.,tree=&portalPermissionsTree.,rc=cptRC);

    %if (&cptRC.=0) %then %do;
				
				%let _igp=0;
			
			%end;
	    %else %do;
	    
	        %let _igp=&cptRC.;
	        
	        %end;
		
		%end;
		
    %end;

%if ("&rc." ne "") %then %do;
   %global &rc.;
   %let &rc.=&_igp;
   %end;

%mend;
