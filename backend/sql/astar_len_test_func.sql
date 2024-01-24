-- function for calculating stats (total len in km, total time in hours) for astar with distance cost
CREATE OR REPLACE FUNCTION route_stats_astar_length(table_name text)
    RETURNS TABLE(
                     route_config text,
                     total_length_km DOUBLE PRECISION,
                     total_time_h DOUBLE PRECISION
                 ) AS $$
    BEGIN
        RETURN QUERY
            EXECUTE format('SELECT $1 as route_config, 
						   MAX(res.agg_cost) as total_length_km,
                           SUM(CASE WHEN 
						   			begin_node=source_node 
						   		THEN 
						   			(res.length_km/max_for) 
						   		ELSE 
						   			(res.length_km/max_back) 
						   		END) as total_time_h
                           FROM %I res',
                table_name) USING table_name;
    END; $$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION calculate_stats_len(route_name text)
RETURNS void AS $$
    BEGIN
         EXECUTE format('CREATE TABLE IF NOT EXISTS %I AS SELECT %L as cost_func, *, null as max_speed, 0 as heur FROM route_stats_astar_length($1)',
                       route_name||'_Stats','length') USING route_name||'_best_len_heur_0';
					   
        EXECUTE format('INSERT INTO %I SELECT %L as cost_func, *, null as max_speed, 1 as heur FROM route_stats_astar_length($1)',
                       route_name||'_Stats','length') USING route_name||'_best_len_heur_1';
					   
		EXECUTE format('INSERT INTO %I SELECT %L as cost_func, *, null as max_speed, 2 as heur FROM route_stats_astar_length($1)',
                       route_name||'_Stats','length') USING route_name||'_best_len_heur_2';
					   
		EXECUTE format('INSERT INTO %I SELECT %L as cost_func, *, null as max_speed, 3 as heur FROM route_stats_astar_length($1)',
                       route_name||'_Stats','length') USING route_name||'_best_len_heur_3';
					   
		EXECUTE format('INSERT INTO %I SELECT %L as cost_func, *, null as max_speed, 4 as heur FROM route_stats_astar_length($1)',
                       route_name||'_Stats','length') USING route_name||'_best_len_heur_4';
					   
		EXECUTE format('INSERT INTO %I SELECT %L as cost_func, *, null as max_speed, 5 as heur FROM route_stats_astar_length($1)',
				   route_name||'_Stats','length') USING route_name||'_best_len_heur_5';
	 END; $$
LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION test_routes_length(start_id BIGINT, end_id BIGINT, route_name text)
RETURNS void AS $$
    BEGIN
        EXECUTE format('CREATE TABLE IF NOT EXISTS %I AS SELECT id, the_geom FROM ways_vertices_pgr WHERE id=$1 OR id=$2',
            route_name) USING start_id, end_id;

        EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, w.the_geom as the_geom, w.source as begin_node, 
							res.node as source_node, res.agg_cost, w.length_km, w.maxspeed_forward as max_for, w.maxspeed_backward as max_back
							FROM astar_length($1, $2, 0) res join ways w on res.edge=w.gid', 
						    route_name||'_best_len_heur_0')
            			USING start_id, end_id;
			
        EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, w.the_geom as the_geom, w.source as begin_node, 
					   		res.node as source_node, res.agg_cost, w.length_km, w.maxspeed_forward as max_for, w.maxspeed_backward as max_back
                        	FROM astar_length($1, $2, 1) res join ways w on res.edge=w.gid', 
					   		route_name||'_best_len_heur_1')
						USING start_id, end_id;
							
		EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, w.the_geom as the_geom, w.source as begin_node, 
					   		res.node as source_node, res.agg_cost, w.length_km, w.maxspeed_forward as max_for, w.maxspeed_backward as max_back
                        	FROM astar_length($1, $2, 2) res join ways w on res.edge=w.gid', 
					   		route_name||'_best_len_heur_2')
						USING start_id, end_id;
							
		EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, w.the_geom as the_geom, w.source as begin_node, 
							res.node as source_node, res.agg_cost, w.length_km, w.maxspeed_forward as max_for, w.maxspeed_backward as max_back
							FROM astar_length($1, $2, 3) res join ways w on res.edge=w.gid', 
							route_name||'_best_len_heur_3')
						USING start_id, end_id;
						
		EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, w.the_geom as the_geom, w.source as begin_node, 
						   res.node as source_node, res.agg_cost, w.length_km, w.maxspeed_forward as max_for, w.maxspeed_backward as max_back
						   FROM astar_length($1, $2, 4) res join ways w on res.edge=w.gid', 
						   route_name||'_best_len_heur_4')
						USING start_id, end_id;
						
		EXECUTE format('CREATE TABLE %I AS SELECT w.gid as edge, w.the_geom as the_geom, w.source as begin_node, 
						   res.node as source_node, res.agg_cost, w.length_km, w.maxspeed_forward as max_for, w.maxspeed_backward as max_back
						   FROM astar_length($1, $2, 5) res join ways w on res.edge=w.gid', 
						   route_name||'_best_len_heur_5')
						USING start_id, end_id;
	
        PERFORM calculate_stats_len(route_name);
		
		
    END; $$
LANGUAGE plpgsql;

