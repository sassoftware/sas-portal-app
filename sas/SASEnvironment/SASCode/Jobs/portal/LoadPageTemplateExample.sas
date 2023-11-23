/*
 * Load Page Template Example
 *
 * NOTE: This job can only be run after the portal has started at least once.  
 *       If the job is run before you start the portal, some of the referenced 
 *       portlet templates will not be present yet and you'll get an error
 *       stating "The object reference to Prototype was requested without an 
 *       identifier".
 *
 * NOTE: If this sas job is run, the template created herein will not be
 *       visible to users unless either the app server is restarted, or
 *       the admin user logs in -
 *
 * This SAS program provides an example program that creates a page template
 * for the portal Web application.  To create a page template, in the
 * SAS code, update the <variables> in the following lines to contain
 * the appropriate values for your configuration:
 *
 * NOTE: DO NOT modify any other variables or lines in this example SAS program.
 *
 * options metaserver="<host>"
 *  Specify the host name of the SAS Metadata Server. Use the value of the
 *  'iomsrv.metadatasrv.host' property in the configuration.properties file
 *      (located in the Lev1\Web\Utilities subdirectory of the SASCONFIG directory).
 *      For example:
 *         localhost
 *         machine
 *         machine.mycompany.com
 *
 * metaport=<port>
 *  Specify the port number of the SAS Metadata Server. This value is a number
 *      between 0 and 65536. Use the value of the 'iomsrv.metadatasrv.port'
 *      property in the configuration.properties file
 *      (located in the Lev1\Web\Utilities subdirectory of the SASCONFIG directory).
 *
 * metauser="<user ID>"
 *  Specify the user ID to use to connect to the SAS Metadata Server; this user
 *      ID is typically the SAS Trusted User (default, sastrust@saspw). For Windows
 *      users, the user ID is domain or machine name qualified.
 *      For example,
 *         machine\saswbadm  where machine is the local machine
 *         NTDOMAIN\saswbadm where NTDOMAIN is the Windows authentication domain
 *
 * metapass="<password>"
 *  Specify the password for the metauser.
 * metarepository="<repository>";
 *  Specify the name of the SAS Metadata Repository where your portal Web
 *      application metadata is stored, followed by a ";" Use the value of the
 *      'oma.repository.foundation.name' property in the configuration.properties file
 *      (located in the Lev1\Web\Utilities subdirectory of the SASCONFIG directory).
 *
 *
 * %let repositoryName=Foundation;
 *  Specify the name of the SAS Metadata Repository where your portal Web
 *      application metadata is stored, followed by a ";" Use the value of the
 *      'oma.repository.foundation.name' property in the configuration.properties file
 *      (located in the Lev1\Web\Utilities subdirectory of the SASCONFIG directory).
 *
 * %let groupName=<SAS Group>;
 *  Specify the SAS group you wish to add the data to, followed by a ";"
 *      Before you can run this program, the SAS group permission trees
 *      must be created in the SAS Metadata Repository.
 *
 * %let pageName<Page Template Name>;
 *  Specify the name of the page template you wish to create, followed by a ";".
 *
 * %let pageDescription=<page template description>;
 *  Specify the description of the page template you wish to create, followed
 *      by a ";".
 *
 * %let shareType<Sticky or Default>;
 *  Specify whether the page is Sticky or Default, followed by a ";".
 *  Default:
 *     Default user or group pages are automatically added to the portal Web
 *     application of the user, or all users in a group. The users can then remove
 *     the page if they do not need it.
 *  Sticky:
 *     Sticky group pages are automatically added to the portal Web application of
 *     the user, or all users in the group and the users cannot remove them.
 *
 * %let profile=DESKTOP_PROFILE;
 *  DO NOT change this value.
 *
 * %let role=DefaultRole;
 *  DO NOT change this value.
 *
 * %let pageRank=<pageRank>;
 *  Specify the page rank you want on this page template, followed by a ";"
 *      All pages created from this page template will have this page rank.
 *
 *
 * data pageTemplate;
 *  Specifies the SAS dataset that defines the data values for the page
 *  template contents.
 *  DO NOT modify the section between the "data pageTemplate" line and the \
 *      "cards4" line. This section describes the data in the dataset as follows:
 *  data pageTemplate;
 *  length portletName $80 portletDescription $256 prototypeName $80;
 *  infile cards4 delimiter=',';
 *  input columnNum portletPos portletName portletDescription prototypeName;
 *  cards4;
 *
 *  The data between the "cards4" line and the ";;;;" line describes each
 *      portlet (1 / line) that you wish to place on the page template. The line is
 *      formatted as a csv (comma separated values) and each column denotes a
 *      different value for the portlet.
 *      For example, the following lines create 4 portlets, two in each page column:
 *
 *  1,1,Bookmarks,Bookmarks portlet Description,Bookmarks template
 *  1,2,Alerts,Alerts portlet Description,Alerts template
 *  2,1,My collection Portlet,Description of collection portlet,
 *      Collection template
 *  2,2,Welcome,Welcome portlet Description,Welcome template
 *  ;;;;
 *
 *      Specify the information for each portlet as follows:
 *  columnNum
 *      Specifies the column number on the page in which to place
 *      the portlet. Each page in the portal Web application can
 *      have multiple columns (maximum of 3 columns).
 *  portletPos
 *      Specifies the order of the portlets within the column; the portlets
 *      are ordered from lowest number to highest number.
 *  portletName
 *      Specifies the name of the portlet to add. If a portlet already
 *      exists with the
 *      same portletName, the existing portlet is used and a new portlet
 *      will not be created. This field cannot contain a comma.
 *  portletDescription
 *      Specifies the description of the portlet to add. This field
 *      cannot contain a comma.
 *  prototypeName
 *      Specifies the name of the prototype that was created when the
 *      portlet was deployed. This field cannot contain a comma.
 *
 * data properties;
 *  Specifies the SAS dataset that defines any additional properties that are
 *      needed by the portlets.  (This variable enables you to add default starting data
 *      to template portlets). If there are no additional properties for any
 *      portlets, then delete the section between the cards4; and ;;;; lines.
 *  DO NOT modify the section between the "data properties" line and the
 *      "cards4" line. This section describes the data in the dataset as follows:
 *  data properties;
 *  length colPos $80 propName $80 propValue $80;
 *  infile cards4 delimiter=',';
 *  input colPos propName propValue;
 *  cards4;
 *
 *  The data between the "cards4" line and the ";;;;" line describes each
 *      property (1 / line) that you wish to define. The line is formatted as a
 *      csv (comma separated values) and each column denotes a portion of the
 *      property definition..
 *      For example, the following lines create 4 properties, one for the first
 *      portlet in the first column and three for the first portlet in the
 *      second column.
 *
 *      1_1,Name0,DefaultValue 0
 *      2_1,MyCollectionPortletPropertyName1,My Collection Portlet Property DefaultValue 1
 *      2_1,MyCollectionPortletPropertyName2,My Collection Portlet Property DefaultValue 2
 *      2_1,MyCollectionPortletPropertyName3,My Collection Portlet Property DefaultValue 3
 *  ;;;;
 *
 *      Specify the information for each property as follows:
 *  colPos
 *      Specifies the column and position of the portlet to which you are adding this property.
 *          Format is <col>_<pos>.
 *  propName
 *      Specifies the name of the property to add.  This field cannot contain a
 *          comma.
 *  propValue
 *      Specifies the value of the property to add. This field  cannot contain
 *          a comma
 *
 * data collectionData;
 *  Specifies the SAS dataset that defines any collection or bookmark links to
 *      add to Collection or Bookmarks portlets.  If there are no links desired for
 *      any portlets, then delete the section between the cards4; and ;;;; lines.
 *  DO NOT modify the section between the "data collectionData" line and the
 *      "cards4" line. This section describes the data in the dataset as follows:
 *  data collectionData;
 *  length colPos $80 dataType $80 searchStr $80;
 *  infile cards4 delimiter=',';
 *  input colPos dataType searchStr;
 *  cards4;
 *
 *  The data between the "cards4" line and the ";;;;" line describes each
 *      link (1 / line) that you wish to add to Collection or Bookmarks
 *      portlets. The line is formatted as a csv (comma separated values) and
 *      each column denotes a portion of the link definition.
 *      For example, the following lines create 3 links, one for the first
 *      portlet in the first column and two for the first portlet in the
 *      second column.
 *
 *      1_1,Document,@Name='SAS'
 *      2_1,Document,@Name='SAS'
 *      2_1,Document,@Name='SAS Integration Technologies'
 *  ;;;;
 *
 *      Specify the information for each link as follows:
 *  colPos
 *      Specifies the column and position of the portlet to which you are adding this link.
 *          Format is <col>_<pos>.
 *  dataType
 *      Specifies the metadata type of the data that should be added to the
 *          Collection or Bookmarks portlet.
 *  searchStr
 *      Specifies an XMLSelect string that will uniquly find the desired data to
 *          add to the Collection or Bookmarks portlet. If the data is
 *          not found, this program will continue executing, ignore this entry, and
 *          print a WARNING to the log.
 *
 *
 *
 *
 * For Example:
 * ------------
 * options metaserver="localhost"
 *   metaport=8561
 *   metauser="sastrust@saspw"
 *   metapass="<password>"
 *   metarepository="Foundation";
 *
 * %let repositoryName=Foundation;
 * %let groupName=Group 3 Portal Users;
 * %let pageName=Test Template page;
 * %let pageDescription=Test Template page description;
 * %let shareType=Default;
 * %let profile=DESKTOP_PROFILE;
 * %let role=DefaultRole;
 * %let pageRank=100;
 * 
 */

