# sas-portal-app

SAS Portal App

## Description

The purpose of this project is to provide a partial replacement for SAS Information Delivery Portal, that was deprecated as of SAS 9.4M8.  

Existing Information Delivery Portal

![Existing SAS Information Delivery Portal](screenshots/existing-idp.png)

New SAS Portal App

![New SAS Portal App](screenshots/new-portal-app.png)


It is not intended to be a full replacement, but will focus on:

- rendering pages similar to the layout that was previously supported
- most widely used portlets and capabilities that do not require java server side rendering of content.

This is very much a work in progress... See the [Roadmap](#roadmap) section for more details.

## Overview

This application has 2 main parts:

- a html and simple java script web page front end
- a set of SAS Stored Processes that will render the SAS Information Delivery Portal content.

This architecture was chosen for the following reasons:

- limited security vulnerability exposure
- existing technology (SAS Stored Process) that is well understood
- SAS Stored Processes already run code as the client end user identity, so security and authorization of portal content is already covered
- simple installation

Other goals of this implementation are:

- Enter configuration information in as few places as possible
- Keep the content needing to be deployed to the webserver minimal, so that updates are mostly to the back end Stored Processes

## Installation

- git clone this repo onto your SAS environment

### SAS Stored Processes

- As a SAS Administrator, import the packages/sas-portal-app-services.spk file either through SAS Management Console or through the CLI.
  - By default, the package will be installed into /System/Applications/SAS Portal App
  - When importing:
    - Select a SAS Application Server Context to run the stored process
        - NOTE: The stored process server definition that is chosen must have sufficient capacity to support the scale of the number of users that you expect to use the application.
        - It may be desirable to create a new SAS Application Server Context for running this application, this will allow you to control access, scale and configuration separate from other uses.
    - Map the Source Directory to the sas directory in this repo.
- Modify the appserver_autoexec_usermods.sas file of the SAS Application Server context selected on import to add the following lines:
<pre>%let portalAppDir=this repo directory;</pre>
where you will replace ''this repo directory'' with the directory that you did the git clone to create.
<pre>%let appLoc=the folder where the application package was installed to</pre>
where you will replace ''the folder where the application package was installed to'' with the folder path, ex. /System/Applications/SAS Portal App.  **NOTE:** This path must match the value specified on the web server install for sasjsAppLoc!

- **NOTE:** If your stored process server instances are already running, you will need to restart them to pick up the appserver_autoexec_usermods.sas updates.

### Web Application

**NOTE:** There is currently an assumption built into the references to SASStoredProcess web application in this application that it can be reached via the same root url (ie. host:port) as this application is deployed to.

#### Deploy Application

Getting the application on to your web server can be done by copying files to your web server.

- under the htdocs directory of your web server, create a new directory, ex. SASPortalApp
- copy the contents of the web directory of the git repo into this directory
  <pre>cp -r this repo directory/web/* SASPortalApp</pre>

##### Verify the path to the Portal application and services

- copy the file setup.js.template as setup.js in your directory under htdocs
- verify the information defined in that file
  - sasjsAppLoc = If you have chosen to import the package into a different location than the default of _/System/Applications/SAS Portal App_, then you will need to modify the path in sasjsAppLoc

## Usage

In your web browser, go to the URL that matches where you installed the application onto your web server, ex. /SASPortalApp.

If you are not already logged in to your SAS Environment, you should be redirected to a logon prompt and/or your single signon should execute to log you in.

**NOTE:** Currently only the Collection Portlet has it's contents rendered.  All other portlet types just create a named, empty placeholder in the layout.

## Support

Use the Issues section of this repo to check for existing known issues, as well as to report new issues.

## Roadmap

The intent for this application is to provide a level of functionality that was included in SAS Information Delivery Portal.  However, it is never going to be intended to be a full replacement.

Here is the list of functionality included in the SAS Information Delivery Portal.  Any input on what functionality needs to be supported is welcome.  This table will be updated as the plans and functionality requirements solidify.

### Legend

The following legend is used for each of the tables below.

| Value | Definition |
| ------ | ------ |
|  available | support for this is already available |
|    yes    | this is planning on being supported       |
|  tbd      | this is being considered for support       |
|  no       | no support for this item is currently planned |
|  N/A      | this column is not application to this row |


### Toolbar Support

The existing SAS Information Delivery Portal has the following capabilities in the toolbar. 

#### Tools

| Activity | Support |
| ------ | ------ |
|  Manage Subscriber Profiles      |  no      |
|   Manage Subscriptions     |    no   |
|   Manage Page History      |    no   |

#### Create New Content

| Content Type | Support |
| ------ | ------ |
|  Application      |  tbd      |
|   Link     |    tbd   |
|   Syndication Channel      |    no   |
|   Portlet                  |    tbd  |
|   Page                     |    tbd  |

#### Preferences

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

#### Search

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

### Capabilities

The SAS Information Delivery Portal currently supports these categories of objects and these capabilities on each of these specific object types within that category.

| Category | Type | View | Add | Remove | Edit Properties | Edit Content |
| ------ | ------ | ------ | ------ | ------ | ------ | ------ |
| Portal Page | All | yes | tbd | tbd | tbd | N/A |
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


### Layouts

SAS Information Delivery Portal currently supports these layouts.

| Layout Mode | # of Columns | Width | View | Edit |
| ------ | ------ | ------ | ------ | ------ | 
| By Column       |  1    | 100% | yes | tbd |
| By Column       |  1    | Custom | yes | tbd |
| By Column       |  2    | 100% | yes | tbd |
| By Column       |  2    | Custom | yes | tbd |
| By Column       |  3    | 100% | yes | tbd |
| By Column       |  3    | Custom | yes | tbd |
| By Grid       |  1    | 100% | yes | tbd |
| By Grid       |  1    | Custom | yes | tbd |
| By Grid       |  2    | 100% | yes | tbd |
| By Grid       |  2    | Custom | yes | tbd |
| By Grid       |  3    | 100% | yes | tbd |
| By Grid       |  3    | Custom | yes | tbd |


## Contributing

The intent is that this project will be maintained by SAS, but that contributions will be submitted from the community.

