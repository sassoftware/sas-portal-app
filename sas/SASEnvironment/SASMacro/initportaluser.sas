/*
 *  This macro will initialize the portal content for a new user
 *  Parameters:
 *    name = the person name of the user to add
 */

%macro initPortalUser(name=,rc=);

%let _ipuRC=-1;

%if ("&name"="") %then %do;
    %put ERROR: User name must be passed to initialize the portal user information.;
    %end;
%else %do;

    /*
     *  The user doesn't have the ability to create their own Permissions Tree, so before getting
     *  too far, make sure that it exists.
     */
    
	%let portalPermissionsTree=&name. Permissions Tree;
	    
	%objectExists(type=Tree,name=&portalPermissionsTree.,existsvar=_ipuTreeExists);
	
	%if (&_ipuTreeExists. = 1) %then %do;

	    /*
	     *  Create Profile areas, if they don't exist
	     */
	    
	    %createUserProfile(name=&name.,rc=cupRC);
	    
	    %if (&cupRC.=0) %then %do;
		    
			/*
			 *  Copy the standard portlets
			 */
			
			%createInitialPortlets(tree=&portalPermissionsTree.,rc=cipRC);
	
	        %if (&cipRC.=0) %then %do;
				
				/*
				 *  Create the Initial Pages
				 */
				%createInitialPages(tree=&portalPermissionsTree.,rc=cipaRC);
				%if (&cipaRC.=0) %then %do;
				
					/*
					 *  Sync any group shared pages
					 */
					
	                %syncUserGroupContent(name=&name.,rc=syncUserGroupContentRC);
	
					%let _ipurc=&syncuserGroupContentRC.;
									    
				    %end;
				%else %do;
	
				    %let _ipurc=&cipaRC.;
				
	                %end;			
				%end;
		    %else %do;
		    
		        %let _ipurc=&cipRC.;
		        
		        %end;
				
			%end;
	    %else %do;
	    
	        %let _ipurc=&cupRC.;
	        
	        %end;
	    %end;
	%else %do;
	    
	    %put ERROR: User portal area not initialized.;
	    %let _ipuRC=-1001;
	    
	    %end;
	    
    %end;

%if ("&rc." ne "") %then %do;
   %global &rc.;
   %let &rc.=&_ipuRC;
   %end;

%mend;