/*  Set metadata options to specify the server. */
/*
options metaserver=""
  metaport=
  metauser=""
  metapass=""
  metarepository="";
*/

%let repositoryName=Foundation;
%let groupName=Group 3 Portal Users;;
%let pageName=Test Template page;
%let pageDescription=Test Template page description;
%let shareType=Default;
%let profile=DESKTOP_PROFILE;
%let role=DefaultRole;
%let pageRank=100;

data pageTemplate;
  length portletName $80 portletDescription $256 prototypeName $80;
  infile cards4 delimiter=',';
  input columnNum portletPos portletName portletDescription prototypeName;
  cards4;
1,1,Bookmarks,Bookmarks portlet Description,Bookmarks template
1,2,Alerts,Alerts portlet Description,Alerts template
2,1,My collection Portlet,Description of collection portlet,Collection template
2,2,Welcome,Welcome portlet Description,Welcome template
;;;;

data properties;
  length colPos $80 propName $80 propValue $80;
  infile cards4 delimiter=',';
  input colPos propName propValue;
  cards4;
1_1,Name0,DefaultValue 0
2_1,MyCollectionPortletPropertyName1,My Collection Portlet Property DefaultValue 1
2_1,MyCollectionPortletPropertyName2,My Collection Portlet Property DefaultValue 2
2_1,MyCollectionPortletPropertyName3,My Collection Portlet Property DefaultValue 3
;;;;

