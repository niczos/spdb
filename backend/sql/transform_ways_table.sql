-- add a column with length in km
alter table ways
add column IF NOT EXISTS length_km double precision; 

update ways 
set length_km = length_m/1000; 

-- drop unused columns
ALTER TABLE ways 
DROP COLUMN IF EXISTS cost_s,
DROP COLUMN IF EXISTS reverse_cost_s,
DROP COLUMN IF EXISTS rule,
DROP COLUMN IF EXISTS priority,
DROP COLUMN IF EXISTS cost,
DROP COLUMN IF EXISTS reverse_cost;


------ data corrections -------------------------------

-- correct ways where len is null
-- ST_LENGTH(the_geom, true) - length in meters
UPDATE ways
SET length_m = ST_LENGTH(the_geom, true)
where length_m is null;

UPDATE ways
SET length_km = ST_LENGTH(the_geom, true)/1000
where length_km is null;



--- fill in maxspeed_backward after checking manually on osm website (only two rows)
UPDATE ways
SET maxspeed_backward = 90
WHERE maxspeed_backward=0 and source_osm=5182143476 and target_osm=5181475837;

UPDATE ways
SET maxspeed_backward = 90
WHERE maxspeed_backward=0 and source_osm=2380612498 and target_osm=5182143476;
