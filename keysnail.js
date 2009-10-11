// ==================== KeySnail configuration file ==================== //

// -------------------- How to bind function to the key sequence -------------------- //
//
// You can bind the function to the key sequence, using the functions listed below.
//
// key.setGlobalKey(keys, func, ksDescription, ksNoRepeat);
// key.setEditKey(keys, func, ksDescription, ksNoRepeat);
// key.setViewKey(keys, func, ksDescription, ksNoRepeat);
// key.setCaretKey(keys, func, ksDescription, ksNoRepeat);
//
// Here are the descriptions of the each argument.
//
// keys          => key (string) or key sequence (array)
//                  if you want to bind a function to mutliple key sequence use 'array of array'
//                  expression of the key follows the Emacs
//                  ex1) Ctrl + Alt + t : C-M-t
//                  ex2) Arrow Key      : <up>, <down>, <left>, <right>
//                  ex3) PgUp, PgDn     : <prior>, <next>
//                  ex4) F1, F2, F3     : <f1>, <f2>, <f3>
//
// func          => anonymous function.
//                  this function can take two arguments.
//                     * argument 1 => key event
//                     * argument 2 => prefix argument (or null)
//                  you can use these arguments through declaring the
//                  following expression.
//                        function (aEvent, aArg)
// ksDescription => Description of the function.
//                  you can omit this argument.
//
// ksNoRepeat    => when false, command (function) is executed
//                  prefix arguments times.
//                  if you want to use prefix argument in your
//                  function, and do not want to repeat it, set
//                  this value to true.
//                  you can omit this argument.
//
// Actually, these functions just wrap the function below.
//
// key.defineKey(keyMapName, keys, func, ksDescription, ksNoRepeat);
//
// keyMapName    => key.modes.GLOBAL, key.modes.VIEW, key.modes.EDIT, key.modes.CARET
//
// ==================== About hook ====================
// User can set the function to the hook.
// For example, when KeySnail the key press event of the key.quitKey,
// functions set to KeyBoardQuit are called.
// You can bind "Cancell isearch", "Deselect the text", and so forth.

// key.quitKey : Cancel the current input.
//               This key event calls the KeyBoardQuit hook.
//               You can set the command like "close the find bar" to it.

// key.helpKey : Display the interactive help. General help key.
//               When you input C-c C-c <helpKey>, keybindings begin with C-c C-c are displayed.
//               And in this script settings, <helpKey> b lists the all keybindings.

// You can preserve your code in this area when generating the init file using GUI.
// Put all your code except special key, set*key, hook, blacklist.
//{{%PRESERVE%
// prompt.rows                = 12;
// prompt.useMigemo           = false;
// prompt.migemoMinWordLength = 2;
// prompt.displayDelayTime    = 300;
// command.kill.killRingMax   = 15;
// command.kill.textLengthMax = 8192;
//}}%PRESERVE%

// ================ Special Keys ====================== //

key.quitKey              = "C-g";
key.helpKey              = "<f1>";
key.escapeKey            = "C-v";
key.macroStartKey        = "Not defined";
key.macroEndKey          = "Not defined";
key.universalArgumentKey = ";";
key.negativeArgument1Key = "C--";
key.negativeArgument2Key = "C-M--";
key.negativeArgument3Key = "M--";
key.suspendKey           = "C-z";

// ================ Hooks ============================= //

hook.setHook('KeyBoardQuit', function (aEvent) {
    command.closeFindBar();
    if (util.isCaretEnabled()) {
        command.resetMark(aEvent);
    } else {
        goDoCommand("cmd_selectNone");
    }
    key.generateKey(aEvent.originalTarget, KeyEvent.DOM_VK_ESCAPE, true);
});

// ================ Key Bindings ====================== //

key.setViewKey('d', function () {
    BrowserCloseTabOrWindow();
}, 'タブ / ウィンドウを閉じる');

key.setViewKey('C-n', function () {
    gBrowser.mTabContainer.advanceSelectedTab(1, true);
}, 'ひとつ右のタブへ');

key.setViewKey('C-p', function () {
    gBrowser.mTabContainer.advanceSelectedTab(-1, true);
}, 'ひとつ左のタブへ');

key.setViewKey('u', function () {
    undoCloseTab();
}, '閉じたタブを元に戻す');

key.setViewKey(['z', '-'], function () {
    ZoomManager.reduce();
}, 'テキストサイズを小さく');

