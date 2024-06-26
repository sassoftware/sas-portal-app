# Implementation Notes

This page is intended to capture any thoughts about the implementation, what the options are/were and what the thought process was behind the implementation choices made.  Some of this is just a place to capture the concepts so they don't get lost or forgotten.

## Overall design

The overall design is:

- a simple front end html page with css and some java script
- a set of backend SAS Stored Processes that provide the functionality

This design was chosen for the following reasons:

- stay away from any java code on the backend server to reduce any issues with security vulnerabilities
- SAS stored processes already access the underlying metadata server as the connecting client without any additional coding needed
- html and some simple java script to decrease the resource requirements on the client machine
- Well known interfaces to metadata (proc metadata) and html generation (xsl) in the SAS language
- Well known processes for scaling SAS Stored Processes to meet demand

## What runs where?

It was decided to have very little content in the html page initially deployed to the web server.  This was done for the following reasons:

- the content will need to be customized that is returned to the user (ex. localization, stored process location, server location, SAS Theme to use, etc.).   This is far easier on the Server side.
- simplify updates: when making updates the goal would be that only the SAS code and accompanying files would need to be updated, while the web server content should stay the same (for at most changes).

## How does the generation work?

There is/was a question about how much should be generated at a single call to the SAS Stored Process.  For example:

1. the entire Portal content, with all portlet pages and their content
2. The portal tabs with the portlet page content being generated when the tab is selected
3. The entire Portal content, with the content of the portlet pages being generated, but delay any portlet calls to other resources delayed until the tab was selected.

For example, say that there are 4 pages (tabs) on the portal display.  Each tab has a series of portlets defined to them.  Some of those, like the SAS Stored Process Portlet or URL display portlet, also have URLs that are processed and the results displayed within that portlet.

Eventually, ##3 was selected as the current implementation.  This was chosen for the following reasons:

- from initial testing, each call to a stored process takes at a minimum 100ms (regardless of content returned).  Thus, multiple calls to get the portal content will increase the response times.
- It is expected that there will not be many tabs (ex. less than 10) on a portal display, and within each of them, there will not be many portlets (ex. less than 10).  It is also expected that for portlets that contain lists (ex. Collection portlet), the list will not be excessive (less than 50 items in the list).   Through experimentation, it was noticed that the metadata calls to retrieve this level of information and render it as html was less than 100ms.  Not that decreasing the size of the metadata request or the html generation that was performed, did not significantly decrease the time.
- it was noticed that when rending SAS Stored Process porlet results or URL display portlet results, they significantly increased the amount of wait time for the initial page to display (even if those portlets were not on the initial tab).

Thus it seemed most efficient to:

- on initial page reference, generate the tab list and the list of portlet content for all tabs
- delay the rendering of SAS Stored Process or URL Display portlet content till the owning tab was selected.

## Metadata Layout

Most of the effort in the generation process is interacting with the metadata in the SAS Metadata Server and thus understanding the metadata model and how information is stored is critically important.  There are diagrams included in the Powerpoint [here](implementationDiagrams.pptx).

## XSL Usage

XSL (Extensible Stylesheet Language) is used extensively in this implementation.  The 2 main usages are:

1. Generating HTML from a metadata xml response
2. Generating Metadata Requests (xml output)

This is done by creating an xsl stylesheet (a file ending in xslt) and applying that stylesheet to an input XML file via PROC XSL.  Unfortunately, error handling in PRC XSL is not straightforward:

- if an xsl stylesheet syntax error occurs, proc xsl returns no indication and doesn't create an output file
- if the stylesheet determines that some piece of information it needs is not set, there is no way to pass back a return code 
- the proc does not set a return code based on the success or failure of running the stylesheet.

Thus, this usage has to adopt the following conventions:

