<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<!-- Common Setup -->

<!-- Set up the metadataContext variable -->
<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/setup.metadatacontext.xslt"/>
<!-- Set up the environment context variables -->
<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/setup.envcontext.xslt"/>

<!-- load the appropriate localizations -->

<xsl:variable name="localizationFile">
 <xsl:choose>
   <xsl:when test="/Mod_Request/NewMetadata/LocalizationFile"><xsl:value-of select="/Mod_Request/NewMetadata/LocalizationFile"/></xsl:when>
   <xsl:otherwise><xsl:value-of select="$localizationDir"/>/resources_en.xml</xsl:otherwise>
 </xsl:choose>
</xsl:variable>

<xsl:variable name="localeXml" select="document($localizationFile)/*"/>

<!-- Main Entry Point -->

<xsl:template match="/">

   <!-- This stylesheet generates a metadata query based on the passed query parameters -->

   <!-- NOTE: The current scope of this implementation is to search for Portal Pages (PSPortalPage) and Portlets (PSPortlet).  While it is
              possible this routine will search more in the future, that is left for future work!
     -->

   <!--   From the old IDP Documentation, here is the behavior of the search criteria 

          For the query parameter:

          Use either of these methods:

           - Enter one or more words, each separated by a space.
             The search tool returns all of the content whose metadata (name, description, or keywords) contains one or more of the words that you entered.
           - Enter a phrase consisting of two or more words, and place double quotation marks around the phrase.
             The search tool returns all of the content whose metadata (name, description, or keywords) contains the exact phrase that you entered.
           - Alternatively, you can search for all content by entering an asterisk (*) with no other text. An asterisk acts as a wildcard only when you enter it by itself. 
             For example, to find Sales History, First Quarter Sales, and Monthly Sales Forecast, you would enter the search term sales. Do not enter sales*, *sales, or *sales* unless you are searching for a name or description that actually contains the asterisks.

             Note: Using an asterisk can slow down your search and return a large amount of content. Use the asterisk sparingly. To narrow this type of search, you should also select one of the content type check boxes, as described below.

          For the Content Types:

          Select one or more check boxes to indicate which content types you want to find. (If you want to find all content types, click the Select All check box.)

          Note: You must select at least one content type. Otherwise, no search results are returned.

    -->

    <xsl:variable name="query" select="Mod_Request/NewMetadata/Query"/>

    <xsl:variable name="type" select="Mod_Request/NewMetadata/Type"/>

    <Multiple_Requests>

         <!--  Get Information about the Permissions Trees this user has access to -->
         <!--   This will be used to properly show the location in the search results -->
         <!--   We do this once here instead of expanding the tree hierarchy on every tree reference in the following queries -->

         <GetMetadataObjects>
          <ReposId><xsl:value-of select="$reposId"/></ReposId>
          <Type>Tree</Type>
          <ns>SAS</ns>
             <!-- 256 = GetMetadata
                  128 = XMLSelect
                    4 =  Template
             -->
          <Flags>388</Flags>
          <Options>
          <XMLSelect search="@TreeType=' Permissions Tree' or @TreeType='Permissions Tree'"/>
          <Templates>
             <Tree Id="" Name="" TreeType="">
                <SubTrees/>
             </Tree>
             </Templates>
          </Options>
         </GetMetadataObjects>

         <!-- NOTE: Took out the query to get the users current list of pages so we don't show them the same pages in the search results, but the current portal doesn't do it, so we aren't either -->

         <!-- TODO:  Should we limit the page search to only available or default pages, persistent pages must already be in their list -->
 
         <xsl:choose>

             <xsl:when test="$query='*'">

                 <!--  Get all the pages -->

                 <GetMetadataObjects>
                  <ReposId><xsl:value-of select="$reposId"/></ReposId>
                  <Type><xsl:value-of select="$type"/></Type>
                  <ns>SAS</ns>
                     <!-- 256 = GetMetadata
                            4 =  Template
                     -->
                  <Flags>260</Flags>
                  <Options>
                  <Templates>
                     <PSPortalPage Id="" Name="" Desc="" MetadataCreated="">
                       <Trees/>
                       <Extensions search="@Name?'SharedPage' or @Name='MarkedForDeletion'"/>
                     </PSPortalPage>
                     <Tree Id="" Name="" TreeType=""/>
                     <Extension Id="" Name=""/>
                     </Templates>
                  </Options>
                 </GetMetadataObjects>

             </xsl:when>

             <xsl:otherwise>

                <!-- The query syntax says you can put double quotes around phrases and/or just type space delimited words
                     I can't figure out how to mix and match quoted strings and non-quoted, so going to implement here
                     that you either quote everything or you quote nothing.
                -->

                <xsl:variable name="queryDelimiter">
                  <xsl:choose>

                  <xsl:when test="contains($query,'&quot;')">&quot;</xsl:when>
                  <xsl:otherwise>\s</xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>

                <!-- When tokenize is done with a ", it adds empty nodes into the resulting node set.
                     Process the node-set returned from tokenize and remove the empty nodes.
                -->
                <xsl:variable name="keywordList" select="tokenize($query,$queryDelimiter)"/>
                <xsl:variable name="nonBlankKeywordList" select="$keywordList[normalize-space()]"/>

                 <!--  Get Pages that match the Keyword search -->

                 <GetMetadataObjects>
                  <ReposId><xsl:value-of select="$reposId"/></ReposId>
                  <Type>Keyword</Type>
                  <ns>SAS</ns>
                     <!-- 256 = GetMetadata
                          128 = XMLSelect
                            4 =  Template
                     -->
                  <Flags>388</Flags>
                  <Options>
                  <XMLSelect>

                 <xsl:variable name="keywordSearchXMLSelect">

                    <xsl:for-each select="$nonBlankKeywordList">
                        <xsl:if test="not(position()=1)">
                          <xsl:text> or </xsl:text>
                        </xsl:if>
                        <xsl:text>@Name?'</xsl:text><xsl:value-of select="."/><xsl:text>'</xsl:text>
                    </xsl:for-each>
                  </xsl:variable>

                  <xsl:attribute name="search"><xsl:value-of select="$keywordSearchXMLSelect"/></xsl:attribute>

                  </XMLSelect>
                  <Templates>
                     <Keyword Id="" Name="">
                        <Objects>
                          <!--  TODO: Handle if multiple content types are passed -->
                          <xsl:attribute name="search"><xsl:value-of select="$type"/></xsl:attribute>
                        </Objects>
                     </Keyword>
                     <PSPortalPage Id="" Name="" Desc="" MetadataCreated="">
                       <Trees/>
                       <Extensions search="@Name?'SharedPage' or @Name='MarkedForDeletion'"/>
                     </PSPortalPage>
                     <Tree Id="" Name="" TreeType=""/>
                     <Extension Id="" Name=""/>
                     </Templates>
                  </Options>
                 </GetMetadataObjects>

                 <!--  Get Pages that match the name or description search -->

                 <!--  TODO: Handle if contentType contains multiple types -->

                 <GetMetadataObjects>
                  <ReposId><xsl:value-of select="$reposId"/></ReposId>
                  <Type><xsl:value-of select="$type"/></Type>
                  <ns>SAS</ns>
                     <!-- 256 = GetMetadata
                          128 = XMLSelect
                            4 =  Template
                     -->
                  <Flags>388</Flags>
                  <Options>
                   <XMLSelect>

                   <xsl:variable name="objectSearchXMLSelect">

                    <xsl:for-each select="$nonBlankKeywordList">
                        <xsl:if test="not(position()=1)">
                          <xsl:text> or </xsl:text>
                        </xsl:if>
                        <xsl:text>((@Name?'</xsl:text><xsl:value-of select="."/><xsl:text>') or (@Desc?'</xsl:text><xsl:value-of select="."/><xsl:text>'))</xsl:text>
                    </xsl:for-each>
                  </xsl:variable>

                  <xsl:attribute name="search"><xsl:value-of select="$objectSearchXMLSelect"/></xsl:attribute>

                  </XMLSelect>
                  <Templates>
                     <PSPortalPage Id="" Name="" Desc="" MetadataCreated="">
                       <Trees/>
                       <Extensions search="@Name?'SharedPage' or @Name='MarkedForDeletion'"/>
                     </PSPortalPage>
                     <Tree Id="" Name="" TreeType=""/>
                     <Extension Id="" Name=""/>
                     </Templates>
                  </Options>
                 </GetMetadataObjects>

             </xsl:otherwise>

         </xsl:choose>

    </Multiple_Requests>

</xsl:template>

<xsl:template name="searchSaveQueries">


         <!--  Get Information about the pages they already have in their portal (so we don't show duplicates)  -->

         <!--  TODO: NOTE: The current portal doesn't do this, it shows them all the pages that match, even ones they already have! -->
         <!--      Thus, don't do it now. -->
 
         <GetMetadataObjects>
          <ReposId><xsl:value-of select="$reposId"/></ReposId>
          <Type>Group</Type>
          <ns>SAS</ns>
             <!-- 256 = GetMetadata
                  128 = XMLSelect
                    4 =  Template
             -->
          <Flags>388</Flags>
          <Options>
          <XMLSelect search="@Name='DESKTOP_PORTALPAGES_GROUP' "/>
          <Templates>
             <Group>
                <Members/>
             </Group>
             <PSPortalPage Id="" Name="" Desc="" MetadataCreated="">
               <Trees/>
             </PSPortalPage>
             <Tree Id="" Name=""/>
             </Templates>
          </Options>
         </GetMetadataObjects>

</xsl:template>

</xsl:stylesheet>