key.setViewKey(['z', '+'], function () {
    ZoomManager.enlarge();
}, 'テキストサイズを大きく');

key.setViewKey(['z', '0'], function () {
    ZoomManager.reset();
}, 'テキストサイズをリセット');

key.setViewKey(['g', 'i'], function () {
    command.focusElement(command.elementsRetrieverTextarea, 0);
}, '最初のインプットエリアへフォーカス', true);

key.setViewKey(['g', 'u'], function () {
    var uri = gBrowser.currentURI;
    if (uri.path == "/") {
        return;
    }
    var pathList = uri.path.split("/");
    if (!pathList.pop()) {
        pathList.pop();
    }
    loadURI(uri.prePath + pathList.join("/") + "/");
}, '一つ上のディレクトリへ移動');

key.setViewKey(['g', 'U'], function () {
    var uri = window._content.location.href;
    if (uri == null) {
        return;
    }
    var root = uri.match(/^[a-z]+:\/\/[^/]+\//);
    if (root) {
        loadURI(root, null, null);
    }
}, 'ルートディレクトリへ移動', true);

key.setViewKey('H', function () {
    BrowserBack();
}, '戻る');

key.setViewKey('L', function () {
    BrowserForward();
}, '進む');

key.setViewKey('r', function () {
    BrowserReload();
}, '更新');

key.setViewKey('R', function () {
    BrowserReloadSkipCache();
}, '更新(キャッシュを無視)');

key.setViewKey('C-c', function () {
    document.getElementById("Browser:Stop").doCommand();
}, 'ページの読み込みを中止');

key.setViewKey('Y', function (aEvent) {
    command.copyRegion(aEvent);
}, '選択中のテキストをコピー');

key.setViewKey(':', function () {
    command.interpreter();
}, 'コマンドインタプリタ');

key.setViewKey('b', function (aEvent, arg) {
    command.bookMarkToolBarJumpTo(aEvent, arg);
}, 'ブックマークツールバーのアイテムを開く', true);

key.setViewKey('f', function (aEvent) {
    hah.enterStartKey(aEvent);
}, 'LoL を開始');

key.setViewKey('j', function (aEvent) {
    key.generateKey(aEvent.originalTarget, KeyEvent.DOM_VK_DOWN, true);
}, '一行スクロールダウン');

key.setViewKey('k', function (aEvent) {
    key.generateKey(aEvent.originalTarget, KeyEvent.DOM_VK_UP, true);
}, '一行スクロールアップ');

key.setViewKey('l', function (aEvent) {
    key.generateKey(aEvent.originalTarget, KeyEvent.DOM_VK_RIGHT, true);
}, '右へスクロール');

key.setViewKey('h', function (aEvent) {
    key.generateKey(aEvent.originalTarget, KeyEvent.DOM_VK_LEFT, true);
}, '左へスクロール');

key.setViewKey('C-u', function () {
    goDoCommand("cmd_scrollPageUp");
}, '一画面分スクロールアップ');

key.setViewKey('C-d', function () {
    goDoCommand("cmd_scrollPageDown");
}, '一画面スクロールダウン');

key.setViewKey(['g', 'g'], function () {
    goDoCommand("cmd_scrollTop");
}, 'ページ先頭へ移動');

key.setViewKey('G', function () {
    goDoCommand("cmd_scrollBottom");
}, 'ページ末尾へ移動');

key.setViewKey(['g', 'n'], function () {
    command.walkInputElement(command.elementsRetrieverButton, true, true);
}, '次のボタンへフォーカスを当てる');

key.setViewKey(['g', 'p'], function () {
    command.walkInputElement(command.elementsRetrieverButton, false, true);
}, '前のボタンへフォーカスを当てる');

key.setEditKey('C-n', function () {
    command.walkInputElement(command.elementsRetrieverTextarea, true, true);
}, '次のテキストエリアへフォーカスを当てる');

key.setEditKey('C-p', function () {
    command.walkInputElement(command.elementsRetrieverTextarea, false, true);
}, '前のテキストエリアへフォーカスを当てる');

key.setViewKey('/', function() {
    command.iSearchFoward();
}, 'インクリメンタル検索');

key.setViewKey('?', function() {
    command.iSearchBackward();
}, 'インクリメンタル検索');

key.setGlobalKey('C-r', function() {
    userscript.reload();
}, '設定ファイルを再読み込み');

key.setViewKey('o', function () {
    command.focusToById("urlbar");
}, 'ロケーションバーへフォーカス');