data collectionData;
  length colPos $80 dataType $80 searchStr $80;
  infile cards4 delimiter=',';
  input colPos dataType searchStr;
  cards4;
1_1,Document,@Name='SAS'
2_1,Document,@Name='SAS'
2_1,Document,@Name='SAS Integration Technologies'
;;;;

/************************************************************
 * Do not modify below this line
 ************************************************************/

/* **********************  Define tempFile Macro ************************** */

%macro tempFile( fname );
  %if %superq(SYSSCPL) eq %str(z/OS) or %superq(SYSSCPL) eq %str(OS/390) %then
    %let recfm=recfm=vb;
  %else
    %let recfm=;
  filename &fname TEMP lrecl=2048 &recfm;
%mend;

%macro statusCheck();
  /* &syserr seems to be reset at every step boundary.
   * We'll assign its current value when the macro is invoked to
   * a global var named errcode. Then if errcode is ever > 0,
   * we can print a suitable message.
    * If syserr = 4, execution was successful, but warnings occurred.
    * Keep track of those separately.
   */
%global ERRCODE;
    %*initialize it once;
    %if &errcode eq %then %let errcode = 0;

    %* if syserr ever not zero then set errcode to that value.;
    %if (&syserr ne 0 and &syserr ne 4) %then %let errcode = &syserr;

%global WARNCODE;
    %*initialize it once;
    %if &warncode eq %then %let warncode = 0;

    %* if syserr ever = 4 then set warncode to that value.;
    %if &syserr = 4 %then %let warncode = &syserr;
