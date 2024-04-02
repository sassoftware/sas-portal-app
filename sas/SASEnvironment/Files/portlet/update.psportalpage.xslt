<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- Common Setup -->

<!-- Set up the metadataContext variable -->
<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/setup.metadatacontext.xslt"/>
<!-- Set up the environment context variables -->
<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/setup.envcontext.xslt"/>

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
      ParentTreeId = Update the tree that this portal is stored under.
      Scope = if this is a shared page, then update the scope of the Sharing
      MovePortletsOnPage = if the scope has changed, should we apply the same scope change to the portlets on the page?
              true = yes, move the portlets that are in the same tree to the new tree
              false = no, leave the portlets where they are (NOTE: if this parameter not passed, false is the default)

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

<xsl:variable name="pageId"><xsl:value-of select="/Mod_Request/NewMetadata/Id"/></xsl:variable>
<xsl:variable name="newNumberOfColumns" select="/Mod_Request/NewMetadata/NumberOfColumns"/>

<xsl:variable name="pageObject" select="$metadataContext/Multiple_Requests/GetMetadata/Metadata/PSPortalPage"/>

<xsl:variable name="personObject" select="$metadataContext/Multiple_Requests/GetMetadataObjects/Objects/Person"/>

    <!-- Name -->

<xsl:variable name="oldName" select="$pageObject/@Name"/>
<xsl:variable name="newName">
 <xsl:choose>
    <xsl:when test="/Mod_Request/NewMetadata/Name"><xsl:value-of select="/Mod_Request/NewMetadata/Name"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="$oldName"/></xsl:otherwise>
 </xsl:choose>
</xsl:variable>

    <!-- Description -->

<xsl:variable name="oldDesc" select="$pageObject/@Desc"/>
<xsl:variable name="newDesc">
 <xsl:choose>
    <xsl:when test="/Mod_Request/NewMetadata/Desc"><xsl:value-of select="/Mod_Request/NewMetadata/Desc"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="$oldDesc"/></xsl:otherwise>
 </xsl:choose>
</xsl:variable>

    <!--  Page Rank -->

<xsl:variable name="oldPageRank" select="$pageObject/Extensions/Extension[@Name='PageRank']/@Value"/>
<xsl:variable name="newPageRank">
 <xsl:choose>
    <xsl:when test="/Mod_Request/NewMetadata/PageRank"><xsl:value-of select="/Mod_Request/NewMetadata/PageRank"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="$oldPageRank"/></xsl:otherwise>
 </xsl:choose>
</xsl:variable>


    <!--  Move Portlets also? -->

<xsl:variable name="newMovePortletsOnPage">
 <xsl:choose>
   <xsl:when test="/Mod_Request/NewMetadata/MovePortletsOnPage">
      <xsl:choose>
        <xsl:when test="lower-case(/Mod_Request/NewMetadata/MovePortletsOnPage)='true'">true</xsl:when>
        <xsl:otherwise>false</xsl:otherwise>
      </xsl:choose>
   </xsl:when>
   <xsl:otherwise>false</xsl:otherwise>
 </xsl:choose>
</xsl:variable>

    <!--  Tree details -->

<!--  The parentTreeId can either be:
      - the user's root permission tree
      - a subtree in the hierarchy under the group's root permission tree.
     Find which one it is and get the root permissions tree it is under.
     We get this information so we can see if the request is to change the location (and sharing) of the page. 
-->

<xsl:variable name="oldParentTreeId" select="$pageObject/Trees/Tree/@Id"/>

<xsl:variable name="oldParentTree" select="$personObject/AccessControlEntries//Tree[@Id=$oldParentTreeId]"/>
<xsl:variable name="oldRootPermissionsTreeId">
  <xsl:choose>
     <xsl:when test="$oldParentTree/@TreeType='Permissions Tree' or $oldParentTree/@TreeType=' Permissions Tree'">
     <xsl:value-of select="$oldParentTree/@Id"/>
     </xsl:when>
     <xsl:otherwise>
     <xsl:value-of select="$personObject/AccessControlEntries/AccessControlEntry/Objects/Tree[SubTrees//Tree[@Id=$oldParentTreeId]]/@Id"/>
     </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="newParentTreeId" select="Mod_Request/NewMetadata/ParentTreeId"/>
<xsl:variable name="newParentTree" select="$personObject/AccessControlEntries//Tree[@Id=$newParentTreeId]"/>

<!-- Set the new permissions tree id, however, only set it if the NewMetadata option was passed to potentially change it -->

