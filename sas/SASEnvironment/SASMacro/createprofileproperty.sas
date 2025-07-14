/*
 *  This macro will create a new property in the user's profile area
 *
 *   groupId=the id of the specific propertyset within the user's profile area to add the property
 *   name=the name of the new property
 *   value=the value of the new property
 */

%macro createProfileProperty(groupid=,name=,value=);

%if ("&groupId." = "" or "&name." = "" or "&value." = "") %then %do;

    %put ERROR: Missing parameters to createProfileProperty macro: groupId=&groupId, name=&name., value=&value.;
    %end;
%else %do;

    filename _cppxsl "&filesDir./portal/profile/createUserProfileProperty.xslt";
    filename _cppxml "&filesDir./portal/root.xml"; 
    filename _cppreq temp;
    
    proc xsl in=_cppxml xsl=_cppxsl out=_cppreq;
	        parameter 
	            "propertySet"="&groupId."
	            "propertyName"="&name."
	            "propertyValue"="&value"
	            ;
    run;
    
    filename _cppxsl;
    filename _cppxml;
  
	%showFormattedXML(_cppreq,Add New Property request);
    
    filename _cpprsp temp;
    
    proc metadata in=_cppreq out=_cpprsp;
    run;
    
   	%showFormattedXML(_cpprsp,Add New Property response);

    filename _cppreq;
    
    filename _cpprsp;
    
    %end;
    
%mend;