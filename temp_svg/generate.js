const TextToSVG = require('text-to-svg');
const textToSVG = TextToSVG.loadSync('./DancingScript.ttf');
const path = textToSVG.getD('Vietnam', {x: 0, y: 0, fontSize: 88, anchor: 'top'});
console.log(path);
