/*
%global path objectFilter;
%let path=/;
%let objectFilter=StoredProcess,Report,InformationMap;
*/

%macro spa_browser(showDescription=0);

%let folderPath=%bquote(&path);
%let mObjectFilter=%bquote(&objectFilter);
%let uObjectFilter=%str(&)objectFilter=%sysfunc(urlencode(&mObjectFilter));
%let type=Transformation;
%let homeURL=/SASStoredProcess/do?_program=&applocencoded.services%2FspaNavigatorPortlet;

%macro filterList(inVal=, outVar=);
    %let value = %str(%bquote(&inVal));
    %global &outVar.;
    %let filterout=%str(*[);

    %do mvI=1 %to %sysfunc(countw(&value, %str(,)));
        %let next_value = %scan(&value, &mvI, %str(,));

        %let filterout=&filterout @TransformRole contains %str(%')&next_value.%str(%') ;
        %if &mvI < %sysfunc(countw(&value, %str(,))) %then %do;
            %let filterout=&filterout or;
        %end;
    %end;
    %let filterout=&filterout %str(]);
    data _null_;
        call symputx("&outVar.","&filterout.");
    run;
%mend;
%filterList(inVal=&mObjectFilter., outVar=filter);
%put NOTE: &filter;

data metaout (keep=name folder dateCreated role description );
  length uri $256 name $60 role $32 path $256 name2 $256 folder $256 dateCreated $80 description $512  ;
  nobj=1; 
  n=1; 
  do while(nobj >= 0);
    nobj=metadata_getnobj("omsobj:&type.?&filter.",n,uri);
    folder='';
    description='';
    arc=metadata_getattr(uri,"Name",name);
    arc=metadata_getattr(uri,"TransformRole",role);
    arc=metadata_getattr(uri,"MetadataCreated",dateCreated);
    arc=metadata_getattr(uri,"Desc",description);
    rc =metadata_getnasn(uri,"Trees",1,path);
    do while (rc>0);
      rc=metadata_getattr(path,"Name",name2);
      folder = "/" || trim(name2) || folder;
      rc=metadata_getnasn(path,"ParentTree",1,path);
    end;
    output;
    n=n+1;
  end;
run;

proc sort data=metaout out=folders nodupkey;
    by folder;
run;
data foldersout (drop=folder w i rename=(rootfolder=folder));
    set folders;
    length role $32 dateCreated $80 description $512 ;
    description='';
    dateCreated='';
    role ='Folder';
	
    do i=1 to countc(folder,'/');
		name = scan(folder,i,'/');
		w=findw(folder,scan(folder,i,'/'));
		if i=1 then do;
			rootfolder = substr(folder,1,w-1);
		end;
		else do;
			rootfolder = substr(folder,1,w-2);
		end;
		output;
	end;
run;

proc sort data=foldersout nodupkey;
    by folder name;
run;

data metaout2;
    set foldersout metaout ;
    if name = '' then delete;
run;

data _null_;
    set metaout2 nobs=nobs;
    file _webout;
        if _n_=1 then do;
            put "<html><head><meta http-equiv='Content-type' content='text/html'><style>
<!--
{
  background-color: #FAFBFE;
  color: #000000;
  font-family: Arial, 'Albany AMT', Helvetica, Helv;
  font-size: x-small;
  font-style: normal;
  font-weight: normal;
  margin-left: 8px;
  margin-right: 8px;
}
A {
    color: #275e94;
    text-decoration: none;
}
.table
{
  border-bottom-width: 0px;
  border-collapse: collapse;
  border-color: #C1C1C1;
  border-left-width: 1px;
  border-right-width: 0px;
  border-spacing: 0px;
  border-style: solid;
  border-top-width: 1px;
}

.l {text-align: left }
.c {text-align: center }
.r {text-align: right }
.d {text-align: right }
.j {text-align: justify }
.t {vertical-align: top }
.m {vertical-align: middle }
.b {vertical-align: bottom }
TD, TH {
    vertical-align: top
    border-bottom: #cecfd2 1px solid;
    border-left: none;
    border-right: #cecfd2 1px solid;
    border-top: none;
    color: #000000;
    font-size: small;
    font-family: 'trebuchet ms', arial, 'arial unicode ms', sans-serif;
}
td.none {border: 0}
.dropbtn {
  background-color: white;
  padding: 2px 4px;
}

.dropdown {
  position: relative;
  display: inline-block;
}

.dropdown-content {
  display: none;
  position: absolute;
  background-color: #ffffff;
  padding: 2px 4px;
  min-width: 200px;
  box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
  z-index: 5;
}

.dropdown-content a {
  color: black;
  background-color: #ffffff;
  padding: 4px 4px;
  display: block;
  min-width: 300px;
  text-decoration: none;
}

