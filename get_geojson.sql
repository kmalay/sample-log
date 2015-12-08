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

	for rec in (select a.id, a.lat, a.lon from test a where rownum <= 20000)
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

sho err
