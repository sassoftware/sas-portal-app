<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>
<!--  Input xml format is the mod_request format.  -->

<!--  Valid NewMetadata parameters

      Name = Change the name of the page
      Desc = Change the description of the page
      PageRank = Change the page rank of the page    
      LayoutType = Column or Grid (default is Column)
      NumberOfColumns = The number of columns in the new Column Layout
      Columns = A list of Column information
        Column = The column information.  This entry is repeated for each column (number determined by NumberOfColumns)
          Width = The column Width
           Portlets = The list of Portlets for this column
             Portlet = A portlet entry in the form <reposname>:PSPortlet:<id>

      Any thing that is not passed should remain unchanged.
 
-->

<!--  Basic Logic 

      if NumberOfColumns is passed:
          Compare existing number of columns to new number of columns

          If same then just update each existing column list of portlets and width 

          Else if new number > old number
            (use existing and add a new one)
            
          Else (new number < old number)
            # delete the ones that no longer are used (don't delete portlets?)
            
          For any existing column
            # just replace existing list of portlets with new list?

      NOTE: Need to verify that when adding new column layouts to a page, they end up in the correct
            order in the LayoutComponents relationship!

      NOTE: Even though there are values on the portal page for number of columns and rows, they don't 
            seem to be updated as the numbers change, so not updating them here.
            Same is true for the number of portlets in a column, the value doesn't seem to be updated
            on the column layout object.
-->

<!--  Global Variables -->

<xsl:variable name="reposId" select="/Mod_Request/NewMetadata/Metareposid"/>

<xsl:variable name="pageId"><xsl:value-of select="/Mod_Request/NewMetadata/Id"/></xsl:variable>
<xsl:variable name="newNumberOfColumns" select="/Mod_Request/NewMetadata/NumberOfColumns"/>

<xsl:variable name="oldName" select="/Mod_Request/GetMetadata/Metadata/PSPortalPage/@Name"/>
<xsl:variable name="newName">
 <xsl:choose>
    <xsl:when test="/Mod_Request/NewMetadata/Name"><xsl:value-of select="/Mod_Request/NewMetadata/Name"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="$oldName"/></xsl:otherwise>
 </xsl:choose>
</xsl:variable>
<xsl:variable name="oldDesc" select="/Mod_Request/GetMetadata/Metadata/PSPortalPage/@Desc"/>
<xsl:variable name="newDesc">
 <xsl:choose>
    <xsl:when test="/Mod_Request/NewMetadata/Desc"><xsl:value-of select="/Mod_Request/NewMetadata/Desc"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="$oldDesc"/></xsl:otherwise>
 </xsl:choose>
</xsl:variable>

<xsl:variable name="oldPageRank" select="/Mod_Request/GetMetadata/Metadata/PSPortalPage/Extensions/Extension[@Name='PageRank']/@Value"/>
<xsl:variable name="newPageRank">
 <xsl:choose>
    <xsl:when test="/Mod_Request/NewMetadata/PageRank"><xsl:value-of select="/Mod_Request/NewMetadata/PageRank"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="$oldPageRank"/></xsl:otherwise>
 </xsl:choose>
</xsl:variable>

<!-- Re-usable scripts -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/delete.all.routines.xslt"/>

