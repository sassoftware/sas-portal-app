<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>

<!-- Common Setup -->
<!-- Note that because this script is included in others, the references here are relative to this file, not the normal full path -->

<!-- Set up the metadataContext variable -->
<xsl:include href="setup.metadatacontext.xslt"/>
<!-- Set up the environment context variables -->
<xsl:include href="setup.envcontext.xslt"/>

<!-- This script is meant to be included by the other specific portlet types after 
     setting global variables which drive the detailed processing here.

     includeCollectionGroup = include the creation of a collection group (1=yes, 0=no)
     portletType = the value to place in the portletType field
     prototypeURI = the value of the URI extension to the prototype to link to
     includePortletRenderState = whether this portlet has additional rendering properties associated with it or not
-->

<xsl:variable name="usingPrototypeId" select="$metadataContext/GetMetadataObjects/Objects/Tree/Members/Prototype[Extensions/Extension[@Name='URI' and @Value=$prototypeURI]]/@Id"/>

<xsl:variable name="parentTreeId" select="/Mod_Request/NewMetadata/ParentTreeId"/>
<xsl:variable name="inComponentLayoutId" select="/Mod_Request/NewMetadata/RelatedId"/>
<xsl:variable name="inComponentLayoutType" select="/Mod_Request/NewMetadata/RelatedType"/>

<xsl:variable name="portletName" select="/Mod_Request/NewMetadata/Name"/>
<xsl:variable name="portletDesc" select="/Mod_Request/NewMetadata/Desc"/>

<xsl:template match="/">

    <UpdateMetadata>

                <Metadata>

                <xsl:call-template name="buildPortlet"/>

                </Metadata>
                <NS>SAS</NS>
                <Flags>268435456</Flags>
                <Options/>

    </UpdateMetadata>

</xsl:template>

<xsl:template name="buildPortlet">

   <xsl:variable name="mainPortlet"><xsl:value-of select="substring-after($reposId,'.')"/>.$newPortlet</xsl:variable>

  <PSPortlet>
             <xsl:attribute name="Id"><xsl:value-of select="$mainPortlet"/></xsl:attribute>
             <xsl:attribute name="Name"><xsl:value-of select="$portletName"/></xsl:attribute>
             <xsl:attribute name="Desc"><xsl:value-of select="$portletDesc"/></xsl:attribute>
             <xsl:attribute name="portletType"><xsl:value-of select="$portletType"/></xsl:attribute>

     <PropertySets>
         <xsl:variable name="newPSId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newPS</xsl:variable>
         <PropertySet Name="PORTLET_CONFIG_ROOT">
            <xsl:attribute name="Id"><xsl:value-of select="$newPSId"/></xsl:attribute>
         </PropertySet>

         <!-- The portlets that come from the JSR 168 efforts have an additional PropertySet PortletRenderState.
              Add it now if asked to do so.
           -->

         <xsl:if test="$includePortletRenderState='1'">
             <xsl:variable name="newPS1Id"><xsl:value-of select="substring-after($reposId,'.')"/>.$newPS1</xsl:variable>
             <PropertySet Name="PortletRenderState">
                <xsl:attribute name="Id"><xsl:value-of select="$newPS1Id"/></xsl:attribute>

                <Trees>
                   <Tree><xsl:attribute name="ObjRef"><xsl:value-of select="$parentTreeId"/></xsl:attribute></Tree>
                </Trees>

                <xsl:variable name="newPS1E1Id"><xsl:value-of select="substring-after($reposId,'.')"/>.$newPS1E1</xsl:variable>
                <xsl:variable name="newPS1E2Id"><xsl:value-of select="substring-after($reposId,'.')"/>.$newPS1E2</xsl:variable>

                <Extensions>
                    <Extension Name="WindowState" ExtensionType="String" Value="1">
                     <xsl:attribute name="Id"><xsl:value-of select="$newPS1E1Id"/></xsl:attribute>
                    </Extension>

                    <Extension Name="PortletMode" ExtensionType="String" Value="0">
                     <xsl:attribute name="Id"><xsl:value-of select="$newPS1E2Id"/></xsl:attribute>
                    </Extension>
                </Extensions>
             </PropertySet>

         </xsl:if>

     </PropertySets>

     <xsl:if test="$includeCollectionGroup='1'">
         <!-- This looks a bit weird and not quite sure why it was originally done this way
               
              For a collection type portlet, it has a group underneath it that will contain the list of items
              in the collection.
              The first item in the list is a reference back to the owning portlet.  While this update looks 
              circular, it is what was created initially by IDP.
         -->
         <Groups>
            <xsl:variable name="newGroupId"><xsl:value-of select="substring-after($reposId,'.')"/>.$newGroup</xsl:variable>
            <Group Name="Portal Collection">
                <xsl:attribute name="Id"><xsl:value-of select="$newGroupId"/></xsl:attribute>
                <xsl:attribute name="Desc"><xsl:value-of select="$portletDesc"/></xsl:attribute>
            </Group>
         </Groups>

     </xsl:if>

     <Trees>
        <Tree><xsl:attribute name="ObjRef"><xsl:value-of select="$parentTreeId"/></xsl:attribute></Tree>
    </Trees>

    <UsingPrototype>
        <Prototype><xsl:attribute name="ObjRef"><xsl:value-of select="$usingPrototypeId"/></xsl:attribute></Prototype>
    </UsingPrototype>

    <xsl:if test="$inComponentLayoutId">

        <LayoutComponents>
            <PSColumnLayoutComponent><xsl:attribute name="ObjRef"><xsl:value-of select="$inComponentLayoutId"/></xsl:attribute></PSColumnLayoutComponent>
        </LayoutComponents>

    </xsl:if>     

  </PSPortlet>

</xsl:template>

</xsl:stylesheet>

