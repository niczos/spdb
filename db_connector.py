import psycopg2
from db_config import db_config

def connect():
    conn = None
    try:
        conn = psycopg2.connect(**db_config)
        return conn
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)

def close_connection(conn):
    if conn is not None:
        conn.close()