%mend statusCheck;

%macro statusPrint;
data _null_;
/* Assure that errors print. If no errors, but warnings, then print them.
 * If neither of the above, print success!
 */
    if &errcode ne 0 then putlog "ERROR: An error occurred while loading metadata.";
    else if &warncode ne 0 then
        putlog "WARNING: Loading metadata generated warnings.";
    else putlog  "NOTE: Successfully loaded metadata.";
run;
%mend statusPrint;


/*  Define macro to find metadata object IDs.

    Parameters:

    VARNAME  - name of a macro variable that will be set to the object ID.
               Set to blank if no matching object is found.  Set to the
               first matching object if more than one object is found.
    OBJTYPE  - An OMA type.  For example, AuthenticationDomain or LogicalServer
    SEARCH   - An XMLSelect string defining the match criteria.  For example,
               @Name='My Object Name'.

    Example:

    %getMetadataID(DOMAIN_ID, AuthenticationDomain, @Name='sas.com');

    finds an AuthenticationDomain named 'sas.com' and returns it in
    the DOMAIN_ID global macro variable.
*/

%macro getMetadataID(VARNAME,OBJTYPE,SEARCH);

  /*  Build the GetMetadata request. */

  %tempFile(request);
  data _null_;
    file request;
    put "<GetMetadataObjects>";
    put "<ReposId>$METAREPOSITORY</ReposId>";
    put "<Type>&OBJTYPE</Type>";
    put "<Objects/>";
    put "<ns>SAS</ns>";
    put "<Flags>128</Flags>";
    put "<Options>";
    put "%bquote(<XMLSelect search="&SEARCH"/>)";
    put "</Options>";
    put "</GetMetadataObjects>";
    run;

  /*  Issue the request. */

  %tempFile(response);
  proc metadata
    in=request
    out=response;
    run;


  /*  Build the XML Map file to parse the response. */

  %tempFile(map);
  data _null_;
    file map encoding="utf-8";
    put '<?xml version="1.0" encoding="utf-8"?>';
    put '<SXLEMAP version="1.0">';
    put '<TABLE name="respid">';
    put "<TABLE_XPATH>//&OBJTYPE.</TABLE_XPATH>";

    put '<COLUMN name="Id">';
    put "<XPATH>//&OBJTYPE.@Id</XPATH>";
    put '<TYPE>character</TYPE>';
    put '<DATATYPE>STRING</DATATYPE>';
    put '<LENGTH>17</LENGTH>';
    put '</COLUMN>';

    put '<COLUMN name="prototypeName">';
    put "<XPATH>//&OBJTYPE.@Name</XPATH>";
    put '<TYPE>character</TYPE>';
    put '<DATATYPE>STRING</DATATYPE>';
    put '<LENGTH>80</LENGTH>';
    put '</COLUMN>';

    put '</TABLE>';
    put '</SXLEMAP>';

    run;

  /*  Parse the response with the XML library engine and PROC SQL. */

  libname response xml xmlmap=map;

  %global &VARNAME;
  %let &VARNAME=;

  %local NOBS;
  proc sql noprint ;
    select Id, count(Id)
    into   :&VARNAME, :NOBS
    from   response.respid;
    quit;

  /*  Cleanup. */
  *filename request;
  *filename response;
  *filename map;
  *libname  response;

  %put;
  %if %superq(&VARNAME) eq %then
    %put WARNING: Unable to find &OBJTYPE matching "&SEARCH";
  %else %if %eval(&NOBS) gt 1 %then
    %put NOTE: Found %cmpres(&NOBS) matching &OBJTYPE.s.  Using first object %superq(&VARNAME);
  %else
    %put NOTE: Found &OBJTYPE %superq(&VARNAME);
%mend;

