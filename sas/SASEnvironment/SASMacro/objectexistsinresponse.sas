%macro objectExistsInResponse(infile=,type=,existsVar=);
  
  %let oexmlmap=_oemap;
  filename &oexmlmap. temp;
  
  data _null_;
    file &oexmlmap. encoding="utf-8";
put '<?xml version="1.0" encoding="utf-8"?>';
put '<SXLEMAP version="2.1">';
put "<TABLE name=""Tree"">";
put '<TABLE_PATH  syntax="XPath">';
put "/GetMetadataObjects/Objects/&type.";
put '</TABLE_PATH>';
put '<COLUMN name="Id"  syntax="XPath">';
put "<PATH>/GetMetadataObjects/Objects/&type.@Id</PATH>";
      put '<TYPE>character</TYPE>';
      put '<DATATYPE>STRING</DATATYPE>';
      put '<LENGTH>17</LENGTH>';
   put '</COLUMN>';

   put '<COLUMN name="Name"  syntax="XPath">';
      put "<PATH>/GetMetadataObjects/Objects/&type.@Name</PATH>";
      put '<TYPE>character</TYPE>';
      put '<DATATYPE>STRING</DATATYPE>';
      put '<LENGTH>80</LENGTH>';
   put '</COLUMN>';

put '</TABLE>';
put '</SXLEMAP>';
    run;

data _null_;
 infile &oexmlmap.;
 input;
 put _infile_;
run;

  /*  Parse the response with the XML library engine and PROC SQL. */

libname _oeresp xmlv2 xmlmap=&oexmlmap. xmlfileref=&infile.;

%let xmlToFormat=&infile.;
%inc "&stepsDir./showFormattedXML.sas";
%symdel xmlToFormat / nowarn;

  %let objectId=;

  proc sql noprint ;
    select Id, count(Id)
    into   :ObjectId, :NOBS
    from   _oeresp.&type.;
    quit;

%put &objectId.;
%put &nobs.;

%global &existsvar.;
%let &&existsVar.=&NOBS.;

libname _oeresp;

filename &oexmlmap.;

%mend;



