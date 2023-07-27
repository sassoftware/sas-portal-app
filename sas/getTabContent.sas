%inc "&portalAppDir./sas/setup.sas";

filename inxml "&filesDir./getPortalPageContent.xml";
   
filename outxml temp;

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

filename inxsl "&filesDir./genPortalPageContent.xslt";

proc xsl in=outxml xsl=inXSL out=_webout;
run;

filename outxml;
filename inxsl;
