from flask import Flask, render_template
from dotenv import load_dotenv
import mariadb
import sys, os

app = Flask(__name__)

app.config['DB_CONFIG'] = {
    'host': os.getenv('APP_DB_HOST', '127.0.0.1'),
    'port': int(os.getenv('APP_DB_PORT', 3306)),
    'user': os.getenv('APP_DB_USER', 'flask_app_user'),
    'password': os.getenv('APP_DB_PASSWORD', 'flask_app_password'),
    'database': os.getenv('APP_DB_NAME', 'flask_app_db')
}

def get_db_connection():
    try:
        conn = mariadb.connect(**app.config['DB_CONFIG'])
        return conn
    except mariadb.Error as e:
        print(f"Error connecting to MariaDB: {e}")
        sys.exit(1)

@app.route('/')
def show_users():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        cursor.execute("SELECT username, email FROM users")
        users = cursor.fetchall()
    except mariadb.Error as e:
        return f"Error fetching data: {e}", 500
    finally:
        cursor.close()
        conn.close()
    
    return render_template('index.html', users=users)

if __name__ == '__main__':
    app.run()