/*  Generate the main page */

%inc "&portalAppDir./sas/setup.sas";

/*
 *  Retrieve the portal metadata
 */

filename inxml "&filesDir./portal/getPortalContent.xml";
   
filename outxml temp;

proc metadata in=inxml out=outxml;
run;

filename inxml;

/*
 *  Generate the main page
 */

filename inxsl "&filesDir./portal/genPortalMain.xslt" encoding='utf-8';

proc xsl in=outxml xsl=inXSL out=_webout;
   parameter "appLocEncoded"="&appLocEncoded."
             "sastheme"="&sastheme."
             "globalMenuBar_skipMenuBar"="&globalMenuBar_skipMenuBar."
             "portalCustomizationMenu"="&portalCustomizationMenu."
             "portalCustomizationMenuTitle"="&portalCustomizationMenuTitle."
             "portalOptionsMenu"="&portalOptionsMenu."
             "portalOptionsMenuTitle"="&portalOptionsMenuTitle."
             "portalSearchMenu"="&portalSearchMenu."
             "portalSearchMenuTitle"="&portalSearchMenuTitle"
             "portalLogoffMenu"="&portalLogoffMenu."
             "portalLogoffMenuTitle"="&portalLogoffMenuTitle."
             "portalHelpMenu"="&portalHelpMenu."
             "portalHelpMenuTitle"="&portalHelpMenuTitle."
             "pageTabs_skipTabMenuTitle"="&pageTabs_skipTabMenuTitle."
             "portletEditContent"="&portletEditContent."
       ;

run;
