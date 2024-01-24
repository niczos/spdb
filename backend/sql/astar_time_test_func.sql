-- function for calculating stats (total len in km, total time in hours) for astar with time cost
CREATE OR REPLACE FUNCTION route_stats_astar_time(table_name text)
    RETURNS TABLE(
                     route_config text,
                     total_length_km DOUBLE PRECISION,
                     total_time_h DOUBLE PRECISION
                 ) AS $$
    BEGIN
        RETURN QUERY
            EXECUTE format('SELECT $1 as route_config, SUM(res.length_km) as total_length_km,
                           MAX(res.agg_cost) as total_time_h
                           FROM %I res',
                table_name) USING table_name;
    END; $$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION calculate_stats_time(route_name text)
RETURNS void AS $$
    BEGIN
         EXECUTE format('CREATE TABLE %I AS SELECT %L as cost_func, *, 90 as max_speed, 0 as heur FROM route_stats_astar_time($1)',
                       route_name||'_Stats','time') USING route_name||'_best_time_sp_90_heur_0';
					   
		EXECUTE format('INSERT INTO %I SELECT %L as cost_func, *, 100 as max_speed, 0 as heur FROM route_stats_astar_time($1)',
                       route_name||'_Stats','time') USING route_name||'_best_time_sp_100_heur_0';
					   
		EXECUTE format('INSERT INTO %I SELECT %L as cost_func, *, 120 as max_speed, 0 as heur FROM route_stats_astar_time($1)',
                       route_name||'_Stats','time') USING route_name||'_best_time_sp_120_heur_0';
					   
		EXECUTE format('INSERT INTO %I SELECT %L as cost_func, *, 140 as max_speed, 0 as heur FROM route_stats_astar_time($1)',
                       route_name||'_Stats','time') USING route_name||'_best_time_sp_140_heur_0';
					   
		------			   
					   
        EXECUTE format('INSERT INTO %I SELECT %L as cost_func, *, 140 as max_speed, 1 as heur FROM route_stats_astar_time($1)',
                       route_name||'_Stats','time') USING route_name||'_best_time_sp_140_heur_1';
					   
		EXECUTE format('INSERT INTO %I SELECT %L as cost_func, *, 140 as max_speed, 2 as heur FROM route_stats_astar_time($1)',
                       route_name||'_Stats','time') USING route_name||'_best_time_sp_140_heur_2';
					   
		----			   
					   
		EXECUTE format('INSERT INTO %I SELECT %L as cost_func, *, 140 as max_speed, 3 as heur FROM route_stats_astar_time($1)',
                       route_name||'_Stats','time') USING route_name||'_best_time_sp_140_heur_3';
					   
		EXECUTE format('INSERT INTO %I SELECT %L as cost_func, *, 120 as max_speed, 3 as heur FROM route_stats_astar_time($1)',
                       route_name||'_Stats','time') USING route_name||'_best_time_sp_120_heur_3';
					   
		EXECUTE format('INSERT INTO %I SELECT %L as cost_func, *, 100 as max_speed, 3 as heur FROM route_stats_astar_time($1)',
                       route_name||'_Stats','time') USING route_name||'_best_time_sp_100_heur_3';
					   
		EXECUTE format('INSERT INTO %I SELECT %L as cost_func, *, 90 as max_speed, 3 as heur FROM route_stats_astar_time($1)',
                       route_name||'_Stats','time') USING route_name||'_best_time_sp_90_heur_3';		   
		-----			   
					   
		EXECUTE format('INSERT INTO %I SELECT %L as cost_func, *, 140 as max_speed, 4 as heur FROM route_stats_astar_time($1)',
                       route_name||'_Stats','time') USING route_name||'_best_time_sp_140_heur_4';
					   
		EXECUTE format('INSERT INTO %I SELECT %L as cost_func, *, 140 as max_speed, 5 as heur FROM route_stats_astar_time($1)',
				   route_name||'_Stats','time') USING route_name||'_best_time_sp_140_heur_5';
	 END; $$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION test_routes_time(start_id BIGINT, end_id BIGINT, route_name text)
