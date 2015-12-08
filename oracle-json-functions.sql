create or replace function get_geo_json
  return clob as
	v_clob	    clob;
begin
	v_clob := 
		'[{
		"type": "FeatureCollection",
		"crs": { "type": "name", "properties": { "name": "urn:ogc:def:crs:OGC:1.3:CRS84" } },                                                                        
		"features": [ ';

	for rec in (select a.id, a.geo_point from test a)
	loop
		v_clob := v_clob ||
			'{ "type": "Feature", "id": '||to_char(rec.id)||', "properties": { "ID": '||to_char(rec.id)||' }, '||'"geometry": { "type": "Point", '||
			'"coordinates": [ '||to_char(rec.geo_point.sdo_point.x)||', '||to_char(rec.geo_point.sdo_point.y)||' ] } },';
	end loop;
	
	v_clob := rtrim(v_clob, ',');
	
	v_clob := v_clob || ' ] } ]';

	return v_clob;
end;
/

sho err




declare
	v_query	varchar2(4000);
begin
	if coalesce(:P4_LON, :P4_LAT) is null
	then
		v_query :=
			'select a.id, a.geo_point.sdo_point.x lon, a.geo_point.sdo_point.y lat
			   from test a
			 where 1 = 2';
	else
		v_query :=
			'select a.id, a.geo_point.sdo_point.x lon, a.geo_point.sdo_point.y lat
			   from test a
			 where sdo_nn(
					a.geo_point,
					sdo_geometry(2001,4326,sdo_point_type(:P4_LON ,:P4_LAT,null),null,null),
					''sdo_num_res=10 unit=KM''
				   ) = ''TRUE''';
	end if;

	return v_query;
end;

[{
	"type": "FeatureCollection",
	"crs": {
		"type": "name",
		"properties": {
			"name": "urn:ogc:def:crs:OGC:1.3:CRS84"
		}
	},
	"features": [
		{
			"type": "Feature",
			"id": 0,
			"properties": {
				"ID": 0
			},
			"geometry": {
				"type": "Point",
				"coordinates": [ 13.44659775684385, 52.529904243312281 ]
			}
		}
	]
}]

create or replace
function get_geojson
  return clob as
	v_json_clob	clob;
	v_return	varchar2(4000);
begin
	apex_json.initialize_clob_output;
	
	apex_json.open_array();
	apex_json.open_object();
		apex_json.write('type', 'FeatureCollection');
		apex_json.open_object('crs');
			apex_json.write('type', 'name');
			apex_json.open_object('properties');
				apex_json.write('name', 'urn:ogc:def:crs:OGC:1.3:CRS84');
			apex_json.close_object();	--properties
		apex_json.close_object();	--crs
		apex_json.open_array('features');

	for rec in (select a.id, a.lat, a.lon from test a where rownum <= 10000)
	loop
		apex_json.open_object();
		apex_json.write('type', 'Feature');
		apex_json.write('id', rec.id);
		apex_json.open_object('properties');
		apex_json.write('ID', rec.id);
		apex_json.close_object();	--properties
		apex_json.open_object('geometry');
		apex_json.write('type','Point');
		apex_json.open_array('coordinates');
		apex_json.write(rec.lon);
		apex_json.write(rec.lat);
		apex_json.close_array();	--coordinates
		apex_json.close_object();	--geometry
		apex_json.close_object();
	end loop;

	apex_json.close_array();	--features
	apex_json.close_object();
	apex_json.close_array();
	
	v_json_clob := apex_json.get_clob_output;

	apex_json.free_output;
   
	return v_json_clob;
end;
/
