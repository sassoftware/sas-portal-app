	/* 
	 *   Group Processing
	 *
	 *   The group must be defined, the appropriate members in it (including the group admin)
	 *   and the group admin must have write access to the group.
	 *
	     %initPortalUser(name=&grpAdminIdentityName.,rc=initPortalUserRC);
	     %put initPortalUserRC=&initPortalUserRC.;
	 *        Substeps:;
                 %createUserProfile(name=&grpAdminIdentityName.,rc=createUserProfileRC);
	             %put createUserProfileRC=&createUserProfileRC.;
	 *;
	              %initUserPermissionsTree(name=&grpAdminIdentityName.,rc=initUserPermissionsTreeRC);
	              %put initUserPermissionsTreeRC=&initUserPermissionsTreeRC.;
	 *;
	 *           SubSteps:;
	               %let portalPermissionsTree=&IdentityName. Permissions Tree;
	                %createPermissionsTree(identityType=user,IdentityName=&userIdentityName.,tree=&portalPermissionsTree.,rc=createPermissionsTreeRC);
	                %put createPermissionsTreeRC=&createPermissionsTreeRC.;
	 *;
	                %createInitialPortlets(tree=&portalPermissionsTree.,rc=createInitialPortletsRC);
                    %put createInitialPortletsRC=&createInitialPortletsRC.;
     *;
                    %createInitialPages(tree=&portalPermissionsTree.,rc=createInitialPagesRC);
                    %put createInitialPagesRC=&createInitialPagesRC.;
     *;
	                %syncUserGroupContent(name=&userIdentityName.,rc=syncUserGroupContentRC);
	                %put syncUserGroupContentRC=&syncUserGroupContentRC.;
	 *;
	 *              NOTE: this sync step is mostly useful for normal users, but may also be applicable if this
	 *              group admin is in multiple groups.
     *
	 *   %initGroupPermissionsTree(name=&grpIdentityName.,rc=initGroupPermissionsTreeRC);
	 *   %put initGroupPermissionsTreeRC=&initGroupPermissionsTreeRC.;
	 *
	 *   Group admin creates content and shares with the group (which populates content into the group permissions tree)
	 *
	 *   For each user in the group
	 *
	 *     An admin must run the following to initialize the User area:
	 
	       %initUserPermissionsTree(name=&userIdentityName.,rc=initUserPermissionsTreeRC);
	       %put initUserPermissionsTreeRC=&initUserPermissionsTreeRC.;
	 
	 *     As the actual user, run:
	 
	       %initPortalUser(name=&userIdentityName.,rc=initUserPortalUserRC);
	       %put initUserPortalUserRC=&initUserPortalUserRC.;	 
	 *
	 *  NOTE: The user has to get access to new project content as it comes online.
	 *           NOTE: This would only be for brand new projects, or brand new shared pages, existing shared pages that
	 *                 were updated would automatically be picked up without doing anything.
	 *        There are 3 ways of doing this:
	 *
	 *        1. when a user logs in, see if there is any new projects or project content (existing IDP approach.)
	 *           Pros:
	 *             - user is always seeing latest content
	 *             - don't have to spend resources sending it to users who don't log on
	 *           Cons:
	 *             - could impact initial portal entrance performance
	 *             - most projects are not updated, lots of wasted effort looking for things that don't exist
	 *
	 *        2. As project content is updated, push the content to the the user's tree
	 *
	 *           Pros:
	 *             - user is always seeing latest content
	 *             - will only be run for projects that are updated.
	 *             - no impact to user portal entrance experience.
	 *
	 *           Cons:
	 *             - Additional step for administrator
	 *             - Doesn't handle new users added to the group (although that should be caught by the initUserPermissionsTree)
	 *
	 *        3. Run a periodic job that will see if any new content exists and push it to the users if so
	 *           Pros:
	 *             - no impact to user portal entrance experience
	 *           Cons:
	 *             - user is not always seeing latest content
	 *             - lots of searching that may result in little action
	 *         
	 *
	 *  Some thoughts on #2:
	 *     As new projects are created:
	 *
	 *       For each user in the group for that project:
 	            - %syncUserGroupContent(name=&userIdentityName.,rc=syncUserGroupContentRC);
	              %put syncUserGroupContentRC=&syncUserGroupContentRC.;
     *
     *     As project content is updated (new pages only):
     *       For each user in the group for that project:
 	            - %syncUserGroupContent(name=&userIdentityName.,rc=syncUserGroupContentRC);
	*             %put syncUserGroupContentRC=&syncUserGroupContentRC.;
     *
     *  For now, going to structure the code such that we can do any of these as we get more feedback.
	 *
	 *
	 *  Clean up
	 *
	 *  - Clean up a user info (inverse of initPortalUser)
	         %termPortalUser(name=&userIdentityName.,rc=termPortalUserRC);
             %put termPortalUserRC=&termPortalUserRC.;
     *    Substeps:;
     *	  - Clean up a permissions tree (inverse of createPermissionsTree but will also clean up any additional content added);
             %let portalPermissionsTree=&userIdentityName. Permissions Tree;
             %deletePermissionsTree(tree=&portalPermissionsTree,rc=deletePermissionsTreeRC);
             %put deletePermissionsTreeRC=&deletePermissionsTreeRC.;
     *	  - Clean up the user profile (inverse of createUserProfile);
             %deleteUserProfile(name=&identityName.,rc=deleteUserProfileRC);
             %put deleteUserProfileRC=&deleteUserProfileRC.;
     *
     *  Utilities
     *
     *  - Get the detailed information about the contents of a permissions tree:;
          filename gettree temp;
          %getPermissionsTree(tree=&portalPermissionsTree.,outfile=gettree,members=1,memberdetails=1,rc=getPermissionsTreeRC);
          %put getPermissionsTreeRC=&getPermissionsTreeRC.;          
          %showFormattedXML(gettree,Permissions Tree Contents for &portalPermissionsTree. Tree);
          filename gettree;
     *
     *  - showFormattedXML can also save the formatted XML:
          filename outxml "/Data/formatted.xml";
          %showFormattedXML(gettree,Permissions Tree Contents for &portalPermissionsTree. Tree,out=outxml);
          filename outxml;
     *
	 */

%inc "&sasDir./request_setup.sas";

%let grpPrefix=Group 4;
%let grpIdentityName=&grpPrefix. Portal Users;
%let grpAdminIdentityName=&grpPrefix. Admin;
%let portalPermissionsTree=&grpAdminIdentityName. Permissions Tree;

%let userIdentityName=&grpPrefix. User 1;
%let portalPermissionsTree=&userIdentityName. Permissions Tree;

*options mprint mlogic;

*options nomprint nomlogic;

/* getPermissionsTree
    
    filename outtmp temp;
    filename out "/Data/grp3user2-permissions-tree-portal.xml";
    %getPermissionsTree(tree=&portalPermissionsTree,outfile=outtmp,members=1,memberdetails=1);
    %showFormattedXML(outtmp,user permission tree,out=out);
    filename out;
    filename outtmp;

*/    
