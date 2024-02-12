<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<xsl:template match="/">

<xsl:variable name="reposId" select="/Mod_Request/NewMetadata/Metareposid"/>

<xsl:variable name="portletId" select="Mod_Request/GetMetadata/Metadata/PSPortlet/@Id"/>
<xsl:variable name="portletType" select="Mod_Request/GetMetadata/Metadata/PSPortlet/@PortletType"/>

<!--  For the following properties, when the portlet is first created, these properties are not
      created by default.  Thus, it's possible that when we get here, we actually have to create them.
      If we determine that to be the case, then create the id in the format that UpdateMetadata expects
      so that it will create a new object.
-->

<!-- Properties -->

<xsl:variable name="configPropertySet" select="Mod_Request/GetMetadata/Metadata/PSPortlet/PropertySets/PropertySet[@Name='PORTLET_CONFIG_ROOT']"/>
<xsl:variable name="configPropertySetId" select="$configPropertySet/@Id"/>

<!-- Portlet Height -->
<!-- NOTE: For some reason, you can't set the height on a report portlet.  Removing the processing for now, but if it is 
     needed, many of the other update processors handle it.
-->

<!-- Portlet URI -->

<!--  The URI we store has the prefix SBIP://METASERVER on it.  No need to force the user to enter that, just have them enter the full path -->

<!--  The URI must end in .srx for it to be properly viewed by WRS, so if it doesn't have it, add it -->

<xsl:variable name="newPortletURIId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newPortletURI</xsl:variable>

<xsl:variable name="oldPortletURIProperty" select="$configPropertySet/SetProperties/Property[@Name='SELECTED_REPORT']"/>

<xsl:variable name="oldPortletFolderURIProperty" select="$configPropertySet/SetProperties/Property[@Name='SELECTED_FOLDER']"/>

<xsl:variable name="oldPortletURI" select="$oldPortletURIProperty/@DefaultValue"/>
<xsl:variable name="oldPortletPath" select="substring-after($oldPortletURI,'SBIP://METASERVER')"/>

<xsl:variable name="oldPortletURIFolder" select="$oldPortletFolderURIProperty/@DefaultValue"/>
<xsl:variable name="oldPortletPathFolder" select="substring-after($oldPortletURIFolder,'SBIP://METASERVER')"/>

<xsl:variable name="oldPortletURIId">
 <xsl:choose>
   <xsl:when test="$oldPortletURIProperty/@Id">
      <xsl:value-of select="$oldPortletURIProperty/@Id"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$newPortletURIId"/>
   </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--  The URI we store has the prefix SBIP://METASERVER on it.  No need to force the user to enter that, just have them enter the full path -->

<xsl:variable name="portletURIPrefix">SBIP://METASERVER</xsl:variable>

<!-- Not sure why, but the report URI adds (Report) to the end of the URI stored and (Folder) to the end of the Folder stored -->

<xsl:variable name="newPortletURI">
  <xsl:choose>
     <xsl:when test="Mod_Request/NewMetadata/PortletPath">
       <xsl:choose>
        <xsl:when test="ends-with(Mod_Request/NewMetadata/PortletPath,'.srx')"><xsl:value-of select="$portletURIPrefix"/><xsl:value-of select="Mod_Request/NewMetadata/PortletPath"/>(Report)</xsl:when>
        <xsl:when test="ends-with(Mod_Request/NewMetadata/PortletPath,'.srx(Report)')"><xsl:value-of select="$portletURIPrefix"/><xsl:value-of select="Mod_Request/NewMetadata/PortletPath"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$portletURIPrefix"/><xsl:value-of select="Mod_Request/NewMetadata/PortletPath"/>.srx(Report)</xsl:otherwise>
       </xsl:choose>
     </xsl:when>
     <xsl:otherwise><xsl:value-of select="$oldPortletURI"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--  See if there is anything changed and if so, do it -->

