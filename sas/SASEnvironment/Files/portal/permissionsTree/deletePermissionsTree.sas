/*  Delete the named permissions tree */

/*  Parameters (Macro Variables) 
    treeName= the name of the permissions tree. default= &groupName. Permissions Tree;
    
*/

%inc "&sasDir./request_setup.sas";

%deletePermissionsTree(tree=&treename.);


