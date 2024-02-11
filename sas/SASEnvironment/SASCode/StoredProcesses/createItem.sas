/*  Save the changes made to an Item Add page */

%inc "&sasDir./request_setup.sas";

/*
 *   The parameters being passed to this routine will be dependent on the
 *   type of item being created.
 *   The only required parameters are:
 *    type = the type of object
 *   The other possible "standard" parameters are:
 *    relatedId = the id of a related Item
 *    relatedType = the type of the related Item
 *   It is possible that a specific type of object could be
 *   added via different relationships to the same related object.
 *   In this case, the relatedRelationship parameter must be set
 *   with the relationship to update.  If this is not set, then it
 *   is up to the create processor for that type to decide what the
 *   default relationship is.
 */

%setupPortalDebug(createItem);
%createItem(rc=createItemRC);

%put createItemRC=&createItemRC.;

%setResponse(&createItemRC.);

%cleanupPortalDebug;

