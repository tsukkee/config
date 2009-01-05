// vimperatorのstatuslineのurl表示をlocationbar2みたいにする
(function() {
    // setting 
    const liberatorNS = "http://vimperator.org/namespaces/liberator";
    var separator_char = "/";
    updateSeparator();

    // services
    let IOService = Cc["@mozilla.org/network/io-service;1"]
                  .getService(Components.interfaces.nsIIOService);
    let TLDSercie = Cc["@mozilla.org/network/effective-tld-service;1"]
                  .getService(Components.interfaces.nsIEffectiveTLDService);

    // statusline
    var statusline = document.getElementById("liberator-statusline");

    // original
    var field_url = document.getElementById("liberator-statusline-field-url");
    field_url.style.display = "none";

    // colorized
    var colorized_field_url = document.createElement("hbox");
    colorized_field_url.setAttribute("flex", 1);
    colorized_field_url.setAttribute("readonly", false);
    colorized_field_url.setAttribute("crop", "end");
    setupNode(colorized_field_url, "");

    // build nodes
    var nodes = {};
    var structure = {
        prePath:  ["protocol", "subdomain", "domain", "port"],
        dirs:    [],
        postPath: ["separator", "file", "query", "fragment", "indicator"]
    };
    
    for(var hboxName in structure) {
        var box = nodes[hboxName] = document.createElement("hbox");
        setupNode(box, hboxName);

        structure[hboxName].forEach(function(name) {
            var node = nodes[name] = document.createElement("label");
            setupNode(node, name);

            nodes[hboxName].appendChild(node);
        });

        colorized_field_url.appendChild(box);
    }

    statusline.insertBefore(colorized_field_url, field_url);

    // click event
    colorized_field_url.addEventListener("click", function(e) {
        var target = e.target;

        if(target.href) {
            liberator.open(target.href, (e.button == 1 || e.ctrlKey || e.metaKey)
                ? liberator.NEW_BACKGROUND_TAB : liberator.CURRENT_TAB);
        }
    }, false);

    // proto
    var dirNodeProto = document.createElement("label");
    setupNode(dirNodeProto, "dir");
    var separatorNodeProto = document.createElement("label");
    setupNode(separatorNodeProto, "separator");

    // update
    var update = function() {
        var url = buffer.URL;
        var pathSegments = "";
        let [, original_url, indicator] = field_url.value.match(/^\s*([^[]*)\s*(\[[^[]*\])?/);
        var isHelp = false;

        // about:*
        if(url.match(/^about:/)) {
            // clear
            structure.prePath.forEach(function(name) {
                nodes[name].value = nodes[name].href = "";
            });

            pathSegments = url;
            separator_char = "";

            indicator = "[" + url.replace(/^about:/, "") + "]";
        }
        
        // help
        else if(url.match(/^chrome:\/\/liberator\/locale\//)) {
            // clear
            structure.prePath.forEach(function(name) {
                nodes[name].value = nodes[name].href = "";
            });

            pathSegments = original_url;
            separator_char = "";

            isHelp = true;
        }

        // normal url
        else {
            // separator
            updateSeparator();

            // create nsIURI object
            var uri = null;
            try {
                uri = IOService.newURI(buffer.URL, null, null);
            }
            catch(e) { 
                liberator.echoerr("colorize_url: url parse error");
                return;
            }

            // protocol
            nodes["protocol"].value = uri.scheme + "://";

            var host = uri.host; 
            if(host) {
                // subdomain
                try {
                    var baseDomain = TLDSercie.getBaseDomainFromHost(host);
                    nodes["subdomain"].value = host.substring(0, host.lastIndexOf(baseDomain));
                    host = baseDomain;
                }
                catch (e) {
                    nodes["subdomain"].value = "";    
                }
                
                // domain
                nodes["domain"].value = host;
            }
            else {
                nodes["subdomain"].value = "";
                nodes["domain"].value = "";
            }

            // port
            if (uri.port > -1) {
                nodes["port"].value = ":" + uri.port;
            }
            else {
                nodes["port"].value = "";
            }

            // prePath href
            var prePathHref = nodes.prePath.href
                = nodes.protocol.value + nodes.subdomain.value 
                + nodes.domain.value + nodes.port.value + "/";

            structure.prePath.forEach(function(name) {
                nodes[name].href = prePathHref;
            });

            pathSegments = losslessDecodeURI(uri).replace(/^[^:]*:\/\/[^/]*\//, "");
        }

        // fragment
        var iFragment = pathSegments.indexOf("#");
        if (iFragment > -1) {
            nodes["fragment"].value = pathSegments.substring(iFragment);
            pathSegments = pathSegments.substring(0, iFragment);
        }
        else {
            nodes["fragment"].value = "";
        }

        // query
        var iQuery = pathSegments.indexOf("?");
        if (iQuery > -1) {
            nodes["query"].value = pathSegments.substring(iQuery);
            pathSegments = pathSegments.substring(0, iQuery);
        }
        else {
            nodes["query"].value = "";
        }

        // file
        pathSegments = pathSegments.split("/");
        nodes["separator"].value = separator_char;
        nodes["file"].value = pathSegments.pop();

        // indicator
        nodes["indicator"].value = indicator || "[ ]";

        // dirs
        var dirs = nodes.dirs;
        while(dirs.childNodes.length > 0) {
            dirs.removeChild(dirs.firstChild);
        }

        var href = prePathHref;
        for (var i = 0, len = pathSegments.length; i < len; i++) {
            // separator
            var separator = separatorNodeProto.cloneNode(true);
            separator.value = separator_char;
            dirs.appendChild(separator);

            // dir
            var dir = dirNodeProto.cloneNode(true);
            dir.value = pathSegments[i];
            dir.href = (href += pathSegments[i] + "/");
            dirs.appendChild(dir);
        }

        // postPath href
        structure.postPath.forEach(function(name) {
            if(name == "separator") {
                return;
            }
            else if(isHelp && name == "file") {
                nodes[name].href = url;
            }
            else {
                nodes[name].href = (href += nodes[name].value);
            }
        });
    };
    update();

    autocommands.add("LocationChange", /.*/, update);

    // function
    function updateSeparator() {
        if(liberator.globalVariables.colorize_url_separator != undefined) {
            separator_char = liberator.globalVariables.colorize_url_separator;
        }
        else {
            separator_char = "/";
        }
    }

    function setupNode(node, name) {
        const className = "liberator-colorize_url";

        node.setAttribute("class", (name != "" ? className + "-" + name + " " : "") + className);
        node.setAttributeNS(liberatorNS, "highlight", toHi(name));
    }

    function toHi(name) {
        const highlightPrefix = "ColorizeUrl";

        return highlightPrefix + name.charAt(0).toUpperCase() + name.substr(1);
    }
    
    // highlight
    // default highlight
    var css = <![CDATA[
        ColorizeUrl                 margin-left: 5px; font-weight: normal;
        ColorizeUrl>*               margin: 0; 
        ColorizeUrl:hover             
        ColorizeUrlPrePath
        ColorizeUrlPrePath>*        margin: 0;
        ColorizeUrlPrePath:hover    text-decoration: underline;
        ColorizeUrlDirs
        ColorizeUrlDirs>*           margin: 0;
        ColorizeUrlDirs:hover
        ColorizeUrlPostPath
        ColorizeUrlPostPath>*       margin: 0;
        ColorizeUrlPostPath:hover
        ColorizeUrlSeparator
        ColorizeUrlSeparator:hover  

        ColorizeUrlProtocol
        ColorizeUrlProtocol:hover
        ColorizeUrlSubdomain        color: #666;
        ColorizeUrlSubdomain:hover
        ColorizeUrlDomain           color: blue; font-weight: bold;
        ColorizeUrlDomain:hover
        ColorizeUrlPort             color: #666;
        ColorizeUrlPort:hover
        ColorizeUrlDir
        ColorizeUrlDir:hover        text-decoration: underline
        ColorizeUrlFile
        ColorizeUrlFile:hover       text-decoration: underline
        ColorizeUrlQuery
        ColorizeUrlQuery:hover      text-decoration: underline
        ColorizeUrlFragment         color: #666;
        ColorizeUrlFragment:hover   text-decoration: underline
        ColorizeUrlIndicator        margin-left: 5px; font-weight: bold; 
        ColorizeUrlIndicator:hover  
    ]]>.toString();

    // append plugins style
    highlight.CSS = (Highlights.prototype.CSS += "\n" + css);
    highlight.reload();
})();