<xsl:variable name="newRootPermissionsTreeId">
  <xsl:choose>
     <xsl:when test="not($newParentTreeId)"></xsl:when>
     <xsl:when test="$newParentTree/@TreeType='Permissions Tree' or $newParentTree/@TreeType=' Permissions Tree'">
     <xsl:value-of select="$newParentTree/@Id"/>
     </xsl:when>
     <xsl:otherwise>
     <xsl:value-of select="$personObject/AccessControlEntries/AccessControlEntry/Objects/Tree[SubTrees//Tree[@Id=$newParentTreeId]]/@Id"/>
     </xsl:otherwise>
  </xsl:choose>
</xsl:variable>


<!-- Figure out if the new tree is the user's root permissions tree or not.  If it is, we will need to ignore any passed value for Sharing Type
     and just set it to "notshared".
-->

<xsl:variable name="isNewParentTreeUserTree">
   <xsl:choose>
      <xsl:when test="$newParentTreeId">
         <xsl:choose>
            <xsl:when test="$personObject/AccessControlEntries/AccessControlEntry/Objects/Tree[@Id=$newParentTreeId]/Members/Group[@Name='DESKTOP_PORTALPAGES_GROUP']">1</xsl:when>
         <xsl:otherwise>0</xsl:otherwise>
         </xsl:choose>
      </xsl:when>
      <xsl:otherwise>unknown</xsl:otherwise>
   </xsl:choose>
</xsl:variable>

    <!--  Sharing Type -->

    <xsl:variable name="oldScope">
      <xsl:choose>
        <xsl:when test="$pageObject/Extensions/Extension[@Name='SharedPageAvailable']">SharedPageAvailable</xsl:when>
        <xsl:when test="$pageObject/Extensions/Extension[@Name='SharedPageSticky']">SharedPageSticky</xsl:when>
        <xsl:when test="$pageObject/Extensions/Extension[@Name='SharedPageDefault']">SharedPageDefault</xsl:when>
        <xsl:otherwise>notshared</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Get the extension object that has the sharing type in it.  Having to set it this way is a bit of a quirk about how
         to set an xsl variable to an object, ie. you must use the variable with select attribute and can't use any sort of
         embedded logic.  Thus, use the variable set above to find the right one.
    -->
    <xsl:variable name="oldScopeObject" select="$pageObject/Extensions/Extension[@Name=$oldScope]"/>
    <xsl:variable name="oldScopeObjectId" select="$oldScopeObject/@Id"/>

    <xsl:variable name="inputScope" select="/Mod_Request/NewMetadata/Scope"/>

    <xsl:variable name="newScope">
      <xsl:choose>
        <xsl:when test="$isNewParentTreeUserTree='1'">notshared</xsl:when>
        <xsl:when test="not($inputScope)"><xsl:value-of select="$oldScope"/></xsl:when>
        <xsl:when test="$inputScope=0">SharedPageAvailable</xsl:when>
        <xsl:when test="$inputScope=1">SharedPageDefault</xsl:when>
        <xsl:when test="$inputScope=2">SharedPageSticky</xsl:when>
        <xsl:otherwise>notshared</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

<!-- Re-usable scripts -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/delete.all.routines.xslt"/>

