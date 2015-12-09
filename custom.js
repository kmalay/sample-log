/**
 * Created by kmalay on 12/9/15.
 */
var drawnItems = new L.FeatureGroup();
map.addLayer(drawnItems);

var searchIcon = L.AwesomeMarkers.icon({
    icon: 'search',
    markerColor: 'red'
});

var options = {
    draw: {
        polyline: false,
        polygon: false,
        circle: false,
        rectangle: false,
        marker: {
            icon: searchIcon
        }
    },
    edit: false
};

var drawControl = new L.Control.Draw(options);
map.addControl(drawControl);

var xMax, yMax, xMin, yMin;

map.on('draw:created', function (e) {
    var type = e.layerType,
        layer = e.layer;
    if (type === 'marker') {
        layer.bindPopup('A popup!');
    }
    drawnItems.clearLayers();
    drawnItems.addLayer(layer);
    xMax = drawnItems.getBounds()._northEast.lat;
    yMax = drawnItems.getBounds()._northEast.lng;
    xMin = drawnItems.getBounds()._southWest.lat;
    yMin = drawnItems.getBounds()._southWest.lng;
    lat = xMax;
    lon = yMax;
    console.log('point: ' + lat + ' ' + lon);
});