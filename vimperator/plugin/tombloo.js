/**
 * ==VimperatorPlugin==
 * @name           tombloo.js
 * @description    Tombloo integrate plugin
 * @description-ja Tombloo経由で選択領域などをpostする
 * @author         Trapezoid
 * @version        0.1b
 * ==/VimperatorPlugin==
 *
 * Usage:
 *  :tombloo arg                    -> post by Tombloo (don't use prompt)
 *  :tombloo! arg                   -> post by Tombloo (use prompt)
 *  :tomblooAction arg              -> execute Tombloo's action in tool menu
 **/
var TomblooService = Components.classes['@brasil.to/tombloo-service;1'].getService().wrappedJSObject;
function update(target, src, keys){
    if(keys){
        keys.forEach(function(key){
                target[key] = src[key];
                });
    } else {
        for(var key in src)
            target[key] = src[key];
    }

    return target;
}

function getContext(){
    var doc = window.content.document;
    var win = window.content.wrappedJSObject;
    return update(update({
        document  : doc,
        window    : win,
        title     : ''+doc.title || '',
        selection : ''+win.getSelection(),
        target    : doc,
        //event     : event,
        //mouse     : mouse,
        //menu      : gContextMenu,
    }, {}), win.location);
}

liberator.commands.addUserCommand(['tomblooAction'],'Execute Tombloo actions',
    function(arg){
        TomblooService.Tombloo.Service.actions[arg].execute();
    },{
        completer: function(filter){
            var completionList = new Array();
            for(var name in TomblooService.Tombloo.Service.actions)
                if(name.indexOf(filter) > -1)
                    completionList.push([name,name]);
            return [0,completionList];
        }
    }
);

liberator.commands.addUserCommand(['tombloo'],'Post by Tombloo',
    function(arg,special){
        TomblooService.Tombloo.Service.share(getContext(), TomblooService.Tombloo.Service.extracters[arg],special);
    },{
        completer: function(filter){
            var completionList = new Array();
            var exts = TomblooService.Tombloo.Service.check(getContext());
            for(var i=0; i < exts.length; i++)
                if(exts[i].name.indexOf(filter) > -1)
                    completionList.push([exts[i].name,exts[i].name]);
            return [0,completionList];
        }
    }
);
