%inc "&portalAppDir./sas/setup.sas";

filename inxml "&filesDir./getPortalContent.xml";
   
filename outxml temp;

%if (%symexist(genout)=0) %then %do;
    %let genout=_webout;
    %end;

/*
 *  Get the Portal page info
 */

proc metadata in=inxml out=outxml;
run;
filename inxml;
/*
%inc "&stepsDir./showFormattedXML.sas";
*/

/*
 *  Generate the html fragments
 */

filename inxsl "&filesDir./genPortalTabContent.xslt";

%put appLocEncoded=&appLocEncoded.;

proc xsl in=outxml xsl=inXSL out=&genout.;

   parameter "appLocEncoded"="&appLocEncoded.";

	/*
	 *  Should we include the wrapper "pages" div tag around generated content?
	 */
/*    
   %if (%symexist(excludePagesDiv)=0) %then %do;
    parameter "includePagesDiv"="1";
    %end;
*/
run;

filename outxml;
filename inxsl;
