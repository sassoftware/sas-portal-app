<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html"/>

<xsl:template name="commonFormFunctions">

<xsl:variable name="portletEditCollectionHasChangedMessage" select="$localeXml/string[@key='portletEditCollectionHasChangedMessage']/text()"/>

<script>

    function submitDisableAllForms() {
        setTimeout("disableAllForms()", 100);
        return true;
    }

    function disableAllForms() {
        // Loop through each form on this page
        for (var i = 0; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text> document.forms.length; i++) {
            // Loop through each element in the form
            var form = document.forms[i];
            for (var j = 0; j <xsl:text disable-output-escaping="yes">&lt;</xsl:text> form.length; j++) {
                // Disable each element
                var element = form.elements[j];
                element.disabled = true;
            }
        }
    }

    function cancelForm(btn, cancelUrl)
    {

        if (cancelUrl) {
           btn.form.action = cancelUrl;
           }
        else {

           btn.form.action=history.go(-2);
           }
        return true;

    }

    function displayChangedMessage(hasChangedMessage)
    {
       retval = true;
       if (hasChanged)
          var retval = confirm(hasChangedMessage);

       if (retval)
          hasChanged = false;

       return retval;
    }

</script>

</xsl:template>

</xsl:stylesheet>

