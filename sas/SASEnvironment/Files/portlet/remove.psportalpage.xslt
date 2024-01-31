<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<!-- Input xml format is the Mod_Request format with results merged in from remove.get execution -->

<xsl:param name="appLocEncoded"/>

<xsl:param name="sastheme">default</xsl:param>
<xsl:variable name="sasthemeContextRoot">SASTheme_<xsl:value-of select="$sastheme"/></xsl:variable>

<xsl:variable name="localizationDir">SASPortalApp/sas/SASEnvironment/Files/localization</xsl:variable>

<xsl:param name="localizationFile"><xsl:value-of select="$localizationDir"/>/resources_en.xml</xsl:param>

<!-- load the appropriate localizations -->

<xsl:variable name="localeXml" select="document($localizationFile)/*"/>

<!-- Strings to be localized -->
<xsl:variable name="okButton" select="$localeXml/string[@key='okButton']/text()"/>
<xsl:variable name="cancelButton" select="$localeXml/string[@key='cancelButton']/text()"/>

<xsl:variable name="portletRemovePagePersonal" select="$localeXml/string[@key='portletRemovePagePersonal']/text()"/>
<xsl:variable name="portletRemovePagePermanent" select="$localeXml/string[@key='portletRemovePagePermanent']/text()"/>
<xsl:variable name="portletRemovePagePortlets" select="$localeXml/string[@key='portletRemovePagePortlets']/text()"/>

<!-- Define the lookup table of writeable trees -->
<xsl:key name="treeKey" match="Tree" use="@Id"/>
<!-- it doesnt say this anywhere in the xsl key doc, but the objects to use for the lookup table
     must be under a shared root object.  Thus, here we can only go to the AccessControlEntries
     level.  Fortunately, the only trees listed under here are the ones we want in our lookup table
  -->
<xsl:variable name="treeLookup" select="/Mod_Request/Multiple_Requests/GetMetadataObjects[1]/Objects/Person/AccessControlEntries"/>
<!-- Get the same set of nodes in a a variable -->
<xsl:variable name="writeableTrees" select="/Mod_Request/Multiple_Requests/GetMetadataObjects[1]/Objects/Person/AccessControlEntries/AccessControlEntry/Objects/Tree"/>

<!-- Re-usable scripts -->

<xsl:include href="SASPortalApp/sas/SASEnvironment/Files/portlet/form.functions.xslt"/>

<xsl:template match="/">

<xsl:call-template name="commonFormFunctions"/>
<xsl:call-template name="thisPageScripts"/>


<xsl:variable name="numWriteableTrees" select="count($writeableTrees)"/>

<xsl:variable name="removeLink" select="concat('/SASStoredProcess/do?_program=',$appLocEncoded,'services/deleteItem')"/>

<xsl:variable name="pageId" select="/Mod_Request/NewMetadata/Id"/>

<xsl:variable name="numPortlets" select="count(/Mod_Request/Multiple_Requests/GetMetadataObjects/Objects/PSPortalPage/LayoutComponents/*/Portlets/*)"/>

<!--  The rules that need to represented on the resulting page are:

    If page is writeable:
            get Remove or Delete prompt
              Only portlets in writeable trees are shown to be removed
    else (page not writeable) (remember that only Available and Default shared pages can be deleted):
            Get Remove prompt only
-->

  <!-- Calculate what type of remove can be done on this page based on the permissions on the parent tree -->

  <xsl:variable name="permissionsTree" select="/Mod_Request/Multiple_Requests/GetMetadataObjects[2]/Objects/PSPortalPage/Trees/Tree"/>
  <xsl:variable name="permissionsTreeId" select="$permissionsTree/@Id"/>

  <xsl:variable name="permissionsTreeKey" select="key('treeKey',$permissionsTreeId,$treeLookup)/@Name"/>

  <xsl:variable name="isWriteable">
    <xsl:choose>
      <xsl:when test="$permissionsTreeKey">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

