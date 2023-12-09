options metauser="admin user" metapass="admin pw";

%inc "&sasDir./request_setup.sas";

/*  Set the user you want to create */

%let portalUser=Group 4 User 1;

%createPortalUser(name=&portalUser.,rc=createPortalUserRC);

%put createPortalUserRC=&createPortalUserRC.;


