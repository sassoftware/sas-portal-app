#  Create User Portal Area Plugins

This directory shows a set of sample implementations that can be used to implement the "Create User Portal Area" exit point.

The purpose of this exit point is to allow the site to modify the process of creating the user portal area for users that are logging in for the first time.

To recap, the process when a user logs into the Portal the first time is:

-	Create the new user’s portal content area (ie. permission tree), this requires admin permissions
-	Initialize the user’s portal content area, this is done as the actual user

When the user goes to the main portal page, a check is made as to whether the user’s portal content area has been created.  

If not, a check is made to see if the admin has set the CreatePortalUserAreaProgram macro variable to the name of a “user exit” that can implement different ways of creating the user.  If the implementation in this exit can actually create the user area, they can set the return code to 0, and then on return, the process continues onto the “initialize” step.  If they can’t create it, but are implementing some other solution, they can modify the default message that is sent back to the user based on the implementation.

There are 2 sample implementations provided: 

-	[inline](inline/README.md): an example showing how to create the permission tree and return a zero rc to continue processing
-	[requests-directory](requests-directory/README.md): an example showing where the user request puts a file in a directory, customizes the message returned to the user, and a batch process to process all the files in that directory

