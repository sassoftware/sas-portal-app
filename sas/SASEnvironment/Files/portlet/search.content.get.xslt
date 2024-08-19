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

    <!-- If the user just wants to search a single type, they could either pass the Type parameter or the searchTypes with a single value (normally searchTypes is a comma separated list of types to search).  -->

    <xsl:variable name="type" select="Mod_Request/NewMetadata/Type"/>
    <xsl:variable name="searchTypes">
      <xsl:choose>
         <xsl:when test="not(Mod_Request/NewMetadata/SearchTypes='')"><xsl:value-of select="Mod_Request/NewMetadata/SearchTypes"/></xsl:when>
         <xsl:when test="not($type='')"><xsl:value-of select="$type"/></xsl:when>
         <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <Multiple_Requests>

         <!-- Calculate the queries that may need to be used on the various object types

              The query syntax may be * (search all) or an actual set of search phrases

              The query syntax says you can put double quotes around phrases and/or just type space delimited words
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

         <!-- Build an XMLSelect search string either for just the Name attribute or the Name and Description attributes -->

         <xsl:variable name="nameSearchXMLSelect">
            <xsl:if test="not($query='*')">
                <xsl:for-each select="$nonBlankKeywordList">
                    <xsl:if test="not(position()=1)">
                      <xsl:text> or </xsl:text>
                    </xsl:if>
                    <xsl:text>@Name?'</xsl:text><xsl:value-of select="."/><xsl:text>'</xsl:text>
                </xsl:for-each>
            </xsl:if>
          </xsl:variable>

         <xsl:variable name="objectSearchXMLSelect">

          <xsl:if test="not($query='*')">
              <xsl:for-each select="$nonBlankKeywordList">
                  <xsl:if test="not(position()=1)">
                    <xsl:text> or </xsl:text>
                  </xsl:if>
                  <xsl:text>((@Name?'</xsl:text><xsl:value-of select="."/><xsl:text>') or (@Desc?'</xsl:text><xsl:value-of select="."/><xsl:text>'))</xsl:text>
              </xsl:for-each>
          </xsl:if>
        </xsl:variable>

        <!-- Generate Queries to find the content that matches the requested query -->

         <xsl:variable name="typeList" select="tokenize($searchTypes,',')"/>
         <xsl:variable name="cleanTypeList" select="$typeList[normalize-space()]"/>

        <!-- The types listed in the type list are not actual metadata types, but are more user friendly names that describe the types.  Translate
             those into the actual metadata queries to issue 
        -->

       <!-- Keyword search

            Find the keywords that match the passed query and get the associated object.
            Make sure to limit the results to just those that have the correct associated object type based on the passed searchTypes

            If an * was passed, then the name search will be missing so no need to issue the query (since it would return all)
       -->

       <xsl:if test="not($nameSearchXMLSelect='')">

                 <!--  Limit the types of objects returned to just those that match the passed search types -->

                 <!--  There has got to be a better way of doing this, but for the life of me, I couldn't come up with one :-( -->

                 <xsl:variable name="hasReport">
                   <xsl:for-each select="$cleanTypeList">
                      <xsl:if test="lower-case(.)='sasreport'">1</xsl:if>
                   </xsl:for-each>
                 </xsl:variable>

                 <xsl:variable name="hasStoredProcess">
                   <xsl:for-each select="$cleanTypeList">
                      <xsl:if test="lower-case(.)='sasstoredprocess'">1</xsl:if>
                   </xsl:for-each>
                 </xsl:variable>

                 <xsl:variable name="keywordObjectFilter">
                    <xsl:choose>
                         <xsl:when test="not($hasReport='') and not($hasStoredProcess='')">*[@PublicType='Report' or @PublicType='StoredProcess']</xsl:when>
                         <xsl:when test="not($hasReport='')">*[@PublicType='Report']</xsl:when>
                         <xsl:when test="not($hasStoredProcess='')">*[@PublicType='StoredProcess']</xsl:when>
                    </xsl:choose>
                 </xsl:variable>

                 <xsl:if test="not($keywordObjectFilter='')">

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
                         <xsl:attribute name="search"><xsl:value-of select="$nameSearchXMLSelect"/></xsl:attribute>
                       </XMLSelect>
                       <Templates>
                          <Keyword Id="" Name="">
                            <Objects>
                               <xsl:attribute name="search"><xsl:value-of select="$keywordObjectFilter"/></xsl:attribute>

                            </Objects>
                          </Keyword>
                          <ClassifierMap Id="" Name="" Desc="" MetadataCreated="" TransformRole="">
                            <Trees/>
                          </ClassifierMap>
                          <Transformation Id="" Name="" Desc="" MetadataCreated="" TransformRole="">
                            <Trees/>
                          </Transformation>
                          <Tree Id="" Name="" TreeType="">
                             <ParentTree/>
                          </Tree>
                          </Templates>
                       </Options>
                      </GetMetadataObjects>

                 </xsl:if>

       </xsl:if>

       <!-- For each type to search in the passed searchTypes parameter, add a query -->

       <xsl:for-each select="$cleanTypeList">
       <xsl:variable name="useType" select="."/>

       <xsl:choose>

           <xsl:when test="lower-case($useType)='sasreport'">
              
             <GetMetadataObjects>
              <ReposId><xsl:value-of select="$reposId"/></ReposId>
              <Type>Transformation</Type>
              <ns>SAS</ns>
                 <!-- 256 = GetMetadata
                      128 = XMLSelect
                        4 =  Template
                 -->
              <Flags>388</Flags>
              <Options>
               <XMLSelect>
                         <xsl:choose>
                           <xsl:when test="$objectSearchXMLSelect=''">
                              <xsl:attribute name="search">@PublicType='Report'</xsl:attribute>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:attribute name="search">@PublicType='Report' and (<xsl:value-of select="$objectSearchXMLSelect"/>)</xsl:attribute>
                           </xsl:otherwise>
                         </xsl:choose>
                       </XMLSelect>
                       <Templates>
                          <Transformation Id="" Name="" Desc="" MetadataCreated="" TransformRole="">
                            <Trees/>
                          </Transformation>
                          <Tree Id="" Name="" TreeType="">
                             <ParentTree/>
                          </Tree>
                          </Templates>
                       </Options>
                      </GetMetadataObjects>


             </xsl:when>
 
             <xsl:when test="lower-case($useType)='sasstoredprocess'">

                 <GetMetadataObjects>
                  <ReposId><xsl:value-of select="$reposId"/></ReposId>
                  <Type>ClassifierMap</Type>
                  <ns>SAS</ns>
                     <!-- 256 = GetMetadata
                          128 = XMLSelect
                            4 =  Template
                     -->
                  <Flags>388</Flags>
                  <Options>
                   <XMLSelect>
                    <xsl:choose>
                       <xsl:when test="$objectSearchXMLSelect=''">
                          <xsl:attribute name="search">@PublicType='StoredProcess'</xsl:attribute>
                       </xsl:when>
                       <xsl:otherwise>
                          <xsl:attribute name="search">@PublicType='StoredProcess' and (<xsl:value-of select="$objectSearchXMLSelect"/>)</xsl:attribute>
                       </xsl:otherwise>
                     </xsl:choose>
                   </XMLSelect>
                   <Templates>
                      <ClassifierMap Id="" Name="" Desc="" MetadataCreated="" TransformRole="">
                        <Trees/>
                      </ClassifierMap>
                      <Tree Id="" Name="" TreeType="">
                         <ParentTree/>
                      </Tree>
                      </Templates>
                   </Options>
                  </GetMetadataObjects>

             </xsl:when>

             <xsl:otherwise>
                 <!--  Unknown content type passed, just ignore it.  -->

                 <!--  If the value is 'content', which was the value of the type parameter passed in, then no search types were passed and
                       we won't return any results (which is what the existing IDP did, which seems odd, but I think since it supported searching
                       a much larger set of objects, the likelihood of large result sets if this caused a query to all types would have been high.
                 -->
             </xsl:otherwise>

          </xsl:choose>

        </xsl:for-each>


    </Multiple_Requests>

</xsl:template>

</xsl:stylesheet>

