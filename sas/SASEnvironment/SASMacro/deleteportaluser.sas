/*
    Delete a Portal User
    
*/

%macro deletePortalUser(name=,rc=);

        /*
         *  Delete Permissions Tree if it doesn't exist.
         */

        %let portalPermissionsTree=&name. Permissions Tree;

        %deletePermissionsTree(tree=&portalPermissionsTree.,rc=_duptRC);

        %if ( &_duptRC = 0) %then %do;

            /*
             *  If we delete the permissions tree, then we need to also delete the
             *  the user profile because it is intertwined with the tree contents and it's
             *  content history.
             */

            %deleteUserProfile(name=&name,rc=_dupt_dupRC);

            %let _duptRC=&_dupt_dupRC.;

            %end;

%if ("&rc." ne "") %then %do;

    %global &rc.;
    
    %let &rc.=&_duptRC.;
    
    %end;           
%mend;
