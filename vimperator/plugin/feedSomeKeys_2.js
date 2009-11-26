let INFO =
<plugin name="feedSomeKeys" version="2.2.3"
        href="http://svn.coderepos.org/share/lang/javascript/vimperator-plugins/trunk/feedSomeKeys_2.js"
        summary="Feed some defined key events into the Web content"
        xmlns="http://vimperator.org/namespaces/liberator">
    <author email="teramako@gmail.com">teramako</author>
    <license href="http://www.mozilla.org/MPL/MPL-1.1.html">MPL 1.1</license>
    <project name="Vimperator" minVersion="2.3"/>
    <p>
        keyイベントをWebコンテンツ側へ送る事を可能にするプラグイン。
        GmailやGreasemonkeyでキーを割り当てている場合に活躍するでしょう。
    </p>
    <item>
        <tags>:fmap :feedmap</tags>
        <spec>:f<oa>eed</oa>map <oa>-depath=<a>frameNumber</a></oa> <oa>-vkey</oa> <oa>-event=<a>eventName</a></oa> <oa>lhs<oa>,<oa>frameNumber</oa>rhs</oa></oa></spec>
        <description>
            <p>
                Feed to the Web contents <oa>lhs</oa>.
                If specified <oa>rhs</oa>, feed <oa>rhs</oa> key events when hit <oa>lhs</oa>.
            </p>
            <p>The following options are interpreted.</p>
            <dl>
                <dt>-v<oa>key</oa></dt>
                <dd>仮想キーコードでイベントを送る</dd>
                <dt>-e<oa>vent</oa></dt>
                <dd>
                    以下の<oa>eventName</oa>が設定可能
                    <ul>
                        <li>keypress (default)</li>
                        <li>keydown</li>
                        <li>keyup</li>
                    </ul>
                </dd>
            </dl>
        </description>
    </item>
    <item>
        <tags>:fmapc :feedmapclear</tags>
        <spec>:fmapc</spec>
        <spec>:feedmapclear</spec>
        <description>
            <p>clear fmap entries</p>
        </description>
    </item>
    <h3 tag="combine-fmap-with-autocmd">Combine fmap with autocmd</h3>
    <code><ex>
:autocmd LocationChange .* fmapc
:autocmd LocationChange 'example\.com' fmap a b c
    </ex></code>
    <h3 tag="fmap-examples">fmap examples</h3>
    <p>
        At first, you need to write following code
        <code>:autocmd LocationChange .* :fmapc</code>
    </p>
    <h4 tag="fmap-example-gmail">Gmail</h4>
    <code>
:autocmd LocationChange 'mail\.google\.com/mail' :fmap c / j k n p o u e x s r a # [ ] z ? gi gs gt gd ga gc
    </code>
    <h4 tag="fmap-example-ldr">Livedoor Reader</h4>
    <code>
:autocmd LocationChange 'reader\.livedoor\.com/reader' :fmap j k s a p o v c &lt;Space> &lt;S-Space> z b &lt; >
    </code>
    <h4 tag="fmap-example-googlereader">Google Reader</h4>
    <code>
:autocmd LocationChange 'www\.google\.co\.jp/reader' :fmap! -vkey j k n p m s t v A r S N P X O gh ga gs gt gu u / ?
    </code>
    <h4 tag="fmap-example-googlecalendar">Google Calendar</h4>
    <code>
:autocmd LocationChange 'www\.google\.com/calendar/' :fmap! -vkey -event keydown t a d w m x c e &lt;Del> / + q s ?
    </code>
</plugin>
var PLUGIN_INFO=
<VimperatorPlugin>
<name>{NAME}</name>
<description>feed some defined key events into the Web content</description>
<version>2.2.3</version>
<author mail="teramako@gmail.com" homepage="http://vimperator.g.hatena.ne.jp/teramako/">teramako</author>
<minVersion>2.3</minVersion>
<updateURL>http://svn.coderepos.org/share/lang/javascript/vimperator-plugins/trunk/feedSomeKeys_2.js</updateURL>
</VimperatorPlugin>;

