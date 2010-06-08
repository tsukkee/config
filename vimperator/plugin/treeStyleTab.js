let INFO =
<plugin name="Tree Style Tab" version="0.0.1"
        href=""
        summary="manipulate Tree Style Tab extension"
        xmlns="http://vimperator.org/namespaces/liberator">
    <author email="takayuki0510@gmail.com">tsukkee</author>
    <license href="http://www.mozilla.org/MPL/MPL-1.1.html">MPL 1.1</license>
    <project name="Vimperator" minVersion="2.3"/>
    <p>
        Tree Style Tabを操作します
    </p>
    <item>
        <tags><![CDATA[zc]]></tags>
        <spec>zc</spec>
        <description>
            <p>Collapse Subtree</p>
        </description>
    </item>
    <item>
        <tags><![CDATA[zo]]></tags>
        <spec>zo</spec>
        <description>
            <p>Expand Subtree</p>
        </description>
    </item>
    <item>
        <tags><![CDATA[zM]]></tags>
        <spec>zM</spec>
        <description>
            <p>Collapse All Subtree</p>
        </description>
    </item>
    <note>
        既存のマッピングを適当に上書きするので注意
    </note>
</plugin>;

(function() {
if(!("TreeStyleTabService" in window)) {
    liberator.echoerr("TreeStyleTab.js needs TreeStyleTab Extension");
    return;
}

function addMap(keys, desc, fn, options) {
    options = options || {};
    mappings.addUserMap([modes.NORMAL], keys,
        "TreeStyleTab - " + desc, fn, options);
}

addMap(["gt"],
    "Go to the next tab with skipping collapsed tab tree",
    function(count) {
        if(count > 0) {
            events.feedkeys(count + "gt", true, false);
        }
        else {
            gBrowser.mTabContainer.advanceSelectedTab(+1, true);
        }
    },
    { count: true });
    //{ flags: Mappings.flags.COUNT });

addMap(["<C-n>", "<C-Tab>", "<C-PageDown>"],
    "Go to the next tab with skipping collapsed tab tree",
    function(count) {
        let count = count < 1 ? 1 : count;
        for(let i = 0; i < count; ++i) {
            gBrowser.mTabContainer.advanceSelectedTab(+1, true);
        }
    },
    { count: true });
    // { flags: Mappings.flags.COUNT });

addMap(["gT", "<C-p>", "<C-S-Tab>", "<C-PageUp>"],
    "Go to the  previous tab with skipping collapsed tab tree",
    function(count) {
        let count = count < 1 ? 1 : count;
        for(let i = 0; i < count; ++i) {
            gBrowser.mTabContainer.advanceSelectedTab(-1, true);
        }
    },
    { count: true });
    // { flags: Mappings.flags.COUNT });

addMap(["zc"], "Collapse Subtree", function() {
    gBrowser.treeStyleTab.collapseExpandSubtree(gBrowser.selectedTab, true);
});

addMap(["zo"], "Expand Subtree", function() {
    gBrowser.treeStyleTab.collapseExpandSubtree(gBrowser.selectedTab, false);
});

addMap(["zM"], "Collapse All Subtree", function() {
    TreeStyleTabService.collapseExpandAllSubtree(true);
});

addMap(["zR"], "Expand All Subtree", function() {
    TreeStyleTabService.collapseExpandAllSubtree(false);
});

addMap(["[z"], "Goto root tab of currrent tree", function() {
    gBrowser.selectedTab = TreeStyleTabService.getRootTab(gBrowser.selectedTab);
});

addMap(["]z"], "Goto last descendant tab of current tree", function() {
    gBrowser.selectedTab = TreeStyleTabService.getLastDescendantTab(gBrowser.selectedTab);
});

addMap(["zk"], "Goto previous sibling tab", function() {
    gBrowser.selectedTab = TreeStyleTabService.getPreviousSiblingTab(
        TreeStyleTabService.getRootTab(gBrowser.selectedTab));
});

addMap(["zj"], "Goto next sibling tab", function() {
    gBrowser.selectedTab = TreeStyleTabService.getNextSiblingTab(
        TreeStyleTabService.getRootTab(gBrowser.selectedTab));
});

addMap([">>"], "Attach current tab to previous tab", function() {
    gBrowser.treeStyleTab.attachTabTo(gBrowser.selectedTab,
        TreeStyleTabService.getPreviousSiblingTab(gBrowser.selectedTab));
});

addMap(["<<"], "Part current tab from parent tab", function() {
    let grandParent = TreeStyleTabService.getParentTab(
        TreeStyleTabService.getParentTab(gBrowser.selectedTab));

    if(grandParent) {
        gBrowser.treeStyleTab.attachTabTo(gBrowser.selectedTab, grandParent);
    }
    else {
        gBrowser.treeStyleTab.partTab(gBrowser.selectedTab);
    }
});

let positions = {
    h: "left",
    j: "bottom",
    k: "top",
    l: "right"
};

for(let i in positions) {
    let position = positions[i];
    addMap(["<C-w>" + i], "Change tabbar position to " + position, function() {
        TreeStyleTabService.changeTabbarPosition(position);
    });
}
})();
