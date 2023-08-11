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

proc xsl in=outxml xsl=inXSL out=&genout.;
run;

filename outxml;
filename inxsl;