liberator.plugins.feedKey = (function(){
var origMaps = [];
var feedMaps = [];

// keyTableの再定義...ひどく不毛...
const keyTable = [
    [ KeyEvent.DOM_VK_BACK_SPACE, ["BS"] ],
    [ KeyEvent.DOM_VK_TAB, ["Tab"] ],
    [ KeyEvent.DOM_VK_RETURN, ["Return", "CR", "Enter"] ],
    //[ KeyEvent.DOM_VK_ENTER, ["Enter"] ],
    [ KeyEvent.DOM_VK_ESCAPE, ["Esc", "Escape"] ],
    [ KeyEvent.DOM_VK_SPACE, ["Spc", "Space"] ],
    [ KeyEvent.DOM_VK_PAGE_UP, ["PageUp"] ],
    [ KeyEvent.DOM_VK_PAGE_DOWN, ["PageDown"] ],
    [ KeyEvent.DOM_VK_END, ["End"] ],
    [ KeyEvent.DOM_VK_HOME, ["Home"] ],
    [ KeyEvent.DOM_VK_LEFT, ["Left"] ],
    [ KeyEvent.DOM_VK_UP, ["Up"] ],
    [ KeyEvent.DOM_VK_RIGHT, ["Right"] ],
    [ KeyEvent.DOM_VK_DOWN, ["Down"] ],
    [ KeyEvent.DOM_VK_INSERT, ["Ins", "Insert"] ],
    [ KeyEvent.DOM_VK_DELETE, ["Del", "Delete"] ],
    [ KeyEvent.DOM_VK_F1, ["F1"] ],
    [ KeyEvent.DOM_VK_F2, ["F2"] ],
    [ KeyEvent.DOM_VK_F3, ["F3"] ],
    [ KeyEvent.DOM_VK_F4, ["F4"] ],
    [ KeyEvent.DOM_VK_F5, ["F5"] ],
    [ KeyEvent.DOM_VK_F6, ["F6"] ],
    [ KeyEvent.DOM_VK_F7, ["F7"] ],
    [ KeyEvent.DOM_VK_F8, ["F8"] ],
    [ KeyEvent.DOM_VK_F9, ["F9"] ],
    [ KeyEvent.DOM_VK_F10, ["F10"] ],
    [ KeyEvent.DOM_VK_F11, ["F11"] ],
    [ KeyEvent.DOM_VK_F12, ["F12"] ],
    [ KeyEvent.DOM_VK_F13, ["F13"] ],
    [ KeyEvent.DOM_VK_F14, ["F14"] ],
    [ KeyEvent.DOM_VK_F15, ["F15"] ],
    [ KeyEvent.DOM_VK_F16, ["F16"] ],
    [ KeyEvent.DOM_VK_F17, ["F17"] ],
    [ KeyEvent.DOM_VK_F18, ["F18"] ],
    [ KeyEvent.DOM_VK_F19, ["F19"] ],
    [ KeyEvent.DOM_VK_F20, ["F20"] ],
    [ KeyEvent.DOM_VK_F21, ["F21"] ],
    [ KeyEvent.DOM_VK_F22, ["F22"] ],
    [ KeyEvent.DOM_VK_F23, ["F23"] ],
    [ KeyEvent.DOM_VK_F24, ["F24"] ],
];
const vkeyTable = [
    [ KeyEvent.DOM_VK_0, ['0'] ],
    [ KeyEvent.DOM_VK_1, ['1'] ],
    [ KeyEvent.DOM_VK_2, ['2'] ],
    [ KeyEvent.DOM_VK_3, ['3'] ],
    [ KeyEvent.DOM_VK_4, ['4'] ],
    [ KeyEvent.DOM_VK_5, ['5'] ],
    [ KeyEvent.DOM_VK_6, ['6'] ],
    [ KeyEvent.DOM_VK_7, ['7'] ],
    [ KeyEvent.DOM_VK_8, ['8'] ],
    [ KeyEvent.DOM_VK_9, ['9'] ],
    [ KeyEvent.DOM_VK_SEMICOLON, [';'] ],
    [ KeyEvent.DOM_VK_EQUALS, ['='] ],
    [ KeyEvent.DOM_VK_A, ['a'] ],
    [ KeyEvent.DOM_VK_B, ['b'] ],
    [ KeyEvent.DOM_VK_C, ['c'] ],
    [ KeyEvent.DOM_VK_D, ['d'] ],
    [ KeyEvent.DOM_VK_E, ['e'] ],
    [ KeyEvent.DOM_VK_F, ['f'] ],
    [ KeyEvent.DOM_VK_G, ['g'] ],
    [ KeyEvent.DOM_VK_H, ['h'] ],
    [ KeyEvent.DOM_VK_I, ['i'] ],
    [ KeyEvent.DOM_VK_J, ['j'] ],
    [ KeyEvent.DOM_VK_K, ['k'] ],
    [ KeyEvent.DOM_VK_L, ['l'] ],
    [ KeyEvent.DOM_VK_M, ['m'] ],
    [ KeyEvent.DOM_VK_N, ['n'] ],
    [ KeyEvent.DOM_VK_O, ['o'] ],
    [ KeyEvent.DOM_VK_P, ['p'] ],
    [ KeyEvent.DOM_VK_Q, ['q'] ],
    [ KeyEvent.DOM_VK_R, ['r'] ],
    [ KeyEvent.DOM_VK_S, ['s'] ],
    [ KeyEvent.DOM_VK_T, ['t'] ],
    [ KeyEvent.DOM_VK_U, ['u'] ],
    [ KeyEvent.DOM_VK_V, ['v'] ],
    [ KeyEvent.DOM_VK_W, ['w'] ],
    [ KeyEvent.DOM_VK_X, ['x'] ],
    [ KeyEvent.DOM_VK_Y, ['y'] ],
    [ KeyEvent.DOM_VK_Z, ['z'] ],
    [ KeyEvent.DOM_VK_MULTIPLY, ['*'] ],
    [ KeyEvent.DOM_VK_ADD, ['+'] ],
    [ KeyEvent.DOM_VK_SUBTRACT, ['-'] ],
    [ KeyEvent.DOM_VK_COMMA, [','] ],
    [ KeyEvent.DOM_VK_PERIOD, ['.'] ],
    [ KeyEvent.DOM_VK_SLASH, ['/', '?'] ],
    [ KeyEvent.DOM_VK_BACK_QUOTE, ['`'] ],
    [ KeyEvent.DOM_VK_OPEN_BRACKET, ['{'] ],
    [ KeyEvent.DOM_VK_BACK_SLASH, ['\\'] ],
    [ KeyEvent.DOM_VK_CLOSE_BRACKET, ['}'] ],
    [ KeyEvent.DOM_VK_QUOTE, ["'"] ],
];

function getKeyCode(str, vkey) {
    str = str.toLowerCase();
    var ret = 0;
    (vkey ? vkeyTable : keyTable).some(function(i) i[1].some(function(k) k.toLowerCase() == str && (ret = i[0])));
    return ret;
}
function init(keys, useVkey){
    destroy();
    keys.forEach(function(key){
        var origKey, feedKey;
        if (key instanceof Array){
            [origKey, feedKey] = key;
        } else if (typeof(key) == 'string'){
            [origKey, feedKey] = [key,key];
        }
        replaceUserMap(origKey, feedKey, useVkey);
    });
}
function replaceUserMap(origKey, feedKey, useVkey, eventName){
    if (mappings.hasMap(modes.NORMAL, origKey)){
        var origMap = mappings.get(modes.NORMAL,origKey);
        if (origMap.description.indexOf(origKey+' -> ') != 0) {
            // origMapをそのままpushするとオブジェクト内の参照先を消されてしまう
            // 仕方なく複製を試みる
            var clone = new Map(origMap.modes.map(function(m) m),
                                origMap.names.map(function(n) n),
                                origMap.description,
                                origMap.action,
                                {
                                    flags:origMap.flags,
                                    rhs:origMap.rhs,
                                    noremap:origMap.noremap,
                                    count: origMap.cout,
                                    arg: origMap.arg,
                                    motion: origMap.motion
                                });
            origMaps.push(clone);
        }
    }
    var map = new Map([modes.NORMAL], [origKey], origKey + ' -> ' + feedKey,
        function(count){
            count = count > 1 ? count : 1;
            for (var i=0; i<count; i++){
                feedKeyIntoContent(feedKey, useVkey, eventName);
            }
        }, { flags:(Mappings.flags ? Mappings.flags.COUNT : null), rhs:feedKey, noremap:true, count:true });
    addUserMap(map);
    if (feedMaps.some(function(fmap){
        if (fmap.names[0] != origKey) return false;
        for (var key in fmap) fmap[key] = map[key];
        return true;
    })) return;
    feedMaps.push(map);
}
function destroy(){
    try{
        feedMaps.forEach(function(map){
            mappings.remove(map.modes[0],map.names[0]);
        });
    }catch(e){ liberator.log(map); }
    origMaps.forEach(function(map){
        addUserMap(map);
    });
    origMaps = [];
    feedMaps = [];
}
function addUserMap(map){
    mappings.addUserMap(map.modes, map.names, map.description, map.action, {
        flags:map.flags,noremap:map.noremap,rhs:map.rhs,count:map.count,arg:map.arg,motion:map.motion
    });
}
function parseKeys(keys){
    var matches = /^\d+(?=\D)/.exec(keys);
    if (matches){
        var num = parseInt(matches[0],10);
        if (!isNaN(num)) return [keys.substr(matches[0].length), num];
    }
    return [keys, 0];
}
function getDestinationElement(frameNum){
    var root = document.commandDispatcher.focusedWindow;
    if (frameNum > 0){
        var frames = [];
        (function(frame){// @see liberator.buffer.shiftFrameFocus
            if (frame.document.body.localName.toLowerCase() == 'body') {
                frames.push(frame);
            }
            for (var i=0; i<frame.frames.length; i++){
                arguments.callee(frame.frames[i]);
            }
        })(window.content);
        frames = frames.filter(function(frame){
            frame.focus();
            if (document.commandDispatcher.focusedWindow == frame) return frame;
        });
        if (frames[frameNum]) return frames[frameNum];
    }
    return root;
}
function feedKeyIntoContent(keys, useVkey, eventName){
    var frameNum = 0;
    [keys, frameNum] = parseKeys(keys);
    var destElem = getDestinationElement(frameNum);
    destElem.focus();
    modes.passAllKeys = true;
    modes.passNextKey = false;
    for (var i=0; i<keys.length; i++){
        var keyCode;
        var shift = false, ctrl = false, alt = false, meta = false;
        if (useVkey && (keyCode = getKeyCode(keys[i], true))) {
            var charCode = 0;
        } else {
            var charCode = keys.charCodeAt(i);
            keyCode = 0;
        }
        if (keys[i] == '<'){
            var matches = keys.substr(i + 1).match(/^((?:[ACMSacms]-)*)([^>]+)/);
            if (matches) {
                if (matches[1]) {
                    ctrl  = /[cC]-/.test(matches[1]);
                    alt   = /[aA]-/.test(matches[1]);
                    shift = /[sS]-/.test(matches[1]);
                    meta  = /[mM]-/.test(matches[1]);
                }
                if (matches[2].length == 1) {
                    if (!ctrl && !alt && !shift && !meta) return false;
                    if (useVkey && (keyCode = getKeyCode(matches[2], true))) {
                        charCode = 0;
                    } else {
                        charCode = matches[2].charCodeAt(0);
                    }
                } else if (matches[2].toLowerCase() == "space") {
                    if (useVkey) {
                        charCode = 0;
                        keyCode = KeyEvent.DOM_VK_SPACE;
                    } else {
                        charCode = KeyEvent.DOM_VK_SPACE;
                    }
                } else if (keyCode = getKeyCode(matches[2])) {
                    charCode = 0;
                } else  {
                    return false;
                }
                i += matches[0].length + 1;
            }
        } else  {
            shift = (keys[i] >= "A" && keys[i] <= "Z") || keys[i] == "?";
        }

        //liberator.log({ctrl:ctrl, alt:alt, shift:shift, meta:meta, keyCode:keyCode, charCode:charCode, useVkey: useVkey});
        var evt = content.document.createEvent('KeyEvents');
        evt.initKeyEvent(eventName, true, true, content, ctrl, alt, shift, meta, keyCode, charCode);
        if (destElem.document.body)
            destElem.document.body.dispatchEvent(evt);
        else
            destElem.document.dispatchEvent(evt);
    }
    modes.passAllKeys = false;
}

// --------------------------
// Command
// --------------------------
commands.addUserCommand(['feedmap','fmap'],'Feed Map a key sequence',
    function(args){
        if(!args.string){
            liberator.echo(template.table("feedmap list",feedMaps.map(function(map) [map.names[0], map.rhs])), true);
            return;
        }
        if (args.bang) destroy();
        var depth = args["-depth"] ? args["-depth"] : "";
        var useVkey = "-vkey" in args;
        var eventName = args["-event"] ? args["-event"] : "keypress";

        args.forEach(function(keypair){
            var [lhs, rhs] = keypair.split(",");
            if (!rhs) rhs = lhs;
            replaceUserMap(lhs, depth + rhs, useVkey, eventName);
        });
    },{
        bang: true,
        argCount: "*",
        options: [
            [["-depth","-d"], commands.OPTION_INT],
            [["-vkey","-v"], commands.OPTION_NOARG],
            [["-event", "-e"], commands.OPTION_STRING, null, [["keypress","-"],["keydown","-"],["keyup","-"]]]
        ]
    }
);
commands.addUserCommand(['feedmapclear','fmapc'],'Clear Feed Maps',destroy);
var converter = {
    get origMap() origMaps,
    get feedMap() feedMaps,
    setup: init,
    reset: destroy
};
return converter;
})();
// vim: fdm=marker sw=4 ts=4 et:
