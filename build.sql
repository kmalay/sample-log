create table test(
    id          number,
    text        varchar2(200),
    lat         number,
    lon         number,
    geo_point   sdo_geometry
);

create sequence test_id_s start with 10001 increment by 1;

update test set id = test_id_s.nextval;

commit;

alter table test modify id number not null;

alter table test add constraint test_pk primary key (id);

exec dbms_stats.gather_table_stats(user, 'TEST');

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