- if the output xml from proc xsl does not exist after proc execution, assume that a syntax error has occurred.
- If not a syntax error, always generate an output xml file:
  - If the stylesheet processing determines a piece of needed information is missing, generate an XML comment starting with ERROR: in the output xml (other xml may also exist in the output file)
  - If the stylesheet determines there is nothing to do, generate the xml file with just a comment indicating this fact
  - Otherwise, the generated xml is assumed to be complete and correct.

The existence of the output xml will be verified and that it contains no ERROR: lines in it.  If the file exists and no ERRORS, return a 0 return code.

There is a macro, checkXSLrc, that is used to do this validation and should be called after any proc xsl call.  

Unfortunately, this does add some overhead (ie. the parsing of the resulting xml file), but in most cases the xml or html is not that large that overhead should be substantial.   If such a case arises where the performance overhead is too much, then either:

- don't call the checkXSLrc macro and assume it will always work
- the xsl should use the <xsl:message terminate="yes"> option to not generate any output (and thus will be quicker to check the result)

For the case where the stylesheet determines that no further processing should be done, and an output file with only in a comment in it is generated, the caller of proc xsl will need to manually perform more checks to see if this is the case, ie. checkxslrc just returns a zero return code, it is up to the coder to determine if the output file indicates there is additional valid content in the output file.

Note that when an XSL error occurs, proc xsl does not return the error messages from the xsl processor.   However, these messages can be found.  On my test systems, the default location is /tmp/sasjava.xxxxx.log, where xxxxx is some generated value.  This file will contain the error messages from the embedded java xsl processor and is critical to diagnose xsl errors.

## Content localization

The text fields that are rendered in the html need to be in the locale of the client end user.  Thus, during the html generation, the correct values, in the correct locale, need to be included.

Note that it is expected that the vast majority of generated html will not contain strings that need to be localized, since most of what is being displayed has been entered by the user in metadata and will already be in the correct language.  Only "fixed strings" (like pulldown menu options, labels on entry fields, etc.) will need to be translated.

This will be done in the backend SAS code.  Depending on what is being generated will determine the means by which the generation gets the correct values:

- if it's the main index page generation, then text subsitution will need to be run over any static files
- have the xsl generate the content initially with the localizated content.

The first option, text substitution could cover both scenarios.  However, text substitution in this case is expensive because the amount of text to not translate far outweighs the text that will be translated, thus searching for text substition strings will process a lot of text that will never be translated.  However, in the case of a stylesheet, the value will be inserted exactly where it needs to be with no searching.

After experimentation, all situations have been converted to using xslt to avoid searching and replacing.

There are currently 3 thoughts on how to manage the content that needs to be localized.

- Use of sasmsgl function which is specifically designed to handle localized strings.  The localized strings are kept in a data set and indexed by a key and a locale setting.  The benefit of this approach is that it is smart enough to use the English translation if no translation is found for that particular key or locale.   The potential downside is the amount of time it will take to look up multiple values (the impact of this is still to be measured).
- Use of macro variables, loaded from a file that is locale specific.  Other than loading the file containing the macro variable definitions for that language, this should have little performance impact.   To provide the "default to English" capability of localization, we would load the English locale version first, followed by the correct one for this localization (and thus overriding the English versions for keys that exist in both).
- Use of xml files that had the localized content in them, 1 file per locale.

After experimentation, it was decided to implement the xml file approach.  This has the following advantages:
- Eliminates the concern was the amount of time it would take to look up each value in the sasmsgl approach.
- Allows the xsl file to read the xml files directly, thus eliminating the need to pass all of the needed localized values from the sas code to the style sheet.
- If there is a need to get localized content within the SAS code, the same set of files can be accessed to get the content (with SAS Macros being provided to do so).

If we need to change this approach, the good news is that it is all handled in the SAS code (and accompanying xslt style sheets) on the backend.

## Modifying Portal Content

There has been a request to allow the user to modify Portal content such as Add, Edit and Remove Pages.

In the SAS Information Delivery portal, this is done using the Customize menu. The menu selections on the Customize menu change based on what tab is selected and what the users permissions are.

