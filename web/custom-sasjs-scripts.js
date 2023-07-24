let sasjs

function login(resolve, reject) {

//console.log('in login');
  // const username = document.getElementById('username').value
  // const password = document.getElementById('password').value
  sasjs.logIn('username', 'password').then((response) => {
    if (response.isLoggedIn) {
      afterLogin(!resolve)
      if (resolve) resolve()
    } else {
      if (reject) reject()
    }
  })
}

function logout() {
  sasjs.logOut()
  loginRequired()
}

function resolve() {
  console.log('in resolve');

}

function reject() {
  console.log('in reject');
}

/*
 *  Now that we know we have a sessions, fully generate the html content
 */

function afterLogin() {

  // console.log('in afterLogin');

  /* since we are only support logging in via redirection, no need for login form
  const loginForm = document.getElementById('login-form')
  const loginButton = document.getElementById('login')
  loginForm.style.display = 'none'
  loginButton.style.display = 'none'
  */

  /*
   *  We are now logged in, populate the page
   */

  //console.log('generating html');
  includeHTML(afterGeneration);

  }

/*
 *  This function runs as a callback after the
 *  html inclusion/generation has been executed.
 */

function afterGeneration() {

// console.log('afterGeneration:');

  //console.log('selecting default tab');
  defaultTab=document.getElementById("default-tab");
  // console.log('init: found default-tab:'+defaultTab);

  if (defaultTab) {
      defaultTab.click();
      }
  else {
     console.log('No default tab found?');
     }

  /*
   *  Un-hide it now
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

function showLogin() {
//console.log('in showLogin');
  const loginForm = document.getElementById('login-form')
  const loginButton = document.getElementById('login')
  //loginForm.style.display = 'flex'
  //loginButton.style.display = 'inline-block'
  loginButton.addEventListener('click', login)

  const dataContainer = document.getElementById('data-container')
  dataContainer.style.display = 'none'
  const logoutContainer = document.getElementById('logout-container')
  logoutContainer.style.display = 'none'

  //  force login to automatically trigger

  loginButton.click();

}

async function loginRequired() {
//console.log('in loginRequired');
  const sasjsConfig = sasjs.getSasjsConfig()
  if (sasjsConfig.loginMechanism === 'Redirected') {
     //console.log('loginMechanism is redirected');
     return await login(resolve, reject)
     }

  return new Promise((resolve, reject) => {
    showLogin()
    const loginButton = document.getElementById('login')
    loginButton.onclick = () => {
      login(resolve, reject)
    }
  })
}

window.onload = function () {
//console.log('in onload');
  const sasjsElement = document.querySelector('sasjs')
  const useComputeApi = sasjsElement.getAttribute('useComputeApi')

  sasjs = new SASjs.default({
    serverUrl: sasjsElement.getAttribute('serverUrl') ?? undefined,
    appLoc: sasjsElement.getAttribute('appLoc') ?? '',
    serverType: sasjsElement.getAttribute('serverType'),
    debug: sasjsElement.getAttribute('debug') === 'true',
    loginMechanism: sasjsElement.getAttribute('loginMechanism') ?? 'Default',
    useComputeApi:
      useComputeApi === 'true'
        ? true
        : useComputeApi === 'false'
        ? false
        : useComputeApi,
    contextName: sasjsElement.getAttribute('contextName') ?? ''
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

function includeHTML(cb) {

// console.log("includeHTML: start");

  var z, i, elmnt, file, xhttp;
  /* Loop through a collection of all HTML elements: */
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

