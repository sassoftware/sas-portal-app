<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<!-- Common Setup -->

<!-- This setup calls the common setup pieces but because this file is referenced
     from another xslt file, the path to the files to include are different than
     normal
-->
<!-- Set up the metadataContext variable -->
<xsl:include href="setup.metadatacontext.xslt"/>
<!-- Set up the environment context variables -->
<xsl:include href="setup.envcontext.xslt"/>

<!-- load the appropriate localizations -->

<!-- This localization handling is not the normal processing!
     Since this file is included in other files, the base uri of this file changes.
     Thus, the passed in localization file location doesn't work.

     We will build a new directory, relative to the directory of this file, and get the 
     correct resources file from the passed in location to build a specialized
     locale file location for this script
-->

<xsl:variable name="localizationDirOverride">../localization</xsl:variable>

<xsl:variable name="localizationFile">
 <xsl:choose>
   <xsl:when test="/Mod_Request/NewMetadata/LocalizationFile"><xsl:value-of select="/Mod_Request/NewMetadata/LocalizationFile"/></xsl:when>
   <xsl:otherwise><xsl:value-of select="$localizationDirOverride"/>/resources_en.xml</xsl:otherwise>
 </xsl:choose>
</xsl:variable>

<xsl:variable name="useLocalizationFile"><xsl:value-of select="$localizationDirOverride"/>/<xsl:value-of select="tokenize($localizationFile,'/')[last()]"/></xsl:variable>

<!-- load the appropriate localizations -->

<xsl:variable name="localeXml" select="document($useLocalizationFile)/*"/>

<!-- Strings to be localized -->
<xsl:variable name="okButton" select="$localeXml/string[@key='okButton']/text()"/>
<xsl:variable name="cancelButton" select="$localeXml/string[@key='cancelButton']/text()"/>

<xsl:variable name="portletRemovePortlet" select="$localeXml/string[@key='portletRemovePortlet']/text()"/>
<xsl:variable name="portletRemovePortletPermanent" select="$localeXml/string[@key='portletRemovePortletPermanent']/text()"/>

<!-- Define the lookup table of writeable trees -->

<xsl:key name="treeKey" match="Tree" use="@Id"/>
<!-- it doesnt say this anywhere in the xsl key doc, but the objects to use for the lookup table
     must be under a shared root object.  Thus, here we can only go to the AccessControlEntries
     level.  Fortunately, the only trees listed under here are the ones we want in our lookup table
  -->
<xsl:variable name="treeLookup" select="$metadataContext/Multiple_Requests/GetMetadataObjects[1]/Objects/Person/AccessControlEntries"/>
<!-- Get the same set of nodes in a a variable -->
<xsl:variable name="writeableTrees" select="$metadataContext/Multiple_Requests/GetMetadataObjects[1]/Objects/Person/AccessControlEntries/AccessControlEntry/Objects/Tree"/>

<!-- Re-usable scripts -->

<xsl:include href="form.functions.xslt"/>

<xsl:template match="/">

<xsl:call-template name="commonFormFunctions"/>
<xsl:call-template name="thisPageScripts"/>

<xsl:variable name="removeLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/deleteItem')"/>

<xsl:variable name="portletId" select="/Mod_Request/NewMetadata/Id"/>
<xsl:variable name="portletType" select="/Mod_Request/NewMetadata/PortletType"/>
<xsl:variable name="layoutComponentId" select="/Mod_Request/NewMetadata/RelatedId"/>
<xsl:variable name="layoutComponentType" select="/Mod_Request/NewMetadata/RelatedType"/>

<xsl:variable name="portletObject" select="$metadataContext/Multiple_Requests/GetMetadataObjects[2]/Objects/PSPortlet"/>

<!--  The rules that need to represented on the resulting portlet are:

    If portlet is writeable:
            get Remove or Delete prompt
    else (portlet not writeable) 
            Get Remove prompt only
-->

   <xsl:variable name="portletPermissionsTree" select="$portletObject/Trees/Tree"/>

   <xsl:variable name="portletPermissionsTreeId" select="$portletPermissionsTree/@Id"/>

   <xsl:variable name="portletPermissionsTreeKey" select="key('treeKey',$portletPermissionsTreeId,$treeLookup)/@Name"/>

   <xsl:variable name="portletIsWriteable">
     <xsl:choose>
       <xsl:when test="$portletPermissionsTreeKey">1</xsl:when>
       <xsl:otherwise>0</xsl:otherwise>
     </xsl:choose>
   </xsl:variable>

   <xsl:if test="$portletIsWriteable='1'">
   </xsl:if>

