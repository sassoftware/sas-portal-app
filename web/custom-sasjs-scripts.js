let sasjs

/********************************************************************************
 *
 *  On window load, see if we have a connection to the SAS Stored Process server,
 *  if not, get one. Otherwise, continue populating the page.
 *
 *******************************************************************************/

window.onload = function () {

  /*
   *  Inject any javascript overrides
   */

  if (!JSOverrides == '') {

     loadLatestScript(JSOverrides,1,'append');

     }

  sasjs = new SASjs.default({
    serverUrl: window.sasjsServerUrl ?? undefined,
    appLoc: window.sasjsAppLoc ?? '',
    serverType: window.sasjsServerType,
    debug: window.sasjsDebug === 'true',
    loginMechanism: window.sasjsLoginMechanism ?? 'Default',
    useComputeApi:
      window.sasjsUseComputeApi === 'true'
        ? true
        : window.sasjsUseComputeApi === 'false'
        ? false
        : window.sasjsUseComputeApi,
    contextName: window.sasjsContextName ?? ''
  })

  sasjs
    .checkSession()
    .then((res) => {
      if (res.isLoggedIn) afterLogin()
      else loginRequired()
    })
    .catch((err) => {
      console.error(err)
    })

}

/********************************************************************************
 *
 *  We need to login, show the appropriate screens to do that
 *
 *******************************************************************************/
function showLogin() {

  //   Make sure the content is hidden while trying to log in

  const dataContainer = document.getElementById('data-container')

  dataContainer.style.display = 'none'

  // const logoutContainer = document.getElementById('logout-container')
  // logoutContainer.style.display = 'none'

  //  force login to automatically trigger

  // loginButton.click();

  login(resolve, reject);
}

/********************************************************************************
 *
 *  We need to login, try to do it now.
 *
 *******************************************************************************/

async function loginRequired() {

  const sasjsConfig = sasjs.getSasjsConfig()
  if (sasjsConfig.loginMechanism === 'Redirected') {
     return await login(resolve, reject)
     }
  // Might be able to remove this?
  return new Promise((resolve, reject) => {
    showLogin()
  })
}

/********************************************************************************
 *
 *  Execute the login and get the returned status
 *
 *******************************************************************************/

function login(resolve, reject) {

  /*
   * No intent to support a login form to ask for your
   * username and password, so just pass hardcoded strings
   * as they will be ignored by sasjs because the login type
   * is set to Redirected.
   */

  sasjs.logIn('username', 'password').then((response) => {
    if (response.isLoggedIn) {
      afterLogin(!resolve)
      if (resolve) resolve()
    } else {
      if (reject) reject()
    }
  })
}

/********************************************************************************
 *
 *  Once we know we have a session, continue generating Content
 *
 *******************************************************************************/
function afterLogin() {

  //  Modify the Stored Process reference use the values set in the setup.js file

  updateSTPReference();

  /*
   *  We are now logged in, populate the page
   */

  includeHTML(afterGeneration);

  }

/********************************************************************************
 *
 *  To avoid having the same configuration information in different places,
 *  we need to modify the the stp reference in the main index file to use
 *  the values specified in the setup.js file before trying to generate the html 
 *
 *******************************************************************************/
function updateSTPReference() {

        //  Modify the Stored Process reference use the values set in the setup.js file

        const dataDiv = document.getElementById('data-container');

        //  Do text replacement to the insert the correct values

        //  SAS Application location (ie. stored process folder)
        //  NOTE: Must url encode the value!

        const existingDataDivReference=dataDiv.getAttribute('w3-include-html')
        const stpLocation=sasjsAppLoc+'/services/';

        newDataDivReference=existingDataDivReference.replace("${APPLOC}",encodeURI(stpLocation));

        // Get any parameters passed to this page and forward them on to the stp
        // NOTE: need to remove the leading ? since we will be adding this to a url that already has parameters

        const queryString = window.location.search.replace('?','');


        if (newDataDivReference.includes('?')) {
           newDataDivReference=newDataDivReference.concat('&',queryString);
           }

        else {
           newDataDivReference=newDataDivReference.concat('?',queryString);
           }

        dataDiv.setAttribute('w3-include-html',newDataDivReference);

}

