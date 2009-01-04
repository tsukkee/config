liberator.plugins.mime_and_charset = function() {
    var doc = window.document;
    var target = doc.getElementById("liberator-statusline");
    var id_prefix = "liberator-statusline-field-";
    var items = [
        {id: "contenttype", value: window.content.document.contentType},
        {id: "characterset", value: window.content.document.characterSet},
    ];
    items.forEach(function(item, i, arr) {
        var label = doc.getElementById(id_prefix + item.id);
        if (label) {
            label.setAttribute("value", item.value);
        }
        else {
            label = doc.createElement("label");
            label.setAttribute("class", "plain");
            label.setAttribute("id", id_prefix + item.id);
            label.setAttribute("flex", 0);
            label.setAttribute("value", item.value);
            target.appendChild(label);
        }
    });
};

autocommands.add(
    "LocationChange",
    /.*/,
    function() liberator.plugins.mime_and_charset()
);

autocommands.add(
    "DOMLoad",
    /.*/,
    function() liberator.plugins.mime_and_charset()
);
