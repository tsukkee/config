/*** BEGIN LICENSE BLOCK {{{
    Copyright (c) 2008 suVene<suvene@zeromemory.info>

    distributable under the terms of an MIT-style license.
    http://www.opensource.jp/licenses/mit-license.html
}}}  END LICENSE BLOCK ***/
// PLUGIN_INFO//{{{
var PLUGIN_INFO =
<VimperatorPlugin>
    <name>{NAME}</name>
    <description>request, and the result is displayed to the buffer.</description>
    <description lang="ja">リクエストの結果をバッファに出力する。</description>
    <author mail="suvene@zeromemory.info" homepage="http://zeromemory.sblo.jp/">suVene</author>
    <version>0.4.7</version>
    <license>MIT</license>
    <minVersion>2.0pre</minVersion>
    <maxVersion>2.0pre</maxVersion>
    <updateURL>http://svn.coderepos.org/share/lang/javascript/vimperator-plugins/trunk/multi_requester.js</updateURL>
    <detail><![CDATA[
== Needs Library ==
- _libly.js(ver.0.1.11)
  @see http://coderepos.org/share/browser/lang/javascript/vimperator-plugins/trunk/_libly.js

== Usage ==
>||
command[!] subcommand [ANY_TEXT]
||<
- !                create new tab.
- ANY_TEXT         your input text

e.g.)
>||
:mr  alc[,goo,any1,any2…] ANY_TEXT           -> request by the input text, and display to the buffer.
:mr! goo[,any1,any2,…]    {window.selection} -> request by the selected text, and display to the new tab.
||<

== Custumize .vimperatorrc ==
=== Command(default [mr]) ===
>||
let g:multi_requester_command = "ANY1, ANY2, ……"
or
liberator.globalVariables.multi_requester_command = [ANY1, ANY2, ……];
||<

=== SITEINFO ===
e.g.)
>||
javascript <<EOM
liberator.globalVariables.multi_requester_siteinfo = [
    {
        map:            ',me',                          // optional: keymap for this siteinfo call
        bang:           true,                           // optional:
        args:           'any'                           // optional:
        name:           'ex',                           // required: subcommand name
        description:    'example',                      // required: commandline short help
        url:            'http://example.com/?%s',       // required: %s <-- replace string
        xpath:          '//*',                          // optional: default all
        srcEncode:      'SHIFT_JIS',                    // optional: default UTF-8
        urlEncode:      'SHIFT_JIS',                    // optional: default srcEncode
        ignoreTags:     'img',                          // optional: default script, syntax 'tag1,tag2,……'
        extractLink:    '//xpath'                       // optional: extract permalink
    },
];
EOM
||<

=== other siteinfo by wedata. ===
    @see http://wedata.net/databases/Multi%20Requester/items

=== Mappings ===
e.g.)
>||
javascript <<EOM
liberator.globalVariables.multi_requester_mappings = [
    [',ml', 'ex'],                  // == :mr  ex
    [',mg', 'goo', '!'],            // == :mr! goo
    [',ma', 'alc',    , 'args'],    // == :mr  alc args
];
EOM
||<

=== Other Options ===
>||
let g:multi_requester_use_wedata = "false"             // true by default
||<

=== Todo ===
- wedata local cache.
     ]]></detail>