### Who can modify what?

#### Rules

- An Admin User is defined as user that has has write permissions to the identity group and explicit write permissions to the Group Permission tree
- A User can be Admin User on multiple Groups
- An admin user on 1 group, can be a standard user on others
- A user’s ability to modify a page is dependent on their role as it relates to the selected page:

<table style="border: 1px solid black;border-collapse: collapse;">
  <tr style="border: 1px solid black;">
    <th rowspan="2" style="border: 1px solid black;">Page Type</th>
    <th colspan="3" style="border: 1px solid black;">Standard User</th>
    <th colspan="3" style="border: 1px solid black;">Content Admin User<sup>1</sup></th>
  <tr>
  <tr>
    <td style="border: 1px solid black;"></td>
    <td style="border: 1px solid black;">Add</td>
    <td style="border: 1px solid black;">Edit</td>
    <td style="border: 1px solid black;">Remove</td>
    <td style="border: 1px solid black;">Add</td>
    <td style="border: 1px solid black;">Edit</td>
    <td style="border: 1px solid black;">Remove</td>
  </tr>
    <tr>
      <td style="border: 1px solid black;">Home Page</td>
      <td style="border: 1px solid black;">No</td>
      <td style="border: 1px solid black;">Yes</td>
      <td style="border: 1px solid black;">No</td>
      <td style="border: 1px solid black;">No</td>
      <td style="border: 1px solid black;">Yes</td>
      <td style="border: 1px solid black;">No</td>
  </tr>
      <tr>
        <td style="border: 1px solid black;">User Page</td>
        <td style="border: 1px solid black;">Yes</td>
        <td style="border: 1px solid black;">Yes</td>
        <td style="border: 1px solid black;">Yes</td>
        <td style="border: 1px solid black;">Yes</td>
        <td style="border: 1px solid black;">Yes</td>
        <td style="border: 1px solid black;">Yes</td>
    </tr>
      <tr>
        <td style="border: 1px solid black;">Shared Default Page</td>
        <td style="border: 1px solid black;">No</td>
        <td style="border: 1px solid black;">No</td>
        <td style="border: 1px solid black;">Yes</td>
        <td style="border: 1px solid black;">Yes</td>
        <td style="border: 1px solid black;">Yes</td>
        <td style="border: 1px solid black;">Yes</td>
    </tr>
          <tr>
	        <td style="border: 1px solid black;">Shared Available Page</td>
	        <td style="border: 1px solid black;">Yes<sup>2</sup></td>
	        <td style="border: 1px solid black;">No</td>
	        <td style="border: 1px solid black;">Yes</td>
	        <td style="border: 1px solid black;">Yes</td>
	        <td style="border: 1px solid black;">Yes</td>
	        <td style="border: 1px solid black;">Yes</td>
    </tr>
              <tr>
		        <td style="border: 1px solid black;">Shared Persistent Page</td>
		        <td style="border: 1px solid black;">No</td>
		        <td style="border: 1px solid black;">No</td>
		        <td style="border: 1px solid black;">No</td>
		        <td style="border: 1px solid black;">Yes</td>
		        <td style="border: 1px solid black;">Yes</td>
		        <td style="border: 1px solid black;">Yes</td>
    </tr>
</table>

Legend:

<sup>1</sup> These abilities apply to pages in groups that this person is an admin of.  For pages in a group where the user is not an admin user, their capabilities follow the Standard User capabilities.

<sup>2</sup> A standard user can select to Add a page to their view that the content administrator has made available to them as an "Available" type of shared page, but can not create a new Shared Available Page to share with others.

## General Editing Portlet Content Architecture

The ability to add/edit/remove content is a key part of the functionality that is provided.  This functionality is provided by a consistent framework.  There are 3 services that generate html pages to the user:

- addItem - This is the entry point for generating property pages used for creating portal/portlet content.
- editItem - This is the entry point for generating property pages used for editing portal/portlet content.
- removeItem - This is the entry point used to generate the delete confirmation page (if any) for removing portal/portlet content.

