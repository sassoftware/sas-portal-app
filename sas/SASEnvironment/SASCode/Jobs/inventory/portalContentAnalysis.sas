/*
 *  Change this macro variable to point to the output file of the dumpAllPortalContent.sas program.
 */

%let responseFile=/Data/portal-content.xml;

filename rsp "&responseFile.";

filename xsl temp;

data _null_;
  infile cards4;
  file xsl;
  input;
  put _infile_;
cards4;
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!--  PSPortlet Processing -->

<xsl:template match="PSPortlet">
  <xsl:param name="ownerType"/>
  
  <xsl:element name="PSPortlet">
  	<xsl:attribute name="Id" select="@Id"/>
  	<xsl:attribute name="Name" select="@Name"/>
  	<xsl:attribute name="PortletType" select="@portletType"/>
  	<xsl:attribute name="OwnerType" select="@ownerType"/>
  	
  	<xsl:variable name="parentNodeName"><xsl:value-of select="name(../../../..)"/></xsl:variable>
  	
  	<xsl:choose>
  	  <xsl:when test="$parentNodeName='PSPortalPage'">
	     <xsl:attribute name="parent"><xsl:value-of select="$parentNodeName"/>:<xsl:value-of select="../../../../@Id"/></xsl:attribute>
	  </xsl:when>
	  <xsl:otherwise>
	     <xsl:attribute name="parent"/>
	  </xsl:otherwise>
	 </xsl:choose>
	 
  </xsl:element>

</xsl:template>

<!--  PSPortalPage Processing -->

<xsl:template match="PSPortalPage">

  <xsl:param name="ownerType"/>

  <xsl:variable name="pageType">
  
     <xsl:choose>
     
        <xsl:when test="Extensions/Extension[@Name='SharedPageAvailable']">
            SharedPageAvailable
        </xsl:when>
        <xsl:when test="Extensions/Extension[@Name='SharedPageDefault']">
            SharedPageDefault
        </xsl:when>
        <xsl:when test="Extensions/Extension[@Name='SharedPageSticky']">
            SharedPageSticky
        </xsl:when>
        
        <xsl:otherwise>
            Personal
        </xsl:otherwise>
     </xsl:choose>
  </xsl:variable>
  
  <xsl:element name="PSPortalPage">
  
    <xsl:attribute name="Id" select="@Id"/>
    <xsl:attribute name="Name" select="@Name"/>
    <xsl:attribute name="ownerType" select="$ownerType"/>
    <xsl:attribute name="pageType" select="$pageType"/>
    
    <xsl:attribute name="parent"><xsl:value-of select="name(../..)"/>:<xsl:value-of select="../../@Id"/></xsl:attribute>
    
  </xsl:element>
  
</xsl:template>

<!--  Permissions Tree Processing -->

<xsl:template match="Tree">
  <xsl:variable name="ownerType"><xsl:value-of select="name(AccessControls/AccessControlEntry/Identities/*)"/></xsl:variable>
  
  <xsl:element name="Tree">
    <xsl:attribute name="Id" select="@Id"/>
    <xsl:attribute name="Name" select="@Name"/>
    <xsl:attribute name="TreeType" select="@TreeType"/>
    <xsl:attribute name="TreeOwnerType" select="$ownerType"/>
    
  </xsl:element>

  <!-- I just couldn't find a way to properly navigate the returned xml to get all of the right objects (getting all the values because of the no duplicat option passed on the xml query)
       thus, going to just get all and the de-dup them later.
    -->
		  <xsl:apply-templates select=".//PSPortalPage">
		       <xsl:with-param name="ownerType"><xsl:value-of select="$ownerType"/></xsl:with-param>
		  </xsl:apply-templates>
          
          <xsl:apply-templates select=".//PSPortlet">
		       <xsl:with-param name="ownerType"><xsl:value-of select="$ownerType"/></xsl:with-param>          
          </xsl:apply-templates>		       
  
</xsl:template>

