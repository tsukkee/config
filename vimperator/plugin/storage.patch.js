/* [=c= /ulb/js %] */
/* [=p= ~/script/packjs.rb %] */

(function () {
  let expr1 = 
  "savePref = function (obj)" +
  "{" +
  "   function setCharPref(name, value)" +
  "   {" +
  "       var str = Components.classes['@mozilla.org/supports-string;1']" +
  "                           .createInstance(Components.interfaces.nsISupportsString);" +
  "       str.data = value;" +
  "       return prefService.setComplexValue(name, Components.interfaces.nsISupportsString, str);" +
  "   }" +
  "" +
  "    if (obj.store)" +
  "        setCharPref(obj.name, obj.serial)" +
  "};" +
  "";

  window.eval(expr1, storage);
  log( window.eval('savePref', storage) );
})();
