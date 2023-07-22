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

function afterLogin() {

//console.log('in afterLogin');

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
  includeHTML();

  //console.log('selecting default tab');
  defaultTab=document.getElementById("default-tab");
  //console.log('init: found default-tab:'+defaultTab);

  if (defaultTab) {
      defaultTab.click();
      }
  else {
     //console.log('No default tab found?');
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
