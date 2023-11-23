/*
 *  This macro will initialize the set of pages for the passed permission tree
 *  Parameters:
 *    tree = the name of the permission tree to initialize with pages
 */

%macro createInitialPages(tree=,rc=);

%let _ciprc=-1;

%if ("&tree"="") %then %do;
    %put ERROR: Tree name must be passed to initialize the page information.;
    %end;
%else %do;

    %let metaRepository=%sysfunc(getoption(METAREPOSITORY));
    
    /*
     *  Get the repository information to feed into the next requests.
     */
    
    filename _ciprepo "&filesDir./portal/getRepositories.xml";
    
    filename _cipget temp;
    
    proc metadata in=_ciprepo out=_cipget;
    run;
    
    filename _ciprepo;
    
    filename _cipgxsl "&filesDir./portal/permissionsTree/getStandardPages.xslt";
    
    filename _cipgreq temp;

    %let publicTreeName=PUBLIC Permissions Tree;
    
    proc xsl in=_cipget out=_cipgreq xsl=_cipgxsl;
       parameter "treeName"="&tree."
                 "reposName"="&metaRepository"
                 "publicTreeName"="&publicTreeName."
                 ;
    run;

    filename _cipget;
    filename _cipgxsl;

    %checkXSLResult(xml=_cipgreq,rc=_cipgxslrc,msg=Generate Metadata request to get content to initialize users pages);
		
	%if ( &_cipgxslrc.=0) %then %do;
    
	    filename _cipgrsp temp;
	    
	    proc metadata in=_cipgreq out=_cipgrsp;
	    run;
	    
	    %showFormattedXML(_cipgrsp,Metadata response to getting user page initialization information);

        /* 
         *  See if there are any pages in the user tree, if so, already initialized.
         */
        
	    filename _cipgmap temp;
	     
	      data _null_;
	        file _cipgmap encoding="utf-8";
			put '<?xml version="1.0" encoding="utf-8"?>';
			put '<SXLEMAP version="2.1">';
			
			put "<TABLE name=""UserPages"">";
            put "<TABLE-PATH syntax=""XPath"">/Multiple_Requests/GetMetadataObjects/Objects/Tree/Members/PSPortalPage</TABLE-PATH>";

            put "<COLUMN name=""TreeName"">";
            put "<PATH syntax=""XPath"">/Multiple_Requests/GetMetadataObjects/Objects/Tree/@Name</PATH>";
            put "<TYPE>character</TYPE>";
            put "<DATATYPE>string</DATATYPE>";
            put "<LENGTH>200</LENGTH>";
            put "</COLUMN>";

            put "<COLUMN name=""Id"">";
            put "<PATH syntax=""XPath"">/Multiple_Requests/GetMetadataObjects/Objects/Tree/Members/PSPortalPage/@Id</PATH>";
            put "<TYPE>character</TYPE>";
            put "<DATATYPE>string</DATATYPE>";
            put "<LENGTH>17</LENGTH>";
            put "</COLUMN>";

            put "</TABLE>";
            put "</SXLEMAP>";
            
          run;
	
		libname _cipgrsp xmlv2 xmlmap=_cipgmap xmlfileref=_cipgrsp;
	
	    /*
	     *  Get the count of pages returned
	     *  NOTE: Since the xml could contain multiple trees, make sure to only get pages in the correct tree.
	     */
	    %let _cipnpgs=0;
	    
	    proc sql noprint ;
	       select count(Id)
	       into   :_cipnpgs
	    from   _cipgrsp.UserPages 
	    where TreeName="&tree.";
	    
	    quit;

	    filename _cipgmap;

	    libname _cipgrsp;

        %if (&_cipnpgs=0) %then %do;
        
		    /*  If no pages, Create the Pages in the user's permissions tree.
		     */
		    
		    filename _cipuxsl "&filesDir/portal/permissionsTree/createStandardPagesUser.xslt";
		    
		    filename _cipapgs temp;
		    
		    proc xsl in=_cipgrsp out=_cipapgs xsl=_cipuxsl;
		       parameter "treeName"="&tree."
	                     "metaRepository"="&metaRepository"
	                     "function"="standardpages"
	                 ;
	
		    run;
	
	        %checkXSLResult(xml=_cipapgs,rc=genxslrc,msg=Generate Metadata request to add user pages);
			
			filename _cipuxsl;
			filename _cipgrsp;
			
		    %if ( &genxslrc.=0) %then %do;
		    
		        filename _ciparsp temp;
	
		        proc metadata in=_cipapgs out=_ciparsp;
		        run;
		        
	     	    %showFormattedXML(_ciparsp,Add Metadata response for user pages);
	
	            filename _ciparsp;
	            
		        %let _ciprc=0;
		        	        
		        %end;
		        
		    %else %do;
		    
		        %let _ciprc=&genxslrc.;
		        
		        %end;
		        
	        filename _cipapgs;
	        
	        %end;
        %else %do;
  	    
	        %put NOTE: Permission Tree &tree. already initialized with list of pages.;
	       
            %let _ciprc=0;
	       
            %end;
            
        %end;
    %else %do;
         %let _ciprc=&_cipgxslrc.;
         %end;
    
    filename _cipgreq;
    
%end;

%if ("&rc" ne "") %then %do;
 
    %global &rc.;
    
    %let &rc.=&_ciprc.;
    
    %end;
    
%mend;
