function pasteImage(fileName, name, x, y) {
    var file = new File(fileName);
    
    app.preferences.rulerUnits = Units.PIXELS

    var doc = app.activeDocument;

    doc.artLayers.add();

    var currentFile = app.open(file);
    currentFile.selection.selectAll();
    currentFile.selection.copy();
    currentFile.close();

    doc.paste();
    doc.activeLayer.name = name;
    doc.activeLayer.resize(50, 50, AnchorPosition.MIDDLECENTER);
    doc.activeLayer.translate(0, 0); //TODO: Change this to translated (x, y)

    try {
        doc.activeLayer.move(doc.layers[doc.layers.length - 1], ElementPlacement.PLACEBEFORE);
    } catch(e) {
        alert(e);
    }
}

