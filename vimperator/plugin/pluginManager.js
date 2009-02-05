var PLUGIN_INFO =
<VimperatorPlugin>
<name>{NAME}</name>
<description>Manage Vimperator Plugins</description>
<description lang="ja">Vimpeatorプラグインの管理</description>
<author mail="teramako@gmail.com" homepage="http://d.hatena.ne.jp/teramako/">teramako</author>
<version>0.5</version>
<minVersion>2.0pre</minVersion>
<maxVersion>2.0pre</maxVersion>
<updateURL>http://svn.coderepos.org/share/lang/javascript/vimperator-plugins/trunk/pluginManager.js</updateURL>
<detail lang="ja"><![CDATA[
これはVimperatorプラグインの詳細情報orヘルプを表示するためのプラグインです。
== Command ==

:plugin[help] [pluginName] [-v]:
    {pluginName}を入れるとそのプラグインの詳細を表示します。
    省略すると全てのプラグインの詳細を表示します。
    オプション -v はより細かなデータを表示します

== For plugin Developers ==
プラグインの先頭に
>||
    var PLUGIN_INFO = ...
||<
とE4X形式でXMLを記述してください
各要素は下記参照

=== 要素 ===
name:
    プラグイン名
description:
    簡易説明
    属性langに"ja"などと言語を指定するとFirefoxのlocaleに合わせたものになります。
author:
    製作者名
    属性mailにe-mail、homepageにURLを付けるとリンクされます
license:
    ライセンスについて
    属性documentにURLを付けるとリンクされます
version:
    プラグインのバージョン
maxVersion:
    プラグインが使用できるVimperatorの最大バージョン
minVersion:
    プラグインが使用できるVimperatorの最小バージョン
updateURL:
    プラグインの最新リソースURL
detail:
    ここにコマンドやマップ、プラグインの説明
    CDATAセクションにwiki的に記述可能

== Wiki書式 ==
見出し:
    - == heading1 == で第一見出し(h1)
    - === heading2 === で第二見出し(h2)
    - ==== heading3 ==== で第三見出し(h3)

リスト:
    - "- "を先頭につけると箇条書きリスト(ul)になります。
      - 改行が可能
        >||
            - 改行
              可能
        ||<
        の場合

        - 改行
          可能

        となります。
      - ネスト可能

    - "+ "を先頭につけると番号付きリスト(ol)になります。
      仕様は箇条書きリストと同じです。

定義リスト:
    - 末尾が":"で終わる行は定義リスト(dl,dt)になります。
    - 次行をネストして始めるとdd要素になります。
    - これもネスト可能です。

整形式テキスト:
    >|| と ||< で囲むと整形式テキスト(pre)になります。
    コードなどを書きたい場合に使用できるでしょう。

インライン:
    - mailtoとhttp、httpsスキームのURLはリンクになります

== ToDo ==
- 更新通知
- スタイルの追加(これはすべき？)

]]></detail>
</VimperatorPlugin>;