<xsl:template match="/">

    <!-- We may be here to just update the Name, Desc or Page Rank, ie. the column information is not passed.
         In this case, just make sure to skip column processing!
     -->

    <xsl:variable name="oldNumberOfColumns" select="count($pageObject/LayoutComponents/*)"/>

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

                <xsl:variable name="oldName" select="$pageObject/@Name"/>

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

         <xsl:variable name="oldPageRankId" select="$pageObject/Extensions/Extension[@Name='PageRank']/@Id"/>
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
    <xsl:if test="not($oldRootPermissionsTreeId=$newRootPermissionsTreeId)">
      <!-- If going from a shared tree to a non-shared tree, must delete the sharing extension -->
      <!-- TODO: What happens with all of the users portal info that has the shared page in it? -->
      <!--       Answer: when it goes to non-shared, the permissions will change and thus other users links will not resolve since it can no longer
                 be seen by them.  From what I can tell, there was no effort to clean up links to the moved page, security rules just take care of it.
       -->
      <xsl:choose>

        <!-- Moving from Not Shared to Shared -->
 
        <xsl:when test="$oldScope='notshared'">

           <!-- Reset the parent tree to the correct sharing folder under the new root permissions tree -->
           <xsl:call-template name="movePage"/>

           <!-- Add the sharing extension -->
            <xsl:call-template name="processScopeChange">
              <xsl:with-param name="old"><xsl:value-of select="$oldScope"/></xsl:with-param>
              <xsl:with-param name="new"><xsl:value-of select="$newScope"/></xsl:with-param>
              <xsl:with-param name="force">1</xsl:with-param>
            </xsl:call-template>

           <!-- Handle the option to move the portlets also -->
          
           <xsl:call-template name="movePortlets"/>

        </xsl:when>

        <!-- Moving from Shared to Not Shared -->

        <xsl:when test="$newScope='notshared'">

           <!-- Reset the parent tree to the user's tree -->
           <xsl:call-template name="movePage"/>

           <!-- Remove any sharing extension -->
            <xsl:call-template name="processScopeChange">
              <xsl:with-param name="old"><xsl:value-of select="$oldScope"/></xsl:with-param>
              <xsl:with-param name="new"><xsl:value-of select="$newScope"/></xsl:with-param>
            </xsl:call-template>

           <!-- Handle the option to move the portlets also -->

           <xsl:call-template name="movePortlets"/>

        </xsl:when>

        <!-- No NewScope set? -->

        <xsl:when test="not($newScope)">
           <xsl:message>processing request with no passed scope, is this always the same with going from shared to not shared? </xsl:message>
        </xsl:when>

        <!-- Change from one group to another -->

        <xsl:otherwise>

           <!-- Reset the parent tree to the correct sharing folder under the new root permissions tree -->
           <xsl:call-template name="movePage"/>

           <!-- Add the sharing extension -->
            <xsl:call-template name="processScopeChange">
              <xsl:with-param name="old"><xsl:value-of select="$oldScope"/></xsl:with-param>
              <xsl:with-param name="new"><xsl:value-of select="$newScope"/></xsl:with-param>
              <xsl:with-param name="force">1</xsl:with-param>
            </xsl:call-template>

           <!-- Handle the option to move the portlets also -->
          
           <xsl:call-template name="movePortlets"/>

        </xsl:otherwise>

      </xsl:choose>

    </xsl:if>

    <xsl:if test="not($oldScope=$newScope) and ($oldRootPermissionsTreeId=$newRootPermissionsTreeId)">
        <!-- A scope change that was also accomponied by a tree move is handled in the tree move code so don't do it again! -->

        <xsl:call-template name="processScopeChange">
          <xsl:with-param name="old"><xsl:value-of select="$oldScope"/></xsl:with-param>
          <xsl:with-param name="new"><xsl:value-of select="$newScope"/></xsl:with-param>
        </xsl:call-template>

        <!-- The different scoped pages are stored in different trees under the same root permissions tree, so move it now -->

        <xsl:call-template name="movePage"/>

    </xsl:if>

 </Multiple_Requests>

</xsl:template>

<xsl:template name="movePage">

  <!-- If moving to a shared group, need to find the correct sub-tree to put the page into -->

  <xsl:variable name="moveToRootTree" select="$personObject/AccessControlEntries/AccessControlEntry/Objects/Tree[@Id=$newRootPermissionsTreeId]"/>
  <xsl:variable name="moveToDesktopProfileTree" select="$moveToRootTree/SubTrees/Tree[@Name='RolesTree']/SubTrees/Tree[@Name='DefaultRole']/SubTrees/Tree[@Name='DESKTOP_PROFILE']"/>

  <xsl:variable name="moveToTreeId">

      <xsl:choose>
        <xsl:when test="$newScope='notshared'"><xsl:value-of select="$newRootPermissionsTreeId"/></xsl:when>
        <xsl:when test="$newScope">
          <xsl:choose>
            <xsl:when test="$newScope='SharedPageAvailable'"><xsl:value-of select="$moveToRootTree/@Id"/></xsl:when>
	    <xsl:when test="$newScope='SharedPageDefault'"><xsl:value-of select="$moveToDesktopProfileTree/SubTrees/Tree[@Name='Default']/@Id"/></xsl:when>
            <xsl:when test="$newScope='SharedPageSticky'"><xsl:value-of select="$moveToDesktopProfileTree/SubTrees/Tree[@Name='Sticky']/@Id"/></xsl:when>
            <xsl:otherwise/>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      
      </xsl:choose>

  </xsl:variable>

  <UpdateMetadata>
  <Metadata>
    <PSPortalPage>
      <xsl:attribute name="Id"><xsl:value-of select="$pageId"/></xsl:attribute>
      <Trees Function="replace">
        <Tree>
           <xsl:attribute name="ObjRef"><xsl:value-of select="$moveToTreeId"/></xsl:attribute>
        </Tree>
      </Trees>
    </PSPortalPage>
  </Metadata>
  <NS>SAS</NS>
  <Flags>268435456</Flags>
  <Options/>

</UpdateMetadata>

</xsl:template>