RETURNS void AS $$
    BEGIN
        EXECUTE format('CREATE TABLE %I AS SELECT id, the_geom FROM ways_vertices_pgr WHERE id=$1 OR id=$2',
            route_name) USING start_id, end_id;
			
		-- checking heuristic parameter 	

        EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, res.agg_cost, w.length_km, w.the_geom as the_geom 
							FROM astar_time($1, $2, 140, 0) res join ways w on res.edge=w.gid', 
						    route_name||'_best_time_sp_140_heur_0')
            			USING start_id, end_id;
						
        EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, res.agg_cost, w.length_km, w.the_geom as the_geom 
							FROM astar_time($1, $2, 140, 1) res join ways w on res.edge=w.gid', 
						    route_name||'_best_time_sp_140_heur_1')
            			USING start_id, end_id;
			
        EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, res.agg_cost, w.length_km, w.the_geom as the_geom 
							FROM astar_time($1, $2, 140, 2) res join ways w on res.edge=w.gid', 
						    route_name||'_best_time_sp_140_heur_2')
            			USING start_id, end_id;
			
        EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, res.agg_cost, w.length_km, w.the_geom as the_geom 
							FROM astar_time($1, $2, 140, 3) res join ways w on res.edge=w.gid', 
						    route_name||'_best_time_sp_140_heur_3')
            			USING start_id, end_id;
			
        EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, res.agg_cost, w.length_km, w.the_geom as the_geom 
							FROM astar_time($1, $2, 140, 4) res join ways w on res.edge=w.gid', 
						    route_name||'_best_time_sp_140_heur_4')
            			USING start_id, end_id;
						
						
        EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, res.agg_cost, w.length_km, w.the_geom as the_geom 
							FROM astar_time($1, $2, 140, 5) res join ways w on res.edge=w.gid', 
						    route_name||'_best_time_sp_140_heur_5')
            			USING start_id, end_id;
						
		-- checking speed parameter 
		
		EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, res.agg_cost, w.length_km, w.the_geom as the_geom 
							FROM astar_time($1, $2, 90, 0) res join ways w on res.edge=w.gid', 
						    route_name||'_best_time_sp_90_heur_0')
            			USING start_id, end_id;
						
		EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, res.agg_cost, w.length_km, w.the_geom as the_geom 
					FROM astar_time($1, $2, 100, 0) res join ways w on res.edge=w.gid', 
					route_name||'_best_time_sp_100_heur_0')
						USING start_id, end_id;
			
        EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, res.agg_cost, w.length_km, w.the_geom as the_geom 
							FROM astar_time($1, $2, 120, 0) res join ways w on res.edge=w.gid', 
						    route_name||'_best_time_sp_120_heur_0')
            			USING start_id, end_id;
						
		-- checking speed and heur=3
		
		EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, res.agg_cost, w.length_km, w.the_geom as the_geom 
							FROM astar_time($1, $2, 90, 3) res join ways w on res.edge=w.gid', 
						    route_name||'_best_time_sp_90_heur_3')
            			USING start_id, end_id;
						
		EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, res.agg_cost, w.length_km, w.the_geom as the_geom 
					FROM astar_time($1, $2, 100, 3) res join ways w on res.edge=w.gid', 
					route_name||'_best_time_sp_100_heur_3')
						USING start_id, end_id;
			
        EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, res.agg_cost, w.length_km, w.the_geom as the_geom 
							FROM astar_time($1, $2, 120, 3) res join ways w on res.edge=w.gid', 
						    route_name||'_best_time_sp_120_heur_3')
            			USING start_id, end_id;
	
	
        PERFORM calculate_stats_time(route_name);
    END; $$
LANGUAGE plpgsql;