/* 
 *  This program will read the list of users from metadata and create the 
 *  portal content area for each one.
 *
 *  NOTE: This program must be executed as an administrator who has the following
 *        permissions:
 *        - is able to list the registered users on the system
 *        - can create subtrees under the SAS Portal Application Tree tree
 *        - can read existing subtrees under the SAS Portal Application Tree tree (to avoid creating duplicate information)
 */

/*
 *  Get the list of users from metadata
 */

filename request temp;

data _null_;
  infile cards4;
  file request;
  input;
  put _infile_;
cards4;
<GetMetadataObjects>
     <ReposId>$METAREPOSITORY</ReposId>
     <Type>Person</Type>
     <ns>SAS</ns>
     <Flags>0</Flags>
     <Options/>
</GetMetadataObjects>
;;;;
run;

filename response temp;

proc metadata in=request out=response;
run;

filename xmlmap temp;

data _null_;
  infile cards4;
  file xmlmap;
  input;
  put _infile_;
cards4;
<?xml version="1.0" encoding="utf-8"?>
<SXLEMAP version="2.1">

<TABLE name="people">
    <TABLE-PATH syntax="XPath">/GetMetadataObjects/Objects/Person</TABLE-PATH>

    <COLUMN name="Id">
        <PATH syntax="XPath">/GetMetadataObjects/Objects/Person/@Id</PATH>
        <TYPE>character</TYPE>
        <DATATYPE>string</DATATYPE>
        <LENGTH>17</LENGTH>
    </COLUMN>

    <COLUMN name="Name">
        <PATH syntax="XPath">/GetMetadataObjects/Objects/Person/@Name</PATH>
        <TYPE>character</TYPE>
        <DATATYPE>string</DATATYPE>
        <LENGTH>256</LENGTH>
    </COLUMN>

</TABLE>
</SXLEMAP>
;;;;
run;

libname people xmlv2 xmlfileref=response xmlmap=xmlmap;

data work.people;
  set people.people;
run;

filename request;
libname people;
filename xmlmap;
filename response;

/*
 *  Build up the program statements to register these users for later execution.
 */

filename tmpcode temp;

data _null_;
  set work.people;
    
  file tmpcode;
  length codeline $ 1024;

  if _n_=1 then do;
     codeline='%macro registerPortalUsers;';
     put codeline;
     end;
     
  codeline=cats('%put Processing User:',name,';');
  put codeline;
  codeline=cats('%createPortalUser(name=',name,',rc=createPortalUserRC);');
  put codeline;
  codeline=cats('%put createPortalUser returned return code=',"&createPortalUserRC.",';');
  put codeline;
     
run;
data _null_;  
  file tmpcode mod;
  put '%mend;';
  put '%registerPortalUsers;';
run;

/* 
 *  Now run the code just generated.
 */

%inc tmpCode / source2;

/*
 *  Final Cleanup
 */

filename tmpcode;

proc delete data=work.people;
run;
