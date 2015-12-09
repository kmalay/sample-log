-- Add lat/lon and geometry column to test table
alter table test add lat number;
alter table test add lon number;
alter table test add geo_point sdo_geometry;

-- Populate geometry based on lat/lon
update test
   set geo_point = sdo_geometry(2001,4326,sdo_point_type(lon,lat,null),null,null)
/

commit;

-- Add spatial metadata for indexing
delete from user_sdo_geom_metadata;
insert into user_sdo_geom_metadata values (
	'test',
	'geo_point',
	sdo_dim_array(
		sdo_dim_element('X',0,20,0.5),
		sdo_dim_element('Y',0,20,0.5)
	),
	4326
);

commit;

-- Create the spatial index
  drop index test_sp_idx;
create index test_sp_idx
	on test (geo_point)
	indextype is mdsys.spatial_index
	parameters ('layer_gtype=point');

select a.geo_point.sdo_point.x lon, a.geo_point.sdo_point.y lat
  from test a
 where rownum <= 10
/

-- Function to be used as an on-demand process that returns geoJSON
declare
	v_clob	clob;
begin
	v_clob := 
		'[{
		"type": "FeatureCollection",
		"crs": { "type": "name", "properties": { "name": "urn:ogc:def:crs:OGC:1.3:CRS84" } },                                                                        
		"features": [ ';

	for rec in (select a.id, a.geo_point from test a where rownum <= 200)
	loop
		v_clob := v_clob ||
			'{ "type": "Feature", "id": '||to_char(rec.id)||', "properties": { "ID": '||to_char(rec.id)||' }, '||'"geometry": { "type": "Point", '||
			'"coordinates": [ '||to_char(rec.geo_point.sdo_point.x)||', '||to_char(rec.geo_point.sdo_point.y)||' ] } },';
			--dbms_output.put_line(rec.id);
	end loop;
	
	v_clob := rtrim(v_clob, ',');
	
	v_clob := v_clob || ' ] } ]';
	--dbms_output.put_line(v_clob);
	htp.p(v_clob);
end;

-- Validate geometry in test table
select a.id, SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(a.geo_point, 0.005)
  from test a
 where SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(a.geo_point, 0.005) != 'TRUE'
/

-- Return the number of records that are within 10 kilometers of specific point
select count(*)
  from test a
 where sdo_within_distance(
	a.geo_point,
	sdo_geometry(2001,4326,sdo_point_type(52.38398208257353,13.423233032226562,null),null,null),
	'distance=10 unit=KM') = 'TRUE'
/

-- Return the 10 closest records to a specific point
select a.id, a.geo_point.sdo_point.x lon, a.geo_point.sdo_point.y lat
  from test a
 where sdo_nn(
	a.geo_point,
	sdo_geometry(2001,4326,sdo_point_type(52.38398208257353 ,13.423233032226562,null),null,null),
	'sdo_num_res=10 unit=KM') = 'TRUE'
/

