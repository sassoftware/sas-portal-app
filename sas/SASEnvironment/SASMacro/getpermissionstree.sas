/*  Get the information about the named permissions tree */

/*  Parameters (Macro Variables) 

    treeName= the name of the permissions tree.
    
*/

%macro getPermissionsTree(outfile=,tree=,existsVar=,members=0,memberDetails=0,rc=);

%let _gptRC=0;

%if ("&outfile"="") %then %do;

     %put ERROR: outfile parameter is required for getPermissionsTree.;
     %let _gptRC=-1;
     
     %end;
     
%if ("&tree"="") %then %do;

     %put ERROR: tree parameter is required for getPermissionsTree.;
     %let _gptRC=-1;
     
     %end;

%if (&_gptRC.=0) %then %do;

    /*
     *  XSL and metadata processing can fail without any real indication, so assume it's
     *  going to fail and reset the rc to 0 when successful.
     */
    
    %let _gptRC=-1;
    
	%objectExists(type=Tree,name=&tree.,existsvar=_gptTreeExists);
	
	%if (&_gptTreeExists.) %then %do;
		
		/*
		 *  Generate the metadata request
		 */
		
		filename _gptnull "&filesDir./portal/root.xml";
	
        filename _gptgxsl "&filesDir./portal/permissionsTree/getPermissionsTree.xslt";
		
		filename _gptgreq temp;
		
		proc xsl in=_gptnull out=_gptgreq xsl=_gptgxsl;
		  parameter "treeName"="&tree."
		            "includeMembers"="&members."
		            "includeMemberDetails"="&memberDetails."
		            ;
		run;
		
		%showFormattedXML(_gptgreq,Metadata Query to get Permissions Tree &treeName.);
			
		proc metadata in=_gptgreq out=&outfile.;
		run;
		
		filename _gptgreq;
		
		%let _gptRC=0;
		
	    %end;
	%else %do;
	    %put Tree &tree. does not exist.;
	    %let _gptRC=0;
	    
	    %end;
		    
	%end;
	
%if ("&existsVar" ne "") %then %do;
 
    %global &existsVar.;
    
    %if %symexist(_gptTreeExists) %then %do;
        %let &existsVar.=&_gptTreeExists.;
        %end;
    %else %do;
        %let &existsVar.=-1;
        %end;
    
    %end;
	    
%if ("&rc" ne "") %then %do;
 
    %global &rc.;
    
    %let &rc.=&_gptRC.;
    
    %end;
    
%mend;
