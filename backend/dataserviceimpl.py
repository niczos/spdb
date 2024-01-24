import psycopg2
from sothawo.mapjfx import Coordinate, CoordinateLine

class Point:
    def __init__(self, latitude, longitude):
        self.latitude = latitude
        self.longitude = longitude

    def latitude(self):
        return self.latitude

    def longitude(self):
        return self.longitude


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
                    coordinates.append(Coordinate(route_segment.y1(), route_segment.x1()))
                    is_first = False

                coordinates.append(Coordinate(route_segment.y2(), route_segment.x2()))

            self.coordinate_line = CoordinateLine(coordinates)

        return self.coordinate_line


class RouteSegment:
    def __init__(self, id, geom, source, target, length, max_speed_forward, x1, y1, x2, y2):
        self.id = id
        self.geom = geom
        self.source = source
        self.target = target
        self.length = length
        self.max_speed_forward = max_speed_forward
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2

    def length(self):
        return self.length

    def max_speed_forward(self):
        return self.max_speed_forward


class DatabaseServiceImpl:
    def __init__(self, db_url, db_username, db_password):
        self.DB_URL = db_url
        self.DB_USERNAME = db_username
        self.DB_PASSWORD = db_password

    NEAREST_START_ID_SQL = "SELECT source FROM ways " + "order by st_distance(st_makepoint(?,?), st_makepoint(y1,x1)) limit 1;"
    NEAREST_END_ID_SQL = "SELECT source FROM ways " + "order by st_distance(st_makepoint(?,?), st_makepoint(y2,x2)) limit 1;"
    FIND_ROUTE_SQL = "SELECT w.gid, w.the_geom, w.source, w.target, w.length_m, w.maxspeed_forward, " + "w.maxspeed_backward, w.x1, w.y1, w.x2, w.y2 " + "FROM astar(?, ?, ?, ?, 0) res join ways w on res.edge=w.gid;"

    def get_connection(self):
        connection = psycopg2.connect(
            database=self.DB_URL,
            user=self.DB_USERNAME,
            password=self.DB_PASSWORD
        )
        connection.autocommit = True
        return connection

    def get_start_or_end(self, point, is_start_point):
        try:
            with self.get_connection() as connection:
                cursor = connection.cursor()
                query = self.NEAREST_START_ID_SQL if is_start_point else self.NEAREST_END_ID_SQL
                cursor.execute(query, (point.latitude(), point.longitude()))
                result = cursor.fetchone()

                if result:
                    return result[0]

                return -1

        except Exception as e:
            print(f"An error occurred: {e}")
            raise

    def find_route(self, start_id, end_id, max_speed, distance_weight):
        try:
            with self.get_connection() as connection:
                cursor = connection.cursor()
                cursor.execute(self.FIND_ROUTE_SQL, (start_id, end_id, max_speed, distance_weight))
                result = cursor.fetchall()

                return self.parse_query_result(result, max_speed)

        except Exception as e:
            print(f"An error occurred: {e}")
            raise

    @staticmethod
    def parse_record(record):
        id, geom, source, target, length, max_speed_forward, x1, y1, x2, y2 = record
        return RouteSegment(id, geom, source, target, length / 1000, max_speed_forward, x1, y1, x2, y2)

    def parse_query_result(self, result, max_speed):
        segments = []
        distance_sum = 0
        time_sum = 0

        for record in result:
            segment = self.parse_record(record)
            distance_sum += segment.length()
            time_sum += segment.length() / min(segment.max_speed_forward(), max_speed)
            segments.append(segment)

        print(f"Segments number: {len(segments)}")
        return Route(segments, distance_sum, time_sum)

