// ================ KeySnail Init File ================ //

// この領域は, GUI により初期化ファイルを生成した際にも引き継がれます
// 特殊キー, キーバインド定義, フック, ブラックリスト以外のコードは, この中に書くようにして下さい
// ============================================================ //
//{{%PRESERVE%
// prompt.rows                = 12;
// prompt.useMigemo           = false;
// prompt.migemoMinWordLength = 2;
// prompt.displayDelayTime    = 300;
// command.kill.killRingMax   = 15;
// command.kill.textLengthMax = 8192;
//}}%PRESERVE%
// ============================================================ //

// ================ Special Keys ====================== //

key.quitKey              = "ESC";
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

key.setGlobalKey('C-r', function () {
    userscript.reload();
}, '設定ファイルを再読み込み');

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

key.setViewKey(['g', 'g'], function () {
    goDoCommand("cmd_scrollTop");
}, 'ページ先頭へ移動');

key.setViewKey(['g', 'n'], function () {
    command.walkInputElement(command.elementsRetrieverButton, true, true);
}, '次のボタンへフォーカスを当てる');

key.setViewKey(['g', 'p'], function () {
    command.walkInputElement(command.elementsRetrieverButton, false, true);
}, '前のボタンへフォーカスを当てる');

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

key.setViewKey(':', function (aEvent, aArg) {
    ext.select(aArg, aEvent);
}, 'エクステ', true);

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

key.setViewKey('G', function () {
    goDoCommand("cmd_scrollBottom");
}, 'ページ末尾へ移動');

key.setViewKey('/', function () {
    command.iSearchForward();
}, 'インクリメンタル検索');

key.setViewKey('?', function () {
    command.iSearchBackward();
}, 'インクリメンタル検索');

key.setViewKey('o', function () {
    command.focusToById("urlbar");
}, 'ロケーションバーへフォーカス');

key.setViewKey([']', 'f'], function (aEvent, aArg) {
    command.focusOtherFrame(aArg);
}, '次のフレームを選択', true);

key.setEditKey('C-n', function () {
    command.walkInputElement(command.elementsRetrieverTextarea, true, true);
}, '次のテキストエリアへフォーカスを当てる');

key.setEditKey('C-p', function () {
    command.walkInputElement(command.elementsRetrieverTextarea, false, true);
}, '前のテキストエリアへフォーカスを当てる');