/********************************************************************************
 *
 *  Populate the passed div tag with the file pointed to by it's w3-include-html attribute
 *
 *  Parameters:
 *
 *   element - the dom element to see if it has html to include
 *   cb1     - the function to call back to when this element's html processing is complete
 *   cb2     - the callback function to pass to the callback function
 *
 *******************************************************************************/

function populateDiv(element, cb1, cb2) {
 
    file = element.getAttribute("w3-include-html");
    if (file) {
      /* Make an HTTP request using the attribute value as the file name: */
      xhttp = new XMLHttpRequest();
      
      /*
       *  Start On State Change function definition
       */

      xhttp.onreadystatechange = function() {
        if (this.readyState == 4) {
          if (this.status == 200) {
             element.innerHTML = this.responseText;
             /*
              *  Execute any scripts that may be in the generated text
              *  Scripts in dynamically generted content aren't parsed and executed
              *  Thus here we need to explicitly find all of the script elements and
              *  add them as children (which will cause the execution).
              *  NOTE: experimented with several ways of doing this, this is the only
              *  way I found that would both execute them AND make the contents of the
              *  scripts available to other scripts.
              */
             element.querySelectorAll('script').forEach(function(node) {
                script = document.createElement('script');
                script.innerHTML=node.innerText;
                element.appendChild(script);

                });

             }
          if (this.status == 404) {
             element.innerHTML = "Page not found.";
             }
          /* Remove the attribute, and call this function once more: */

          element.removeAttribute("w3-include-html");

          if (cb1) cb1(cb2);

          }
        }
      /*
       * End  On State Change function definition
       */
      xhttp.open("GET", file, true);
      xhttp.send();
      /* Done processing the file request, exit and let the onreadystatechange function do it's thing */
      return;

      }

}

/********************************************************************************
 *
 *  Find any references to other html sources and include them 
 *
 *******************************************************************************/
function includeHTML(cb) {


  var z, i, elmnt, file, xhttp;
  /* Loop through a collection of all HTML elements: */
  /* TODO: This feels like we should be able to look for just elements that
           have the w3-include-html attribute and only process those...
   */
  z = document.getElementsByTagName("*");

  for (i = 0; i < z.length; i++) {

    elmnt = z[i];

    hasHTMLtoInclude=elmnt.hasAttribute("w3-include-html");

    if (hasHTMLtoInclude) {

       /*
        *  pass this routine as the callback to process the next one after 
        *  this one completes and pass along any callback that was passed on the 
        *  the initial call to this routine
        *
        *  The net result here is that each reference to w3-include-html will 
        *  be processed sequentially, by way of passing a callback to populateDiv
        *  back to this function to find the next one, until there are no more.
        *
        */

          populateDiv(elmnt,includeHTML,cb);

          return;

       }

    }

/*
 *  Now call the callback if one was passed
 */

 if (cb) cb();

}

/********************************************************************************
 *
 *  This function runs as a callback after the
 *  html inclusion/generation has been executed and completed.
 *
 *******************************************************************************/
