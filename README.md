# sas-portal-app

SAS Portal App

## Description
The purpose of this project is to provide a partial replacement for SAS Information Delivery Portal, that was deprecated as of SAS 9.4M8.  

It is not intended to be a full replacement, but will focus on those items that are most widely used and does not require java server side rendering of content.

This is very much a work in progress... See the list of issues and current limitations

## Overview

This application has 2 main parts:

- a html and simple java script web page front end
- a set of SAS Stored Processes that will render the SAS Information Delivery Portal content.

This architecture was chosen for the following reasons:

- limited security vulnerability exposure
- existing technology (SAS Stored Process) that is well understood
- SAS Stored Processes already run code as the client end user identity, so security and authorization of portal content is already covered
- simple installation

## Installation

- git clone this repo onto your SAS environment

- As a SAS Administrator, import the packages/sas-portal-app-services.spk file either through SAS Management Console or through the CLI.
  - By default, the package will be installed into /System/Applications/SAS Portal App
  - When importing:
    - Select a SAS Application Server Context to run the stored process
        - NOTE: The stored process server definition that is chosen must have sufficient capacity to support the scale of the number of users that you expect to use the application.
        - It may be desirable to create a new SAS Application Server Context for running this application, this will allow you to control access, scale and configuration separate from other uses.
    - Map the Source Directory to the sas directory in this repo.
- Modify the appserver_autoexec_usermods.sas file of the SAS Application Server context selected on import to add the following line:
<pre>%let portalAppDir=this repo directory;</pre>
where you will replace ''this repo directory'' with the directory that you did the git clone to create.

- Set up your web server

**NOTE:** There is currently an assumption built into the references to SASStoredProcess web application in this application that it can be reached via the same root url (ie. host:port) as this application is deployed to.

  - Deploy Application
  Getting the application on to your web server can be done in multiple ways, depending on your configuration.
    - Copy Files
    This path should be chosen when the git repo directory is on another machine then your web server or your web server has disabled FollowSymLinks.
      - under the htdocs directory of your web server, create a new directory, ex. SASPortalApp
      - copy the contents of the web directory of the git repo into this directory
  <pre>cp -r this repo directory/web/* SASPortalApp</pre>
    - Symlink to git repo web directory
    If you have cloned the repo into a directory accessable to your web server, and it is configured to follow Symlinks, then this option may work for you.
      - cd htdocs
      - ln -s <git repo web directory> SASPortalApp
  - Verify the path to the Portal application and services
    - If you have chosen to import the package into a different location than the default of /System/Applications/SAS Portal App, then you will need to modify the paths used in index.html to reference the Stored Processes.  
      - Modify the sasjs configuration appLoc entry to match where they were installed
      - Modify the /SASStoredProcess references to change the location in the referenced _program parameter

## Usage

In your web browser, go to the URL that matches where you installed the application onto your web server, ex. /SASPortalApp.

If you are not already logged in to your SAS Environment, you should be redirected to a logon prompt and/or your single signon should execute to log you in.

**NOTE:** While most issues need to be discovered by looking at the issues for the repo, [there is currently one that is glaring that is mentioned here.](https://gitlab.sas.com/sascxr/sas-portal-app/-/issues/1)  When first displaying the page, none of the tab content is being intinitially displayed!  In the short term until this issue is resolved, please just manually select a tab.

## Support

Use the Issues section of this repo to check for existing known issues, as well as to report new issues.

## Roadmap

The intent for this application is to provide a level of functionality that was included in SAS Information Delivery Portal.  However, it is never going to be intended to be a full replacement.

Here is the list of functionality included in the SAS Information Delivery Portal.  Any input on what functionality needs to be supported is welcome.  This table will be updated as the plans and functionality requirements solidify.

Tools

| Activity | Support |
| ------ | ------ |
|  Manage Subscriber Profiles      |  no      |
|   Manage Subscriptions     |    no   |
|   Manage Page History      |    no   |

Create New Content

| Content Type | Support |
| ------ | ------ |
|  Application      |  tbd      |
|   Link     |    tbd   |
|   Syndication Channel      |    no   |
|   Portlet                  |    tbd  |
|   Page                     |    tbd  |

Preferences

| Category | Setting | Support |
| ------ | ------ | ------ |
|  General | User Theme      |  tbd      |
|  General | Email Notifications | no    |
|  General | Alert Notifications | no    |
|  Regional | User Locale        | tbd   |
|  Regional | Timezone           | tbd   |
|  Format   | Date Formats (Date/Time) | tbd |
|  Format   | Date Formats (Long Date) | tbd |
|  Format   | Date Formats (Short Date) | tbd |
|  Format   | Date Formats (Time) | tbd |
|  Format   | Currency (Negative Values) | tbd |
|  Format   | Currency (Currency Symbol) | tbd |
|  Portal   | Preferred Navigation | tbd |
|  Portal   | Package Sort Order | no |

Search

| Category | Setting | Support |
| ------ | ------ | ------ |
| By Keyword | | no |
| By Content Type | Application | no |
| By Content Type | File | no |
| By Content Type | Link | no |
| By Content Type | Package | no |
| By Content Type | Page | no |
| By Content Type | PageTemplate | no |
| By Content Type | Portlet | no |
| By Content Type | Publication Channel | no |
| By Content Type | SAS Information Map | no |
| By Content Type | SAS Report | no |
| By Content Type | SAS Stored Process | no |
| By Content Type | Syndication Channel | no |
| Search Results | Results Per Page | no |

Capabilities

| Category | Type | View | Add | Remove | Edit Properties | Edit Content |
| ------ | ------ | ------ | ------ | ------ | ------ | ------ |
| Portal Page | All | yes | tbd | tbd | tbd | na |
| Portlet | Collection | yes | tbd | tbd | tbd | tbd |
| Portlet | Report Portlet | tbd | tbd | tbd | tbd | tbd |
| Portlet | Report Portlet Local | no | no | no | no | no |
| Portlet | SAS BI Dashboard | no | no | no | no | no |
| Portlet | SAS Collections | no | no | no | no | no |
| Portlet | SAS Diagnostics | no | no | no | no | no |
| Portlet | SAS Navigator | tbd | no | no | no | no |
| Portlet | SAS Report | tbd | tbd | no | no | no |
| Portlet | SAS Stored Process | tbd | tbd | no | no | no |
| Portlet | Shared Alerts | no | no | no | no | no |
| Portlet | URL Display Portlet | yes | tbd | no | no | no |
| Portlet | WebDav Content | no | no | no | no | no |
| Portlet | WebDav Graph | no | no | no | no | no |
| Portlet | WebDav Navigator | no | no | no | no | no |






## Contributing

The intent is that this project will be maintained by SAS, but that contributions will be submitted from the community.

