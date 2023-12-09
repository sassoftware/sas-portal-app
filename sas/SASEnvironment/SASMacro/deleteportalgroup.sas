/*
    Delete a Group's portal information
    
*/

%macro deletePortalGroup(name=,rc=);

        /*
         *  TODO: Verify that the passed name is a group name
         */

        /*
         *  Delete Permissions Tree if it doesn't exist.
         */

        %let portalPermissionsTree=&name. Permissions Tree;

        %deletePermissionsTree(tree=&portalPermissionsTree.,rc=_duptRC);

%if ("&rc." ne "") %then %do;

    %global &rc.;
    
    %let &rc.=&_duptRC.;
    
    %end;           
%mend;