function afterGeneration() {

  /*
   *  This set of functions is used with different types of pages.
   *  Some, will have tabs and one of them marked "default-tab".  If we find that,
   *  select it.
   *  All pages have a "data-container" that needs to be populated and displayed.
   */

  // restore current tab if any
  var activeTabId = sessionStorage.getItem('activeTabId');
  var tabFound=false;

  if (activeTabId) {

      var previousTab=document.getElementById('page_'+activeTabId);

      if (previousTab) {
         tabFound=true;
         previousTab.click();
         }
     }
  if (!tabFound) {

      // No previously selected tab, just get default
      defaultTabs=document.getElementsByClassName("default-tab");

      if (defaultTabs) {

          // Should only be 1 

          defaultTab=defaultTabs[0];

          if (defaultTab) {

             defaultTab.click();

             }

          }
      }
  /*
   *  Inject any styles that may have been generated as part of the html generation
   */

  injectStyles()

  /*
   *  Un-hide the content now
   */

  const dataContainer = document.getElementById('data-container')
  dataContainer.style.display = ''

  /* Don't give them a way to log out for now

  const logoutContainer = document.getElementById('logout-container')
  logoutContainer.style.display = ''

  let logoutButton = document.getElementById('logout')
  if (!logoutButton) {
    logoutButton = document.createElement('button')
    logoutButton.id = 'logout'
    logoutButton.innerText = 'Logout'
    logoutButton.onclick = logout

    logoutContainer.appendChild(logoutButton)
  }
  */

}

/********************************************************************************
 *
 *  Because the SAS Theme being used/requested might be different than the default,
 *  we need to add the correct CSS reference after we have figured out what 
 *  theme is to be used during the server side generation. 
 *  This routine gets the information returned by the generation and inserts
 *  the correct CSS references in this file's header.
 *
 *******************************************************************************/
function injectStyles() {

    /*
     *  The generated content created a hidden div field that contains the current theme to use
     *  add that information to the header now.
     */

    const theme = document.getElementById('sastheme').innerHTML;
    // Get the theme path
    const themeContextRoot = 'SASTheme_'+theme;
         var headTag = document.getElementsByTagName('head')[0]

         const linkforSASStyleCSSfile = document.createElement("link");
         linkforSASStyleCSSfile.href = '/'+themeContextRoot+'/themes/'+theme+'/styles/sasStyle.css'
         linkforSASStyleCSSfile.type = 'text/css'
         linkforSASStyleCSSfile.rel = 'stylesheet'
         headTag.appendChild(linkforSASStyleCSSfile);

         const linkforSASComponentsCSSfile = document.createElement("link");
         linkforSASComponentsCSSfile.href = '/'+themeContextRoot+'/themes/'+theme+'/styles/sasComponents_FF_5.css'
         linkforSASComponentsCSSfile.type = 'text/css'
         linkforSASComponentsCSSfile.rel = 'stylesheet'
         headTag.appendChild(linkforSASComponentsCSSfile);

         const linkforPortalStyleCSSfile = document.createElement("link");
         linkforPortalStyleCSSfile.href = '/'+themeContextRoot+'/themes/'+theme+'/styles/Portal.css'
         linkforPortalStyleCSSfile.type = 'text/css'
         linkforPortalStyleCSSfile.rel = 'stylesheet'
         headTag.appendChild(linkforPortalStyleCSSfile);

         const linkforCustomStyleCSSfile = document.createElement("link");
         linkforCustomStyleCSSfile.href = '/'+themeContextRoot+'/themes/'+theme+'/styles/custom.css'
         linkforCustomStyleCSSfile.type = 'text/css'
         linkforCustomStyleCSSfile.rel = 'stylesheet'
         headTag.appendChild(linkforCustomStyleCSSfile);

         const linkforLocalCSSfile = document.createElement("link");
         linkforLocalCSSfile.href = 'thisStyle.css'
         linkforLocalCSSfile.type = 'text/css'
         linkforLocalCSSfile.rel = 'stylesheet'
         headTag.appendChild(linkforLocalCSSfile);

         //  See if the admin has defined some custom css overrides

         if (!CSSOverrides=='') {
             const linkforOverridesCSSfile = document.createElement("link");
             //  Include a unique id so that the latest version is always
             // picked up
             var uid = (new Date().getTime()).toString(36);
             linkforOverridesCSSfile.href = CSSOverrides+'?v='+uid
             linkforOverridesCSSfile.type = 'text/css'
             linkforOverridesCSSfile.rel = 'stylesheet'
             headTag.appendChild(linkforOverridesCSSfile);
         }

}

/********************************************************************************/

function logout() {
  sasjs.logOut()
  //loginRequired()
}