<xsl:template match="/">

    <!-- We may be here to just update the Name, Desc or Page Rank, ie. the column information is not passed.
         In this case, just make sure to skip column processing!
     -->

    <xsl:variable name="oldNumberOfColumns" select="count(/Mod_Request/GetMetadata/Metadata/PSPortalPage/LayoutComponents/*)"/>

 <Multiple_Requests>

    <xsl:if test="$newNumberOfColumns">

        <xsl:choose>
           <xsl:when test="$newNumberOfColumns &lt; 1 or $newNumberOfColumns &gt; 3">
               <message>ERROR: Invalid number of columns, $newNumberOfColumns, passed, must be 1,2 or 3</message>
           </xsl:when>
           <xsl:otherwise>

              <xsl:comment> oldNumberOfColumns=<xsl:value-of select="$oldNumberOfColumns"/> </xsl:comment>
              <xsl:comment> newNumberOfColumns=<xsl:value-of select="$newNumberOfColumns"/> </xsl:comment>
              <xsl:choose>
                <xsl:when test="$oldNumberOfColumns &lt; $newNumberOfColumns">

                   <!-- Create the necessary number of new Column Layouts -->
                   <!-- Couldn't find a good way of looping in xslt, so hard code the options since there aren't that many -->

                   <!-- NOTE: There should never be a situation where no columns exist for a page (ie. oldNumberOfColumns >= 1) -->

                   <UpdateMetadata>
                     <Metadata>

                     <xsl:choose>

                        <xsl:when test="$oldNumberOfColumns='1' and $newNumberOfColumns='2'">
                            <xsl:call-template name="createColumnLayout"><xsl:with-param name="columnNumber">2</xsl:with-param></xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$oldNumberOfColumns='1' and $newNumberOfColumns='3'">
                            <xsl:call-template name="createColumnLayout"><xsl:with-param name="columnNumber">2</xsl:with-param></xsl:call-template>
                            <xsl:call-template name="createColumnLayout"><xsl:with-param name="columnNumber">3</xsl:with-param></xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$oldNumberOfColumns='2' and $newNumberOfColumns='3'">
                            <xsl:call-template name="createColumnLayout"><xsl:with-param name="columnNumber">3</xsl:with-param></xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise><message>ERROR: Invalid number of columns, old=<xsl:value-of select="$oldNumberOfColumns"/>, new=<xsl:value-of select="$newNumberOfColumns"/></message>
                        </xsl:otherwise>
                     </xsl:choose>

                     <!-- Now update existing Column Layouts-->

                     <xsl:call-template name="updateColumnLayout"><xsl:with-param name="columnNumber">1</xsl:with-param></xsl:call-template>
                     <xsl:if test="$oldNumberOfColumns='2'">
                         <xsl:call-template name="updateColumnLayout"><xsl:with-param name="columnNumber">2</xsl:with-param></xsl:call-template>
                     </xsl:if>

                     </Metadata>

                     <NS>SAS</NS>
                     <Flags>268435456</Flags>
                     <Options/>

                   </UpdateMetadata>

                </xsl:when>

                <xsl:when test="$oldNumberOfColumns &gt; $newNumberOfColumns">

                   <!-- Delete any Column Layouts that already exist but aren't referenced in the New metadata definition -->

                   <!-- for some reason we only generate a DeleteMetadata statement, then the xsl checking on the result
                        will fail because it expects to find some reference to UpdateMetadata.  Generate a comment
                        with that phrase in it so it will pass the test, even in this scenario -->

                   <xsl:comment>Include the phrase UpdateMetadata so the xsl checking thinks it worked</xsl:comment>
                   <DeleteMetadata>
                     <Metadata>

                     <xsl:choose>
                        <xsl:when test="$oldNumberOfColumns='2' and $newNumberOfColumns='1'">
                            <xsl:call-template name="deleteColumnLayout"><xsl:with-param name="columnNumber">2</xsl:with-param></xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$oldNumberOfColumns='3' and $newNumberOfColumns='1'">
                            <xsl:call-template name="deleteColumnLayout"><xsl:with-param name="columnNumber">2</xsl:with-param></xsl:call-template>
                            <xsl:call-template name="deleteColumnLayout"><xsl:with-param name="columnNumber">3</xsl:with-param></xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$oldNumberOfColumns='3' and $newNumberOfColumns='2'">
                            <xsl:call-template name="deleteColumnLayout"><xsl:with-param name="columnNumber">3</xsl:with-param></xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise><message>ERROR: Invalid number of columns, old=<xsl:value-of select="$oldNumberOfColumns"/>, new=<xsl:value-of select="$newNumberOfColumns"/></message>
                        </xsl:otherwise>
                     </xsl:choose>
                     </Metadata>

                     <NS>SAS</NS>
                     <Flags>268435456</Flags>
                     <Options/>

                   </DeleteMetadata>

                   <!-- Now update existing Columns -->

                   <UpdateMetadata>
                     <Metadata>

                       <xsl:call-template name="updateColumnLayout"><xsl:with-param name="columnNumber">1</xsl:with-param></xsl:call-template>
                       <xsl:if test="$newNumberOfColumns='2'">
                           <xsl:call-template name="updateColumnLayout"><xsl:with-param name="columnNumber">2</xsl:with-param></xsl:call-template>
                       </xsl:if>

                     </Metadata>

                     <NS>SAS</NS>
                     <Flags>268435456</Flags>
                     <Options/>

                   </UpdateMetadata>

                </xsl:when>
                <xsl:otherwise>

                   <!--  Number of columns hasn't changed, but the contents might have so update all that exist -->
                   <UpdateMetadata>
                     <Metadata>

                       <xsl:call-template name="updateColumnLayout"><xsl:with-param name="columnNumber">1</xsl:with-param></xsl:call-template>
                       <xsl:choose>

                           <xsl:when test="$newNumberOfColumns='2'">
                               <xsl:call-template name="updateColumnLayout"><xsl:with-param name="columnNumber">2</xsl:with-param></xsl:call-template>
                           </xsl:when>
                           <xsl:when test="$newNumberOfColumns='3'">
                               <xsl:call-template name="updateColumnLayout"><xsl:with-param name="columnNumber">2</xsl:with-param></xsl:call-template>
                               <xsl:call-template name="updateColumnLayout"><xsl:with-param name="columnNumber">3</xsl:with-param></xsl:call-template>
                           </xsl:when>

                       </xsl:choose>

                     </Metadata>

                     <NS>SAS</NS>
                     <Flags>268435456</Flags>
                     <Options/>

                   </UpdateMetadata>
 
                </xsl:otherwise>
              </xsl:choose>

              </xsl:otherwise>
           </xsl:choose>
    </xsl:if>

    <!-- See if we are to update the Page itself -->

    <xsl:if test="not($newName=$oldName) or not($newDesc=$oldDesc)">

         <UpdateMetadata>
           <Metadata>
              <PSPortalPage>
                <xsl:attribute name="Id"><xsl:value-of select="$pageId"/></xsl:attribute>

                <xsl:variable name="oldName" select="/Mod_Request/GetMetadata/Metadata/PSPortalPage/@Name"/>

                <xsl:if test="not($newName='') and not($newName=$oldName)">
                   <xsl:attribute name="Name"><xsl:value-of select="$newName"/></xsl:attribute>
                </xsl:if>

                <xsl:if test="not($newDesc='') and not($newDesc=$oldDesc)">
                   <xsl:attribute name="Desc"><xsl:value-of select="$newDesc"/></xsl:attribute>
                </xsl:if>
              </PSPortalPage>

           </Metadata>

           <NS>SAS</NS>
           <Flags>268435456</Flags>
           <Options/>

         </UpdateMetadata>

    </xsl:if>
    <xsl:if test="not($newPageRank=$oldPageRank)">

         <xsl:variable name="oldPageRankId" select="/Mod_Request/GetMetadata/Metadata/PSPortalPage/Extensions/Extension[@Name='PageRank']/@Id"/>
         <UpdateMetadata>
           <Metadata>
              <Extension>
                <xsl:attribute name="Id"><xsl:value-of select="$oldPageRankId"/></xsl:attribute>
                <xsl:attribute name="Value"><xsl:value-of select="$newPageRank"/></xsl:attribute>
              </Extension>
           </Metadata>

           <NS>SAS</NS>
           <Flags>268435456</Flags>
           <Options/>

         </UpdateMetadata>

    </xsl:if>
 </Multiple_Requests>

