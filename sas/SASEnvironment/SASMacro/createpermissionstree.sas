/*  Generate and execute a metadata request to add a new permissions tree for the passed identity */

/*  Parameters (Macro Variables) 

    identityType= the type of identity to be set as the owner, values are group or user
    identityName= the name of the identity for which to create the permissions tree
    tree= the name of the permissions tree to create.  If not set, default is
              &identityName. Permissions Tree
*/

%macro createPermissionsTree(identityType=,identityName=,tree=,rc=);

%let _cptRC=0;

%if ("&identityType" ne "group" and "&identityType" ne "user") %then %do;
    %put ERROR: Invalid identityType, &identityType., passed, must be either group or user;
    %let _cptRC=-1;
    %end;
%if ("&identityName" = "") %then %do;

    %put ERROR: IdentityName is required to be non-missing.;
    %let _cptRC=-1;
    
    %end;

%if (&_cptRC. = 0) %then %do;
	
	%if ("&tree"="") %then %do;
	    %let tree=&identityName. Permissions Tree;
	    %end;
	    
	%objectExists(type=Tree,name=&tree.,existsvar=_cptTreeExists);
	
	%if (&_cptTreeExists. = 0) %then %do;
		
		/*
		 *  Get the repository information from the server
		 */
		
		filename _cptrxml "&filesDir./portal/getRepositories.xml";
		
		filename _cptrout temp;
		
		proc metadata in=_cptrxml out=_cptrout;
		run;
		
		filename _cptrxml;
		
		/*
		 *  Retrieve the metadata references that are going to be needed to add the new permissions tree
		 */
		
		filename _cpttxsl "&filesDir./portal/permissionsTree/getPermissionsTreeReferences.xslt";
		
		filename _cptixml temp;
		
		/*
		 *  Substitute in the details of this request
		 */
		
		%let reposname=%sysfunc(dequote(%sysfunc(getoption(METAREPOSITORY))));
		
		proc xsl in=_cptrout out=_cptixml xsl=_cpttxsl;
		  parameter "identityType"="&identityType." "identityName"="&identityName." "reposName"="&reposName.";
		run;
		
		filename _cptrout;
		filename _cpttxsl;

		%checkXSLResult(xml=_cptixml,rc=getxslrc,msg=Metadata request to get References to build Permissions tree);
		
		%if ( &getxslrc.=0) %then %do;

			filename _cptoxml temp;
			
			proc metadata in=_cptixml out=_cptoxml;
			run;
			
			%showFormattedXML(_cptoxml,Metadata response from getting References to build Permissions tree);
			
			/*
			 *  Generate an addMetadata request using the references just retrieved.
			 */
			
			filename _cptixsl "&filesDir./portal/permissionsTree/createPermissionsTree.xslt";
			
			filename _cptaxml temp;
			
			proc xsl in=_cptoxml out=_cptaxml xsl=_cptixsl;
			   parameter "treeName"="&tree.";
			run;
			
			/*
			 *  Now execute the addMetadata request if the generation succeeded
			 */
			
			%checkXSLResult(xml=_cptaxml,rc=xslrc,msg=Metadata request to add the Permissions Tree);
			
			%if ( &xslrc.=0) %then %do;
			
				filename _cptarsp temp;
	
				proc metadata in=_cptaxml out=_cptarsp;
				run;
	
				filename _cptarsp;
			
			    %end;
			%else %do;
			   %put ERROR: AddMetadata for Permissions Tree skipped.;
			   %let _cptRC=&xslrc.;
			   
			   %end;
	
			filename _cptaxml;
			filename _cptoxml;
	
	        %end;
        %else %do;
        
		   %let _cptRC=&getxslrc.;
        
            %end;
            
   		filename _cptixml;

	    %end;
	 %else %do;
	    %put NOTE: Tree &tree. already exists.;
	    %end;

     %end;
     
%if ("&rc." ne "") %then %do;

    %global &rc.;
    
    %let &rc.=&_cptRC.;
    
    %end;     
%mend;

