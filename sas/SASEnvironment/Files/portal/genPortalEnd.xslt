<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<xsl:param name="sastheme">default</xsl:param>
<xsl:variable name="sasthemeContextRoot">SASTheme_<xsl:value-of select="$sastheme"/></xsl:variable>

<!-- Strings to be localized -->

<xsl:param name="portalTitle">SAS<sup style="font-size: smaller;">®</sup> Portal</xl:param>

<xsl:param name="globalMenuBar_skipMenuBar">Skip Menu Bar</xsl:param>
<xsl:param name="portalCustomizationMenu">Customize</xsl:param>
<xsl:param name="portalCustomizationMenuTitle">Select to display the menu for portal customization</xsl:param>
<xsl:param name="portalOptionsMenu">Options</xsl:param>
<xsl:param name="portalOptionsMenuTitle">Select to display the options menu.</xsl:param>

<xsl:param name="portalSearchMenu">Search</xsl:param>
<xsl:param name="portalSearchMenuTitle">Select to go to the portal search page.</xsl:param>

<xsl:param name="portalLogoffMenu">Logoff</xsl:param>
<xsl:param name="portalLogoffMenuTitle">Log Off</xsl:param>

<xsl:param name="portalHelpMenu">Help</xsl:param>
<xsl:param name="portalHelpMenuTitle">Select to display the help menu.</xsl:param>

<xsl:param name="pageTabs_skipTabMenu">Skip Tab Menu</xsl:param>

<xsl:template match="/">

</div>


                <a name="pageTabs_skipTabMenu"></a>
                <table class="secondaryMenuTable" width="100%" cellspacing="0" cellpadding="0">
                        <tbody><tr>
                                <td class="secondaryMenuRow" align="left" height="5"></td>
                        </tr>
                </tbody></table>

                </div>

    </div>
    </td>
</tr>
</tbody>
</table>
<!-- div id="pages" w3-include-html="/SASStoredProcess/do?_action=form,properties,execute,nobanner,newwindow&_program=${APPLOC}services%2FgetTabContent"></div -->

</xsl:template>

</xsl:stylesheet> 
