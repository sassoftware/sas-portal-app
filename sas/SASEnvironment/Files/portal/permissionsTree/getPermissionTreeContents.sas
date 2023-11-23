options metauser="sasadm@saspw" metapass="SASpw1";
filename request temp;

data _null_;
  infile cards4;
  file request;
  input;
  put _infile_;
cards4;
<Multiple_Requests>
<!-- Get an example of a Users Permission tree after initialization -->
<GetMetadataObjects>
                                <ReposId>$METAREPOSITORY</ReposId>
                                <Type>Tree</Type>
                                <ns>SAS</ns>
                                <Flags>404</Flags>
                                <Options>
                     <XMLSelect search="@Name='Group 3 User 1 Permissions Tree'"/>
                     <Templates>
                        <Tree Id="" Name="" TreeType="">
                        
                           <Members/>
                           <SubTrees/>
                           <Extensions/>
                        </Tree>
                        <Group Id="" Name="" Desc="">
                          <Members/>
                          <Properties/>
                        </Group>
                        <PSPortalPage Id="" Name="" Desc="">
                           <Extensions/>
                           <Groups/>
                           <LayoutComponents/>
                           <UsingPrototype/>
                        </PSPortalPage>
                        
                        <PSPortlet Id="" Name="" Desc="" PortletType="">
                        
                          <LayoutComponents/>
                          <PropertySets/>
                          <UsingPrototype/>
                          <Groups/>
                        </PSPortlet>
                        <PSColumnLayoutComponent  Id="" Name="" Desc="" ColumnWidth="" NumberOfPortlets="">
                          <Portlets/>
                        </PSColumnLayoutComponent>
                        
                        <PropertySet Id="" Name="" Desc="" PropertySetName="">
                           <Properties/>
                        </PropertySet>
                        <Property Id="" Name="" Desc="" PropertyName="" PropertyRole="" DefaultValue=""  SQLType="" UseValueOnly="">
                           <OwningType/>
                        </Property>
                        <PropertyType Id="" Name="" Desc="" SQLType=""/>

                        <Extension Id="" Name="" Value="">
                        </Extension>
                        <Prototype Id="" Name="" MetadataType="">
                           <Extensions/>
                           <Groups/>
                           <!-- Should get the Trees here, but that would cause any other trees listed here to be traversed! -->
                           
                        </Prototype>
                     </Templates>
                </Options>
</GetMetadataObjects>
<!-- Get the Page Template information -->
<GetMetadataObjects>
                               <ReposId>$METAREPOSITORY</ReposId>
                                <Type>Tree</Type>
                                <ns>SAS</ns>
                                <Flags>404</Flags>
                                <Options>
                     <XMLSelect search="@Name='PUBLIC Permissions Tree'"/>
                     <Templates>
                        <Tree Id="" Name="" TreeType="">
                        
                           <Members/>
                           <SubTrees/>
                           <Groups/>
                           <Extensions/>
                        </Tree>
                        <Group Id="" Name="" Desc="">
                           <Members/>
                           </Group>
                         <Extension Id="" Name="" Value="">
                        </Extension>
                        <Prototype Id="" Name="" MetadataType="">
                           <Extensions/>
                           <Groups/>
                           <!-- Should get the Trees here, but that would cause any other trees listed here to be traversed! -->
                        </Prototype>
                          
                     </Templates>
                </Options>
</GetMetadataObjects>

</Multiple_Requests>
;;;;
run;

filename response temp;

proc metadata in=request out=response;
run;

options insert=(sasautos="/Data/sas-portal-app/sas/SASEnvironment/SASMacro");

%showFormattedXML(response);