liberator.plugins.pluginManager = (function(){

function id(value) value;
var lang = window.navigator.language;
var tags = { // {{{
    name: function(info) fromUTF8Octets(info.toString()),
    author: function(info){
        var name = fromUTF8Octets(info.toString());
        var xml = <>{name}</>;
        if (info.@mail.toString() != '')
            xml += <><span> </span>&lt;<a href={'mailto:'+name+' <'+info.@mail+'>'} highlight="URL">{info.@mail}</a>&gt;</>;
        if (info.@homepage.toString() != '')
            xml += <><span> </span>({makeLink(info.@homepage.toString())})</>;
        return xml;
    },
    description: function(info) makeLink(fromUTF8Octets(info.toString())),
    license: function(info){
        var xml = <>{fromUTF8Octets(info.toString())}</>;
        if (info.@document.toString() != '')
            xml += <><span> </span>{makeLink(info.@document.toString())}</>;
        return xml;
    },
    version: id,
    maxVersion: id,
    minVersion: id,
    updateURL: function(info) makeLink(info.toString(), true),
    detail: function(info){
        if (info.* && info.*[0] && info.*[0].nodeKind() == 'element')
            return info.*;

        var text = fromUTF8Octets(info.*.toString());
        var xml = WikiParser(text);
        return xml;
    }
}; // }}}

function chooseByLang(elems){
    if (!elems)
        return null;
    function get(lang){
        var i = elems.length();
        while (i-->0){
            if (elems[i].@lang.toString() == lang)
                return elems[i];
        }
    }
    return get(lang) || get(lang.split('-', 2).shift()) || get('') ||
           get('en-US') || get('en') || elems[0] || elems;
}
for (let it in Iterator(tags)){
    let [name, value] = it;
    tags[name] = function(info){
        if (!info[name])
            return null;
        return value.call(tags, chooseByLang(info[name]));
    };
}
function makeLink(str, withLink){
    var href = withLink ? '$&' : '#';
    return XMLList(str.replace(/(?:https?:\/\/|mailto:)\S+/g, '<a href="' + href + '" highlight="URL">$&</a>'));
}
function fromUTF8Octets(octets){
    return decodeURIComponent(octets.replace(/[%\x80-\xFF]/g, function(c){
        return '%' + c.charCodeAt(0).toString(16);
    }));
}
// --------------------------------------------------------
// Plugin
// -----------------------------------------------------{{{
var plugins = [];
function getPlugins(reload){
    if (plugins.length > 0 && !reload){
        return plugins;
    }
    plugins = [];
    var contexts = liberator.plugins.contexts;
    for (let path in contexts){
        let context = contexts[path];
        plugins.push(new Plugin(path, context));
    }
    return plugins;
}
function Plugin() { this.initialize.apply(this, arguments); }
Plugin.prototype = { // {{{
    initialize: function(path, context){
        this.path = path;
        this.name = context.NAME;
        this.info = context.PLUGIN_INFO || <></>;
        this.getItems();
    },
    getItems: function(){
        if (this.items) return this.items;
        this.items = {};
        for (let tag in tags){
            if (tag == "detail") continue;
            let xml = this.info[tag];
            let value = tags[tag](this.info);
            if (value && value.toString().length > 0)
                this.items[tag] = value;
        }
        return this.items;
    },
    getDetail: function(){
        if (this.detail)
            return this.detail;
        else if (!this.info || !this.info.detail)
            return null;

        return this.detail = tags['detail'](this.info);
    },
    itemFormatter: function(showDetail){
        let data = [
            ["path", this.path]
        ];
        let items = this.getItems();
        for (let name in items){
            data.push([name, items[name]]);
        }
        if (showDetail && this.getDetail())
            data.push(["detail", this.getDetail()]);

        return template.table(this.name, data);
    },
    checkVersion: function(){
        return this.updatePlugin(true);
    },
    updatePlugin: function(checkOnly){ //{{{
        var [localResource, serverResource, store] = this.getResourceInfo();
        var localDate = Date.parse(localResource['Last-Modified']) || 0;
        var serverDate = Date.parse(serverResource.headers['Last-Modified']) || 0;

        var data = {
            'Local Version': this.info.version || 'unknown',
            'Local Last-Modified': localResource['Last-Modified'] || 'unkonwn',
            'Local Path': this.path || 'unknown',
            'Server Latest Version': serverResource.version || 'unknown',
            'Server Last-Modified': serverResource.headers['Last-Modified'] || 'unknown',
            'Update URL': this.info.updateURL || '-'
        };

        if (checkOnly) return template.table(this.name, data);

        if (!this.info.version || !serverResource.version){
            data.Information = '<span style="font-weight: bold;">unknown version.</span>';
        } else if (this.info.version == serverResource.version &&
                   localResource['Last-Modified'] == serverResource.headers['Last-Modified']){
            data.Information = 'up to date.';
        } else if (this.compVersion(this.info.version, serverResource.version) > 0 ||
                   localDate > serverDate){
            data.information = '<span highlight="WarningMsg">local version is newest.</span>';
        } else {
            data.Information = this.overwritePlugin(serverResource);
            localResource = {}; // cleanup pref.
            localResource['Last-Modified'] = serverResource.headers['Last-Modified'];
            store.set(this.name, localResource);
            store.save();
        }
        return template.table(this.name, data);
    }, // }}}
    getResourceInfo: function(){
        var store = storage.newMap('plugins-pluginManager', true);
        var url = this.info.updateURL;
        var localResource = store.get(this.name) || {};
        var serverResource = {
                version: '',
                source: '',
                headers: {}
            };

        if (url && /^(http|ftp):\/\//.test(url)){
            let xhr = util.httpGet(url);
            let version = '';
            let source = xhr.responseText || '';
            let headers = {};
            try {
                xhr.getAllResponseHeaders().split(/\r?\n/).forEach(function(h){
                    var pair = h.split(': ');
                    if (pair && pair.length > 1) {
                        headers[pair.shift()] = pair.join('');
                    }
                });
            } catch(e){}
            let m = /\bPLUGIN_INFO[ \t\r\n]*=[ \t\r\n]*<VimperatorPlugin(?:[ \t\r\n][^>]*)?>([\s\S]+?)<\/VimperatorPlugin[ \t\r\n]*>/(source);
            if (m){
                m = m[1].replace(/(?:<!(?:\[CDATA\[(?:[^\]]|\](?!\]>))*\]\]|--(?:[^-]|-(?!-))*--)>)+/g, '');
                m = /^[\w\W]*?<version(?:[ \t\r\n][^>]*)?>([^<]+)<\/version[ \t\r\n]*>/(m);
                if (m){
                    version = m[1];
                }
            }
            serverResource = {version: version, source: source, headers: headers};
        }

        if (!localResource['Last-Modified']){
            localResource['Last-Modified'] = serverResource.headers['Last-Modified'];
            store.set(this.name, localResource);
        }
        return [localResource, serverResource, store];
    },
    overwritePlugin: function(serverResource){
        /*
        if (!plugin[0] || plugin[0][0] != 'path')
            return '<span highlight="WarningMsg">plugin localpath was not found.</span>';

        var localpath = plugin[0][1];
        */
        var source = serverResource.source;
        var file = io.getFile(this.path);

        if (!source)
            return '<span highlight="WarningMsg">source is null.</span>';

        try {
            io.writeFile(file, source);
        } catch (e){
            liberaotr.log('Could not write to ' + file.path + ': ' + e.message);
            return 'E190: Cannot open ' + filename.quote() + ' for writing';
        }

        try {
            io.source(this.path);
        } catch (e){
            return e.message;
        }

        return '<span style="font-weight: bold; color: blue;">update complete.</span>';
    },
    compVersion: function(a, b){
        const comparator = Cc["@mozilla.org/xpcom/version-comparator;1"].getService(Ci.nsIVersionComparator);
        return comparator.compare(a, b);
    }
}; // }}}
// }}}

