let sasjs

/********************************************************************************
 *
 *  On window load, see if we have a connection to the SAS Stored Process server,
 *  if not, get one. Otherwise, continue populating the page.
 *
 *******************************************************************************/

window.onload = function () {

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

        const newDataDivReference=existingDataDivReference.replace("${APPLOC}",encodeURI(stpLocation));
        dataDiv.setAttribute('w3-include-html',newDataDivReference);

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
    /*search for elements with a certain atrribute:*/
    file = elmnt.getAttribute("w3-include-html");
    if (file) {
      /* Make an HTTP request using the attribute value as the file name: */
      xhttp = new XMLHttpRequest();
      xhttp.onreadystatechange = function() {
        if (this.readyState == 4) {
          if (this.status == 200) {
             elmnt.innerHTML = this.responseText;
             }
          if (this.status == 404) {elmnt.innerHTML = "Page not found.";}
          /* Remove the attribute, and call this function once more: */
          elmnt.removeAttribute("w3-include-html");
          includeHTML(cb);
        }
      }
      xhttp.open("GET", file, true);
      xhttp.send();
      /* Exit the function: */
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

  defaultTab=document.getElementById("default-tab");

  if (defaultTab) {
      defaultTab.click();
      }
  else {
     console.log('No default tab found?');
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

         var headTag = document.getElementsByTagName('head')[0]
         const linkforSASComponentsCSSfile = document.createElement("link");
         linkforSASComponentsCSSfile.href = '/'+theme+'/themes/default/styles/sasComponents_FF_5.css'
         linkforSASComponentsCSSfile.type = 'text/css'
         linkforSASComponentsCSSfile.rel = 'stylesheet'
         headTag.appendChild(linkforSASComponentsCSSfile);

         const linkforSASStyleCSSfile = document.createElement("link");
         linkforSASStyleCSSfile.href = '/'+theme+'/themes/default/styles/sasStyle.css'
         linkforSASStyleCSSfile.type = 'text/css'
         linkforSASStyleCSSfile.rel = 'stylesheet'
         headTag.appendChild(linkforSASStyleCSSfile);

}

/********************************************************************************/

function logout() {
  sasjs.logOut()
  //loginRequired()
}

/********************************************************************************/

function resolve() {
  console.log('in resolve');

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

    // Get all elements with class="tabcontent" and hide them
    tabcontent = document.getElementsByClassName("tabcontent");
    for (i = 0; i < tabcontent.length; i++) {
	tabcontent[i].className = tabcontent[i].className.replace(" active", "");
    }
    // Get all elements representing portal tabs and unselect them
    // NOTE: I tried to optimize this to only change info on the one that had the selected class
    //       but because the collection is dynamic, as soon as I modified the class value that
    //       was used for searching, the length of the collection changed.

    tablinks = document.getElementsByClassName("tab-button");

    numActiveTabs=tablinks.length;

    for (i = 0; i < tablinks.length; i++) {
	tablinks[i].className = tablinks[i].className.replace("BannerTabButtonActive", "BannerTabButtonCenter");

    }

    // Show the current tab, and add an "active" class to the button that opened the tab

    document.getElementById(tabName).className += " active";

    // Change the class settings on the selected object to change the styles applied
    tabButton=evt.currentTarget;

    tabButton.className = tabButton.className.replace("BannerTabButtonCenter", "BannerTabButtonActive");

}

