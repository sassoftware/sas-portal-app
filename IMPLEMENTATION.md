# Implementation Notes

This page is intended to capture any thoughts about the implementation, what the options are/were and what the thought process was behind the implementation choices made.  Some of this is just a place to capture the concepts so they don't get lost or forgotten.

# Overall design

The overall design is:

- a simple front end html page with css and some java script
- a set of backend SAS Stored Processes that provide the functionality

This design was chosen for the following reasons:

- stay away from any java code on the backend server to reduce any issues with security vulnerabilities
- SAS stored processes already access the underlying metadata server as the connecting client without any additional coding needed
- html and some simple java script to decrease the resource requirements on the client machine
- Well known interfaces to metadata (proc metadata) and html generation (xsl) in the SAS language
- Well known processes for scaling SAS Stored Processes to meet demand

# What runs where?

It was decided to have very little content in the html page initially deployed to the web server.  This was done for the following reasons:

- the content will need to be customized that is returned to the user (ex. localization, stored process location, server location, SAS Theme to use, etc.).   This is far easier on the Server side.
- simplify updates: when making updates the goal would be that only the SAS code and accompanying files would need to be updated, while the web server content should stay the same (for at most changes).

# How does the generation work?

There is/was a question about how much should be generated at a single call to the SAS Stored Process.  For example:

1. the entire Portal content, with all portlet pages and their content
2. The portal tabs with the portlet page content being generated when the tab is selected
3. The entire Portal content, with the content of the portlet pages being generated, but delay any portlet calls to other resources delayed until the tab was selected.

For example, say that there are 4 pages (tabs) on the portal display.  Each tab has a series of portlets defined to them.  Some of those, like the SAS Stored Process Portlet or URL display portlet, also have URLs that are processed and the results displayed within that portlet.

Eventually, #3 was selected as the current implementation.  This was chosen for the following reasons:

- from initial testing, each call to a stored process takes at a minimum 100ms (regardless of content returned).  Thus, multiple calls to get the portal content will increase the response times.
- It is expected that there will not be many tabs (ex. less than 10) on a portal display, and within each of them, there will not be many portlets (ex. less than 10).  It is also expected that for portlets that contain lists (ex. Collection portlet), the list will not be excessive (less than 50 items in the list).   Through experimentation, it was noticed that the metadata calls to retrieve this level of information and render it as html was less than 100ms.  Not that decreasing the size of the metadata request or the html generation that was performed, did not significantly decrease the time.
- it was noticed that when rending SAS Stored Process porlet results or URL display portlet results, they significantly increased the amount of wait time for the initial page to display (even if those portlets were not on the initial tab).

Thus it seemed most efficient to:

- on initial page reference, generate the tab list and the list of portlet content for all tabs
- delay the rendering of SAS Stored Process or URL Display portlet content till the owning tab was selected.


