from db_connector import connect, close_connection

class Point:
    def __init__(self, latitude, longitude):
        self.latitude = latitude
        self.longitude = longitude

    def get_latitude(self):
        return self.latitude

    def get_longitude(self):
        return self.longitude
    
class PointLine:
    def __init__(self, points):
        self.points = points

    def add_point(self, point):
        self.points.append(point)

    def get_coordinates(self):
        return [(point.get_latitude, point.get_longitude) for point in self.points]


class Route:
    def __init__(self, segments, distance, estimated_time):
        self.segments = segments
        self.distance = distance
        self.estimated_time = estimated_time
        self.coordinate_line = None

    def get_coordinate_line(self):
        if self.coordinate_line is None:
            coordinates = []

            list_iterator = iter(self.segments)
            is_first = True

            for route_segment in list_iterator:
                if is_first:
                    coordinates.append(Point(route_segment.y1(), route_segment.x1()))
                    is_first = False

                coordinates.append(Point(route_segment.y2(), route_segment.x2()))

            self.coordinate_line = PointLine(coordinates)

        return self.coordinate_line


class RouteSegment:
    def __init__(self, id, geom, source, target, length, max_speed_forward, max_speed_backward, x1, y1, x2, y2):
        self.id = id
        self.geom = geom
        self.source = source
        self.target = target
        self.length = length
        self.max_speed_forward = max_speed_forward
        self.max_speed_backward = max_speed_backward
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2

    def get_length(self):
        return self.length

    def get_max_speed_forward(self):
        return self.max_speed_forward
    
    def get_max_speed_backward(self):
        return self.max_speed_backward


class DatabaseService:
    def __init__(self):
        pass

    NEAREST_START_ID_SQL = "SELECT source FROM ways " + "ORDER BY ST_DISTANCE(ST_MAKEPOINT(%s, %s), ST_MAKEPOINT(y1, x1)) LIMIT 1;"
    NEAREST_END_ID_SQL = "SELECT source FROM ways " + "ORDER BY ST_DISTANCE(ST_MAKEPOINT(%s, %s), ST_MAKEPOINT(y2, x2)) LIMIT 1;"
    FIND_ROUTE_TIME_SQL = "SELECT w.gid, w.the_geom, w.source, w.target, w.length_km, w.maxspeed_forward, w.maxspeed_backward, w.x1, w.y1, w.x2, w.y2 " + "FROM astar_time(%s, %s, %s, %s) res JOIN ways w ON res.edge=w.gid;"
    FIND_ROUTE_LENGTH_SQL = "SELECT w.gid, w.the_geom, w.source, w.target, w.length_km, w.maxspeed_forward, w.maxspeed_backward, w.x1, w.y1, w.x2, w.y2 " + "FROM astar_length(%s, %s, %s) res JOIN ways w ON res.edge=w.gid;"

    def get_connection(self):
        conn = connect()
        return conn

    def get_start_or_end(self, point, is_start_point):
        try:
            with self.get_connection() as connection:
                cursor = connection.cursor()
                query = self.NEAREST_START_ID_SQL if is_start_point else self.NEAREST_END_ID_SQL
                cursor.execute(query, (point.get_latitude(), point.get_longitude()))
                result = cursor.fetchone()

                if result:
                    return result[0]

                return -1

        except Exception as e:
            print(f"An error occurred: {e}")
            raise

    def find_route(self, start_id, end_id, max_speed, heuristic):
        try:
            with self.get_connection() as connection:
                cursor = connection.cursor()
                cursor.execute(self.FIND_ROUTE_TIME_SQL, (start_id, end_id, max_speed, heuristic))
                result_time = cursor.fetchall()

                cursor = connection.cursor()
                cursor.execute(self.FIND_ROUTE_LENGTH_SQL, (start_id, end_id, heuristic))
                result_length = cursor.fetchall()

                return self.parse_query_result(result_time, int(max_speed)), self.parse_query_result(result_length, 1000)

        except Exception as e:
            print(f"An error occurred: {e}")
            raise

    @staticmethod
    def parse_record(record):
        id, geom, source, target, length, max_speed_forward, max_speed_backward, x1, y1, x2, y2 = record
        return RouteSegment(id, geom, source, target, length, max_speed_forward, max_speed_backward, x1, y1, x2, y2)

    def parse_query_result(self, result, max_speed):
        segments = []
        distance_sum = 0
        time_sum = 0

        for record in result:
            segment = self.parse_record(record)
            distance_sum += segment.get_length()
            time_sum += segment.get_length() / min(segment.get_max_speed_forward(), max_speed)
            segments.append(segment)

        return Route(segments, distance_sum, time_sum)