// --------------------------------------------------------
// WikiParser
// -----------------------------------------------------{{{
var WikiParser = (function () {

  function cloneArray (ary)
    Array.concat(ary);

  function State (lines, result) {
    if (!(this instanceof arguments.callee))
        return new arguments.callee(lines, result);

    this.lines = lines;
    this.result = result || <></>;
  }
  State.prototype = {
    get end () !this.lines.length,
    get head () this.lines[0],
    set head (value) this.lines[0] = value,
    get clone () State(cloneArray(this.lines), this.result),
    get next () State(this.lines.slice(1), this.result),
    wrap: function (name) {
      let result = this.clone;
      result.result = <{name}>{this.result}</{name}>;
      return result;
    },
    set: function (v) {
      let result = this.clone;
      result.result = v instanceof State ? v.result : v;
      return result;
    },
  };

  function Error (name, state) {
    if (!(this instanceof arguments.callee))
        return new arguments.callee(name, state);

    this.__ok = false;
    this.name = name;
    this.state = state; //TODO clone
  }

  function ok (v)
    v instanceof State;

  function xmlJoin (xs, init) {
    let result = init || <></>;
    for (let i = 0, l = xs.length; i < l; i++)
      result += xs[i];
    return result;
  }

  function strip (s)
    s.replace(/^\s+|\s+$/g, '');

  // FIXME
  function link (s) {
    let m;
    let result = <></>;
    while (s && (m = s.match(/(?:https?:\/\/|mailto:)\S+/))) {
      result += <>{RegExp.leftContext || ''}<a href={m[0]}>{m[0]}</a></>;
      s = RegExp.rightContext;
    }
    if (s)
      result += <>{s}</>;
    return result;
  }

  function stripAndLink (s)
    link(strip(s));


  ////////////////////////////////////////////////////////////////////////////////

  // [Parser] -> OKError Parser
  function or () {
    let as = [];
    for (let i = 0, l = arguments.length; i < l; i++)
      as.push(arguments[i]);
    return function (st) {
      let a;
      for each (let a in as) {
        let r = a(st);
        if (ok(r))
          return r;
      }
      return Error('or-end', st);
    };
  }

  function map (p) {
    return function (st) {
      let result = [];
      let cnt = 0;
      while (!st.end) {
        st = p(st);
        if (ok(st))
          result.push(st.result);
        else
          break;
        if (cnt++ > 100) {
          liberator.log('100 break: map')
          break;
        }
      }
      return st.set(result);
    }
  }

  function whileMap (p) {
    return function (st) {
      let result = [];
      let next;
      let cnt = 0;
      while (!st.end) {
        next = p(st);
        if (ok(next))
          result.push(next.result);
        else
          break;
        st = next;
        if (cnt++ > 100) {
          liberator.log('100 break: whileMap')
          break;
        }
      }
      if (result.length)
        return st.set(result);
      else
        return Error('whileMap', st);
    }
  }

  function lv_map (lv, more, p) {
    let re = RegExp('^' + lv.replace(/[^\s]/g, ' ') + (more ? '\\s+' : '') + '(.*)$');
    return function (st) {
      let result = [];
      let cnt = 0;
      while (!st.end) {
        if (!re.test(st.head))
          break;
        st = p(st);
        if (!ok(st))
          return st;
        result.push(st.result);
        if (cnt++ > 100) {
          liberator.log('100 break')
          break;
        }
      }
      return st.set(result);
    };
  }


  ////////////////////////////////////////////////////////////////////////////////

  function wiki (st) {
    let r = wikiLines(st);
    if (ok(r)) {
      let xs = r.result;
      return r.set(xmlJoin(xs)).wrap('div');
    } else {
      return Error('wiki', st);
    }
  }

  // St -> St XML
  function plain (st) {
    let text = st.head;
    return st.next.set(<>{stripAndLink(text)}<br /></>);
  }

  // St -> St XML
  function hn (n) {
    let re = RegExp('^\\s*=={' + n + '}\\s+(.*)\\s*=={' + n + '}\\s*$');
    return function (st) {
      let m = st.head.match(re);
      if (m) {
        let hn = 'h' + n;
        return st.next.set(<{hn} style={'font-size:'+(0.75+1/n)+'em'}>{stripAndLink(m[1])}</{hn}>)
      } else {
        return Error('not head1', st);
      }
    };
  }

  let h1 = hn(1);
  let h2 = hn(2);
  let h3 = hn(3);
  let h4 = hn(4);

  // St -> St XML
  function dl (st) {
    let r = whileMap(dtdd)(st);
    if (ok(r)) {
      let body = xmlJoin(r.result);
      return r.set(body).wrap('dl');
    } else {
      return Error('dl', st);
    }
  }

  // St -> St XML
  function dtdd (st) {
    let r = dt(st);
    if (ok(r)) {
      let [lv, _dt] = r.result;
      let _dd = lv_dd(lv, wikiLine)(r);
      return _dd.set(_dt + <dd>{xmlJoin(_dd.result)}</dd>);
    } else {
      return r;
    }
  }

  // St -> St (lv, XML)
  function dt (st) {
    let m = st.head.match(/^(\s*)(.+):\s*$/);
    if (m) {
      return st.next.set([m[1], <dt style="font-weight:bold;">{m[2]}</dt>]);
    } else {
      return Error('not dt', st);
    }
  }

  // lv -> (St -> St [XML])
  function lv_dd (lv) {
    return lv_map(lv, true, wikiLine);
  }

  // St -> St XML
  function ul (st) {
    let lis = whileMap(li)(st);
    if (ok(lis)) {
      return lis.set(xmlJoin(lis.result)).wrap('ul');
    } else {
      return Error('ul', st);
    }
  }

  // St -> St XML
  function li (st) {
    let m = st.head.match(/^(\s*- )(.*)$/);
    if (m) {
      st.head = st.head.replace(/- /, '  ');
      let r = lv_map(m[1], false, wikiLine)(st);
      return r.set(xmlJoin(r.result)).wrap('li');
    } else {
      return Error('li', st);
    }
  }

  // St -> St XML
  function ol (st) {
    let lis = whileMap(oli)(st);
    if (ok(lis)) {
      return lis.set(xmlJoin(lis.result)).wrap('ol');
    } else {
      return Error('ol', st);
    }
  }

  // St -> St XML
  function oli (st) {
    let m = st.head.match(/^(\s*\+ )(.*)$/);
    if (m) {
      st.head = st.head.replace(/\+ /, '  ');
      let r = lv_map(m[1], false, wikiLine)(st);
      return r.set(xmlJoin(r.result)).wrap('li');
    } else {
      return Error('li', st);
    }
  }

  // St -> St XML
  function pre (st) {
    let m = st.head.match(/^(\s*)>\|\|\s*$/);
    if (m) {
      let result = '';
      let cnt = 0;
      while (!st.end) {
        st = st.next;
        if (/^(\s*)\|\|<\s*$/.test(st.head)){
          st = st.next;
          break;
        }
        result += st.head.replace(m[1], '') + '\n';
        if (cnt++ > 100) {
          liberator.log('br')
          break;
        }
      }
      return st.set(<pre>{result}</pre>);
    } else {
      return Error('pre', st);
    }
  }

  // St -> St XML
  let wikiLine = or(h1, h2, h3, h4, dl, ul, ol, pre, plain);

  // St -> St [XML]
  let wikiLines = map(wikiLine);

  return liberator.plugins.PMWikiParser = function (src) {
    let r = wiki(State(src.split(/\n/)));
    if (ok(r))
      return r.result;
    else
      liberator.echoerr(r.name);
  };

})();
// End WikiParser }}}

