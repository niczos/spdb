from flask import Flask, jsonify
from db_connector import connect, close_connection

app = Flask(__name__)

@app.route('/get_route')
def get_route():
    conn = connect()
    cursor = conn.cursor()

    try:
        query = "SELECT * FROM ...;"
        cursor.execute(query)

        result = cursor.fetchall()

        data = {
            'route': result,
            'details': 'Szczegóły trasy',
        }
        return jsonify(data)

    except Exception as e:
        print(e)
    finally:
        cursor.close()
        close_connection(conn)

if __name__ == '__main__':
    app.run(debug=True)
