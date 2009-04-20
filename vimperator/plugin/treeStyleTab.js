mappings.addUserMap([modes.NORMAL], ["zc"],
    "TreeStyleTab - Collapse SubTree",
    function(count) {
        if(gBrowser.treeStyleTab);
            gBrowser.treeStyleTab.collapseExpandSubtree(tabs.getTab(), true);
        else
            liberator.echoerr("need TreeStyleTab", 0);
    },
    {});

mappings.addUserMap([modes.NORMAL], ["zo"],
    "TreeStyleTab - Expand SubTree",
    function(count) {
        if(gBrowser.treeStyleTab);
            gBrowser.treeStyleTab.collapseExpandSubtree(tabs.getTab(), false);
        else
            liberator.echoerr("need TreeStyleTab", 0);
    },
    {});

mappings.addUserMap([modes.NORMAL], ["zC"],
    "TreeStyleTab - Collapse All SubTree",
    function(count) {
        if(gBrowser.treeStyleTab);
            TreeStyleTabService.collapseExpandAllSubtree(true);
        else
            liberator.echoerr("need TreeStyleTab", 0);
    },
    {});

mappings.addUserMap([modes.NORMAL], ["zO"],
    "TreeStyleTab - Expand All SubTree",
    function(count) {
        if(gBrowser.treeStyleTab);
            TreeStyleTabService.collapseExpandAllSubtree(false);
        else
            liberator.echoerr("need TreeStyleTab", 0);
    },
    {});
