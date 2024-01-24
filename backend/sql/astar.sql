-- a* shortest path finding with time-based cost
CREATE OR REPLACE FUNCTION astar_time(start_id BIGINT, end_id BIGINT, target_speed int,heuristic int)
     RETURNS TABLE(
         seq INT,
         path_seq INT,
         node BIGINT,
         edge BIGINT,
         cost DOUBLE PRECISION,
         agg_cost DOUBLE PRECISION
                  ) AS $$
    BEGIN
        RETURN QUERY
            SELECT r.seq, r.path_seq, r.node, r.edge, r.cost, r.agg_cost
			FROM pgr_astar('SELECT gid AS id,
                         source::integer,
                         target::integer,
                         w.length_km/least(w.maxspeed_forward,'||target_speed||')::double precision AS cost,
                         w.length_km/least(w.maxspeed_backward,'||target_speed||')::double precision  AS reverse_cost,
                         x1, y1, x2, y2
                         FROM ways w', start_id, end_id, true, heuristic) r;
    END; $$
    LANGUAGE plpgsql;
	
    
-- a* shortest path finding with distance-based cost    
CREATE OR REPLACE FUNCTION astar_length(start_id BIGINT, end_id BIGINT, heuristic int)
     RETURNS TABLE(
         seq INT,
         path_seq INT,
         node BIGINT,
         edge BIGINT,
         cost DOUBLE PRECISION,
         agg_cost DOUBLE PRECISION
                  ) AS $$
    BEGIN
        RETURN QUERY
            SELECT r.seq, r.path_seq, r.node, r.edge, r.cost, r.agg_cost
			FROM pgr_astar('SELECT gid AS id,
                         source::integer,
                         target::integer,
                         w.length_km::double precision AS cost,
                         w.length_km::double precision  AS reverse_cost,
                         x1, y1, x2, y2
                         FROM ways w', start_id, end_id, true, heuristic) r;
    END; $$
    LANGUAGE plpgsql;
	
