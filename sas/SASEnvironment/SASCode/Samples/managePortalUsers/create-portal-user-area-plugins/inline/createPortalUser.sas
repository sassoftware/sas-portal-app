/*
 *  This sample shows how one can "inline" the creation 
 *  of the user's Portal Content Area (ie. permissions tree).
 *
 *  This code creates the user's portal content area as the admin
 *  and set the _cptTreeExists macro variable=1 to indicate to the
 *  calling program that it has been created successfully.
 *
 *  NOTE: Great Care must be taken when using this type of code
 *        as it exposes how to switch to a user with a higher level
 *        of permissions than a standard user would.   
 *        Suggestions for use:
 *          - only use this in a dev environment
 *          - securely retrieve the portal admin user and password
 *          - protect this file with file permissions
 *          - encode any password that is set/used here.
 */
  
%macro myCreatePortalUser(user=);

%createPortalUser(name=&user.,rc=createPortalUserRC);

%put createPortalUserRC=&createPortalUserRC.;

%if (&createPortalUserRC.=0) %then %do;

    %let _cptTreeExists=1;

    %end;

%mend;

/*  Set the portalAdminUser and portalAdminPW to 
 *  a userid/pw that has write permissions to
 *  the SAS Portal Application tree.
 */
%let portalAdminUser=xxxxx;
%let portalAdminPW=yyyyy;

options metauser="&portalAdminUser." metapass="&portalAdminPW.";

/*  Set the user you want to create */

%let portalUser=&_metaPerson.;

%myCreatePortalUser(user=&portalUser);

/*  Reset the meta connection values to return to user connection */

options metauser="" metapass="";

