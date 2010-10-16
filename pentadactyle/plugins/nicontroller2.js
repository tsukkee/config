/*
Commands
:nicoplay
:nicogoto +number
:nicomove (+/-)number
:nicomute
:nicovolume (+/-)number
:nicovisible
:nicorepeat
:nicosize
:nicomment! -c[ommands] command comment

ニコニコ動画2010/7版API
cf.) http://d.hatena.ne.jp/ofk/20100726/1280139013 
     http://miya2000.jottit.com/niconico
     http://d.hatena.ne.jp/kiyo_hoge/20100819/1282240857
ext_play(boolean)
    trueなら再生。falseなら停止。
ext_setPlayheadTime(number)
    number秒に頭だし。
ext_setMute(boolean)
    ミュートのオンオフ。
ext_setVolume(number)
    ボリューム設定（0〜100）。
ext_setCommentVisible(boolean)
    コメント表示のオンオフ。
ext_setRepeat(boolean)
    リピートのオンオフ。
ext_setVideoSize(string)
    fitなら全画面、normalなら通常画面。
ext_isMute()
    ミュート状態をbooleanで。
ext_getVolume()
    ボリュームを0〜100で。
ext_isCommentVisible()
    コメント表示状態をbooleanで。
ext_isRepeat()
    リピート状態をbooleanで。
ext_getVideoSize()
    画面の表示をfitかnormalという文字列で。
ext_getStatus()
    ビデオの状況を文字列で。映像が終了していたらend、ポーズ状態ならpaused、再生中ならplaying、シーク中ならseeking、読み込み中（再生中ではない）ならload、それ以外はstoppedになります。昔は状態が少しバグっていた気がします（要確認）。
ext_getPlayheadTime()
    現在の再生位置を秒単位の整数で返します。
ext_getTotalTime()
    動画の長さを秒単位の整数で返します。
ext_isEditedOwnerThread()
    投稿者コメントが投稿可能かどうかをbooleanで。
ext_sendLocalMessage(string, string, number)
    内容、コマンド、書き込み時間でコメント投稿します。
ext_getLoadedRatio()
    ダウンロードの進行状況を0〜100で返します。
ext_sendOwnerMessage(string, string, number)
    内容、コマンド、書き込み時間で投稿者コメント投稿します。
ext_setInputMessage(string, string)
    内容、コマンドをプレイヤーの入力枠に挿入します。
ext_getThreads(string)
    動画の情報をwindow[string]という関数をコールバック引数に取って返します。
ext_getComments(string, number)
    動画のコメントをwindow[string]という関数をコールバック引数に取って指定件数分返します。
*/

(function() {

// Constants
const NICOVIDEO_HOST = "www.nicovideo.jp";
const FLVPLAYER_ID   = "flvplayer";

const IS_END     = "end";
const IS_PAUSED  = "paused";
const IS_PLAYING = "playing";
const IS_SEEKING = "seeking";
const IS_LOADING = "load";
const IS_STOPPED = "stopped";

const VOLUME_MIN = 0;
const VOLUME_MAX = 100;

const SIZE_NORMAL = "normal";
const SIZE_FIT    = "fit";

const COMMANDS_NORMAL = [
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

// Wrapper functions
function getFlvPlayer()
{
    if(content.window.location.host != NICOVIDEO_HOST)
        throw new Error("The current page is not nicovideo");

    let flvplayer = content.document.getElementById(FLVPLAYER_ID);
    if(!flvplayer) throw new Error("flvplayer is not found");

    // なぜか__proto__からだとうまくいく
    return flvplayer.wrappedJSObject.__proto__;
}

function togglePlay() {
    let p = getFlvPlayer();
    p.ext_play(p.ext_getStatus() != IS_PLAYING);
}

function goto(time) {
    let p = getFlvPlayer();
    p.ext_setPlayheadTime(
        Math.max(0, Math.min(p.ext_getTotalTime(), time))
    );
}

function getPlayheadTime()
{
    let p = getFlvPlayer();
    return p.ext_getPlayheadTime();
}

function fastForward(time) {
    goto(getPlayheadTime() + time);
}

function toggleMute() {
    let p = getFlvPlayer();
    p.ext_setMute(!p.ext_isMute());
}

function changeVolume(delta) {
    let p = getFlvPlayer();
    p.ext_setVolume(
        Math.max(VOLUME_MIN, Math.min(VOLUME_MAX, p.ext_getVolume() + delta))
    );
}

function toggleCommentVisible() {
    let p = getFlvPlayer();
    p.ext_setCommentVisible(!p.ext_isCommentVisible());
}

function toggleRepeat() {
    let p = getFlvPlayer();
    p.ext_setRepeat(!p.ext_isRepeat());
}

function toggleSize() {
    let p = getFlvPlayer();
    p.ext_setVideoSize(
        p.ext_getVideoSize() == SIZE_FIT ? SIZE_NORMAL : SIZE_FIT
    );
}

function sendComment(message, command) {
    let p = getFlvPlayer();
    p.ext_sendLocalMessage(message, command, p.ext_getPlayheadTime());
}

function setComment(message, command) {
    let p = getFlvPlayer();
    p.ext_setInputMessage(message, command);
}

// Define commands
commands.addUserCommand(['nicoplay'], 'toggle play/pause',
    function(args) {
        togglePlay();
    },
    {
    },
    true
);

commands.addUserCommand(['nicogoto'], 'go to time',
    function(args) {
        goto(parseInt(args.string, 10) || 0);
    },
    {
        argCount: "?"
    },
    true
);

commands.addUserCommand(['nicomove'], 'move by time',
    function(args) {
        fastForward(parseInt(args.string, 10) || 0);
    },
    {
        argCount: 1
    },
    true
);

commands.addUserCommand(['nicomute'], 'toggle mute',
    function(args) {
        toggleMute();
    },
    {
    },
    true
);

commands.addUserCommand(['nicovolume'], 'change volume',
    function(args) {
        changeVolume(parseInt(args.string, 10) || 0);
    },
    {
        argCount: 1
    },
    true
);

commands.addUserCommand(['nicovisible'], 'toggle comment visibility',
    function(args) {
        toggleCommentVisible();
    },
    {
    },
    true
);

commands.addUserCommand(['nicorepeat'], 'toggle repeat',
    function(args) {
        toggleRepeat();
    },
    {
    },
    true
);

commands.addUserCommand(['nicosize'], 'toggle size',
    function(args) {
        toggleSize();
    },
    {
    },
    true
);

commands.addUserCommand(['nicomment'], 'send comment',
    function(args) {
        let commands = args["-commands"] ? args["-commands"].join(" ") : "";

        if(args.bang) {
            setComment(args.literalArg, commands);
        }
        else {
            sendComment(args.literalArg, commands);
        }
    },
    {
        argCount: '+',
        literal: 0,
        bang: true,
        options: [
            [["-commands", "-c"], commands.OPTION_STRING, null, COMMANDS_NORMAL, true]
        ]
    },
    true
);

})();