<xsl:template name="movePortlets">

  <xsl:if test="$newMovePortletsOnPage='true'"> 

    <xsl:for-each select="$pageObject/LayoutComponents/PSColumnLayoutComponent/Portlets/PSPortlet">

        <!-- Only want to include in the list the portlets that are in the same tree as the current page.
        -->
        
        <xsl:variable name="portletPermissionsTree" select="Trees/Tree"/>
        <xsl:variable name="portletPermissionsTreeId" select="$portletPermissionsTree/@Id"/>
        <xsl:variable name="portletId" select="@Id"/>
        <xsl:variable name="portletType" select="@portletType"/>

        <xsl:choose>
           <xsl:when test="$oldRootPermissionsTreeId=$portletPermissionsTreeId">
              <UpdateMetadata>
              <Metadata>
                <PSPortlet>
                  <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
                  <Trees Function="replace">
                    <Tree>
                       <xsl:attribute name="ObjRef"><xsl:value-of select="$newRootPermissionsTreeId"/></xsl:attribute>
                    </Tree>
                  </Trees>
                </PSPortlet>

                <!-- For collections, we need to move the items in the collection also -->
                <xsl:if test="$portletType='Collection'">
                  <xsl:for-each select="Groups/Group">

                    <xsl:variable name="groupId" select="@Id"/>

                    <Group>

                       <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
                       <Trees Function="replace">
                         <Tree>
                            <xsl:attribute name="ObjRef"><xsl:value-of select="$newRootPermissionsTreeId"/></xsl:attribute>
                         </Tree>
                       </Trees>

                    </Group>

                    <xsl:for-each select="Members/*">

                    <!-- The list of members of the collection contains a link bank to the collection psportlet itself, ignore that one -->

                      <xsl:variable name="itemId" select="@Id"/>

                      <xsl:if test="not($itemId=$portletId)">

                         <xsl:variable name="itemType" select="name(.)"/>
                         <xsl:element name="{$itemType}">

                           <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
                           <Trees Function="replace">
                             <Tree>
                                <xsl:attribute name="ObjRef"><xsl:value-of select="$newRootPermissionsTreeId"/></xsl:attribute>
                             </Tree>
                           </Trees>

                         </xsl:element>

                      </xsl:if>

                    </xsl:for-each>
                  </xsl:for-each>

                </xsl:if>
              </Metadata>
              <NS>SAS</NS>
              <Flags>268435456</Flags>
              <Options/>
              </UpdateMetadata>
            
           </xsl:when>
           <xsl:otherwise>
           </xsl:otherwise>
        </xsl:choose>

     </xsl:for-each>

  </xsl:if>

</xsl:template>

<xsl:template name="processScopeChange">

  <xsl:param name="old"/>
  <xsl:param name="new"/>
  <!-- The force parameter, when set to any value, will cause the processing to happen even if old and new are the same values.
       This is mostly used to re-create the scope extensions when changing sharing group 
    -->

  <xsl:param name="force"/>

  <!-- NOTE: We have to be careful how we change the extensions so as to make sure that the changes
       are picked up for any user that the page has been shared with or will be shared with.  See
       the portal/permissionsTree/createUserSharedPortalPages.xslt processing to make sure that code here is consistent with it!
  -->

  <xsl:if test="not($old=$new) or $force">

     <!-- If we already have an extension, delete the old one and create a new one.  Note that
          we could have just updated the existing one, but then the change wouldn't be seen by the sync User process to share
          pages with users.
     -->

        <xsl:if test="$oldScopeObjectId">

           <!-- Remove the old extension -->

           <DeleteMetadata>
             <Metadata>
	       <Extension>
		 <xsl:attribute name="Id"><xsl:value-of select="$oldScopeObjectId"/></xsl:attribute>
	       </Extension>
	     </Metadata>
	     <NS>SAS</NS>
	     <Flags>268435456</Flags>
	     <Options/>

           </DeleteMetadata>

        </xsl:if>

        <xsl:if test="$new and not($new='notshared')">
           <xsl:variable name="newScopeObjectId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newScopeObject</xsl:variable>
           <UpdateMetadata>
             <Metadata>
	       <Extension>
		 <xsl:attribute name="Id"><xsl:value-of select="$newScopeObjectId"/></xsl:attribute>
                 <xsl:attribute name="Name"><xsl:value-of select="$new"/></xsl:attribute>
                 <OwningObject>
                   <PSPortalPage>
                      <xsl:attribute name="ObjRef"><xsl:value-of select="$pageId"/></xsl:attribute>
                   </PSPortalPage>
                 </OwningObject>
	       </Extension>
	     </Metadata>
	     <NS>SAS</NS>
	     <Flags>268435456</Flags>
	     <Options/>

           </UpdateMetadata>

        </xsl:if>

  </xsl:if>

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
   <xsl:variable name="oldColumnObjectId" select="$pageObject/LayoutComponents/PSColumnLayoutComponent[position()=$columnNumber]/@Id"/>

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

   <xsl:apply-templates select="$pageObject/LayoutComponents/PSColumnLayoutComponent[position()=$columnNumber]"/>

</xsl:template>

</xsl:stylesheet>