<!--  NOTE: We set up a hidden formResponse iframe to capture the result so that we can either display the results (if debugging) or simply cause a "go back" to happen after the form is submitted (by using the iframe onload function).  The event handler to handle this is in the CommonFormFunctions template -->

<form name="deleteOptionsForm" method="post" target="formResponse">

    <xsl:attribute name="action"><xsl:value-of select="$removeLink"/></xsl:attribute>

    <input type="hidden" name="id">
      <xsl:attribute name="value"><xsl:value-of select="$portletId"/></xsl:attribute></input>
    <input type="hidden" name="type"><xsl:attribute name="value">PSPortlet</xsl:attribute></input>
    <input type="hidden" name="portletType"><xsl:attribute name="value"><xsl:value-of select="$portletType"/></xsl:attribute></input>
    <input type="hidden" name="RelatedId"><xsl:attribute name="value"><xsl:value-of select="$layoutComponentId"/></xsl:attribute></input>
    <input type="hidden" name="RelatedType"><xsl:attribute name="value"><xsl:value-of select="$layoutComponentType"/></xsl:attribute></input>
 
    <table cellpadding="0" cellspacing="0" width="100%" class="dataEntryBG" border="0">
        <tr>
            <td colspan="4"><img border="0" height="12" alt="">
               <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
               </img>
           </td>
        </tr>
        <tr>
            <td colspan="4" align="center" valign="center" width="100%">
             <div id="portal_message"></div>
            </td>
        </tr>
        <tr>
            <td><img border="0" width="12" alt="">
               <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
               </img>
            </td>
            <td align="center" valign="center" colspan="2" width="100%">
            <div id="portal_message"></div>
            </td>
            <td><img border="0" width="12" alt="">
               <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
               </img>
            </td>
        </tr>
        <tr>
            <td><img border="0" width="12"
                alt="" >
             <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
              </img>

            </td>
            <td class="commonLabel" align="left" valign="center" colspan="2" width="100%">
                <input type="radio" id="portletremove" name="removetype" value="remove" checked="checked"/> 
                <label for="portletremove"><xsl:value-of select="$portletRemovePortlet"/>
                </label>
            </td>
            <td><img border="0" width="12" alt="" >
                  <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
              </img>

             </td>
        </tr>


        <xsl:if test="$portletIsWriteable='1'">

            <tr>
                <td><img border="0"  width="12" alt="" >
           <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
           </img>

                 </td>
                <td class="commonLabel" align="left" valign="center" colspan="2" width="100%">
                    <input type="radio" id="portletdelete" name="removetype" value="delete" />
                    <label for="portletdelete"><xsl:value-of select="$portletRemovePortletPermanent"/>
                    </label>
                </td>
                <td><img border="0"  width="12" alt="" >
           <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
           </img>

                </td>
            </tr>

        </xsl:if>

        <tr>
            <td colspan="4"><img border="0" height="6" alt="" >
       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
       </img>

            </td>
        </tr>
   
            <tr>
                <td colspan="4"><img border="0" height="24" alt="" >
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                       </img>
                </td>
            </tr>

            <tr>
                <td colspan="4" class="wizardMessageFooter" height="1"></td>
            </tr>


            <tr class="buttonBar">
                <td colspan="4"><img border="0" height="6" alt="" >
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                       </img>
                </td>
            </tr>
            <tr class="buttonBar">
                <td colspan="4" align="left">
                <img border="0" width="12" alt="" > 
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                       </img>
                <input class="button" type="submit" onclick='return submitDisableAllForms();'> 
                    <xsl:attribute name="value"><xsl:value-of select="$okButton"/></xsl:attribute>
                </input>
                &#160;
                <input class="button" type="button" onclick='history.go(-1);' >
                    <xsl:attribute name="value"><xsl:value-of select="$cancelButton"/></xsl:attribute>
                </input>
                </td>
            </tr>
            <tr class="buttonBar">
                <td colspan="4"><img border="0" height="6" alt="" >
                       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                       </img>
                </td>
            </tr>

        


    </table>

</form>

  <!-- This iframe is here to capture the response from submitting the form -->
  
  <iframe id="formResponse" name="formResponse" style="display:none" width="100%">
  
  </iframe>

</xsl:template>

<xsl:template name="thisPageScripts">
<script>
  
    /*
     *  Any script content specific to this page.
     */

  function toggleDeleteContainedElementsDiv() {

    var elementDiv = document.getElementById('containedElementsDiv');

    var visibility=elementDiv.style.visibility;
    
    if (visibility=="hidden") {

       elementDiv.style.visibility="visible";
       elementDiv.style.display="block";
       }
    else {
       elementDiv.style.visibility="hidden";
       elementDiv.style.display="none";
       }
    }

</script>

</xsl:template>



</xsl:stylesheet>