%macro updateSharingProperty();
   data _null_;
       length uri $256;
       length dataId $20;
       length type $80;
       length searchStr $256;

       /* Find and delete the Property */
       type="Property";
       searchStr="@Name='Portal.LastSharingPerformed'";

       uri="omsobj:" || strip(type) || "?" || strip(searchStr);
       dataId="";

       * Resolve the URI;
       retcode=metadata_resolve(uri,type,dataId);

       if (retcode > 0) then do;

           rc=metadata_setattr(uri,"DefaultValue","-1");
           put rc=;
           putlog "Metadata for " uri +(-1) " was updated!";

       end;
       else if (retcode = -1) then do;
           putlog "WARNING: Unable to connect to the metadata server.";
       end;
       else if (retcode = -2) then do;
           putlog "WARNING: Unable to set attribute for " uri +(-1) " 'DefaultValue'.";
       end;
       else if (retcode = -3) then do;
           putlog "WARNING: Metadata for " uri +(-1) " was not found.";
       end;

       run;
%mend;

/* Initialize */
%let errcode = 0;
%let warncode = 0;


/* Verify that the page template does not already exist */
%getMetadataID(PAGE_TREE, Tree, Tree[@Name='&pageName'][ParentTree/Tree[@Name='&shareType']/ParentTree/Tree[@Name='&profile']/ParentTree/Tree[@Name='&role']/ParentTree/Tree[@Name='RolesTree']/ParentTree/Tree[@Name='&groupName Permissions Tree']]);
data _null_;
 if length("&PAGE_TREE") > 1 then
    do;
        putlog "ERROR: Aborting because the Page template Tree &pageName already exists!";
        abort return;
    end;
else do;
    putlog "NOTE: Ignore above warning about tree not existing.";
end;
run;


/* Get the tree to add the template to */
%getMetadataID(PARENT_TREE, Tree, Tree[@Name='&shareType'][ParentTree/Tree[@Name='&profile']/ParentTree/Tree[@Name='&role']/ParentTree/Tree[@Name='RolesTree']/ParentTree/Tree[@Name='&groupName Permissions Tree']]);

%macro createParentTreeIfNeeded();
    %* If the parent tree does not exist;
    %* The if below is checking for equality to 17 blanks;
    %if &PARENT_TREE=                  %then %do;
        %* Create the group permissions tree layers;
        data _null_;
            length dataId $20;
            length rolesTreeURI $256;
            length defaultRoleURI $256;
            length desktopProfileURI $256;
            length stickyURI $256;
            length defaultURI $256;
        
            dataId="";
            rolesTreeURI="";
            defaultRoleURI="";
            desktopProfileURI="";
            stickyURI="";
            defaultURI="";
    
            %* Format the uri for the permissions tree;
            permTreeURI="omsobj:Tree?@Name='&groupName Permissions Tree'";
        
            %* If the permissions tree was found;
            putlog "INFO: Looking for " permTreeURI;
            retcode=metadata_resolve(permTreeURI, "Tree", dataId);
            if (retcode > 0) then do;
                putlog "INFO: Found " permTreeURI;
        
                %* Create the RolesTree tree;
                retcode = metadata_newobj("Tree", rolesTreeURI, "RolesTree", "", permTreeURI, "SubTrees");
                if (retcode >= 0) then do;
                    putlog "INFO: Created RolesTree " rolesTreeURI;
        
                    %* Create the DefaultRole tree;
                    retcode = metadata_newobj("Tree", defaultRoleURI, "DefaultRole", "", rolesTreeURI, "SubTrees");
                    if (retcode >= 0) then do;
                        putlog "INFO: Created DefaultRole " defaultRoleURI;
        
                        %* Create the profile tree;
                        retcode = metadata_newobj("Tree", desktopProfileURI, "DESKTOP_PROFILE", "", defaultRoleURI, "SubTrees");
                        if (retcode >= 0) then do;
                            putlog "INFO: Created DESKTOP_PROFILE " desktopProfileURI;
        
                            %* Create the Sticky tree;
                            retcode = metadata_newobj("Tree", stickyURI, "Sticky", "", desktopProfileURI, "SubTrees");
                            if (retcode >= 0) then do;
                                putlog "INFO: Created Sticky " stickyURI;
            
                                %* Create the Default tree;
                                retcode = metadata_newobj("Tree", defaultURI, "Default", "", desktopProfileURI, "SubTrees");
                                if (retcode >= 0) then do;
                                    putlog "INFO: Created Default " defaultURI;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
            else if (retcode = 0) then do;
                putlog "ERROR: Could not find permissions tree!  " permTreeURI;
                abort return;
            end;
        
            if (retcode = -1) then do;
                putlog "ERROR: Unable to connect to the metadata server.";
                abort return;
            end;
            else if (retcode < 0) then do;
                putlog "ERROR: Could not create metadata.  rc=" retcode;
                abort return;
            end;
        
            run;
    %end;
    %else %do;
        %put INFO: Parent Tree Found!;
    %end;
