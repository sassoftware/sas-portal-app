
/*  Save the changes made on the edit Portlet Content page for the Display URL portlet */

/*
 *  Current parameters supported:
 *
 *  portletURL = the url to display
 *  portletHeight = the height of the portlet
 *
 */

%inc "&portalAppDir./sas/setup.sas";

/*
 *  Get the current values
 *  If the property does not yet exist, create a new property and associate it
 *  If the property does exist, modify it (use objref=)
 */

/*
 *  Retrieve the portlet metadata
 */

filename inxml "&filesDir./portlet/getPortletContent.xml";

filename request temp;

data _null_;

  infile inxml ;
  file request;
  input;

  length line $400;
  /*
   *  Replace the passed id in the metadata request
   */
  line=transtrn(_infile_,'${TYPEID}',"&id.");
  put line;
run;

filename outxml temp;

proc metadata in=request out=outxml;
run;

filename updtxsl "&filesDir./portlet/updateportlet.displayurl.xslt";

filename update temp;

proc xsl in=outxml out=update xsl=updtxsl;

  parameter "portletHeight"="&portletHeight." "portletURL"="&portletURL.";

run;
/*
%put syserr=&syserr.;
%put sysrc=&sysrc.;
%put sysmsg=&sysmsg.;

data _null_;
  infile update;
  input;
  put _infile_;
  run;
*/
  
filename updtxsl;

/*
 *  Now update the properties
 */

filename updtrsp temp;

proc metadata in=update out=updtrsp;
run;

/*
data _null_;
  infile updtrsp;
  input;
  put _infile_;
  run;
*/

filename outxml;

filename update;
filename updtrsp;

/*
 *  Send back to the browser to go back
 */
data _null_;
  file _webout;
  put "<script>history.go(-2)</script>";
run;

