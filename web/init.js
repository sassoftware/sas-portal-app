/*
 *  NOTE: If this file is changed, you need to make sure to force all callers
 *        of it to load the new file by increasing the v= parameter on the call!
 */

/*
 *  This function will force a load of the latest version (ie. don't use the cached
 *  version) if requested to do so.
 */

function loadLatestScript(src,useLatest,placement) {
     const script=document.createElement("script");
     if (useLatest=='1') {

        var uid = (new Date().getTime()).toString(36);
        var newSrc=src+'?v='+uid;
        }
     else {
        var newSrc=src;
        }

     script.src=newSrc;

     if (placement=="prepend") {
        document.head.prepend(script);
        }
     else {
        document.head.append(script);
        }
}

function loadScripts() {

    /*  To make it easy to change the configuration, and we expect the setup.js
        file to be small, always load the latest version.
     */

    loadLatestScript('setup.js',1,"prepend");

    /*
     *  Use the cached version of these common scripts 
     */

    loadLatestScript('sasjs.js');
    loadLatestScript('custom-sasjs-scripts.js');

    }