%mend createParentTreeIfNeeded;

/* Call the macro */
%createParentTreeIfNeeded;

/* Get the parent tree again */
%getMetadataID(PARENT_TREE, Tree, Tree[@Name='&shareType'][ParentTree/Tree[@Name='&profile']/ParentTree/Tree[@Name='&role']/ParentTree/Tree[@Name='RolesTree']/ParentTree/Tree[@Name='&groupName Permissions Tree']]);

%getMetadataID(StringType, PropertyType, @Name='String');

/*
 *  SBIP URLs require spaces to be changed to + in the repository name
 */
%global sbip_repository_name;

data _null_;
  length transstring $256;
  transstring = translate("&repositoryName", '+', ' ');
  call symput('sbip_repository_name', trim(transstring));
run;


/* Get all of the PSPortlet templates */
%getMetadataID(AllPrototypes, Prototype, @MetadataType='PSPortlet');
/*
title 'Printing response table';
proc print data=response.respid;
run;
*/

/* Sort the datasets prior to merging */
proc sort data= pageTemplate; by prototypeName;
run;

/*
 * For some reason, sorting response.respid doesn't really sort.  We copy
 * the contents to a new dataset to bypass this problem.
 */
data prototypes;
    set response.respid;
run;

proc sort data=prototypes; by prototypeName;
run;

/*
title 'Printing sorted prototypes';
proc print data=prototypes;
run;
*/

/* Merge on prototypeName so that the new table has the prototype object id too */
data newTemplate;
  merge pageTemplate(in= inPageTemplate) prototypes;
   by prototypeName;
   if inPageTemplate;
run;

/* resort based on original intention */
proc sort data= newTemplate; by columnNum portletPos;
run;

/*
title 'Printing new template';
proc print data=newTemplate;
run;
*/

/* Output the starting XML */
data _x;
    length LongVar $200;
    longVar = "<AddMetadata><Metadata>";
    output;

    /* Output the start of the page template */
    longVar = "<Tree name='&pageName' desc='&pageDescription' TreeType='PortalPageTemplate'>";
    output;
run;

/* Output the page template */
data _y;
    length LongVar $200;
    set newTemplate END=last;
    by columnNum;

    /* Output the start of the page template */
    if _N_ = 1 then do;
        longVar = "    <SubTrees>";
        output;
    end;

    /* Output the column heading on the first of this column */
    if FIRST.columnNum then do;
        longVar = "        <Tree name='Column " || strip(columnNum) || "' desc='Column " || strip(columnNum) || "' TreeType='PortalPageColumnTemplate'>";
        output;
        longVar = "            <Members>";
        output;
    end;

    /* Output this portlet */
    longVar = "                <Group name='Portlet Template Group' desc='" || strip(portletName) || "," || strip(portletDescription) || "' id='$colPos" || strip(columnNum) || "_" || strip(portletPos) || "'>";
    output;
    longVar = "                    <Members>";
    output;
    longVar = "                        <Prototype ObjRef='" || strip(Id) || "' />";
    output;
    longVar = "                    </Members>";
    output;
    longVar = "                </Group>";
    output;

    /* Output the ending column XML on the last of this column */
    if LAST.columnNum then do;
        longVar = "            </Members>";
        output;
        longVar = "        </Tree>";
        output;
    end;

    /* Output ending XML for the page template */
    if last then do;
        longVar = "    </SubTrees>";
        output;
    end;

run;


Proc datasets nolist lib= work;
append base= _x data = _y force;
quit;

data _y;
    length LongVar $200;

    /* Output ending XML for the page template */
    longVar = "    <ParentTree>";
    output;
    longVar = "        <Tree ObjRef='&parent_Tree' />";
    output;
    longVar = "    </ParentTree>";
    output;
    longVar = "    <Extensions>";
    output;
    longVar = "        <Extension Name='PageRank' Value='&pageRank' />";
    output;
    longVar = "    </Extensions>";
    output;
    longVar = "</Tree>";
    output;
