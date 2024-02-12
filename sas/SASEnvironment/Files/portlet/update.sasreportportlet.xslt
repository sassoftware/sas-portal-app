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

<xsl:variable name="configProperties" select="$configPropertySet/SetProperties"/>
<xsl:variable name="configPropertySets" select="$configPropertySet/PropertySets"/>

<!-- Portlet Height -->

<xsl:variable name="newPortletHeightId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newPortletHeight</xsl:variable>

<xsl:variable name="oldPortletHeightPropertySet" select="$configPropertySets/PropertySet[@Name='portletHeight']"/>
<xsl:variable name="oldPortletHeightProperty" select="$oldPortletHeightPropertySet/SetProperties/Property[@Name='PreferenceInstanceProperty']"/>

<xsl:variable name="oldPortletHeightId">
 <xsl:choose>
   <xsl:when test="$oldPortletHeightProperty/@Id">
      <xsl:value-of select="$oldPortletHeightProperty/@Id"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$newPortletHeightId"/>
   </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="oldPortletHeight" select="$oldPortletHeightProperty/@DefaultValue"/>

<xsl:variable name="newPortletHeight">
  <xsl:choose>
     <xsl:when test="Mod_Request/NewMetadata/PortletHeight"><xsl:value-of select="Mod_Request/NewMetadata/PortletHeight"/></xsl:when>
     <xsl:otherwise><xsl:value-of select="$oldPortletHeight"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Portlet URI -->

<!--  The URI we store has the prefix SBIP://METASERVER on it.  No need to force the user to enter that, just have them enter the full path -->

<!--  The URI must end in .srx for it to be properly viewed by WRS, so if it doesn't have it, add it -->

<xsl:variable name="newPortletURIId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newPortletURI</xsl:variable>

<xsl:variable name="oldPortletURIPropertySet" select="$configPropertySets/PropertySet[@Name='selectedFolderItem']"/>
<xsl:variable name="oldPortletURIProperty" select="$oldPortletURIPropertySet/SetProperties/Property[@Name='PreferenceInstanceProperty']"/>

<xsl:variable name="oldPortletFolderURIPropertySet" select="$configPropertySets/PropertySet[@Name='selectedFolder']"/>
<xsl:variable name="oldPortletFolderURIProperty" select="$oldPortletFolderURIPropertySet/SetProperties/Property[@Name='PreferenceInstanceProperty']"/>

<xsl:variable name="oldPortletURI" select="$configPropertySets/PropertySet[@Name='selectedFolderItem']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>
<xsl:variable name="oldPortletPath" select="substring-after($oldPortletURI,'SBIP://METASERVER')"/>

<xsl:variable name="oldPortletURIFolder" select="$configPropertySets/PropertySet[@Name='selectedFolder']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>
<xsl:variable name="oldPortletPathFolder" select="substring-after($oldPortletURIFolder,'SBIP://METASERVER')"/>

<xsl:variable name="oldPortletPrompts" select="$configPropertySets/PropertySet[@Name='promptNames']/SetProperties/Property[@Name='PreferenceInstanceProperty']/@DefaultValue"/>

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

<xsl:variable name="oldPortletURI" select="$oldPortletURIProperty/@DefaultValue"/>
<xsl:variable name="newPortletURI">
  <xsl:choose>
     <xsl:when test="Mod_Request/NewMetadata/PortletPath">
       <xsl:choose>
        <xsl:when test="ends-with(Mod_Request/NewMetadata/PortletPath,'.srx')"><xsl:value-of select="$portletURIPrefix"/><xsl:value-of select="Mod_Request/NewMetadata/PortletPath"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$portletURIPrefix"/><xsl:value-of select="Mod_Request/NewMetadata/PortletPath"/>.srx</xsl:otherwise>
       </xsl:choose>
     </xsl:when>
     <xsl:otherwise><xsl:value-of select="$oldPortletURI"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--  See if there is anything changed and if so, do it -->

