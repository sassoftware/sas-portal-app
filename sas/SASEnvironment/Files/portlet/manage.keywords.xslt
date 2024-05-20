<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template name="ManageKeywords">

<!--  This template is intended to manage the list of keywords associated with an object 

      Parameters:

          oldKeywords = a blank separated list of the existing keywords on an object.  If passed as blank, no existing
                        keywords exist.
          newKeywords = a blank separated list of the new new keywords for an object.  If passed as blank, it can be 1 of
                        2 situations:
                        - if oldKeywords is also blank, then no keyword processing should take place
                        - if oldKeywords is not blank, then delete all the existing keywords on an object.

          owningObject= a reference to the owning object of the existing Keywords into an existing metadata context.  This is
                        used to find the existing keyword object information.

          owningObjectType = The type of object that the keywords should be associated with.
          owningObjectId = The id of the object that the keywords should be associated with.

          embeddedObject = When creating new objects, you can either generate a unique UpdateMetadata for the keyword updates (default), or just generate the Keyword object as an embeddedObject inside another update (Value=1)

      The parameters seem a bit redundant, but they are set so that multiple situations can be handled by 1 rouinte:

      Creating keywords on new objects:  In this case:
                         oldKeywords = blank
                         newKeywords = not blank
                         owningObject = blank
                         owningObjectType = not blank
                         owningObjectId = not blank (probably a reference to a new object metadata id, like $newObjectId
      
      Creating keywords on existing objects:  In this case:
                         oldKeywords = blank or not blank
                         newKeywords = not blank
                         owningObject = reference into metadata context for existing object
                         owningObjectType = blank
                         owningObjectId = blank 

      Deleting all keywords on existing objects:  In this case:
                         oldKeywords = not blank
                         newKeywords = blank
                         owningObject = reference into metadata context for existing object
                         owningObjectType = blank
                         owningObjectId = blank 

      Since keywords are not shared across objects, if oldKeywords not equal newKeywords, all existing oldKeywords will be
      deleted and newKeywords added, even if they set of keywords overlap.

-->

   <xsl:param name="oldKeywords"/>
   <xsl:param name="newKeywords"/>

   <xsl:param name="owningObject"/>
   <xsl:param name="owningObjectType"/>
   <xsl:param name="owningObjectId"/>

   <xsl:param name="embeddedObject">0</xsl:param>

    <!-- NOTE: If oldKeywords is not blank and newKeywords is blank, all existing keywords will be removed from the object! -->
 
    <xsl:if test="not($newKeywords=$oldKeywords)">

       <!-- If we are going to do any changes to keywords, the owningObject must be passed, check it now -->

       <xsl:choose>

           <xsl:when test="$owningObject or ($owningObjectType and $owningObjectId)">

               <xsl:variable name="useOwningObjectType">
                   <xsl:choose>
                       <xsl:when test="$owningObject">
                           <xsl:value-of select="name($owningObject)"/>
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:value-of select="$owningObjectType"/>
                       </xsl:otherwise>
                   </xsl:choose>
               </xsl:variable>

               <xsl:variable name="useOwningObjectId">
                   <xsl:choose>
                       <xsl:when test="$owningObject">
                           <xsl:value-of select="$owningObject/@Id"/>
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:value-of select="$owningObjectId"/>
                       </xsl:otherwise>
                   </xsl:choose>
               </xsl:variable>

               <xsl:if test="not($oldKeywords='')">

                   <xsl:choose>
                      <xsl:when test="$owningObject">

                          <!-- If for some reason we only generate a DeleteMetadata statement, then the xsl checking on the result
                               will fail because it expects to find some reference to UpdateMetadata.  Generate a comment
                               with that phrase in it so it will pass the test, even in this scenario -->

                          <xsl:comment>Include the phrase UpdateMetadata so the xsl checking thinks it worked</xsl:comment>

                          <DeleteMetadata>

                            <Metadata>

                            <xsl:for-each select="$owningObject/Keywords/Keyword">
                              <Keyword>
                                <xsl:attribute name="Id"><xsl:value-of select="@Id"/></xsl:attribute>
                                <!-- add Name to simplify debugging if needed -->
                                <xsl:attribute name="Name"><xsl:value-of select="@Name"/></xsl:attribute>
                              </Keyword>

                            </xsl:for-each>

                            </Metadata>

                            <NS>SAS</NS>
                            <Flags>268435456</Flags>
                            <Options/>

                          </DeleteMetadata>

                      </xsl:when>

                      <xsl:otherwise>
                          <xsl:comment>ERROR: owningObject not passed to ManageKeywords, unable to remove existing keywords.</xsl:comment>
                      </xsl:otherwise>

                   </xsl:choose>                   

               </xsl:if>

               <!-- Now add the new keywords -->

               <xsl:if test="not($newKeywords='')">

                 <xsl:choose>

                   <xsl:when test="$embeddedObject='0'">

                       <UpdateMetadata>
                         <Metadata>

                          <xsl:call-template name="genKeywordMetadataList">

                              <xsl:with-param name="useOwningObjectId" select="$useOwningObjectId"/>
                              <xsl:with-param name="useOwningObjectType" select="$useOwningObjectType"/>
                              <xsl:with-param name="newKeywords" select="$newKeywords"/>
                              <xsl:with-param name="embeddedObject" select="$embeddedObject"/>

                          </xsl:call-template>

                         </Metadata>

                         <NS>SAS</NS>
                         <Flags>268435456</Flags>
                         <Options/>

                       </UpdateMetadata>

                     </xsl:when>
                     <xsl:otherwise>

                          <xsl:call-template name="genKeywordMetadataList">

                              <xsl:with-param name="useOwningObjectId" select="$useOwningObjectId"/>
                              <xsl:with-param name="useOwningObjectType" select="$useOwningObjectType"/>
                              <xsl:with-param name="newKeywords" select="$newKeywords"/>
                              <xsl:with-param name="embeddedObject" select="$embeddedObject"/>

                          </xsl:call-template>

                     </xsl:otherwise>

                   </xsl:choose>

               </xsl:if>

       </xsl:when>
       <xsl:otherwise>
          <xsl:comment>ERROR: Owning Object information not passed to ManageKeywords!</xsl:comment>
       </xsl:otherwise>

       </xsl:choose>

       
    </xsl:if>

</xsl:template>

<xsl:template name="genKeywordMetadataList">

       <xsl:param name="useOwningObjectId"/>
       <xsl:param name="useOwningObjectType"/>
       <xsl:param name="newKeywords"/>
       <xsl:param name="embeddedObject"/>

       <xsl:variable name="repositoryId" select="substring-before($useOwningObjectId,'.')"/>

       <xsl:variable name="keywords" select="tokenize($newKeywords,' ')"/>

       <!--  We use the for-each-group here with a group by statement to remove duplicates from the input string -->

       <xsl:for-each-group select="$keywords" group-by='.'>

           <xsl:variable name="keywordName" select="."/>
           <!--  Since we have de-duped the list of keywords, using the name will generate a unique id -->
           <xsl:variable name="keywordUniqueId">$<xsl:value-of select="$keywordName"/></xsl:variable>

           <xsl:variable name="keywordId"><xsl:value-of select="$repositoryId"/>.<xsl:value-of select="$keywordUniqueId"/></xsl:variable>
           <Keyword>
              <xsl:attribute name="Id"><xsl:value-of select="$keywordId"/></xsl:attribute>
              <xsl:attribute name="Name"><xsl:value-of select="$keywordName"/></xsl:attribute>

              <xsl:if test="$embeddedObject='0'">

              <Objects>

                 <xsl:element name="{$useOwningObjectType}">

                    <xsl:attribute name="ObjRef"><xsl:value-of select="$useOwningObjectId"/></xsl:attribute>

                 </xsl:element>
              </Objects>

              </xsl:if>

           </Keyword>
       </xsl:for-each-group>

</xsl:template>

</xsl:stylesheet>

