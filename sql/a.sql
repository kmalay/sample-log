declare
    v_query	    varchar2(4000);
begin
    if coalesce(:P3_LON, :P3_LAT) is null
    then
        v_query :=
            'select a.id,' ||
            '       a.geo_point.sdo_point.x lon,' ||
            '       a.geo_point.sdo_point.y lat,' ||
            '       a.text,' ||
            '       null distance' ||
            '   from test a' ||
            ' where 1 = 2';
    else
        v_query :=
            'select a.id,' ||
            '       a.geo_point.sdo_point.x lon,' ||
            '       a.geo_point.sdo_point.y lat,' ||
            '       a.text,' ||
            '       round(sdo_geom.sdo_distance(' ||
            '                 a.geo_point,' ||
            '                 sdo_geometry(2001, 4326, sdo_point_type(:P3_LON, :P3_LAT, null), null, null),' ||
            '                 0.005,' ||
            '                 ''unit=M''' ||
            '            )' ||
            '       ) distance' ||
            '  from test a' ||
            ' where sdo_nn(' ||
            '           a.geo_point,' ||
            '           sdo_geometry(2001, 4326, sdo_point_type(:P3_LON, :P3_LAT, null), null, null),' ||
            '           ''sdo_num_res=10 unit=M''' ||
            '       ) = ''TRUE''' ||
            ' order by 5';
    end if;

    return v_query;
end;