</xsl:template>

<xsl:template name="createColumnLayout">
   <xsl:param name="columnNumber"/>
  
   <xsl:variable name="newColumnLayoutId"><xsl:value-of select="substring-after($reposId,'.')"/>.$columnLayout<xsl:value-of select="$columnNumber"/></xsl:variable>
   <xsl:variable name="columnObject" select="/Mod_Request/NewMetadata/Columns/Column[$columnNumber]"/>

   <PSColumnLayoutComponent Name="COLUMNLAYOUTCOMPONENT" NumberOfPortlets="0">

      <xsl:attribute name="Id"><xsl:value-of select="$newColumnLayoutId"/></xsl:attribute>

      <xsl:call-template name="setColumnWidth">
         <xsl:with-param name="columnNumber"><xsl:value-of select="$columnNumber"/></xsl:with-param>
         <xsl:with-param name="newColumn">1</xsl:with-param>
      </xsl:call-template>

      <OwningPage>
          <PSPortalPage>
             <xsl:attribute name="ObjRef"><xsl:value-of select="$pageId"/></xsl:attribute>
          </PSPortalPage>
      </OwningPage>

      <xsl:call-template name="setColumnPortlets">
         <xsl:with-param name="columnNumber"><xsl:value-of select="$columnNumber"/></xsl:with-param>
      </xsl:call-template>

   </PSColumnLayoutComponent>
  
