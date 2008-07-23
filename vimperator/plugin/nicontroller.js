/*
 * ==VimperatorPlugin==
 * @name            nicontroller.js
 * @description     this script give you keyboard opration for nicovideo.jp.
 * @description-ja  ニコニコ動画のプレーヤーをキーボードで操作できるようにする。
 * @author          janus_wel <janus_wel@fb3.so-net.ne.jp>
 * @version         0.30
 * @minversion      1.1
 * ==VimperatorPlugin==
 *
 * LICENSE
 *   New BSD License
 *
 * USAGE
 *   :nicoinfo
 *     プレーヤーに関しての情報を表示する。今のところバージョンだけ。
 *   :nicopause
 *     再生 / 一時停止を切り替える。
 *   :nicomute
 *     音声あり / なしを切り替える。
 *   :nicommentvisible
 *     コメント表示 / 非表示を切り替える。
 *   :nicorepeat
 *     リピート再生するかどうかを切り替える。
 *   :nicosize
 *     最大化 / ノーマルを切り替える。
 *   :nicoseek [position]
 *     指定した場所にシークする。秒数で指定が可能。
 *     指定なしの場合一番最初にシークする。
 *   :nicoseek! delta
 *     現在の位置から delta 分離れた所にシークする。秒数で指定が可能。
 *     マイナスを指定すると戻る。指定なしの場合変化しない。
 *   :nicovolume [volume]
 *     ボリュームを設定する。 0 ～ 100 が指定できる。
 *     指定なしの場合 100 にセットする。
 *   :nicovolume! delta
 *     ボリュームを現在の値から変更する。 -100 ～ +100 を指定可能。
 *     指定なしの場合変化しない。
 *   :nicomment comment
 *     コメント欄を指定した文字列で埋める。
 *   :nicommand command
 *     コマンド欄を指定した文字列で埋める。
 *
 * HISTORY
 *   2008/07/13 v0.10 initial written.
 *   2008/07/14 v0.20 add nicosize, nicoseek, nicovolume
 *   2008/07/15 v0.30 add nicoinfo
 *
 * */
