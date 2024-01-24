
select * from ways where source=1969650;

-- Warszawa  - 52.229916, 21.0122043, source - 3190533
-- Kraków - 50.0647012, 19.9460984, source - 1969650
DO $$
DECLARE route_name TEXT := 'Warszawa_Kraków'; 
BEGIN
PERFORM test_routes_time(3190533, 1969650, route_name);
PERFORM test_routes_length(3190533, 1969650, route_name);	
END $$;

SELECT * from "Warszawa_Kraków_Stats" order by total_time_h;
SELECT * from "Warszawa_Kraków_Stats" order by total_length_km;

-- Warszawa Kabaty -   52.129543, 21.073175, source - 3205068
-- Warszawa Ursus - 52.195248, 20.884162, source - 3238859
DO $$
DECLARE route_name TEXT := 'Kabaty_Ursus'; 
BEGIN
PERFORM test_routes_time(3205068, 3238859, route_name);
PERFORM test_routes_length(3205068, 3238859, route_name);	
END $$;

SELECT * from "Kabaty_Ursus_Stats" order by total_time_h;
SELECT * from "Kabaty_Ursus_Stats" order by total_length_km;


-- Warszawa  - 52.229916, 21.0122043, source - 3190533
-- Łódź - 51.759356, 19.455861, source - 4022751
DO $$
DECLARE route_name TEXT := 'Warszawa_Łódź'; 
BEGIN
PERFORM test_routes_time(3190533, 4022751, route_name);
PERFORM test_routes_length(3190533, 4022751, route_name);	
END $$;

SELECT * from "Warszawa_Łódź_Stats" order by total_time_h;
SELECT * from "Warszawa_Łódź_Stats" order by total_length_km;


select s.* FROM(
SELECT source,
 least(st_distance(st_makepoint(51.759356, 19.455861), st_makepoint(y2,x2)),
	   st_distance(st_makepoint(51.759356, 19.455861), st_makepoint(y1,x1))) as dist,
	*
FROM ways
order by dist
limit 1) s;

select s.* FROM(
SELECT source,
 least(st_distance(st_makepoint(52.195248, 20.884162), st_makepoint(y2,x2)),
	   st_distance(st_makepoint(52.195248, 20.884162), st_makepoint(y1,x1))) as dist,
	*
FROM ways
order by dist
limit 1) s;


-- remove tables if needed
DO $$ 
	BEGIN
		PERFORM drop_tables_mult('public',format('%s','Warszawa_Kraków'));
		PERFORM drop_tables_mult('public',format('%s','Warszawa_Łódź'));
		PERFORM drop_tables_mult('public',format('%s','Kabaty_Ursus'));
END $$;

