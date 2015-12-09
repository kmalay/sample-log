[{
"type": "FeatureCollection",
"crs": { "type": "name", "properties": { "name": "urn:ogc:def:crs:OGC:1.3:CRS84" } },
"features": [
{ "type": "Feature", "id": 1, "properties": { "ID": 1 }, "geometry": { "type": "Point", "coordinates": [ 13.183888701186456, 52.568527582373456 ] } },
{ "type": "Feature", "id": 2, "properties": { "ID": 2 }, "geometry": { "type": "Point", "coordinates": [ 13.446136690980969, 52.386177507970935 ] } }
]}]




var htmlResults = $("#report_geoJSON div.t-Report-tableWrap td.t-Report-cell").html();
var geoJSON = $.parseJSON(htmlResults);
