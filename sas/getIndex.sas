/*  Generate the main page */

%inc "&portalAppDir./sas/setup.sas";

filename inhtml "&filesDir./index.html.snippet" encoding='utf-8';

data _null_;
 infile inhtml;
 file _webout;
 input;
 put _infile_;
 run;