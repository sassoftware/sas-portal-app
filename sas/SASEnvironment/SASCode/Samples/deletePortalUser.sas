options metauser="admin user" metapass="admin pw";

%inc "&sasDir./request_setup.sas";

/*  Set the user you want to delete */

%let portalUser=Group 4 User 1;

%deletePortalUser(name=&portalUser.,rc=deletePortalUserRC);

%put deletePortalUserRC=&deletePortalUserRC.;