<form name="deleteOptionsForm" method="post">
    <xsl:attribute name="action"><xsl:value-of select="$removeLink"/></xsl:attribute>

    <input type="hidden" name="id">
      <xsl:attribute name="value"><xsl:value-of select="$pageId"/></xsl:attribute></input>
    <input type="hidden" name="type"><xsl:attribute name="value">PSPortalPage</xsl:attribute></input>
 
    <table cellpadding="0" cellspacing="0" width="100%" class="dataEntryBG" border="0">
        <tr>
            <td colspan="4"><img border="0" height="12" alt="">
               <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
               </img>
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
                <input type="radio" id="pageremove" name="scope" value="remove" checked="checked" onclick="toggleDeleteContainedElementsDiv();" /> 
                <label for="pageremove"><xsl:value-of select="$portletRemovePagePersonal"/>
                </label>
            </td>
            <td><img border="0" width="12" alt="" >
                  <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
              </img>

             </td>
        </tr>

        <tr>
            <td colspan="4"><img border="0" height="6" alt="" >
       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
       </img>

            </td>
        </tr>
   
        <xsl:if test="$isWriteable='1'">

            <tr>
                <td><img border="0"  width="12" alt="" >
           <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
           </img>

                 </td>
                <td class="commonLabel" align="left" valign="center" colspan="2" width="100%">
                    <input type="radio" id="pagedelete" name="scope" value="delete" onclick="toggleDeleteContainedElementsDiv();" /> 
                    <label for="pagedelete"><xsl:value-of select="$portletRemovePagePermanent"/>
                    </label>
                </td>
                <td><img border="0"  width="12" alt="" >
           <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
           </img>

                </td>
            </tr>

        </xsl:if>

        <tr>
            <td><img border="0"  width="12" alt="" >
       <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
       </img>

        </td>
            <td valign="center" colspan="2" width="100%">
            <div id="containedElementsDiv" style="visibility: hidden; display: none">

            <table cellpadding="0" cellspacing="0" border="0" width="100%">
                <tr>
                    <td colspan="2"><img border="0" height="12" alt="" >
                         <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
       </img>

                    </td>
                </tr>
                <tr>
                    <td><img border="0" width="12" alt="" >
                           <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
       </img>

                        </td>
                    <td class="commonLabel">
                        <input type="checkbox" name="deletePortletsOnPage" value="true" id="deleteContainedElements"/> 
                        <label for="deleteContainedElements"><xsl:value-of select="$portletRemovePagePortlets"/> </label>
                    </td>
                </tr>
                <tr>
                    <td colspan="2"><img border="0" height="6" alt="" >
                         <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                         </img>
                     </td>
                </tr>

                <tr>
                    <td><img border="0" width="12" alt="" >
                        <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
       </img>
                    </td>
                    <td>
                    <div id="listOfElementsDiv" class="listOfItemsDiv">

                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
<!--
                        <tr>
                            <td><img border="0" height="6" alt="" >
                                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
       </img>

                            </td>
                        </tr>
-->
<!--
                        <tr>
                            <td><img border="0" height="6" alt="" >
                                <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute>
                               </img>
                            </td>
                        </tr>
-->
                        <xsl:for-each select="/Mod_Request/Multiple_Requests/GetMetadataObjects[2]/Objects/PSPortalPage/LayoutComponents/PSColumnLayoutComponent/Portlets/PSPortlet">


                             <!-- Only want to include in the list the portlets that we have write access to.  Thus, we have to look up 
                                  the parent tree in the list of writeable trees to determine applicability
                             -->

                             <xsl:variable name="portletPermissionsTree" select="Trees/Tree"/>
                             <xsl:variable name="portletPermissionsTreeId" select="$portletPermissionsTree/@Id"/>

                             <xsl:variable name="portletPermissionsTreeKey" select="key('treeKey',$portletPermissionsTreeId,$treeLookup)/@Name"/>

                             <xsl:variable name="portletIsWriteable">
                               <xsl:choose>
                                 <xsl:when test="$portletPermissionsTreeKey">1</xsl:when>
                                 <xsl:otherwise>0</xsl:otherwise>
                               </xsl:choose>
                             </xsl:variable>

                             <xsl:if test="$portletIsWriteable='1'">

                             <tr>
                                 
                                 <td valign="center" nowrap="nowrap">

                                 <table border="0" cellpadding="0" cellspacing="0"
                                     width="100%">
                                     <tr>
                                         <td><img border="0" width="2" alt="" >
                                              <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute></img>

                                         </td>
                                         <td><img border="0" width="10" alt="" >
                                              <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/1x1.gif</xsl:attribute></img>

                                         </td>
                                         

                                         <td class="commonLabel" valign="center" nowrap="nowrap">
                                                <img border="0" width="16" height="16" alt='Portlet' >
                                                        <xsl:attribute name="src">/<xsl:value-of select="$sasthemeContextRoot"/>/themes/<xsl:value-of select="$sastheme"/>/images/Portlet.gif</xsl:attribute>
                                                </img>

                                         </td>
                                         <td>&#160;</td>
                                         <td class="commonLabel" nowrap="nowrap"><xsl:value-of select="@Name"/>
                                         </td>
                                         <td width="100%">&#160;</td>
                                     </tr>
                                 </table>
                                 
                                 </td>
                             </tr>
                             </xsl:if>

                          </xsl:for-each>

                    </table>

                    </div>
                    </td>
                </tr>
            </table>

            </div>
            </td>
            <td><img border="0" width="12" alt="" >
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

</xsl:template>

<xsl:template name="thisPageScripts">
<script>
  
    /*
     *  Any script content specific to this page.
     */

  function toggleDeleteContainedElementsDiv() {

    var elementDiv = document.getElementById('containedElementsDiv');

    var visibility=elementDiv.style.visibility;
    
console.log('toggleDeleteContainedElementsDiv: visibility'+visibility);

    if (visibility=="hidden") {

       elementDiv.style.visibility="visible";
console.log('toggleDeleteContainedElementsDiv: set visible');
       elementDiv.style.display="block";
       }
    else {
       elementDiv.style.visibility="hidden";
console.log('toggleDeleteContainedElementsDiv: set hidden');
       elementDiv.style.display="none";
       }
    }

</script>

</xsl:template>



</xsl:stylesheet>

