function uuidToSvg(value) {
    var uuidStr = value.replace(/-/g, "");
    uuidStr = `${uuidStr}${uuidStr}${uuidStr}`;
    var outStr = '<svg class="" viewBox="0 0 400 400">'
    for (var rowIdx=0; rowIdx<4; rowIdx++) {
        for (var colIdx = 0; colIdx < 4; colIdx++) {
            var x = colIdx * 100;
            var y = rowIdx * 100;
            // rowIdx x numLetters x numCols + colIdx x numLetters
            var start = rowIdx * 6 * 4 + colIdx * 6;
            var col = uuidStr.slice(start, start + 6);
            outStr += `<rect x="${x}" y="${y}" width="100" height="100" style="stroke-width:0;fill:#${col}"/>`
        }
    }
    return outStr + '</svg>';
}
