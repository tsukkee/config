(function() {
if(!("MultipleTabService" in window)) {
    liberator.echoerr("MultipleTabHandler.js needs MultipleTabHandler extension");
    return;
}

/**
 * Mappings
 */

function addMap(keys, desc, fn) {
    mappings.addUserMap([modes.NORMAL], keys,
        "MultipleTabHandler - " + desc, fn, {});
}

addMap(["<Leader>m"], "toggle selection", function() {
    MultipleTabService.toggleSelection(gBrowser.selectedTab);
});

addMap(["<Leader>c"], "clear selection", function() {
    MultipleTabService.clearSelection();
});

addMap(["r"], "reload", function() {
    if(MultipleTabService.hasSelection()) {
        let tabs = MultipleTabService.getSelectedTabs();
        MultipleTabService.reloadTabs(tabs);
    }
    else {
        events.feedkeys("r", true, false);
    }
});

addMap(["d"], "delete", function() {
    if(MultipleTabService.hasSelection()) {
        let tabs = MultipleTabService.getSelectedTabs();
        MultipleTabService.closeTabs(tabs);
    }
    else {
        events.feedkeys("d", true, false);
    }
});

addMap(["A"], "add bookmark", function() {
    if(MultipleTabService.hasSelection()) {
        let tabs = MultipleTabService.getSelectedTabs();
        MultipleTabService.addBookmarkFor(tabs);
    }
    else {
        events.feedkeys("A", true, false);
    }
});

/**
 * Commands
 */

function addCommand(name, desc, fn, option) {
    commands.addUserCommand(name, "MultipleTabHandler - " + desc,
        fn, option, true /*replace*/);
}

addCommand(["multipleduplicate", "mdu[plicate]"], "duplicate", function(args) {
    if(MultipleTabService.hasSelection()) {
        let tabs = MultipleTabService.getSelectedTabs();
        MultipleTabService.duplicateTabs(tabs);
    }
    else
    {
        // copy from original tabduplicate in liberator/common/content/tabs.js
        let tab = tabs.getTab();

        let activate = args.bang ? true : false;
        if (/\btabopen\b/.test(options["activate"]))
            activate = !activate;

        for (let i in util.range(0, Math.max(1, args.count)))
            tabs.cloneTab(tab, activate);
    }
},
{
    argCount: "0",
    bang: true,
    count: true
});

addCommand(["multipledetach", "mde[tach]"], "detach", function(args) {
    if(MultipleTabService.hasSelection()) {
        let tabs = MultipleTabService.getSelectedTabs();
        MultipleTabService.splitWindowFromTabs(tabs);
    }
    else
    {
        tabs.detachTab(null);
    }
}, {});

// built-in copy format
let builtin_formats = [
    { label: 'URI', format: '%URL%' },
    { label: 'TitleAndURI', format: '%TITLE%%EOL%%URL%' },
    { label: 'Anchor', format: '<a href="%URL_HTMLIFIED%">%TITLE_HTMLIFIED%</a>' }
];

// load custom formats
let formats = [];
function loadFormats() {
    formats = [];

    builtin_formats.forEach(function(format) {
        formats.push([format.label, format.format]);
    });

    MultipleTabService.formats.forEach(function(format) {
        formats.push([format.label, format.format]);
    });

    // TODO: read global setting
}
loadFormats();

addCommand(["multiplecopy", "mco[py]"], "copy (bang to reload formats)", function(args) {
    if(args.bang) { loadFormats(); return; }

    let tabs = MultipleTabService.hasSelection()
        ? MultipleTabService.getSelectedTabs() : [gBrowser.selectedTab];

    let items = formats.filter(function(format) format[0] == args.string);
    let format = items.length > 0 ? items[0][1] : null;
    MultipleTabService.copyURIsToClipboard(tabs, 0, format);
},
{
    completer: function(context, args) {
        if(args.bang) return;

        context.title = ['Label', 'Format'];
        if (!context.filter) { context.completions = formats; return; }
        var filter = context.filter.toLowerCase();
        context.completions = formats.filter(function(format) format[0].toLowerCase().indexOf(filter) == 0);
    },
    bang: true
});

/**
 * with TreeStyleTab
 */
if("TreeStyleTabService" in window) {
    addMap(["zt"], "select current tree", function() {
        let root = TreeStyleTabService.getRootTab(gBrowser.selectedTab);
        let tabs = TreeStyleTabService.getDescendantTabs(root);
        tabs.push(root);

        tabs.forEach(function(tab) MultipleTabService.setSelection(tab, true));
    });

    addMap(["zs"], "select all siblings", function() {
        let parent = TreeStyleTabService.getParentTab(gBrowser.selectedTab);
        let siblings = (parent == null)
            ? TreeStyleTabService.rootTabs
            : TreeStyleTabService.getChildTabs(parent);

        siblings.forEach(function(tab) MultipleTabService.setSelection(tab, true));
    });
}
})();