// --------------------------------------------------------
// HTML Stack
// -----------------------------------------------------{{{
function HTMLStack(){
    this.stack = [];
}
HTMLStack.prototype = { // {{{
    get length() this.stack.length,
    get last() this.stack[this.length-1],
    get lastLocalName() this.last[this.last.length()-1].localName(),
    get inlineElements() 'a abbr acronym b basefont bdo big br button cite code dfn em font i iframe img inout kbd label map object q s samp script select small span strike strong sub sup textarea tt u var'.split(' '),
    isInline: function(xml)
        xml.length() > 1 || xml.nodeKind() == 'text' || this.inlineElements.indexOf(xml.localName()) >= 0,
    push: function(xml) this.stack.push(xml),
    append: function(xml){
        if (this.length == 0){
            this.push(xml);
            return xml;
        }
        var buf = this.last[this.last.length()-1];
        if (buf.nodeKind() == 'text'){
            this.last[this.last.length()-1] += this.isInline(xml) ? <><br/>{xml}</> : xml;
        } else if (this.isInline(xml)){
            this.stack[this.length-1] += xml;
        } else if (buf.localName() == xml.localName()){
            buf.* += xml.*;
        } else {
            this.stack[this.length-1] += xml;
        }
        return this.last;
    },
    appendChild: function(xml){
        if (this.length == 0){
            this.push(xml);
            return xml;
        }
        var buf = this.stack[this.length-1];
        if (buf[buf.length()-1].localName() == xml.localName()){
            if (this.isInline(xml.*[0]))
                buf[buf.length()-1].* += <br/> + xml.*;
            else
                buf[buf.length()-1].* += xml.*;
        } else
            this.stack[this.length-1] += xml;

        return this.last;
    },
    appendLastChild: function(xml){
        var buf = this.last[this.last.length()-1].*;
        if (buf.length() > 0 && buf[buf.length()-1].nodeKind() == 'element'){
            let tmp = buf[buf.length()-1].*;
            if (tmp[tmp.length()-1].nodeKind() == 'element'){
                buf[buf.length()-1].* += xml;
            } else {
                buf[buf.length()-1].* += <><br/>{xml}</>;
            }
        } else {
            this.last[this.last.length()-1].* += xml;
        }
        return this.last;
    },
    reorg: function(from){
        if (this.length == 0) return;
        if (!from) from = 0;
        var xmllist = this.stack.splice(from);
        var xml;
        if (xmllist.length > 1){
            xml = xmllist.reduceRight(function(p, c){
                let buf = c[c.length()-1].*;
                if (buf.length() > 0){
                    if (buf[buf.length()-1].nodeKind() == 'text'){
                        c += p;
                    } else {
                        buf[buf.length()-1].* += p;
                    }
                } else {
                    c += p;
                }
                return c;
            });
        } else if (xmllist.length > 0){
            xml = xmllist[0];
        }
        this.push(xml);
        return this.last;
    }
}; // }}}
// }}}

