/*  Get the information about the named permissions tree */

/*  Parameters (Macro Variables) 

    treeName= the name of the permissions tree.
    
*/

%inc "&sasDir./request_setup.sas";

%if (%symexist(treemetadata)=0) %then %do;
     %let outxml=outxml;
     filename outxml temp;
     %end;
%else %do;
     %let outxml=&treemetadata.;
     %end;

%getPermissionsTree(&outxml.,&treeName.,itExists);

%if (%symexist(treemetadata)=0) %then %do;
    filename outxml;
    %end;