<xsl:template match="/">

   <PortalContent>
   <xsl:apply-templates select="/GetMetadataObjects/Objects/Tree/SubTrees/*"/>
   </PortalContent>
   
</xsl:template>

</xsl:stylesheet>
;;;;
run;

filename rspsum temp;

proc xsl in=rsp xsl=xsl out=rspsum;
run;
/*
%let SHOWXML=1;
%showFormattedXML(rspsum);
*/
filename portmap temp;

data _null_;

 infile cards4;
 file portmap;
 input;
 put _infile_;
cards4;
<?xml version="1.0" encoding="utf-8"?>
<SXLEMAP version="2.1">

<TABLE name="trees">
    <TABLE-PATH syntax="XPath">/PortalContent/Tree</TABLE-PATH>

    <COLUMN name="Id">
        <PATH syntax="XPath">/PortalContent/Tree/@Id</PATH>
        <TYPE>character</TYPE>
        <DATATYPE>string</DATATYPE>
        <LENGTH>17</LENGTH>
    </COLUMN>

    <COLUMN name="Name">
        <PATH syntax="XPath">/PortalContent/Tree/@Name</PATH>
        <TYPE>character</TYPE>
        <DATATYPE>string</DATATYPE>
        <LENGTH>200</LENGTH>
    </COLUMN>

    <COLUMN name="TreeType">
        <PATH syntax="XPath">/PortalContent/Tree/@TreeType</PATH>
        <TYPE>character</TYPE>
        <DATATYPE>string</DATATYPE>
        <LENGTH>200</LENGTH>
    </COLUMN>

    <COLUMN name="TreeOwnerType">
        <PATH syntax="XPath">/PortalContent/Tree/@TreeOwnerType</PATH>
        <TYPE>character</TYPE>
        <DATATYPE>string</DATATYPE>
        <LENGTH>200</LENGTH>
    </COLUMN>
</TABLE>
<TABLE name="pages">
    <TABLE-PATH syntax="XPath">/PortalContent/PSPortalPage</TABLE-PATH>

    <COLUMN name="Id">
        <PATH syntax="XPath">/PortalContent/PSPortalPage/@Id</PATH>
        <TYPE>character</TYPE>
        <DATATYPE>string</DATATYPE>
        <LENGTH>17</LENGTH>
    </COLUMN>

    <COLUMN name="Name">
        <PATH syntax="XPath">/PortalContent/PSPortalPage/@Name</PATH>
        <TYPE>character</TYPE>
        <DATATYPE>string</DATATYPE>
        <LENGTH>200</LENGTH>
    </COLUMN>

    <COLUMN name="Type">
        <PATH syntax="XPath">/PortalContent/PSPortalPage/@pageType</PATH>
        <TYPE>character</TYPE>
        <DATATYPE>string</DATATYPE>
        <LENGTH>200</LENGTH>
    </COLUMN>

    <COLUMN name="OwnerType">
        <PATH syntax="XPath">/PortalContent/PSPortalPage/@OwnerType</PATH>
        <TYPE>character</TYPE>
        <DATATYPE>string</DATATYPE>
        <LENGTH>200</LENGTH>
    </COLUMN>

    <COLUMN name="parent">
        <PATH syntax="XPath">/PortalContent/PSPortalPage/@parent</PATH>
        <TYPE>character</TYPE>
        <DATATYPE>string</DATATYPE>
        <LENGTH>200</LENGTH>
    </COLUMN>
</TABLE>

