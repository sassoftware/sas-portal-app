/*
 *  This macro will initialize the set of desktop groups for the passed permission tree
 *  Parameters:
 *    tree = the name of the permission tree to initialize with desktop information
 */

%macro createInitialDesktop(tree=,user=,rc=);

%let _cidrc=-1;

%if ("&tree"="") %then %do;
    %put ERROR: Tree name must be passed to initialize the user desktop information.;
    %end;
%else %do;

    /*
     *  See if the permissions tree already has the desktop groups
     */

     %let _cidFilter=*[@Name=%str(%')&tree.%str(%')][Members/Group[@Name=%str(%')DESKTOP_PORTALPAGES_GROUP%str(%')]];
	
 	 %objectExists(type=Tree,existsvar=_cidExists,filter=&_cidFilter.);
	   
     %if (&_cidExists.=0) %then %do;
	
        %put No initial desktop info found, initializing them now.;
		
		/*
		 *  Get the repository information from the server
		 */
		
		filename _cidrxml "&filesDir./portal/getRepositories.xml";
		
		filename _cidrout temp;
		
		proc metadata in=_cidrxml out=_cidrout;
		run;
		
		filename _cidrxml;
		
		/*
		 *  Retrieve the metadata references that are going to be needed to add the new permissions tree
		 */
		
		filename _cidtxsl "&filesDir./portal/permissionsTree/getPermissionsTreeProfileReferences.xslt";
		
		filename _cidixml temp;
		
		/*
		 *  Substitute in the details of this request
		 */
	        %let reposname=%sysfunc(dequote(%sysfunc(getoption(METAREPOSITORY))));	
		
		proc xsl in=_cidrout out=_cidixml xsl=_cidtxsl;
		  parameter "identityName"="&user." 
		            "reposName"="&reposName."
		            "treeName"="&tree."
		            ;
		run;
		
		filename _cidrout;
		filename _cidtxsl;

		%checkXSLResult(xml=_cidixml,rc=_cidxslrc,msg=Metadata request to get References to build User Desktop information);
		
		%if ( &_cidxslrc.=0) %then %do;
	    
	       filename _cidoxml temp;
			
			proc metadata in=_cidixml out=_cidoxml;
			run;
			
			%showFormattedXML(_cidoxml,Metadata response from getting References to build User Desktop information);
			
			/*
			 *  Generate an addMetadata request using the references just retrieved.
			 */
			
			filename _cidixsl "&filesDir./portal/permissionsTree/createPermissionsTreeDesktop.xslt";
			
			filename _cidaxml temp;
			
			proc xsl in=_cidoxml out=_cidaxml xsl=_cidixsl;
			run;
			
			/*
			 *  Now execute the addMetadata request if the generation succeeded
			 */
			
			%checkXSLResult(xml=_cidaxml,rc=_cidxslrc2,msg=Metadata request to add the User Desktop information);
			
			%if ( &_cidxslrc2.=0) %then %do;
			
				filename _cidarsp temp;
	
				proc metadata in=_cidaxml out=_cidarsp;
				run;
	
				filename _cidarsp;
                                %let _cidRC=0;
			
			    %end;
			%else %do;
			   %put ERROR: AddMetadata for User Desktop Information skipped.;
			   %let _cidRC=&_cidxslrc2.;
			   
			   %end;
	
			filename _cidaxml;
			filename _cidoxml;
	        %end;
	        
	    %else %do;

			   %put ERROR: Generating AddMetadata for User Desktop Information failed.;
			   %let _cidRC=&_cidxslrc.;
	    
	        %end;
	        
	    filename _cidixml;
	    
	    %end;
	 %else %do;
	    
	    %put NOTE: Permission Tree &tree. already initialized with desktop information.;
	       
	    %let _cidrc=0;
	       
	    %end;
	       
	 %end;      

%if ("&rc" ne "") %then %do;
 
    %global &rc.;
    
    %let &rc.=&_cidrc.;
    
    %end;
%mend;
