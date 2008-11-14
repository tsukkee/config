/**
 * ==VimperatorPlugin==
 * @name           arpeggio.js
 * @description    add arpeggio.vim like function
 * @description-ja arpeggio.vimのような機能を追加
 * @minVersion     2.0pre
 * @author         tsukkee takayuki0510@gmail.com
 * @version        0.0.0
 * ==/VimperatorPlugin==
 *
 * (設定例)
 * .vimperatorrcの中で
 * source .vimperator/plugin/arpeggio.js
 * などとしてから
 * liberator.plugins.arpeggioMap(modes.NORMAL, "asd", true, function() { ... });
 * とする
 */

(function() {

if(liberator.plugins.arpeggioMap) return;

// Setting 
var timeout = liberator.globalVariables.arpeggio_timeout || 40;

// Utilities
// references:
// http://jutememo.blogspot.com/2008/09/python_29.html
// http://code.activestate.com/recipes/190465/
function combinations(items, n) {
    if(n == 0) {
        yield [];
    }
    else {
        for(let i = 0, len = items.length; i < len; ++i) {
            let items_ = items.concat([]); // clone
            let item = items_.splice(i, 1);
            for(let j in arguments.callee(items_, len - 1)) {
                yield [item].concat(j);
            }
        }
    }
}

function permutations(items) {
    return combinations(items, items.length);
}

function getMap(mode, origKey) {
    if(mappings.hasMap(mode, origKey)) {
        var origMap = mappings.get(mode, origKey);

        /*
        var clone = new Map(
            origMap.modes.map(function(m) m),
            origMap.names.map(function(n) n),
            origMap.description,
            origMap.action,
            { flags: origMap.flags, noremap: origMap.noremap, rhs: origMap.rhs }
        );
        */
        var clone = eval(uneval(origMap));
        return clone;
    }
    else {
        return null;
    }
}

function addUserMap(map) {
    mappings.addUserMap(
        map.modes,
        map.names,
        map.description,
        map.action,
        { flags: map.flags, noremap: map.noremap, rhs: map.rhs }
    );
}

// ArpeggioMap
function ArpeggioMap(mode, noremap, keys, fn) {
    this.arpeggioHasDone = false;
    var keys = keys.split("");

    // preserve original mappings
    this.origMaps = [];
    for(let i = 0, len = keys.length; i < len; ++i) {
        let key = keys[i];
        let origMap = getMap(mode, key)
        if(origMap) {
            this.origMaps[key] = origMap;        
        }
    }
    
    // asign arpeggio mappings
    var self = this;
    for(let i = 0, len = keys.length; i < len; ++i) {
        let remains = keys.concat([]); // clone
        let key = remains.splice(i, 1).toString();

        mappings.addUserMap([mode], [key],
            "arpeggio start: " + key,
            function(count) {
                self.addRemainMaps(mode, noremap, remains, fn);

                setTimeout(function() {
                    self.removeRemainMaps(mode, remains);

                    if(!self.arpeggioHasDone) {
                        // restore
                        let origMap = self.origMaps[key];
                        if(origMap && !/^arpeggio start:/.test(origMap.description)) {
                            // FIXME: this doesn't work
                            origMap.execute(null, count);
                        }
                        else {
                            events.feedkeys((count > 1 ? count : "") + key, true);
                        }
                    }

                    self.arpeggioHasDone = false;
                }, timeout);
            },
            {}
        );
    }
}

ArpeggioMap.prototype = {
    addRemainMaps: function(mode, noremap, keys, fn) {
        for(var combo in permutations(keys)) {
            let key = combo.join("");

            // preserve original mapping
            let origMap = getMap(mode, key);
            if(origMap) this.origMaps[key] = origMap;

            var self = this;
            mappings.addUserMap([mode], [key],
                "arpeggio remains: " + key,
                function(count) {
                    alert(fn);
                    if(typeof(fn) == "function") {
                        fn();
                    }
                    else {
                        events.feedkeys(fn, true);
                    }
                    self.arpeggioHasDone = true;
                },
                {
                    noremap: true
                }
            );
        }
    },

    removeRemainMaps: function(mode, keys) {
        for(var combo in permutations(keys)) {
            let key = combo.join("");
            mappings.remove(mode, key);

            // restore original mapping
            let origMap = this.origMaps[key];
            if(origMap && !/^arpeggio/.test(origMap.description)) {
                addUserMap(this.origMaps[key]);
            }
        }
    }
};

// add plugins function
liberator.plugins.arpeggioMap = function(mode, noremap, key, fn) {
    new ArpeggioMap(mode, noremap, key, fn);
};

// TODO: 
liberator.plugins.arpeggioUnmap = function(mode, key) {

};

// FIXME: this doesn't work
// TODO: add more commands
// add commands
commands.addUserCommand(
    ["Arpeggionnomap"], "add arpeggio map", 
    function(args, bang) {
        var keys = args.arguments.shift();
        var command = args.arguments.join(" ");
        if(bang) {
            liberator.plugins.arpeggioMap(modes.NORMAL, true, keys, command);
        }
        else {
            liberator.plugins.arpeggioUnmap(modes.NORMAL, keys);
        }
    },
    {
        bang: true
    }
);

})();
