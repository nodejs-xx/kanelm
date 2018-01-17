require('./index.html');
require('./main.scss');

const Elm = require('./Main.elm');
const StorageKey = 'elm-data';

var storedData = localStorage.getItem(StorageKey);
var state = storedData ? JSON.parse(storedData) : null;
var app = Elm.Main.fullscreen(state);

app.ports.setStorage.subscribe(function(state) {
  localStorage.setItem(StorageKey, JSON.stringify(state));
});
