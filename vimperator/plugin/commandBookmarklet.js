/**
 * bookmarklet wo command ni suru plugin
 *
 * @author halt feits <halt.feits@gmail.com>
 * @version 0.6.0
 */

(function(){
  var filter = "javascript:";
  var items  = bookmarks.get(filter);

  if (items.length == 0) {
    if (filter.length > 0) {
      liberator.echoerr('E283: No bookmarks matching "' + filter + '"');
    } else {
      liberator.echoerr("No bookmarks set");
    }
  }

  const regex = /[^a-zA-Z]/;
  items.forEach(function(item) {
    var [url, title] = [item.url, item.title];
    var desc = title;
    title = escape( title.replace(/ +/g,'').toLowerCase() );
    if (regex.test(title)) {
        title = "bm"+title.replace(/[^a-zA-Z]+/g,'');
        title = title.substr(0, title.length>50?50:title.length);
    }
    if (width(title) > 50) {
      while (width(title) > 47) {
        title = title.slice(0, -2);
      }
      title += "...";
    }
    title = util.escapeHTML(title);

    var command = function () { liberator.open(url); };
    commands.addUserCommand(
      [title],
      "bookmarklet : "+desc,
      command,
      {
        shortHelp: "Bookmarklet",
      }
    );
  });

  function width(str) str.replace(/[^\x20-\xFF]/g, "  ").length;
})();
// vim:sw=2 ts=2 et:
