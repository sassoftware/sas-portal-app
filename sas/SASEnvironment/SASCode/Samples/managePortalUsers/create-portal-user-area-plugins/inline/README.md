#  Inline user registration

This sample shows how one can "inline" the creation of the user's Portal Content Area (ie. permissions tree). This code creates the user's portal content area as the admin and set the _cptTreeExists macro variable=1 to indicate to the calling program that it has been created successfully.

**NOTE:* Great Care must be taken when using this type of code as it exposes how to switch to a user with a higher level of permissions than a standard user would.

Suggestions for use:
- only use this in a dev environment
- securely retrieve the portal admin user and password
- protect this file with file permissions
- encode any password that is set/used here.

###  User Request/Registration

When the user tries to log in to the portal and has not been previously registered, this plugin should receive the request, create the portal content user for the requesting user and return a 0 return code so that additional user initialization can occur.

1. Copy the sas/SASEnvironment/SASCode/Samples/managePortalUsers/create-portal-user-area-plugins/inline directory to your own directory location:
<pre>
cd /Data1/SASConfig/Lev1/SASPortal  #assuming this is your server context
mkdir SASEnvironment/SASCode/user-registration-inline
cp SASPortalApp/sas/SASEnvironment/SASCode/Samples/managePortalUsers/create-portal-user-area-plugins/inline/* SASEnvironment/SASCode/user-registration-inline
</pre>

2. **IMPORTANT** Determine how to best set/retrieve an administrative user credentials in the file createPortalUser.sas and make the appropriate modifications.  The user used for this step must have write permissions to the SAS Portal Application Tree AND Read Access to all trees under it (if this second condition isn't met, you run the risk of duplicate information being created!).

3. In your server or requests usermods configuration, set the variable CreatePortalUserAreaProgram to point to your create user program.  

For example
<pre>

%global CreatePortalUserAreaProgram;

%let CreatePortalUserAreaProgram=SASEnvironment/SASCode/user-registration/inline/createPortalUser.sas;

</pre>

