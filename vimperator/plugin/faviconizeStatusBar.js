/**
 * ==VimperatorPlugin==
 * @name           faviconizeStatusBar.js
 * @description    add favicon to statusbar
 * @description-ja ステータスバーにファビコン追加
 * @minVersion     2.0pre
 * @author         tsukkee takayuki0510@gmail.com
 * @version        0.1
 * ==/VimperatorPlugin==
 */

(function() {

// initialize
var panel = document.getElementById('page-proxy-favicon-clone');
if (!panel) {
    panel = document.createElement('statusbarpanel');
    panel.setAttribute('id', 'page-proxy-favicon-clone');
}

var base = document.getElementById('page-proxy-favicon');
var status_bar = document.getElementById('status-bar');
var liberator_statusline = document.getElementById('liberator-statusline');

// display favicon
liberator.plugins.faviconizeStatusBar = function () {
    while (panel.childNodes.length > 0) {
        panel.removeChild(panel.childNodes.item(0));
    }
    panel.appendChild(base.cloneNode(true));
    status_bar.insertBefore(panel, liberator_statusline);
}

autocommands.add('DOMLoad', '.*',
    'js liberator.plugins.faviconizeStatusBar()');

autocommands.add('LocationChange', '.*',
    'js liberator.plugins.faviconizeStatusBar()');

})();
