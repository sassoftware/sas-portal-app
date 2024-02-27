/*
 *  This program must be run as an admin user who has permissions
 *  to delete portal content areas, ie. Permission Trees, and
 *  can see those that exist.
 */

%inc "&sasDir./request_setup.sas";

/*  Set the group you want to delete */

%if (%symexist(portalGroup)=0) %then %do;
    %let portalGroup=Group 4;
    %end;

%deletePortalGroup(name=&portalGroup.,rc=deletePortalGroupRC);

%put deletePortalGroupRC=&deletePortalGroupRC.;


