/*
 *  Initialize the portal information for a new user
 *  Parameters:
 *    identityName = the person name of the user to add
 */

%inc "&sasDir./request_setup.sas";

%let initRC=-1;

%put identityName=&identityName.;

%initPortalUser(name=&identityName.,rc=initRC);

%put initRC=&initRC.;