// --------------------------------------------------------
// Vimperator Command
// -----------------------------------------------------{{{
commands.addUserCommand(['plugin[help]'], 'list Vimperator plugins',
    function(args){
        var xml;
        if (args["-check"])
            xml = liberator.plugins.pluginManager.checkVersion(args);
        else if (args["-update"])
            xml = liberator.plugins.pluginManager.update(args);
        else if (args["-source"]) {
            if (args.length < 1)
                return liberator.echoerr('Argument(plugin name) required');
            return liberator.plugins.pluginManager.source(args);
        } else
            xml = liberator.plugins.pluginManager.list(args, args["-verbose"]);

        liberator.echo(xml, true);
    }, {
        argCount: '*',
        options: [
            [['-verbose', '-v'], commands.OPTION_NOARG],
            [['-check', '-c'], commands.OPTION_NOARG],
            [['-update', '-u'], commands.OPTION_NOARG],
            [['-source', '-s'], commands.OPTION_NOARG],
        ],
        completer: function(context){
            context.title = ['PluginName', '[Version]Description'];
            context.completions = getPlugins().map(function(plugin) [
                plugin.name,
                '[' + (plugin.items.version || 'unknown') + ']' +
                (plugin.items.description || '-')
            ]).filter(function(row)
                row[0].toLowerCase().indexOf(context.filter.toLowerCase()) >= 0);
        }
    }, true); // }}}

// --------------------------------------------------------
// Public Member (liberator.plugins.pluginManger)
// -----------------------------------------------------{{{
var public = {
    getPlugins: function(names, forceReload){
        let plugins = getPlugins(forceReload);
        if (!names || names.length == 0)
            return plugins;

        return plugins.filter(function(plugin) names.indexOf(plugin.name) >= 0);
    },
    checkVersion: function(names){
        let xml = <></>;
        this.getPlugins(names).forEach(function(plugin){
            xml += plugin.checkVersion();
        });
        return xml;
    },
    update: function(names){
        let xml = <></>;
        this.getPlugins(names).forEach(function(plugin){
            xml += plugin.updatePlugin();
        });
        return xml;
    },
    source: function(names){
        // XXX 一度に開くようにするべき？ (ref: editor.js L849)
        this.getPlugins(names).forEach(function(plugin){
            editor.editFileExternally(plugin.path);
        });
        return;
    },
    list: function(names, verbose){
        let xml = <></>
        this.getPlugins(names).forEach(function(plugin){
            xml += plugin.itemFormatter(verbose);
        });
        return xml;
    }
};
return public;
// }}}
})();
// vim: sw=4 ts=4 et fdm=marker:

