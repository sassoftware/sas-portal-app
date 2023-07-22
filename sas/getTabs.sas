%inc "&portalAppDir./sas/setup.sas";

filename inxml "&filesDir./getPortalTabList.xml";
   
filename outxml temp;

/*
 *  Get the Portal page info
 */

proc metadata in=inxml out=outxml;
run;

/*

%inc "&stepsDir./showFormattedXML.sas";

*/

/*
 *  Generate the html fragments
 */

filename inxsl "&filesDir./genPortalTabList.xslt";

*filename outHTML temp;

proc xsl in=outxml xsl=inXSL out=_webout;
run;

/*
 *  Copy it to the stream to return
 */
/*
data _null_;
 infile outHTML;
 file _webout;
 input;
 put _infile_;
 run;
*/
filename outxml;
filename inxml;
filename inxsl;
*filename outHTML;