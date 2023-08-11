%inc "&portalAppDir./sas/setup.sas";

%if (%symexist(genout)=0) %then %do;
    %let genout=_webout;
    %end;
    
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

proc xsl in=outxml xsl=inXSL out=&genout.;
run;

filename inxml;
filename inxsl;
filename outxml;
