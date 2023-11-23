	/*
	 *  Get 2 Permission Trees for comparison
	 */

%inc "&sasDir./request_setup.sas";

	%let identityType=user;

    %let identityName=Group 3 User 2;
	%let portalPermissionsTree=&identityName. Permissions Tree;
    
    filename tree1 temp;
    
    %getPermissionsTree(tree=&portalPermissionsTree,outfile=tree1,rc=gptRC,members=1,memberDetails=1);
    
    %put RC from getting tree &portalPermissionsTree., &gptRC.;
    
    %let identityName=Group 1 User 1;
	%let portalPermissionsTree=&identityName. Permissions Tree;
    
    filename tree2 temp;
    
    %getPermissionsTree(tree=&portalPermissionsTree,outfile=tree2,rc=gptRC2,members=1,memberDetails=1);

    %put RC from getting tree &portalPermissionsTree., &gptRC2.;

    %if (%symexist(showxml)) %then %do;
        %let saveShowXML=&showxml.;
        %end;
    %else %do;
        %let saveShowXML=;
        %end;
        
     /*
      * Force printing of formatted xml
      */
     
     %let showxml=1;

    %showFormattedXML(tree1,Tree1);
    %showFormattedXML(tree2,Tree2);
    
    %if ("&saveShowXML."="") %then %do;
    
        %symdel showxml /nowarn;
        %end;
        
    %else %do;
        %let showxml=&saveShowXML.;
        %end;

    /*
     *  Make the XML easier to compare visually.
     */
    
    filename xmlcomp "&filesDir./portal/permissionsTree/formatTreeForCompare.xslt";
    
    %let outTreeDir=/Data;
    
    %if (%symexist(outTreeDir)) %then %do;
        filename tree1cmp "&outTreeDir./tree1.xml";
        %end;
    %else %do;
       filename tree1cmp temp;
       %end;

    proc xsl in=tree1 out=tree1cmp xsl=xmlcomp;
    run;

    %if (%symexist(outTreeDir)) %then %do;
        filename tree2cmp "&outTreeDir./tree2.xml";
        %end;
    %else %do;
       filename tree2cmp temp;
       %end;
    
    proc xsl in=tree2 out=tree2cmp xsl=xmlcomp;
    run;
    
    filename xmlcomp;

    %showFormattedXML(tree1cmp,Tree1 For Compare);
    %showFormattedXML(tree2cmp,Tree2 For Compare);
    
    filename tree1;
    filename tree2;
    

