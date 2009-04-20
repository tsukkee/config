mappings.addUserMap([modes.NORMAL], ["<Leader>m"],
    "Multiple Tab Handler - toggle selection",
    function(count) {
        if(window.MultipleTabService)
            MultipleTabService.toggleSelection(tabs.getTab());
        else
            liberator.echoerr("need Multiple Tab Handler", 0);        
    },
    {});

mappings.addUserMap([modes.NORMAL], ["<Leader>c"],
    "Multiple Tab Handler - clear selection",
    function(count) {
        if(window.MultipleTabService)
            MultipleTabService.clearSelection();
        else
            liberator.echoerr("need Multiple Tab Handler", 0);

    },
    {});

mappings.addUserMap([modes.NORMAL], ["r"],
    "Multiple Tab Handler - reload",
    function(count) {
        if(window.MultipleTabService &&  MultipleTabService.hasSelection()) {
            let tabs = MultipleTabService.getSelectedTabs();
            MultipleTabService.reloadTabs(tabs);
        }
        else {
            events.feedkeys("r", true, false);
        }
    },
    {});

mappings.addUserMap([modes.NORMAL], ["d"],
    "Multiple Tab Handler - delete",
    function(count) {
        if(window.MultipleTabService && MultipleTabService.hasSelection()) {
            let tabs = MultipleTabService.getSelectedTabs();
            MultipleTabService.closeTabs(tabs);
        }
        else {
            events.feedkeys("d", true, false);
        }
    },
    {});

commands.addUserCommand(["multitabduplicate"],
    "Multiple Tab Handler - duplicate",
    function(args) {
        if(window.MultipleTabService && MultipleTabService.hasSelection()) {
            let tabs = MultipleTabService.getSelectedTabs();
            MultipleTabService.duplicateTabs(tabs);
        }
    },
    {}); 

commands.addUserCommand(["multitabdetach"],
    "Multiple Tab Handler - detach",
    function(args) {
        if(window.MultipleTabService && MultipleTabService.hasSelection()) {
            let tabs = MultipleTabService.getSelectedTabs();
            MultipleTabService.splitWindowFromTabs(tabs);
        }
    },
    {});