.dropdown-content a:hover {background-color: #f1f1f1;}

.dropdown:hover .dropdown-content {display: block;}

.dropdown:hover .dropbtn {background-color: #999999;}
-->
</style></head><body class='body'>
";

%let folderName=%scan(&folderPath., -1, '/');
%let folderNameImage=Folder.gif;
%if ("&folderName." eq "") %then %do;
    %let folderName=SAS Folders;
    %let folderNameImage=SASFolders.gif;
%end;
%let upOneLevel=%substr(&folderPath.,1,(%length(&folderPath.)-%length(%scan(&folderPath.,-1,'/')))-1);
%if ("&upOneLevel." eq "") %then %do;
    %let upOneLevel=/;
%end;

put "<table border='0' cellspacing='0'>
<tr class='tableColumnHeaderRow'>
<td class=none nowrap='nowrap'>
Location: <div class='dropdown'>
  <button class='dropbtn'><img src=/SASTheme_default/themes/default/images/&folderNameImage. border='0'> &folderName.</button>
  <div class='dropdown-content' nowrap='nowrap' nowrap>
  "; 
    url = symget('folderPath');
      space = '&nbsp;';
      
    if (trim(url) ne "/") then do;
      
    put "<a href=&homeURL.&uObjectFilter.%str(&)_action=execute%str(&)path=/>";
    put "<img src='/SASTheme_default/themes/default/images/SASFolders.gif' border='0'>  SAS Folders</a>";
      
        do i = 1 to countw(url,'/');
            lName = scan(url,i,'/');
            lUrl = urlencode(substr(url,1,findw(url,scan(url,i,'/'),'/',0)+length(lName)-1));
            put "<a href=&homeURL.&uObjectFilter.%str(&)_action=execute%str(&)path="lUrl">";
            do k = 1 to i ;
                space=cats(%str(space));
                put space;
            end;
            l = cats(space, ' <img src="/SASTheme_default/themes/default/images/Folder.gif" border="0">&nbsp;', lName,'</a>');
            put l;
        end;
    end;
put "
   </div>
</div>
</td>";
put '<td class=none>&nbsp;&nbsp;&nbsp;</td>';
put "<td nowrap='nowrap' class=none>";
if (symget('folderPath') ne '/') then do;
  put "<a href='&homeURL.&uObjectFilter.%str(&)_action=execute%str(&)path=&upOneLevel.'><img src='/SASTheme_default/themes/default/images/up_one_level.gif' alt='Up one level' title='Up one level' border='0'> <span title='Up one level'>Up one level</span></a>";
end;
else do;
  put "<img src='/SASTheme_default/themes/default/images/up_one_level_inactive.gif' alt='Up one level' title='Up one level' border='0'> <span title='Up one level'>Up one level</span>";
end;
put "</td>";
put "</tr>
</table> 
";


put '
<table class="table" width="100%" border="1" cellspacing="0">
<thead>
<tr class="tableColumnHeaderRow">
<th class=l><span class=portletTableHeader>Name</span></span></th>
<th class=l><span class=l>Type</span></span></th>
<th class=l><span>Date Created</span></span></th>
</tr>';
    end;

if ((folder eq symget('folderPath')) and (role eq "Folder")) then do;
        
            if (folder = '/') then do;
                folder='';
            end;
            lUrl=urlencode(cats(folder,'/',name));
            lUrl=catt(folder,'/',name);
            of=symget('mObjectFilter');
            homeU=symget('homeURL');
            url=cats(homeU,'&_action=execute&path=',lUrl);
            put '<tr><td><span><img style="vertical-align:baseline;" border="0" src="/SASTheme_default/themes/default/images/Folder.gif" width="16" height="16" alt="Open Folder" title="Open Folder">';
            put '<a href="' url '" >';
            put name;
            put '</a>';
            if &showDescription=1 then do;
                put '<br/><small>' description '</small>';
            end;
            put '</span></td><td><span>';
            put role;
            put '</span></td><td><span>';
            put dateCreated;
            put '</span></td></tr>';
        
end;
if (folder eq symget('folderPath') and role ne "Folder") then do;
        if role="Report" then do;
            url=cats('/SASWebReportStudio/openRVUrl.do?rsRID=SBIP://METASERVER',folder,'/',name,'(Report)');
            
            put '<tr><td><span><img style="vertical-align:baseline;" border="0" src="/SASTheme_default/themes/default/images/Report.gif" width="16" height="16" alt="SAS report" title="SAS report">';
            put '<a href="' url '" target=_blank>';
            put name;
            put '</a>';
            if &showDescription=1 then do;
                put '<br/><small>' description '</small>';
            end;
            put '</span></td><td><span>';
            put role;
            put '</span></td><td><span>';
            put dateCreated;
            put '</span></td></tr>';
        end;
        if role="StoredProcess" then do;
            url=cats('/SASStoredProcess/do?_action=execute&_program=',folder,'/',name);
            
            put '<tr><td><span><img style="vertical-align:baseline;" border="0" src="/SASTheme_default/themes/default/images/StoredProcess.gif" width="16" height="16" alt="SAS StoredProcess" title="SAS StoredProcess">';
            put '<a href="' url '" target=_blank>';
            put name;
            put '</a>';
            put '</span></td><td><span>';
            put role ;
            put '</span></td><td><span>';
            put dateCreated;
            put '</span></td></tr>';
        end;
        
    end;
    else do;
        put ;
    end;
    
    if _n_=nobs then do;
        put '</table></body></html>';
    end;
run;

%mend;

%inc "&sasDir./request_setup.sas";

%spa_browser();