<TABLE name="portlets">
    <TABLE-PATH syntax="XPath">/PortalContent/PSPortlet</TABLE-PATH>

    <COLUMN name="Id">
        <PATH syntax="XPath">/PortalContent/PSPortlet/@Id</PATH>
        <TYPE>character</TYPE>
        <DATATYPE>string</DATATYPE>
        <LENGTH>17</LENGTH>
    </COLUMN>

    <COLUMN name="Name">
        <PATH syntax="XPath">/PortalContent/PSPortlet/@Name</PATH>
        <TYPE>character</TYPE>
        <DATATYPE>string</DATATYPE>
        <LENGTH>200</LENGTH>
    </COLUMN>

    <COLUMN name="Type">
        <PATH syntax="XPath">/PortalContent/PSPortlet/@PortletType</PATH>
        <TYPE>character</TYPE>
        <DATATYPE>string</DATATYPE>
        <LENGTH>200</LENGTH>
    </COLUMN>

    <COLUMN name="OwnerType">
        <PATH syntax="XPath">/PortalContent/PSPortlet/@OwnerType</PATH>
        <TYPE>character</TYPE>
        <DATATYPE>string</DATATYPE>
        <LENGTH>200</LENGTH>
    </COLUMN>

    <COLUMN name="page">
        <PATH syntax="XPath">/PortalContent/PSPortlet/@parent</PATH>
        <TYPE>character</TYPE>
        <DATATYPE>string</DATATYPE>
        <LENGTH>200</LENGTH>
    </COLUMN>

</TABLE>

</SXLEMAP>
;;;;
run;

libname content xmlv2 xmlmap=portmap xmlfileref=rspsum;

proc sql;
   title "Number of Trees";
   
  select count(*) from content.trees;

run;

proc sort data=content.trees out=work.trees nodupkey;
  by Id;
run;

Title "Number of Trees by Type";

proc sql;
   select TreeOwnerType, count(*) from work.trees group by TreeOwnerType;
run;
quit;

/*
 *  In the returned metadata, there might be multiple links to the same page, so de-dup the
 *  content now.
 */

proc sort data=content.pages out=work.pages;
  by Id descending type descending name;
run;

proc sql;
   create table work.pageCounts as select id, count(*) as occurrences from work.pages group by id;
   
   create table work.uniquePageReferences as select pages.*, pageCounts.occurrences from
      work.pages left join work.pageCounts on pages.id=pageCounts.id;
      
run;
quit;

/*
 *  Make sure it's sorted by id and so that the sharedPage reference shows up first */

proc sort data=work.uniquePageReferences out=work.uniquePageReferences;
  by Id descending type;
run;

proc sort data=work.uniquePageReferences out=work.uniquePages nodupkey;
  by id;
run;

proc sql;

  title "Number of Page References";
  
  select count(*) from content.pages;
  
  Title "Number of Unique Pages";

  select count(*) from work.uniquePages;
  run;

/*
 *  In the returned metadata, there might be multiple links to the same portlet, so de-dup the
 *  content now.
 *
 *  TODO: There seem to be cases where the page value is set on the row that doesn't have a name set and the 
 *        following code loses the page value.
 */

proc sort data=content.portlets out=work.portlets nodupkey;
  by Id descending name descending page ;
run;

proc sort data=work.portlets out=work.uniqueportlets nodupkey;
  by Id;
run;
proc sort data=content.pages out=work.pages nodupkey;
  by Id descending name; 
run;
proc sort data=work.pages out=work.uniquepages nodupkey;
  by Id;
run;

proc sql;
  create table work.pagePortlets as select uniqueportlets.*, uniquepages.parent
   from work.uniquepages inner join work.uniqueportlets
   on uniquepages.id=scan(uniqueportlets.page,2,':');
run;

proc sort data=work.pagePortlets out=work.uniquePagePortlets nodupkey;
  by id;
run;

proc sql;
   create table work.abnormalPortlets as
   select uniquePagePortlets.* from work.uniquePagePortlets(where=(type not in ('PlaceHolder','Bookmarks','Collection','DisplayURL','SASStoredProcess')));
   run;
   
proc sql;;

  title "Number of Portlet References";
  
  select count(*) from content.portlets;

  Title "Number of Unique Portlets by Type";

  select type, count(*) from work.uniqueportlets group by type;

  Title "Number of Unique Portlets by Page Use";

  select type, count(*) from work.uniquePagePortlets group by type;
  
  Title "Number of Unique Pages by Type";

  select type, count(*) from work.uniquepages group by type;
run;

title;
