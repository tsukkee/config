(function() {

mappings.addUserMap([modes.NORMAL], ["zc"],
    "TreeStyleTab - Collapse SubTree",
    function(count) {
        if(gBrowser.treeStyleTab)
            gBrowser.treeStyleTab.collapseExpandSubtree(tabs.getTab(), true);
        else
            liberator.echoerr("need TreeStyleTab", 0);
    },
    {});

mappings.addUserMap([modes.NORMAL], ["zo"],
    "TreeStyleTab - Expand SubTree",
    function(count) {
        if(gBrowser.treeStyleTab)
            gBrowser.treeStyleTab.collapseExpandSubtree(tabs.getTab(), false);
        else
            liberator.echoerr("need TreeStyleTab", 0);
    },
    {});

mappings.addUserMap([modes.NORMAL], ["zM"],
    "TreeStyleTab - Collapse All SubTree",
    function(count) {
        if(gBrowser.treeStyleTab)
            TreeStyleTabService.collapseExpandAllSubtree(true);
        else
            liberator.echoerr("need TreeStyleTab", 0);
    },
    {});

mappings.addUserMap([modes.NORMAL], ["zR"],
    "TreeStyleTab - Expand All SubTree",
    function(count) {
        if(gBrowser.treeStyleTab)
            TreeStyleTabService.collapseExpandAllSubtree(false);
        else
            liberator.echoerr("need TreeStyleTab", 0);
    },
    {});

mappings.addUserMap([modes.NORMAL], [">>"],
    "TreeStyleTab - Attach Current Tab as Previous Tab's Child Tab",
    function(count) {
        if(gBrowser.treeStyleTab) {
            let currentTab = tabs.getTab();
            gBrowser.treeStyleTab.attachTabTo(currentTab,
                TreeStyleTabService.getPreviousSiblingTab(currentTab));
        }
        else 
            liberator.echoerr("need TreeStyleTab", 0);
    },
    {});

mappings.addUserMap([modes.NORMAL], ["<<"],
    "TreeStyleTab - Part Current Tab from Parent Tab",
    function(count) {
        if(gBrowser.treeStyleTab) {
            let currentTab = tabs.getTab();
            let grandParent = TreeStyleTabService.getParentTab(
                TreeStyleTabService.getParentTab(currentTab));
            if(grandParent)
                gBrowser.treeStyleTab.attachTabTo(currentTab, grandParent);
            else
                gBrowser.treeStyleTab.partTab(currentTab);
        }
        else 
            liberator.echoerr("need TreeStyleTab", 0);
    },
    {});

let positions = {
    h: "left",
    j: "bottom",
    k: "top",
    l: "right"
};

for(let i in positions) {
    let position = positions[i];
    mappings.addUserMap([modes.NORMAL], ["<C-w>" + i],
        "TreeStyleTab - Change Tabbar Position to " + position,
        function(count) {
            if(gBrowser.treeStyleTab) {
                TreeStyleTabService.changeTabbarPosition(position);
            }
            else
                liberator.echoerr("need TreeStyleTab", 0);
        },
        {});
}

})();
