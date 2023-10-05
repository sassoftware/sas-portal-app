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
- if its content generated by xsl, then the values to use will be passed as parameters to the stylesheet during xsl processing

The first option, text substitution could cover both scenarios.  However, text substitution in this case is expensive because the amount of text to not translate far outweighs the text that will be translated, thus searching for text substition strings will process a lot of text that will never be translated.  However, in the case of a stylesheet, the value will be inserted exactly where it needs to be with no searching.

After experimentation, all situations have been converted to using xslt parameter substitution to avoid searching and replacing.

There are currently 2 thoughts on how to manage the content that needs to be localized.

- Use of sasmsgl function which is specifically designed to handle localized strings.  The localized strings are kept in a data set and indexed by a key and a locale setting.  The benefit of this approach is that it is smart enough to use the English translation if no translation is found for that particular key or locale.   The potential downside is the amount of time it will take to look up multiple values (the impact of this is still to be measured).
- Use of macro variables, loaded from a file that is locale specific.  Other than loading the file containing the macro variable definitions for that language, this should have little performance impact.   To provide the "default to English" capability of localization, we would load the English locale version first, followed by the correct one for this localization (and thus overriding the English versions for keys that exist in both).

After experimentation, it was decided to implement the macro variable approach.  The concern was the amount of time it would take to look up each value in the sasmsgl approach.

If we need to change this approach, the good news is that it is all handled in the SAS code (and accompanying xslt style sheets) on the backend.

## Editing Portal Layout

There has been a request to allow the user to edit the layout of their portal pages.  Will have to research how much work this will be.

## Editing Portlet Content

There has been a request to allow the user to edit content.  This will require "property" pages for each type of portlet.

The approach will be to have a property sheet per portlet type (generated according to the rules listed above in the Generation section) and then a "save" stored process which will take the content of the form and apply it.

There are some easy ones, like the Display URL portlet, that only takes limited properties.   There are others that take lists which will be more difficult, but should be do-able.  There are some, like SAS Stored Process and Report, portlets that allow for navigation of the SAS Folder tree to select a stored process or report.  This will be more difficult and the first pass will simply just allow the user to enter the path to the report or stored process as a text string.

The editing has to handle 2 cases:

1. The case where all the properties already exist on the portlet definition
2. The case where some/all of the properties have not already been defined.

Number 2 is more difficult as it will require creating content from scratch.

## New Users

It looks to me like when a New User first enters the existing SAS ID Portal, a copy of a portal template is made for that user.  This has to be researched and some form of implementation done.   Note that because the entire page is being generated now on entry to the URL, we can do this population at that point of no information exists for that user.


