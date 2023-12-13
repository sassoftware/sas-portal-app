#  Create User Portal Area Batch

This directory shows a sample implementation of a batch process that will create the portal content area for a set of users:

1. All users defined in metadata.

See [createMetadataUsersContentAreas.sas](createMetadataUsersContentAreas.sas) for details.

**NOTE:** While discouraged from being used in large environments (***large*** being defined as an environment where there are many more users defined to the system than will be using the portal), the portal content areas can be initialized in a batch mode for all metadata users defined.

2. All users defined in a file

A file is read that contains the list of users to create their portal content area.

See [createFileUsersContentAreas.sas](createFileUsersContentAreas.sas) for details.

##

1. Copy the sas/SASEnvironment/SASCode/Samples/managePortalUsers/create-portal-user-area-plugins/batch directory contents to your own directory location:
<pre>
cd /Data1/SASConfig/Lev1/SASPortal  #assuming this is where this repo directory is linked.
mkdir SASEnvironment/SASCode/create-user-portal-area-batch
cp SASPortalApp/sas/SASEnvironment/SASCode/Samples/managePortalUsers/create-portal-user-area-batch/* SASEnvironment/SASCode/create-user-portal-area-batch
</pre>
2. Verify the metadata server configuration that will be accessed via this program
**NOTE: This program must be run as a metadata user that has the permissions to create folders/trees under the SAS Portal Application Tree AND to have read permission on any existing trees that exist there (to avoid duplicating content).   Passing a specific metauser and metapass on the command line is one option to make sure this happens (although it is not a secure means to do so).  It is included in this example solely to point out the importance of running with the correct metadata user and permissions.
3. If using a list of users in a file, create the file with 1 user name per line (the name specified here must match the User metadata object created for that user).
4. Execute the sas program
<pre>
/Data1/SASConfig/Lev1/SASPortal/sas.sh -sysin SASEnvironment/SASCode/create-user-portal-area-batch/<sas program>-log $HOME/batch-registration.log -initstmt "options metauser='portal admin' metapass='portal admin password';"
</pre>
Where <sas program> is the program to execute based on which scenario (metadata users, list of users in a file) is being used.

**NOTE: Passing a specific metauser and metapass on the command line is one option to make sure this happens (although it is not a secure means to do so).  It is included in this example solely to point out the importance of running with the correct metadata user and permissions.

 