<xsl:choose>

  <xsl:when test="not($oldPortletHeight = $newPortletHeight) or not($oldPortletURI = $newPortletURI)">

    <UpdateMetadata>

      <Metadata>

        <!--  Portlet Height -->

        <xsl:if test="not($oldPortletHeight=$newPortletHeight)">

             <!-- Get the information we will need to create the property set hierarchy if it doesn't exist yet -->

             <!--  We have to start at the propertyset level and see what needs to be created -->
             <xsl:variable name="newPortletHeightPropertySetId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newPortletHeightPropertySet</xsl:variable>
             <xsl:variable name="portletHeightPropertySetId">
                <xsl:choose>
                   <xsl:when test="$oldPortletHeightPropertySet/@Id">
                      <xsl:value-of select="$oldPortletHeightPropertySet/@Id"/>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:value-of select="$newPortletHeightPropertySetId"/>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:variable>

            <xsl:if test="$portletHeightPropertySetId=$newPortletHeightPropertySetId">
                   <!-- The property set doesn't exist, so create it now -->

                   <PropertySet Name="portletHeight">
                      <xsl:attribute name="Id"><xsl:value-of select="$portletHeightPropertySetId"/></xsl:attribute>
                      <xsl:variable name="portletHeightPropertySetExtensionId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newPortletHeightPropertySetExtension</xsl:variable>
                      <Extensions>
                        <Extension Name="ReadOnly" ExtensionType="String" Value="false">
                           <xsl:attribute name="Id"><xsl:value-of select="$portletHeightPropertySetExtensionId"/></xsl:attribute>
                        </Extension>
                      </Extensions>   

                      <OwningObject>
                         <PropertySet>
                           <xsl:attribute name="ObjRef"><xsl:value-of select="$configPropertySetId"/></xsl:attribute>
                         </PropertySet>
                      </OwningObject>
                   </PropertySet>

            </xsl:if>

           <Property><xsl:attribute name="Id"><xsl:value-of select="$oldPortletHeightId"/></xsl:attribute><xsl:attribute name="DefaultValue"><xsl:value-of select="$newPortletHeight"/></xsl:attribute>

               <!-- If the old id is not the same as the new id, then we already had the object, so no further
                    metadata is required.  If they are the same, then we need to fill in the rest of the information
                    about this property -->
               <xsl:if test="$oldPortletHeightId=$newPortletHeightId">

                   <xsl:attribute name="Name">PreferenceInstanceProperty</xsl:attribute>
                   <xsl:attribute name="SQLType">12</xsl:attribute>

                   <AssociatedPropertySet>
                      <PropertySet>
                        <xsl:attribute name="ObjRef"><xsl:value-of select="$portletHeightPropertySetId"/></xsl:attribute>
                      </PropertySet>
                   </AssociatedPropertySet>

               </xsl:if>

        </Property>

        </xsl:if>

        <!--  Portlet URI -->

        <xsl:if test="not($oldPortletURI=$newPortletURI)">

             <!-- Get the information we will need to create the property set hierarchy if it doesn't exist yet -->

             <!--  We have to start at the propertyset level and see what needs to be created -->
             <xsl:variable name="newPortletURIPropertySetId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newPortletURIPropertySet</xsl:variable>
             <xsl:variable name="portletURIPropertySetId">
                <xsl:choose>
                   <xsl:when test="$oldPortletURIPropertySet/@Id">
                      <xsl:value-of select="$oldPortletURIPropertySet/@Id"/>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:value-of select="$newPortletURIPropertySetId"/>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:variable>

            <xsl:if test="$portletURIPropertySetId=$newPortletURIPropertySetId">
                   <!-- The property set doesn't exist, so create it now -->

                   <PropertySet Name="selectedFolderItem">
                      <xsl:attribute name="Id"><xsl:value-of select="$portletURIPropertySetId"/></xsl:attribute>
                      <xsl:variable name="portletURIPropertySetExtensionId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newPortletURIPropertySetExtension</xsl:variable>
                      <Extensions>
                        <Extension Name="ReadOnly" ExtensionType="String" Value="false">
                           <xsl:attribute name="Id"><xsl:value-of select="$portletURIPropertySetExtensionId"/></xsl:attribute>
                        </Extension>
                      </Extensions>   

                      <OwningObject>
                         <PropertySet>
                           <xsl:attribute name="ObjRef"><xsl:value-of select="$configPropertySetId"/></xsl:attribute>
                         </PropertySet>
                      </OwningObject>
                   </PropertySet>

            </xsl:if>

           <Property><xsl:attribute name="Id"><xsl:value-of select="$oldPortletURIId"/></xsl:attribute><xsl:attribute name="DefaultValue"><xsl:value-of select="$newPortletURI"/></xsl:attribute>

               <!-- If the old id is not the same as the new id, then we already had the object, so no further
                    metadata is required.  If they are the same, then we need to fill in the rest of the information
                    about this property -->
               <xsl:if test="$oldPortletURIId=$newPortletURIId">

                   <xsl:attribute name="Name">PreferenceInstanceProperty</xsl:attribute>
                   <xsl:attribute name="SQLType">12</xsl:attribute>

                   <AssociatedPropertySet>
                      <PropertySet>
                        <xsl:attribute name="ObjRef"><xsl:value-of select="$portletURIPropertySetId"/></xsl:attribute>
                      </PropertySet>
                   </AssociatedPropertySet>

               </xsl:if>

        </Property>

        <!--  Portlet Folder URI -->

        <!--  If the folder Item Changed, need to determine if the hidden property selectedFolder changed also. -->

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

             <!-- Get the information we will need to create the property set hierarchy if it doesn't exist yet -->

             <!--  We have to start at the propertyset level and see what needs to be created -->
             <xsl:variable name="newPortletFolderURIPropertySetId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newPortletFolderURIPropertySet</xsl:variable>
             <xsl:variable name="portletFolderURIPropertySetId">
                <xsl:choose>
                   <xsl:when test="$oldPortletFolderURIPropertySet/@Id">
                      <xsl:value-of select="$oldPortletFolderURIPropertySet/@Id"/>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:value-of select="$newPortletFolderURIPropertySetId"/>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:variable>

            <xsl:if test="$portletFolderURIPropertySetId=$newPortletFolderURIPropertySetId">
                   <!-- The property set doesn't exist, so create it now -->

                   <PropertySet Name="selectedFolder">
                      <xsl:attribute name="Id"><xsl:value-of select="$portletFolderURIPropertySetId"/></xsl:attribute>
                      <xsl:variable name="portletFolderURIPropertySetExtensionId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newPortletFolderURIPropertySetExtension</xsl:variable>
                      <Extensions>
                        <Extension Name="ReadOnly" ExtensionType="String" Value="false">
                           <xsl:attribute name="Id"><xsl:value-of select="$portletFolderURIPropertySetExtensionId"/></xsl:attribute>
                        </Extension>
                      </Extensions>   

                      <OwningObject>
                         <PropertySet>
                           <xsl:attribute name="ObjRef"><xsl:value-of select="$configPropertySetId"/></xsl:attribute>
                         </PropertySet>
                      </OwningObject>
                   </PropertySet>

            </xsl:if>
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

           <Property><xsl:attribute name="Id"><xsl:value-of select="$oldPortletFolderURIId"/></xsl:attribute><xsl:attribute name="DefaultValue"><xsl:value-of select="$newPortletFolderURI"/></xsl:attribute>

               <!-- If the old id is not the same as the new id, then we already had the object, so no further
                    metadata is required.  If they are the same, then we need to fill in the rest of the information
                    about this property -->
               <xsl:if test="$oldPortletFolderURIId=$newPortletFolderURIId">

                   <xsl:attribute name="Name">PreferenceInstanceProperty</xsl:attribute>
                   <xsl:attribute name="SQLType">12</xsl:attribute>

                   <AssociatedPropertySet>
                      <PropertySet>
                        <xsl:attribute name="ObjRef"><xsl:value-of select="$portletFolderURIPropertySetId"/></xsl:attribute>
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

