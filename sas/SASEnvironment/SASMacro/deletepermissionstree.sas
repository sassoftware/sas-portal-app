/*  Delete the named permissions tree */

/*  Parameters (Macro Variables) 

    tree= the name of the permissions tree.
    
    TODO: Have to add logic to iterate down the tree and delete all of its members!
    
*/

%macro deletePermissionsTree(tree=,rc=);

%let _dptRC=-1;

	filename _dptxml temp;
	
	%let treemetadata=_dptxml;

        %getPermissionsTree(outfile=_dptxml,tree=&tree.,existsVar=deleteTreeExists,members=1,memberDetails=1);	

        %if (&deleteTreeExists.) %then %do;
	
			%showFormattedXML(_dptxml,Retrieved Permissions Tree with members );
			
			/*
			 *  Generate the metadata delete request
			 */
			
			filename _dptdxsl "&filesDir./portal/permissionsTree/deletePermissionsTree.xslt";
			
			filename _dptdreq temp;
			
			proc xsl in=_dptxml out=_dptdreq xsl=_dptdxsl;
			run;
			
  			filename _dptdxsl;

		    %checkXSLResult(xml=_dptdreq,rc=_dptdxslrc,msg=Generate Delete request for Permissions tree and members);
		
	        %if ( &_dptdxslrc.=0) %then %do;
	
				filename _dptdrsp temp;

				proc metadata in=_dptdreq out=_dptdrsp;
				run;
				
                %let _dptRC=&syserr.;

		     	%showFormattedXML(_dptdrsp,Response from delete of Permissions tree and members);

                
		        %end;
		    %else %do;
		    
		        %let _dptRC=&_dptdxslrc.;
		        
		        %end;

      		filename _dptdreq;
		
	        
            %end;
            
	  %else %do;
	
	        %put Tree &tree. does not exist.;
	        %let _dptRC=0;
	    
	        %end;
	        
      filename _dptxml;
      
%if ("&rc." ne "") %then %do;

    %global &rc.;
    
    %let &rc.=&_dptRC.;
    
    %end;           
%mend;