/*
_vimperatorrc に以下のスクリプトを貼り付けると幸せになれるかも
コマンド ( [',n-'] や [',n+'] の部分 ) は適宜変えてね。

javascript <<EOM

// [N],n-
// N 秒前にシークする。
// 指定なしの場合 10 秒前。
liberator.mappings.addUserMap(
    [liberator.modes.NORMAL],
    [',n-'],
    'seek by count backward',
    function(count) {
        if(count === -1) count = 10;
        liberator.execute(':nicoseek! ' + '-' + count);
    },
    { flags: liberator.Mappings.flags.COUNT }
);

// [N],n+
// N 秒後にシークする。
// 指定なしの場合 10 秒後。
liberator.mappings.addUserMap(
    [liberator.modes.NORMAL],
    [',n+'],
    'seek by count forward',
    function(count) {
        if(count === -1) count = 10;
        liberator.execute(':nicoseek! ' + count);
    },
    { flags: liberator.Mappings.flags.COUNT }
);

EOM

*/
(function(){

// NicoPlayerController Class
function NicoPlayerController(){}
NicoPlayerController.prototype = {
    constants: {
        VERSION:    '0.30',
        WATCH_URL:  '^http://www\.nicovideo\.jp/watch/[a-z][a-z]\\d+$',
        TAG_URL:    '^http://www\.nicovideo\.jp/tag/',
        WATCH_PAGE: 1,
        TAG_PAGE:   2,
    },

    version: function(){ return this.constants.VERSION; },

    pagecheck: function() {
        if(this.getURL().match(this.constants.WATCH_URL)) return this.constants.WATCH_PAGE;
        if(this.getURL().match(this.constants.TAG_URL))   return this.constants.TAG_PAGE;
        throw 'current tab is not nicovideo.jp';
    },

    getURL: function() {
        return liberator.buffer.URL;
    },

    _flvplayer: function() {
        if(this.pagecheck()) {
            var flvplayer = window.content.document.getElementById('flvplayer');
            if(! flvplayer) throw 'flvplayer is not found';

            return flvplayer.wrappedJSObject ? flvplayer.wrappedJSObject : flvplayer ? flvplayer : null;
        }
        return null;
    },

    togglePlay: function() {
        var p = this._flvplayer();
        (p.ext_getStatus() === 'paused') ? p.ext_play(true) : p.ext_play(false);
    },

    toggleMute: function() {
        var p = this._flvplayer();
        p.ext_setMute(! p.ext_isMute());
    },

    toggleCommentVisible: function() {
        var p = this._flvplayer();
        p.ext_setCommentVisible(! p.ext_isCommentVisible());
    },

    toggleRepeat: function() {
        var p = this._flvplayer();
        p.ext_setRepeat(! p.ext_isRepeat());
    },

    toggleSize: function() {
        var p = this._flvplayer();
        (p.ext_getVideoSize() === 'normal') ? p.ext_setVideoSize('fit') : p.ext_setVideoSize('normal');
    },

    seekTo: function(position) {
        if(position) {
            if(isNaN(position)) throw 'assign unsigned number : seekTo()';
        }
        else position = 0;

        var p = this._flvplayer();
        p.ext_setPlayheadTime(position);
    },

    seekBy: function(delta) {
        if(delta) {
            if(isNaN(delta)) throw 'assign number : seekBy()';
        }
        else delta = 0;

        var p = this._flvplayer();
        var position = p.ext_getPlayheadTime();
        position += parseInt(delta, 10);
        
        p.ext_setPlayheadTime(position);
    },

    volumeTo: function(volume) {
        if(volume) {
            if(isNaN(volume)) throw 'assign unsigned number : seekTo()';
        }
        else volume = 100;

        var p = this._flvplayer();
        p.ext_setVolume(volume);
    },

    volumeBy: function(delta) {
        if(delta) {
            if(isNaN(delta)) throw 'assign number : seekBy()';
        }
        else delta = 0;

        var p = this._flvplayer();
        var volume = p.ext_getVolume();
        volume += parseInt(delta, 10);
        
        p.ext_setVolume(volume);
    },

    getValue: function(name) {
        return this._flvplayer().GetVariable(name);
    },

    setValue: function(name, value) {
        return this._flvplayer().SetVariable(name, value);
    },
};

var controller = new NicoPlayerController();

liberator.commands.addUserCommand(
    ['nicoinfo'],
    'display player information',
    function() {
        try {
            var info = [
                'player version : ' + controller.getValue('PLAYER_VERSION'),
                'script version : ' + controller.version(),
            ].join("\n");
            liberator.echo(info, liberator.commandline.FORCE_MULTILINE);
        }
        catch(e) {
            liberator.echoerr(e);
        }
    },
    {}
);

liberator.commands.addUserCommand(
    ['nicopause'],
    'toggle play / pause',
    function() {
        try      { controller.togglePlay(); }
        catch(e) { liberator.echoerr(e); }
    },
    {}
);

liberator.commands.addUserCommand(
    ['nicomute'],
    'toggle mute',
    function() {
        try      { controller.toggleMute(); }
        catch(e) { liberator.echoerr(e); }
    },
    {}
);

liberator.commands.addUserCommand(
    ['nicommentvisible'],
    'toggle comment visible',
    function() {
        try      { controller.toggleCommentVisible(); }
        catch(e) { liberator.echoerr(e); }
    },
    {}
);

liberator.commands.addUserCommand(
    ['nicorepeat'],
    'toggle repeat',
    function() {
        try      { controller.toggleRepeat(); }
        catch(e) { liberator.echoerr(e); }
    },
    {}
);

liberator.commands.addUserCommand(
    ['nicoseek'],
    'controll seek bar',
    function(arg, special) {
        try      { special ? controller.seekBy(arg) : controller.seekTo(arg); }
        catch(e) { liberator.echoerr(e); }
    },
    {}
);

liberator.commands.addUserCommand(
    ['nicovolume'],
    'controll volume',
    function(arg, special) {
        try      { special ? controller.volumeBy(arg) : controller.volumeTo(arg); }
        catch(e) { liberator.echoerr(e); }
    },
    {}
);

liberator.commands.addUserCommand(
    ['nicosize'],
    'toggle video size',
    function() {
        try      { controller.toggleSize(); }
        catch(e) { liberator.echoerr(e); }
    },
    {}
);

liberator.commands.addUserCommand(
    ['nicomment'],
    'fill comment box',
    function(arg) {
        try      { controller.setValue('ChatInput.text', arg); }
        catch(e) { liberator.echoerr(e); }
    },
    {}
);

liberator.commands.addUserCommand(
    ['nicommand'],
    'fill command box',
    function(arg) {
        try      { controller.setValue('inputArea.MailInput.text', arg); }
        catch(e) { liberator.echoerr(e); }
    },
    {
        completer: function(filter){
            var templates = [];
            const commands = [
                ['naka',      'normal comment (flow right to left)'],
                ['ue',        'fix comment to vertical top and horizonal center of the screen'],
                ['shita',     'fix comment to vertical bottom and horizonal center of the screen'],
                ['medium',    'normal size comment'],
                ['big',       'big size comment'],
                ['small',     'small size comment'],
                ['white',     'white color comment'],
                ['red',       'red color comment'],
                ['pink',      'pink color comment'],
                ['orange',    'orange color comment'],
                ['yellow',    'yellow color comment'],
                ['green',     'green color comment'],
                ['cyan',      'cyan color comment'],
                ['blue',      'bule color comment'],
                ['purple',    'purple color comment'],
                ['184',       'anonymouse comment'],
                ['sage',      'post comment on "sage" mode'],
                ['invisible', 'invisible comment'],
            ];
            const premiumcommands = [
                ['niconicowhite',  'nicinicowhite color comment'],
                ['truered',        'truered color comment'],
                ['passionorange',  'passionorange comment'],
                ['madyellow',      'madyellow comment'],
                ['elementalgreen', 'elementalgreen comment'],
                ['marineblue',     'marineblue'],
                ['nobleviolet',    'nobleviolet'],
                ['black',          'black'],
            ];

            commands.forEach(function(command) {
                if(command[0].indexOf(filter.toLowerCase()) === 0){
                    templates.push(command);
                }
            });
            if(controller.getValue('premiumNo')) {
                premiumcommands.forEach(function(premiumcommand){
                    if(premiumcommand[0].indexOf(filter.toLowerCase()) === 0){
                        templates.push(premiumcommand);
                    }
                });
            }

            return [0, templates];
        },
    }
);
})();

// vim: set sw=4 ts=4 et;
