%macro openlink(out=_webout, rc=linksearchRC);
    
    %let _olRC=0;
    %let openlinkProcessor = &filesDir./portlet/render.openlink.xslt;
    %let rootProcessor = &filesDir./portal/root.xml;
    %let linkObjectUrlProcessor = &filesDir./portlet/render.openlink.xslt;
    
    filename _olxsl "&openlinkProcessor.";
    
    filename _rootxml "&rootProcessor.";
    
    filename _olout temp;
    proc xsl in=_rootxml xsl=_olxsl out=_olout;
      parameter "objectPath"="&objectPath";
    run;
    
    /*  Show the generated query */
    
    %showFormattedXML(_olout,Show render.openlink.xslt query);
    
    
    /*  Execute the generated query */
    
    filename xmlresp temp;
    
    proc metadata in=_olout out=xmlresp;
    run;
    
    %showFormattedXML(xmlresp,Document search getter metadata response);
    
    
    filename _urixsl "&linkObjectUrlProcessor.";
    
    proc xsl in=xmlresp xsl=_urixsl out=&out.;
    run;
    
    filename _urixsl;
    
    %if ("&rc." ne "" ) %then %do;
        %global &rc.;
        %let &rc.=&_olRC.;
        %end;
    
%mend;