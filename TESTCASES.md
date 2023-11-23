# sas-portal-app testcases

This page tries to collect the set of test cases that have been, or should be, executed against the portal application.  The page is broken down by topic area.

## User/Group Content management

### User

- user content created at initial logon
- user content updated (potentially) at subsequent logons if new shared content exists

- user content deleted when user no longer exists?
  - what should happen to group content created by a group admin and the group admin no longer exists

### Group

- group content area (ie. tree structure) created via batch process (initPortalData.sh ?)
- Content administrator can add content to group content area
  - this content is the "shared" content, see Content Sharing below

## Theme support

- existing themes should be displayed as expected
  - Note: there are certain features of prior theme support that is not supported, see the capabilities chart in the main readme page for this project for a list of those capabilities and/or limitations.

## Localization

- all application content should be localized.  
  - the "metadata" content will only be displayed in the language in which it was created.
 
## Page Rendering


## Content Sharing

All tests will need to be run with different page types

   - sticky (Persistent)
   - default (added but user can delete)
   - available (should not show up in user area!)

- shared content exists at new user initialization
- new shared content after user initialization
- new shared content after user has already added other shared pages
- user is added to a new group that has shared content
   - content should be added, page rank should be honored

- shared content is deleted

## Content Editing

## Customer extensions

### Server side extensions

  - look for SASPortalApp_setup_usermods.sas in server directory (.)
  - look for SASPortalApp/sas/setup_usermods.sas

### Web application side extensions

- look for a usermods css and js in web app directory
