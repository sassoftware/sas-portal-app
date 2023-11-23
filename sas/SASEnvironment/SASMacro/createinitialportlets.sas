/*
 *  This macro will initialize the set of portlets for the passed permission tree
 *  Parameters:
 *    tree = the name of the permission tree to initialize with portlets
 */

%macro createInitialPortlets(tree=,rc=);

%let _ciorc=-1;

%if ("&tree"="") %then %do;
    %put ERROR: Tree name must be passed to initialize the portlet information.;
    %end;
%else %do;

    /*
     *  See if the permissions tree already has the portlets
     *
     *  NOTE: There may be simpler ways of doing this, but I was trying to optimize the
     *  query to metadata server (ie. navigate down a given tree as opposed to up from PSPortlets).
     *  Can probably figure out a series of data step function calls...
     */
    
    filename _cionull "&filesDir./portal/root.xml";
    
    filename _ciogreq temp;
    
    filename _ciogxsl "&filesDir./portal/permissionsTree/getPermissionsTreePortlets.xslt";
    
    proc xsl in=_cionull xsl=_ciogxsl out=_ciogreq;
       parameter "treeName"="&tree.";
       run;

    filename _cionull;
    filename _ciogxsl;

    %checkXSLResult(xml=_ciogreq,rc=crtxslrc,msg=Generate Metadata request to get list of portlets in a Permissions Tree);
		
	%if ( &crtxslrc.=0) %then %do;
    
	    filename _ciogrsp temp;
	    
	    proc metadata in=_ciogreq out=_ciogrsp;
	    run;
	
	    %showFormattedXML(_ciogrsp,Metadata response from getting list of portlets in a Permissions Tree);
	
	    /*  Read the response and see if any were returned */
	   
	    /*  Take advantage of this information and get the Id of the tree we retrieved */
	       
	      filename _ciogmap temp;
	      
	      data _null_;
	        file _ciogmap encoding="utf-8";
			
			put '<?xml version="1.0" encoding="utf-8"?>';
			put '<SXLEMAP version="2.1">';
			
			put "<TABLE name=""Tree"">";
            put "<TABLE-PATH syntax=""XPath"">/GetMetadataObjects/Objects/Tree</TABLE-PATH>";

            put "<COLUMN name=""Id"">";
            put "<PATH syntax=""XPath"">/GetMetadataObjects/Objects/Tree/@Id</PATH>";
            put "<TYPE>character</TYPE>";
            put "<DATATYPE>string</DATATYPE>";
            put "<LENGTH>17</LENGTH>";
            put "</COLUMN>";
            
            put "</TABLE>";
            
   			put "<TABLE name=""UserPortlets"">";
            put "<TABLE-PATH syntax=""XPath"">/GetMetadataObjects/Objects/Tree/Members/PSPortlet</TABLE-PATH>";

            put "<COLUMN name=""Id"">";
            put "<PATH syntax=""XPath"">/GetMetadataObjects/Objects/Tree/Members/PSPortlet/@Id</PATH>";
            put "<TYPE>character</TYPE>";
            put "<DATATYPE>string</DATATYPE>";
            put "<LENGTH>17</LENGTH>";
            put "</COLUMN>";
            
            put "</TABLE>";

            put "</SXLEMAP>";
			
	    run;
	
		libname _ciogrsp xmlv2 xmlmap=_ciogmap xmlfileref=_ciogrsp;
	
	    /*
	     *  Get the count of portlets returned
	     */
	    %let numPortlets=0;
	    
	    proc sql noprint ;
	       select Id
	       into   :treeId
	    from   _ciogrsp.Tree;
	    quit;
	    
	    proc sql noprint ;
	       select count(Id)
	       into   :numPortlets
	    from   _ciogrsp.UserPortlets;
	    quit;
	
	    filename _ciogmap;
	    
	    libname _ciogrsp;
	    
	    filename _ciogrsp;
	   
	    /*  If none were returned, add them */
	   
	    %if (&numPortlets.=0) %then %do;
	
	       %put No initial set of portlets found, initializing them now.;
	       
	       /*
	        *  Get the list of prototypes from which we should generate the list of portlets
	        */
	       
	       filename _ciolreq "&filesDir./portal/permissionsTree/getStandardPortlets.xml";
	
	       %showFormattedXML(_ciolreq,Query for standard portlets to initialize from);
	       
	       filename _ciolrsp temp;
	       
	       proc metadata in=_ciolreq out=_ciolrsp;
	       run;
	       
	       %showFormattedXML(_ciolrsp,Set of standard portlets to initialize from);
	       
	       filename _ciolreq;
	       
	       filename _cioaxsl "&filesDir./portal/permissionsTree/createStandardPortletsUser.xslt";
	       
	       filename _cioareq temp;
	       
	       /*
	        *  Generate the appropriate metadata add request 
	        */
	       
	       proc xsl in=_ciolrsp xsl=_cioaxsl out=_cioareq;
	          parameter "treeName"="&tree." "treeId"="&treeId.";
	       run;

	       filename _cioaxsl;
	       filename _ciolrsp;
	       
          %checkXSLResult(xml=_cioareq,rc=_cioaxslrc,msg=Generated add request for standard user portlets);
		
	      %if ( &_cioaxslrc.=0) %then %do;
	       
		       /*
		        *  Run the request
		        */
		       
		       filename _cioarsp temp;
		       
		       proc metadata in=_cioareq out=_cioarsp;
		       run;
		       
		       %showFormattedXML(_cioarsp,Response to adding user portlets);
		       
		       filename _cioarsp;
		   
		       %let _ciorc=0;
		       
		       %end;
	
	       %else %do;
	       
	           %let _ciorc=&_cioaxslrc.;
	           
	           %end;
	           
	       filename _cioareq;
       
	       %end;
	    %else %do;
	    
	       %put NOTE: Permission Tree &tree. already initialized with list of portlets.;
	       
	       %let _ciorc=0;
	       
	       %end;
        %end;
     %else %do;
     
        %let _ciorc=&crtxslrc.;
        
        %end;
        
     filename _ciogreq;
        
%end;

%if ("&rc" ne "") %then %do;
 
    %global &rc.;
    
    %let &rc.=&_ciorc.;
    
    %end;
%mend;