run;

Proc datasets nolist lib= work;
append base= _x data = _y force;
quit;

/* Make sure we're sorted correctly */
proc sort data= properties; by colPos;
run;

/* Output the properties for the portlets */
data _y;
    length LongVar $200;
    set properties END=last;
    by colPos;

    /* Output the column heading on the first of this column */
    if FIRST.colPos then do;
        longVar = "        <PropertySet Name='PORTLET_CONFIG_ROOT'>";
        output;
        longVar = "            <OwningObject>";
        output;
        longVar = "                 <Group ObjRef='$colPos" || strip(colPos) || "' />";
        output;
        longVar = "            </OwningObject>";
        output;
        longVar = "            <SetProperties>";
        output;
    end;

    /* Output the property */
    * putlog "NOTE: Adding property " propName +(-1) " with value " propValue +(-1) " to position " colPos +(-1);
    longVar = "                    <Property name='" || strip(propName) || "' desc='" || strip(propName) || "' DefaultValue='" || strip(propValue) || "'>";
    output;
    longVar = "                        <OwningType>";
    output;
    longVar = "                            <PropertyType ObjRef='&StringType'/>";
    output;
    longVar = "                        </OwningType>";
    output;
    longVar = "                    </Property>";
    output;

    /* Output the ending XML on the last of this column */
    if LAST.colPos then do;
        longVar = "            </SetProperties>";
        output;
        longVar = "        </PropertySet>";
        output;
    end;
run;

Proc datasets nolist lib= work;
append base= _x data = _y force;
quit;

/* Make sure we're sorted correctly */
proc sort data= properties; by colPos;
run;

/* Output the collection data for the portlets */
data _y;
    length LongVar $200;
    set collectionData END=last;
    by colPos;

    /* Output the collection start for this portlet */
    if FIRST.colPos then do;
        longVar = "        <Group Name='Portal Collection' Desc='Additional collection data for template portlet'>";
        output;
        longVar = "            <Groups>";
        output;
        longVar = "                <Group ObjRef='$colPos" || strip(colPos) || "' />";
        output;
        longVar = "            </Groups>";
        output;
        longVar = "            <Members>";
        output;
    end;

    /* Output the reference to the data */
    length uri $256;
    length dataId $20;
    length type $80;
    type=dataType;
    uri="omsobj:" || strip(dataType) || "?" || strip(searchStr);
    dataId="";
    * putlog "NOTE: Adding data " uri +(-1) " to position " colPos +(-1);
    rc=metadata_resolve(uri,type,dataId);
    if (rc > 0) then do;
        longVar = "                    <" || strip(dataType) || " ObjRef='" || strip(dataId) || "'/>";
        output;
    end;
    else do;
        putlog "WARNING: Data for " uri +(-1) " at position " colPos +(-1) " was not found!";
    end;

    /* Output the ending XML on the last of this collection */
    if LAST.colPos then do;
        longVar = "            </Members>";
        output;
        longVar = "        </Group>";
        output;
    end;
run;

Proc datasets nolist lib= work;
append base= _x data = _y force;
quit;

/* Output the ending XML */
data _y;
    length LongVar $200;
    longVar = "</Metadata>";
    output;
    longVar = "<Reposid>$METAREPOSITORY</Reposid>";
    output;
    longVar = "<Ns>SAS</Ns>";
    output;
    longVar = "<Flags>268435456</Flags>";
    output;
    longVar = "<Options/>";
    output;
    longVar = "</AddMetadata>";
    output;
run;

Proc datasets nolist lib= work;
append base= _x data = _y force;
quit;

/* load the data into a temp file */
%tempFile(tempxml);
data _null_;
file tempxml;
do i = 1 to _n_;
    set _x;
    put longVar;
end;
run;

/* Load the data to the server */
proc metadata
  in=tempxml;
  run;
%statusCheck;
quit;

/* Cleanup */
filename tempxml;
filename request;
filename response;
filename map;
libname  response;
Proc datasets  nolist lib=work;
  delete _x;
  delete _y;
  delete pageTemplate;
  delete newTemplate;
  delete prototypes;
quit;

%updateSharingProperty;
%statusPrint;