<xsl:choose>

  <xsl:when test="not($oldPortletURI = $newPortletURI)">

    <UpdateMetadata>

      <Metadata>

        <!--  Portlet URI -->

        <xsl:if test="not($oldPortletURI=$newPortletURI)">

           <Property><xsl:attribute name="Id"><xsl:value-of select="$oldPortletURIId"/></xsl:attribute><xsl:attribute name="DefaultValue"><xsl:value-of select="$newPortletURI"/></xsl:attribute>

               <!-- If the old id is not the same as the new id, then we already had the object, so no further
                    metadata is required.  If they are the same, then we need to fill in the rest of the information
                    about this property -->
               <xsl:if test="$oldPortletURIId=$newPortletURIId">

                   <xsl:attribute name="Name">SELECTED_REPORT</xsl:attribute>
                   <xsl:attribute name="SQLType">12</xsl:attribute>

                   <AssociatedPropertySet>
                      <PropertySet>
                        <xsl:attribute name="ObjRef"><xsl:value-of select="$configPropertySetId"/></xsl:attribute>
                      </PropertySet>
                   </AssociatedPropertySet>

               </xsl:if>

        </Property>

        <!--  Portlet Folder URI -->

        <!--  If the folder Item Changed, need to determine if the hidden property SELECTED_FOLDER changed also. -->

         <xsl:variable name="oldPortletURITokens" select="tokenize($oldPortletURI,'/')"/>
         <xsl:variable name="oldPortletURInumTokens" select="count($oldPortletURITokens)"/>
         <xsl:variable name="oldPortletFolderURI">
           <xsl:for-each select="$oldPortletURITokens">
              <xsl:choose><xsl:when test="position()=1"><xsl:value-of select="."/></xsl:when>
                         <xsl:when test="position() &lt; $oldPortletURInumTokens">/<xsl:value-of select="."/></xsl:when>
              </xsl:choose>
           </xsl:for-each>
         </xsl:variable>

         <xsl:variable name="newPortletURITokens" select="tokenize($newPortletURI,'/')"/>
         <xsl:variable name="newPortletURInumTokens" select="count($newPortletURITokens)"/>
         <xsl:variable name="newPortletFolderURI">
           <xsl:for-each select="$newPortletURITokens">
              <xsl:choose><xsl:when test="position()=1"><xsl:value-of select="."/></xsl:when>
                         <xsl:when test="position() &lt; $newPortletURInumTokens">/<xsl:value-of select="."/></xsl:when>
              </xsl:choose>
           </xsl:for-each>
         </xsl:variable>

         <xsl:if test="not($oldPortletFolderURI=$newPortletFolderURI)">

            <!-- The folder changed, see what we need to do -->

             <xsl:variable name="newPortletFolderURIId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newPortletFolderURI</xsl:variable>
             <xsl:variable name="oldPortletFolderURIId">
              <xsl:choose>
                <xsl:when test="$oldPortletFolderURIProperty/@Id">
                   <xsl:value-of select="$oldPortletFolderURIProperty/@Id"/>
                </xsl:when>
                <xsl:otherwise>
                 <xsl:value-of select="$newPortletFolderURIId"/>
                </xsl:otherwise>
               </xsl:choose>
             </xsl:variable>
           <xsl:variable name="toStorePortletFolderURI"><xsl:value-of select="$newPortletFolderURI"/>(Folder)</xsl:variable>
           <Property><xsl:attribute name="Id"><xsl:value-of select="$oldPortletFolderURIId"/></xsl:attribute><xsl:attribute name="DefaultValue"><xsl:value-of select="$toStorePortletFolderURI"/></xsl:attribute>

               <!-- If the old id is not the same as the new id, then we already had the object, so no further
                    metadata is required.  If they are the same, then we need to fill in the rest of the information
                    about this property -->
               <xsl:if test="$oldPortletFolderURIId=$newPortletFolderURIId">

                   <xsl:attribute name="Name">SELECTED_FOLDER</xsl:attribute>
                   <xsl:attribute name="SQLType">12</xsl:attribute>

                   <AssociatedPropertySet>
                      <PropertySet>
                        <xsl:attribute name="ObjRef"><xsl:value-of select="$configPropertySetId"/></xsl:attribute>
                      </PropertySet>
                   </AssociatedPropertySet>

               </xsl:if>

        </Property>

         </xsl:if> 

        </xsl:if>

      </Metadata>

      <NS>SAS</NS>
      <Flags>268435456</Flags>
      <Options/>

    </UpdateMetadata>

  </xsl:when>

  <xsl:otherwise>
     <Root/>
     <xsl:comment>NOTE: No update required.</xsl:comment>
  </xsl:otherwise>

 </xsl:choose>

</xsl:template>

</xsl:stylesheet>

