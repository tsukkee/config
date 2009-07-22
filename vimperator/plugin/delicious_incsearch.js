(function() {
// load scripts
let d = {};
try {
    liberator.loadScript("chrome://delicious_incsearch/content/database.js", d);
    liberator.loadScript("chrome://delicious_incsearch/content/incsearch.js", d);
}
catch(e)
{
    liberator.echoerr(e);
    return;
}

// load database
let database = new d.Database('bookmark', 'delicious_incsearch');

// only use search method
d.IncSearch.prototype.checkLoop = d.IncSearch.prototype.reset = function() {};
let incsearch = new d.IncSearch(null, null, { dispMax: 15, database: database });

// completion
let format = {
    anchored: false,
    keys: { text: 'url', description: 'title', icon: '', extra: 'extra' },
    title: ["Title", "Info"],
    process: [
        // Title
        function(item, text) {
            let url = item.text.replace(/^https?:\/\//, '');
            return <>{item.description} <span class="extra-info">{url}</span></>;
        },
        // Info
        function(item, text) {
            return <><span class="extra-info">{item.extra}</span></>;
        }
    ]
};

// create extra
let result_mapper = function(item) {
    item.extra = [item.tags.replace(/\s/g, ""), item.info].join(" ");
    return item;
};

commands.addUserCommand(["deliciousIncsearch", "ds"], "delicious IncSearch",
    function(args) {
        liberator.open(args.string, args.bang ? liberator.NEW_TAB : null);
    },
    {
        completer: function(context, args) {
            context.format = format;
            context.filters = [];

            incsearch.search(context.filter.split(/\s/), 0);
            context.completions = incsearch.results.map(result_mapper);
        },
        literal: 0,
        argCount: '*',
        bang: true
    },
    true);
})();
