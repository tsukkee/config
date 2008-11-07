(function() {

// Setting
var timeout = 40;

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

// from feedSomeKeys.js
function getMap(mode, origKey) {
    if(mappings.hasMap(mode, origKey)) {
        var origMap = mappings.get(mode, origKey);

        var clone = new Map(
            origMap.modes.map(function(m) m),
            origMap.names.map(function(n) n),
            origMap.description,
            origMap.action,
            { flags:origMap.flags, rhs:origMap.rhs, noremap:origMap.noremap }
        );

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
    var self = this;
    self.arpeggioHasDone = false;
    self.origMaps = [];

    var keys = keys.split("");
    
    for(let i = 0, len = keys.length; i < len; ++i) {
        let remains = keys.concat([]); // clone
        let key = remains.splice(i, 1).toString();

        let origMap = getMap(mode, key);
        let newMap = null;

        mappings.addUserMap([mode], [key],
            "arpeggio start: " + key,
            function(count) {
                self.addRemainMaps(mode, noremap, remains, fn);

                setTimeout(function() {
                    self.removeRemainMaps(mode, remains);
                    if(!self.arpeggioHasDone) {
                        if(origMap) addUserMap(origMap);
                        events.feedkeys((count > 1 ? count : "") + key, true);
                        if(newMap) addUserMap(newMap);
                    }
                    self.arpeggioHasDone = false;
                }, timeout);
            },
            {
                noremap: true    
            }
        );

        newMap = getMap(mode, key);
    }
}

ArpeggioMap.prototype = {
    addRemainMaps: function(mode, noremap, keys, fn) {
        var self = this;

        for(var combo in permutations(keys)) {
            let key = combo.join("");

            mappings.addUserMap([mode], [key],
                "arpeggio: " + key,
                function(count) {
                    fn();
                    self.arpeggioHasDone = true;
                },
                {
                    noremap: true
                });
        }
    },

    removeRemainMaps: function(mode, keys) {
        for(var combo in permutations(keys)) {
            let key = combo.join("");
            mappings.remove(mode, key);
        }
    }
};


// new ArpeggioMap(modes.NORMAL, true, "as", function() {
    // alert("as");    
// });

})();
