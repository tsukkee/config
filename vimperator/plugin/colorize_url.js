liberator.plugins.colorize_url = (function() {
    // setting
    var separator_char = "/";

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

    // create
    var nodes = {};
    var className = "liberator-colorize_url";
    var prefix = className + "-";
    var structure = {
        prePath:  ["protocol", "subdomain", "domain", "port"],
        paths:    [],
        postPath: ["separator", "file", "query", "fragment"]
    };
    
    for(var hboxName in structure) {
        var box = nodes[hboxName] = document.createElement("hbox");
        box.setAttribute("class", prefix + hboxName + " " + className);

        var labels = structure[hboxName];
        labels.forEach(function(name) {
            var node = nodes[name] = document.createElement("label");
            node.setAttribute("class", prefix + name + " " + className);
            nodes[hboxName].appendChild(node);
        });

        colorized_field_url.appendChild(box);
    }

    statusline.insertBefore(colorized_field_url, field_url);

    // proto
    var pathNodeProto = document.createElement("label");
    pathNodeProto.setAttribute("class", prefix + "path " + className);
    var separatorNodeProto = document.createElement("label");
    separatorNodeProto.setAttribute("class", prefix + "separator " + className);

    // update
    var update = function() {
        var url = buffer.URL;
        if(url.match(/^about:/)) {
            return;
        }

        // create nsIURI object
        var uri = null;
        try {
            uri = IOService.newURI(buffer.URL, null, null);
        }
        catch(e) { }

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

        var pathSegments = losslessDecodeURI(uri).replace(/^[^:]*:\/\/[^/]*\//, "");

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

        // paths
        var paths = nodes.paths;
        while(paths.childNodes.length > 0) {
            paths.removeChild(paths.firstChild);
        }

        for (var i = 0, len = pathSegments.length; i < len; i++) {
            // separator
            var separator = separatorNodeProto.cloneNode(true);
            separator.value = separator_char;
            paths.appendChild(separator);

            // path
            var path = pathNodeProto.cloneNode(true);
            path.value = pathSegments[i];
            paths.appendChild(path);
        }
    };
    update();

    autocommands.add("LocationChange", /.*/, update);

    return {
        setSeparator: function(c) {
            separator_char = c;
        }
    };
})();