</VimperatorPlugin>;
//}}}
(function() {
if (!liberator.plugins.libly) {
    liberator.log('multi_requester: needs _libly.js');
    return;
}

// global variables {{{
var DEFAULT_COMMAND = ['mr'];
var SITEINFO = [
    {
        name:        'alc',
        description: 'SPACE ALC (\u82F1\u8F9E\u6717 on the Web)',
        url:         'http://eow.alc.co.jp/%s/UTF-8/',
        xpath:       'id("resultList")'
    },
    {
        name:        'goo',
        description: 'goo \u8F9E\u66F8',
        url:         'http://dictionary.goo.ne.jp/search.php?MT=%s&kind=all&mode=0&IE=UTF-8',
        xpath:       'id("incontents")/*[@class="ch04" or @class="fs14" or contains(@class, "diclst")]',
        srcEncode:   'EUC-JP',
        urlEncode:   'UTF-8'
    },
];
var libly = liberator.plugins.libly;
var $U = libly.$U;
var logger = $U.getLogger('multi_requester');
var mergedSiteinfo = {};
//}}}

// Vimperator plugin command register {{{
var CommandRegister = {
    register: function(cmdClass, siteinfo) {
        cmdClass.siteinfo = siteinfo;

        commands.addUserCommand(
            cmdClass.name,
            cmdClass.description,
            $U.bind(cmdClass, cmdClass.cmdAction),
            {
                completer: cmdClass.cmdCompleter || function(context, arg) {
                    context.title = ['Name', 'Descprition'];
                    var filters = context.filter.split(',');
                    var prefilters = filters.slice(0, filters.length - 1);
                    var prefilter = !prefilters.length ? '' : prefilters.join(',') + ',';
                    var subfilters = siteinfo.filter(function(s) prefilters.every(function(p) s.name != p));
                    var allSuggestions = subfilters.map(function(s) [prefilter + s.name, s.description]);
                    context.completions = context.filter
                        ? allSuggestions.filter(function(s) s[0].indexOf(context.filter) == 0)
                        : allSuggestions;
                },
                options: cmdClass.cmdOptions,
                argCount: cmdClass.argCount || undefined,
                bang: cmdClass.bang || true,
                count: cmdClass.count || false
            },
            true // replace
        );

    },
    addUserMaps: function(prefix, mapdef) {
        mapdef.forEach(function([key, command, bang, args]) {
            var cmd = prefix + (bang ? '! ' : ' ') + command + ' ';
            mappings.addUserMap(
                [modes.NORMAL, modes.VISUAL],
                [key],
                'user defined mapping',
                function() {
                    if (args) {
                        liberator.execute(cmd + args);
                    } else {
                        let sel = $U.getSelectedString();
                        if (sel.length) {
                            liberator.execute(cmd + sel);
                        } else {
                            commandline.open(':', cmd, modes.EX);
                        }
                    }
                },
                {
                    rhs: ':' + cmd,
                    norremap: true
                }
            );
        });
    }
};
//}}}

// initial data access class {{{
var DataAccess = {
    getCommand: function() {
        var c = liberator.globalVariables.multi_requester_command;
        var ret;
        if (typeof c == 'string') {
            ret = [c];
        } else if (typeof c == 'Array') {
            ret = check;
        } else {
            ret = DEFAULT_COMMAND;
        }
        return ret;
    },
    getSiteInfo: function() {

        var self = this;
        var useWedata = typeof liberator.globalVariables.multi_requester_use_wedata == 'undefined' ?
                        true : $U.eval(liberator.globalVariables.multi_requester_use_wedata);

        if (liberator.globalVariables.multi_requester_siteinfo) {
            liberator.globalVariables.multi_requester_siteinfo.forEach(function(site) {
                if (!mergedSiteinfo[site.name]) mergedSiteinfo[site.name] = {};
                $U.extend(mergedSiteinfo[site.name], site);
                if (site.map) {
                    CommandRegister.addUserMaps(MultiRequester.name[0],
                        [[site.map, site.name, site.bang, site.args]]);
                }
            });
        }

        SITEINFO.forEach(function(site) {
            if (!mergedSiteinfo[site.name]) mergedSiteinfo[site.name] = {};
            $U.extend(mergedSiteinfo[site.name], site);
            if (site.map) {
                CommandRegister.addUserMaps(MultiRequester.name[0],
                    [[site.map, site.name, site.bang, site.args]]);
            }
        });

        if (useWedata) {
            logger.log('use wedata');
            this.getWedata(function(site) {
                if (mergedSiteinfo[site.name]) return;
                mergedSiteinfo[site.name] = {};
                $U.extend(mergedSiteinfo[site.name], site);
            });
        }

        return $U.A(mergedSiteinfo);
    },
    getWedata: function(func) {
        var req = new libly.Request(
            'http://wedata.net/databases/Multi%20Requester/items.json'
        );
        req.addEventListener('onSuccess', function(res) {
            var text = res.responseText;
            if (!text) return;
            var json = $U.evalJson(text);
            if (!json) return;

            json.forEach(function(item) func(item.data));
            CommandRegister.register(MultiRequester, $U.A(mergedSiteinfo));

        });
        req.get();
    }
};
//}}}

// main controller {{{
var MultiRequester = {
    name: DataAccess.getCommand(),
    description: 'request, and display to the buffer',
    doProcess: false,
    requestNames: '',
    requestCount: 0,
    echoHash: {},
    cmdAction: function(args) { //{{{

        if (MultiRequester.doProcess) return;

        var argstr = args.string;
        var bang = args.bang;
        var count = args.count;

        var parsedArgs = this.parseArgs(argstr);
        if (parsedArgs.count == 0) { return; } // do nothing

        MultiRequester.doProcess = true;
        MultiRequester.requestNames = parsedArgs.names;
        MultiRequester.requestCount = 0;
        MultiRequester.echoHash = {};
        var siteinfo = parsedArgs.siteinfo;
        for (let i = 0, len = parsedArgs.count; i < len; i++) {

            let info = siteinfo[i];
            let url = info.url;
            // see: http://fifnel.com/2008/11/14/1980/
            let srcEncode = info.srcEncode || 'UTF-8';
            let urlEncode = info.urlEncode || srcEncode;

            let idxRepStr = url.indexOf('%s');
            if (idxRepStr > -1 && !parsedArgs.str) continue;

            // via. lookupDictionary.js
            let ttbu = Components.classes['@mozilla.org/intl/texttosuburi;1']
                                 .getService(Components.interfaces.nsITextToSubURI);
            url = url.replace(/%s/g, ttbu.ConvertAndEscape(urlEncode, parsedArgs.str));
            logger.log(url + '[' + srcEncode + '][' + urlEncode + ']::' + info.xpath);

            if (bang) {
                liberator.open(url, liberator.NEW_TAB);
            } else {
                let req = new libly.Request(url, null, {
                    encoding: srcEncode,
                    siteinfo: info,
                    args: {
                        args: args,
                        bang: bang,
                        count: count
                    }
                });
                req.addEventListener('onException', $U.bind(this, this.onException));
                req.addEventListener('onSuccess', $U.bind(this, this.onSuccess));
                req.addEventListener('onFailure', $U.bind(this, this.onFailure));
                req.get();
                MultiRequester.requestCount++;
            }
        }

        if (MultiRequester.requestCount) {
            logger.echo('Loading ' + parsedArgs.names + ' ...', commandline.FORCE_SINGLELINE);
        } else {
            MultiRequester.doProcess = false;
        }
    },
    // return {names: '', str: '', count: 0, siteinfo: [{}]}
    parseArgs: function(args) {

        var self = this;
        var ret = {};
        ret.names = '';
        ret.str = '';
        ret.count = 0;
        ret.siteinfo = [];

        if (!args) return ret;

        var arguments = args.split(/ +/);
        var sel = $U.getSelectedString();

        if (arguments.length < 1) return ret;

        ret.names = arguments.shift();
        ret.str = (arguments.length < 1 ? sel : arguments.join()).replace(/[\n\r]+/g, '');

        ret.names.split(',').forEach(function(name) {
            var site = self.getSite(name);
            if (site) {
                ret.count++;
                ret.siteinfo.push(site);
            }
        });

        return ret;
    },
    getSite: function(name) {
        if (!name) this.siteinfo[0];
        var ret = null;
        this.siteinfo.forEach(function(s) {
            if (s.name == name) ret = s;
        });
        return ret;
    },//}}}
    extractLink: function(res, extractLink) { //{{{

        var el = res.getHTMLDocument(extractLink);
        if (!el) throw 'extract link failed.: extractLink -> ' + extractLink;
        var url = $U.pathToURL(el[0], res.req.url);
        var req = new libly.Request(url, null, $U.extend(res.req.options, {extractLink: true}));
        req.addEventListener('onException', $U.bind(this, this.onException));
        req.addEventListener('onSuccess', $U.bind(this, this.onSuccess));
        req.addEventListener('onFailure', $U.bind(this, this.onFailure));
        req.get();
        MultiRequester.requestCount++;
        MultiRequester.doProcess = true;

    },//}}}
    onSuccess: function(res) { //{{{

        if (!MultiRequester.doProcess) {
            MultiRequester.requestCount = 0;
            return;
        }

        logger.log('success!!: ' + res.req.url);
        MultiRequester.requestCount--;
        if (MultiRequester.requestCount == 0) {
            MultiRequester.doProcess = false;
        }

        var url, escapedUrl, xpath, doc, html, extractLink, ignoreTags;

        try {

            if (!res.isSuccess() || res.responseText == '') throw 'response is fail or null';

            url = res.req.url;
            escapedUrl = util.escapeHTML(url);
            xpath = res.req.options.siteinfo.xpath;
            extractLink = res.req.options.siteinfo.extractLink;

            if (extractLink && !res.req.options.extractLink) {
                this.extractLink(res, extractLink);
                return;
            }
            ignoreTags = ['script'].concat(libly.$U.A(res.req.options.siteinfo.ignoreTags));
            doc = document.createElementNS(null, 'div');
            res.getHTMLDocument(xpath, null, ignoreTags, function(node, i) {
                if (node.tagName.toLowerCase() != 'html')
                    doc.appendChild(node);
            });
            if (!doc) throw 'XPath result is undefined or null.: XPath -> ' + xpath;

            $U.getNodesFromXPath('descendant-or-self::a | descendant-or-self::img', doc, function(node) {
                var tagName = node.tagName.toLowerCase();
                if (tagName == 'a') {
                    node.href = $U.pathToURL(node, url, res.doc);
                } else if (tagName == 'img') {
                    node.src = $U.pathToURL(node, url, res.doc);
                }
            });

            html = '<a href="' + escapedUrl + '" class="hl-Title" target="_self">' + escapedUrl + '</a>' +
                   $U.xmlSerialize(doc);

            MultiRequester.echoHash[res.req.options.siteinfo.name] = html;

        } catch (e) {
            logger.log('error!!: ' + e);
            MultiRequester.echoHash[res.req.options.siteinfo.name] =
                            '<span style="color: red;">error!!: ' + e + '</span>';
        }

        if (MultiRequester.requestCount == 0) {
            let echoList = [];
            MultiRequester.requestNames.split(',').forEach(function(name) {
                echoList.push(MultiRequester.echoHash[name]);
            });
            html = '<div style="white-space:normal;"><base href="' + escapedUrl + '"/>' +
                   echoList.join('') +
                   '</div>';
            try { logger.echo(new XMLList(html)); } catch (e) { logger.log(e); logger.echo(html); }
        }

    },
    onFailure: function(res) {
        MultiRequester.doProcess = false;
        logger.echoerr('request failure!!: ' + res.statusText);
    },
    onException: function(e) {
        MultiRequester.doProcess = false;
        logger.echoerr('exception!!: ' + e);
    }//}}}
};
//}}}

// boot strap {{{
CommandRegister.register(MultiRequester, DataAccess.getSiteInfo());
if (liberator.globalVariables.multi_requester_mappings) {
    CommandRegister.addUserMaps(MultiRequester.name[0], liberator.globalVariables.multi_requester_mappings);
}
//}}}

return MultiRequester;

})();
// vim: set fdm=marker sw=4 ts=4 sts=0 et:

