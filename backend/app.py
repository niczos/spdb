from flask import Flask, request, jsonify
from flask_cors import CORS
from db_connector import connect, close_connection
from db_service import DatabaseService, Point, Route

app = Flask(__name__)
CORS(app, resources={r"/get_route": {"origins": "*"}})

data_service = DatabaseService()

@app.route('/get_route', methods=['POST'])
def get_route():
    try:
        request_data = request.get_json()

        source_latitude = request_data.get('sourceLatitude')
        source_longitude = request_data.get('sourceLongitude')
        start_point = Point(source_latitude, source_longitude)
        destination_latitude = request_data.get('destinationLatitude')
        destination_longitude = request_data.get('destinationLongitude')
        end_point = Point(destination_latitude, destination_longitude)
        max_speed = request_data.get('speedLimit')
        heuristic = 0

        start_id = data_service.get_start_or_end(start_point, is_start_point=True)
        end_id = data_service.get_start_or_end(end_point, is_start_point=False)

        route_time, route_length = data_service.find_route(start_id, end_id, max_speed, heuristic)

        return jsonify({
            'route_time': {
                'segments': [
                    {
                        'id': segment.id,
                        'length': segment.length,
                        'max_speed_forward': segment.max_speed_forward,
                        'coordinates': [
                            {'latitude': segment.y1, 'longitude': segment.x1},
                            {'latitude': segment.y2, 'longitude': segment.x2},
                        ]
                    } for segment in route_time.segments
                ],
                'distance': route_time.distance,
                'estimated_time': route_time.estimated_time
            },
            'route_length': {
                'segments': [
                    {
                        'id': segment.id,
                        'length': segment.length,
                        'max_speed_forward': segment.max_speed_forward,
                        'coordinates': [
                            {'latitude': segment.y1, 'longitude': segment.x1},
                            {'latitude': segment.y2, 'longitude': segment.x2},
                        ]
                    } for segment in route_length.segments
                ],
                'distance': route_length.distance,
                'estimated_time': route_length.estimated_time
            }
        })

        return jsonify(request_data)

    except Exception as e:
        print(f"An error occurred: {e}")
        return jsonify({'error': 'An error occurred while processing the request'}), 500

if __name__ == '__main__':
    app.run(debug=True)