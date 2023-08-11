/*  Generate the main page */

%inc "&portalAppDir./sas/setup.sas";

/*
 *  Get the fixed html content before the generated tabs list content
 */

%let pagestrt=&filesDir./index.html.start.snippet;

/*
 *  Generate the tab list
 */

filename tablist temp;
%let tablist=%sysfunc(pathname(tablist));

%let genout=tablist;
%inc "&sasDir./getTabs.sas" / source2; 
%symdel genout;

/*
 *  Get the fixed html content after the generated tabs list content, but before the tab content
 */

%let pageend=&filesDir./index.html.end.snippet;

/*
 *  Generate the tab content
 */

filename tabs temp;
%let tabs=%sysfunc(pathname(tabs));

%let genout=tabs;
%inc "&sasDir./getTabContent.sas" / source2; 
%symdel genout;

/*
 *  Put the files together and do any necessary text substitution
 */

filename snippets ("&pagestrt.","&tablist.","&pageend.","&tabs.") encoding="utf-8";

/*
 *  TODO:  Try to avoid doing a lot of text substitution as that operation can be expensive
 *         as the content grows.   Where possible, pass values into the xsl as parameters so that
 *         the values are correct and replaced during html generation!
 */

data _null_;
 infile snippets;
 file _webout;
 input;
 put _infile_;
 *length out $1024;
 /*
  *   Replace the location placeholder with the metadata folder where the application was installed
  */
 *out=transtrn(_infile_,trim(left('${APPLOC}')),trim(left("&appLocEncoded.")));
 *put out;
 
 run;

filename snippets;

filename tabs;
filename tablist;
 