/********************************************************************************/

function resolve() {
  // console.log('in resolve');

}

/********************************************************************************/

function reject() {
  console.log('in reject');
}

/********************************************************************************
 *
 *  Show the content for the selected Tab (and hide the others)
 *
 *******************************************************************************/

function showTab(evt, tabName) {
    // Declare all variables
    var i, tabcontent, tablinks;

    // All of the div sections for each tab are marked with a class of tabcontent
    // Get all of those with class="tabcontent" and hide them

    tabcontent = document.getElementsByClassName("tabcontent");
    for (i = 0; i < tabcontent.length; i++) {
	tabcontent[i].className = tabcontent[i].className.replace(" active", "");
    }

    // Find the cell that is currently active, ie. the table cell that has the active tab in it

    selectedCell=document.querySelector(".BannerTabMenuActiveTabCell");

    /*  Each button container has:
        - an image for the left side of the tab
        - a button that has a background image for the center part of the tab
        - an image for the right side of the tab

        All of these have to be changed when changing from active to inactive

     */

    for (const child of selectedCell.getElementsByTagName('img')) {
         imgSrc=child.getAttribute('src');
         child.setAttribute('src',imgSrc.replace('Active',''));

        }

    for (const child of selectedCell.getElementsByTagName('td')) {
         tdClass=child.getAttribute('class');
         child.setAttribute('class',tdClass.replace('Active',''));

         /*
          *  If it has a style attribute, then change the background image also
          */

         tdStyle=child.getAttribute('style');
         if (tdStyle) {

            child.setAttribute('style',tdStyle.replace('Active',''));

            
            }
        }

    selectedCell.setAttribute('class','BannerTabMenuTabCell');

    /*
     * When the page was first generated, any portlets that should have a src tag, were created with a "data-src"
     * so that they would not be called at that time (with the intent that they would be called when the tab was
     * selected).
     * Now that the tab has been selected, we need to change that attribute to src on all items in this div
     *  so that it will populate
     */

    tabDiv=document.getElementById(tabName);

    if (tabDiv) {

	    matches = tabDiv.querySelectorAll("*[data-src]");

	    /*
	     *  Set the src field and remove the data-src attribute so we don't generate it again on subsequent
	     *  visits to this tab.
	     */
	    if (matches) {

	    matches.forEach((match) => {
	       match.setAttribute('src',match.getAttribute('data-src'));
	       match.removeAttribute('data-src');
	       });

	    }
       }

    // Show the current tab, and add an "active" class to the button that opened the tab

    tabDiv.className += " active";

    // Change the class settings on the selected object to change the styles applied
    // The onclick method is on the table that contains the selected tab!

    tabButton=evt.currentTarget;

    //  The parent of the selected item is the table td entry that contains the button container
    //  we need to make sure this is updated so we can determine which tab is selected later if it's switched

    tabButton.parentElement.setAttribute('class','BannerTabMenuActiveTabCell');

      /*  Each button container has:
          - an image for the left side of the tab
          - a button that has a background image for the center part of the tab
          - an image for the right side of the tab

          All of these have to be changed when changing from inactive to active

       */

      for (const child of tabButton.getElementsByTagName('img')) {
           imgSrc=child.getAttribute('src');
           child.setAttribute('src',imgSrc.replace('.gif','Active.gif'));

          }

      for (const child of tabButton.getElementsByTagName('td')) {
           tdClass=child.getAttribute('class');
           child.setAttribute('class',tdClass.replace('BannerTabButton','BannerTabButtonActive'));

           /*
            *  If it has a style attribute, then change the background image also
            */

           tdStyle=child.getAttribute('style');
           if (tdStyle) {

              child.setAttribute('style',tdStyle.replace('.gif','Active.gif'));

              }
          }

    // remember current tab

    sessionStorage.setItem('activeTabId', tabName);

}
function resizeIframe(obj) {
    obj.style.height = obj.contentWindow.document.documentElement.scrollHeight + 'px';
  }

