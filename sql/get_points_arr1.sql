create or replace
function get_points_arr1
  return clob as
	v_json_clob	clob;
	v_return	varchar2(4000);
begin
	apex_json.initialize_clob_output;

	apex_json.open_array();

	for rec in (select a.id, a.lat, a.lon, a.text from test a where id <= 35000)
	loop
		apex_json.open_array();
		apex_json.write(rec.lat);
		apex_json.write(rec.lon);
		apex_json.write(rec.text);
		apex_json.close_array();
	end loop;

	apex_json.close_array();

	v_json_clob := apex_json.get_clob_output;

	apex_json.free_output;

	return v_json_clob;
end;
/

sho err
