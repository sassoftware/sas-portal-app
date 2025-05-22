#  Requesting User Registration

This sample shows how one can write a file to a directory that requests the admin to create the user's Portal Content Area (ie. permissions tree).

 The intent is that the files in this directory will then be post processed either through a batch job that runs on a normal schedule, or to use system capabilities to trigger a sas job to run when the file is created.

Note that in this case, the _cptTreeExists macro variable should not be changed
from the value at call this program (ie. 0), but this code can change the
message being returned to the user interface, by setting the _cptErrorMessage
 macro variable.

##  Setup

A directory must be created and have the appropriate permissions for all users that may use the portal to have write (ie. create file) permissions.

This directory name must match across all SAS programs in this directory in the requestsDirectory macro variable. For example, the default in those files is Data/user-registry-requests.

After creating this directory, make sure that all programs used for registration and processing the registration are updated to set this directory name.

###  User Request/Registration

When the user tries to log in to the portal and has not been previously registered, a request is sent to request the admin register the user.  To set up the user registration request process:

1. Copy the sas/SASEnvironment/SASCode/Samples/managePortalUsers/create-portal-user-area-plugins/requests-directory directory to your own directory location:
<pre>
cd /Data1/SASConfig/Lev1/SASPortal  #assuming this is where this repo directory is linked.
mkdir SASEnvironment/SASCode/user-registration
cp SASPortalApp/sas/SASEnvironment/SASCode/Samples/managePortalUsers/create-portal-user-area-plugins/requests-directory/* SASEnvironment/SASCode/user-registration
</pre>

In your server or requests usermods configuration, set the variable CreatePortalUserAreaProgram to point to your registration program.  

For example
<pre>

%global CreatePortalUserAreaProgram;

%let CreatePortalUserAreaProgram=SASEnvironment/SASCode/user-registration/requestPortalUser.sas;

</pre>

**NOTE: Make sure that technical userid that is running the stored process server (ie. the uid running the process) has read permission to this file.

### Modify message sent to user

Modify the requestPortalUser.sas program to set the message to return to the user to one that is most appropriate to your implementation in the macro variable _cptTreeErrorMessage. For example:
<pre>
%let _cptTreeErrorMessage=Your request has been registered, please try again later.;
</pre>

## Process the requests

There are multiple ways that the requests could be processed:

- a batch job that executes and processes all files in the directory.  
  - NOTE: This same type of logic could be executed as a stored process which is only available to an administrator.
- a triggered job that is passed the specific file that has been added.  The Linux inotify utility is useful here.

**NOTE: Regardless of the mechanism used to process the registration requests, the metadata user who is executing the request processing MUST have write metadata permissions to the SAS Portal Application Tree AND must have the ability to see all existing trees underneath it.  The easiest way to achieve this is to add a specific group of users to the Portal ACT.

### Batch Processing

A sample program, batch-registration.sas, that will loop over all files in the directory and create the users is included.  This program can be invoked like:

<pre>
/Data1/SASConfig/Lev1/SASPortal/sas.sh -sysin SASEnvironment/SASCode/user-registration/batch-registration.sas -log $HOME/batch-registration.log -initstmt "options metauser='portal admin' metapass='portal admin password';"
</pre>
**NOTE: This program must be run as a metadata user that has the permissions to create folders/trees under the SAS Portal Application Tree AND to have read permission on any existing trees that exist there (to avoid duplicating content).   Passing a specific metauser and metapass on the command line is one option to make sure this happens (although it is not a secure means to do so).  It is included in this example solely to point out the importance of running with the correct metadata user and permissions.
