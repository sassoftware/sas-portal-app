/*
 *   This program will retrieve the content associated with the ID Portal.  
 *   NOTE: This program must be run by an administrator that has the appropriate permissions to see
 *         all portal content!
 *   WARNING: Depending on the amount of Portal usage, the output could be large.  Please make sure
 *            to set the outfile variable below to a location that has plenty of space.
 *   
 */

/*
 *  Set this variable to the location of the output file that should contain the results
 */

%let outfile=/tmp/portal-content.xml;

/*
 *  Build the metadata request to get the portal content
 */

filename xmlreq temp;

data _null_;
 infile cards4;
 file xmlreq;
 input;
 put _infile_;
cards4;
<GetMetadataObjects>
                                <ReposId>$METAREPOSITORY</ReposId>
                                <Type>Tree</Type>
                                <ns>SAS</ns>
                                <!-- 256 = GetMetadata
                                     128 = XMLSelect
                                      16 = Include Subtypes (for Templates to use Root for un-templated objects)
                                       4 =  Template
                                  524288 = No Expand Dups (when the same object is referenced multiple times in the same response, only expand once)
                                -->
                                <Flags>524692</Flags>
                                <Options>
                                   <XMLSelect search="@Name='Portal Application Tree'"/>
                                   <Templates>
	                                  <Tree Id="" Name="" TreeType="">
	                                      <AccessControls/>
	                                         <Members/>
	                                         <SubTrees/>
	                                          <UsingPrototype/>
	                                  </Tree>
	                                  <AccessControlEntry Id="" Name="">
	                                     <Identities/>
	                                     <Permissions/>
	                                  </AccessControlEntry>
                                     <PSPortalPage Id="" Name="" Desc="">
                                       <Extensions/>
                                       <LayoutComponents/>
                                       <PropertySets/>
                                       <Properties/>
                                     </PSPortalPage>

                                     <PSPortlet Id="" Name="" Desc="" PortletType="">
                                       <PropertySets/>
                                       <Properties/>
                                       <UsingPrototype/>
                                       <Groups/>
                                     </PSPortlet>

                                     <Group Id="" Name="" Desc="">
                                        <Members/>
                                        <Properties/>
                                        <PropertySets/>
                                     </Group>

                                     <PropertySet Id="" Name="" Desc="" SetRole="">
                                       <SetProperties/>
                                     </PropertySet>

                                     <Property Id="" Name="" Desc="" DefaultValue="" PropertyName="">
                                       <AssociatedPropertySet/>
                                     </Property>

                                     <Extension Id="" Name="" Desc="" Value=""/>

                                     <PSColumnLayoutComponent Id="" Name="">
                                       <Portlets/>
                                     </PSColumnLayoutComponent>

                                     <Prototype Id="" Name="" Desc="" MetadataType="">
                                       <Extensions/>
                                     </Prototype>
                                     <Document Id="" Name="" Desc="" TextRole="" TextType="" URI=""/>
                                     
                                     <Transformation Id="" Name="" Desc="" TransformRole=""/>  
                                     
                                   <Root Id="" Name="" Desc=""/>

                                   </Templates>
                              </Options>
</GetMetadataObjects>
;;;;
run;

/*
 *  Get the metadata
 */

filename xmlrsp temp;

proc metadata in=xmlreq out=xmlrsp;
run;

filename xmlreq;

/* Format the xml for easier reading */

filename _fmtXSL temp;
filename _fmtdXML "&outfile.";
		
data _null_;

    file _fmtXSL;
	put '<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">';
	put '<xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>';
	put '<xsl:template match="*">';
	put '<xsl:copy>';
	put '<xsl:copy-of select="@*"/>';
	put '<xsl:apply-templates/>';
	put '</xsl:copy>';
	put '</xsl:template>';
	put '<xsl:template match="comment()|processing-instruction()">';
	put '<xsl:copy/>';
	put '</xsl:template>';
	put '</xsl:stylesheet>';
run;

proc xsl in=xmlrsp xsl=_fmtXSL out=_fmtdXML ;
run;
		
filename _fmtXSL;
filename _fmtdXML;

filename xmlrsp;