These services when called return html.

There are 3 services that generate and execute metadata requests, either by being called by the html generation services, or, eventually, being called directly as a service.

- createItem - This is the entry point used to save any changes made from the property pages created by addItem.
- updateItem - This is the entry point used to save any changes made from the property pages created by editItem.
- deleteItem - This is the entry point used to actually delete the item from metadata or to remove an existing relationship to an item.

These services when called will return text, ie. the response information of the service call.

Each html generator includes on each html page generated a "formResponse" hidden field, and an event handler for that field. When a "execute" service is called, the output is directed to this hidden field.  When the service returns text, the event handler executes to look at what is in the formResponse field.  From here it can do things like issue a message to the user, change the contents of teh screen, etc.

### Plugin Framework

In the Stored Process implementation, there are "plugin" points where the details of the specific type of content being added/edited/removed.   If this specific type of content is not available to be modified in the requested fashion, a "not supported" message will be returned to the user.

The plugin points are:

1. a "getter" xsl transform that generates a metadata rquest that retrieves information that might be needed  for the rest of this service's processing. All "getter"s reside in the sas/SASEnvironment/Files/portlet directory.
2. a "parameter handler" snippet of SAS code that is responsible for looking for the macro variables that correspond to the parameters for this service and adding them to the an xml stream for later "generator" processing.  All "parameter handlers" reside in the sas/SASEnvironment/SASCode/Steps/portlet directory.
3. a "generator" xsl transform that generates a metadata request to be executed or an html page to be returned to the end user. All "generator"s reside in the sas/SASEnvironment/Files/portlet directory.

The names of each of these (and whether they are optional or not) are summarized in this table.

| Service | Getter | Parameter Handler | Generator |
| ------ | ------ | ------ | ------ | 
| addItem | add.<type>.get.xslt (optional) | N/A | add.<type>.xslt |
| createItem | create.<type>.get.xslt | create.<type>.parameters.sas | create.<type>.xslt |
| editItem | edit.<type>.get.xslt (optional) | N/A | edit.<type>.xslt |
| updateItem | update.<type>.get.xslt | update.<type>.parameters.sas | update.<type>.xslt |
| removeItem | remove.<type>.get.xslt (optional) | N/A | remove.<type>.xslt |
| deleteItem | delete.<type>.get.xslt | delete.<type>.parameters.sas | delete.<type>.xslt |

Many times the same content can be used for multiple entries but each file must be named as above or that type will not be supported by that service.  To ease this restriction, one can use xsl:include in xslt files or %include in the sas files to not have to duplicate content.

## New Users

In the existing SAS ID Portal, when a new user logs in, the necessary portal content for that user is created automatically, including any content that has been shared by a content administrator.

Several options were researched on how to handle this:

- batch load the user content 
- initiliaze the user content on logon

The batch load process has several drawbacks, including having to decide during that process which users should be initiatlized (or do all which would create considerably more metadata than will probably ever be used) and introducing error situations if a user tries to log in when they have not yet been initialized.

Thus, the implementation allows for the user content to be initialized at user logon.  While it's being developed, this capability is controlled by setting a macro variable,INITNEWUSER, to 1.  Eventually, this will be the default value.  It can be set in any of the 3 customization points described above.

## Synchronizing Shared Content with Users

In the existing SAS ID Portal, when an existing user logs in, there is a check to see if any new shared content has been created that this user should have access to.

The same thought process and options exist here as was described under New Users.  The same conclusion was reached, ie. it is best to do the check at User logon.

While it's being developed, this capability is controlled by setting a macro variable,SYNCUSER, to 1.  Eventually, this will be the default value.  It can be set in any of the 3 customization points described above.

## New Groups

In the existing SAS ID Portal, there is a batch process that can be run to create portal content area for all groups.  This process will need to be replicated as well.

