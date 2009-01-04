mappings.addUserMap([modes.NORMAL], ["zc"],
    "TreeStyleTab - Collapse SubTree",
    function(count) {
        gBrowser.treeStyleTab.collapseExpandSubtree(tabs.getTab(), true);
    },
    {});

mappings.addUserMap([modes.NORMAL], ["zo"],
    "TreeStyleTab - Expand SubTree",
    function(count) {
        gBrowser.treeStyleTab.collapseExpandSubtree(tabs.getTab(), false);
    },
    {});

mappings.addUserMap([modes.NORMAL], ["zC"],
    "TreeStyleTab - Collapse All SubTree",
    function(count) {
        TreeStyleTabService.collapseExpandAllSubtree(true);
    },
    {});

mappings.addUserMap([modes.NORMAL], ["zO"],
    "TreeStyleTab - Expand All SubTree",
    function(count) {
        TreeStyleTabService.collapseExpandAllSubtree(false);
    },
    {});