</xsl:template>

<xsl:template name="setColumnWidth">
   <xsl:param name="columnNumber"/>
   <xsl:param name="newColumn">0</xsl:param>

   <xsl:variable name="columnWidth" select="/Mod_Request/NewMetadata/Columns/Column[position()=$columnNumber]/Width"/>
        <!-- If no width explicitly passed for this column, use default based on number of columns -->
        <!-- NOTE: This is not handling the case where the other columns have length and using the default
             here could end up adding up to more than 100 -->

        <xsl:variable name="useColumnWidth">
        <xsl:choose>
          <xsl:when test="$columnWidth"><xsl:value-of select="$columnWidth"/></xsl:when>
          <xsl:when test="$newColumn='1'">
              <xsl:choose>
		  <xsl:when test="$newNumberOfColumns = '3'">33</xsl:when>
		  <xsl:when test="$newNumberOfColumns = '2'">50</xsl:when>
		  <xsl:otherwise>100</xsl:otherwise>
              </xsl:choose>
          </xsl:when>
          <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
        </xsl:variable>

        <xsl:if test="$useColumnWidth">
          <xsl:attribute name="ColumnWidth"><xsl:value-of select="$useColumnWidth"/></xsl:attribute>
        </xsl:if>

</xsl:template>

<xsl:template name="setColumnPortlets">

   <xsl:param name="columnNumber"/>

   <xsl:variable name="columnObject" select="/Mod_Request/NewMetadata/Columns/Column[position()=$columnNumber]"/>

  <!-- NOTE: If the new column definition has no portlets, and the existing one had portlets, the intent is
             to remove all references to portlets from this column.  The replace function will handle that case
             also for us.
  -->

  <!-- TODO: It would be better if we would compare the new list to the existing list and only if something is 
             different, then do the update.
  -->

  <Portlets Function="replace">
    <xsl:for-each select="$columnObject/Portlets/*">
       <xsl:variable name="portletId"><xsl:value-of select="tokenize(.,':')[3]"/></xsl:variable>
       <PSPortlet>
           <xsl:attribute name="ObjRef"><xsl:value-of select="$portletId"/></xsl:attribute>
       </PSPortlet>
    </xsl:for-each>
  </Portlets>
     
</xsl:template>

<xsl:template name="updateColumnLayout">
   <xsl:param name="columnNumber"/>
   <xsl:variable name="newColumnObject" select="/Mod_Request/NewMetadata/Columns/Column[position()=$columnNumber]"/>
   <xsl:variable name="oldColumnObjectId" select="/Mod_Request/GetMetadata/Metadata/PSPortalPage/LayoutComponents/PSColumnLayoutComponent[position()=$columnNumber]/@Id"/>

   <PSColumnLayoutComponent>
    <xsl:attribute name="Id"><xsl:value-of select="$oldColumnObjectId"/></xsl:attribute>

    <xsl:call-template name="setColumnWidth">
      <xsl:with-param name="columnNumber"><xsl:value-of select="$columnNumber"/></xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="setColumnPortlets">
      <xsl:with-param name="columnNumber"><xsl:value-of select="$columnNumber"/></xsl:with-param>
    </xsl:call-template>

   </PSColumnLayoutComponent>

</xsl:template>

<xsl:template name="deleteColumnLayout">
   <xsl:param name="columnNumber"/>

   <xsl:apply-templates select="/Mod_Request/GetMetadata/Metadata/PSPortalPage/LayoutComponents/PSColumnLayoutComponent[position()=$columnNumber]"/>

</xsl:template>

</xsl:stylesheet>

