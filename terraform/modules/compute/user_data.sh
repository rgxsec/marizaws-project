#!/bin/bash
yum update -y
yum install -y python3 python3-pip postgresql15

pip3 install flask psycopg2-binary

cat > /home/ec2-user/app.py << 'EOF'
from flask import Flask, request, jsonify
import psycopg2

app = Flask(__name__)

def get_db():
    return psycopg2.connect(
        host="${db_host}",
        dbname="${db_name}",
        user="${db_username}",
        password="${db_password}"
    )

@app.route('/')
def login_page():
    return '''
        <form method="POST" action="/login">
            <input type="text" name="username" placeholder="Username"/>
            <input type="password" name="password" placeholder="Password"/>
            <button type="submit">Login</button>
        </form>
    '''

@app.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute("SELECT id FROM users WHERE username=%s AND password=%s", (username, password))
        user = cur.fetchone()
        if user:
            return jsonify({"status": "success"}), 200
        return jsonify({"status": "unauthorized"}), 401
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
EOF

# Seed the database with fake users
python3 - << 'PYEOF'
import psycopg2
conn = psycopg2.connect(
    host="${db_host}",
    dbname="${db_name}",
    user="${db_username}",
    password="${db_password}"
)
cur = conn.cursor()
cur.execute("CREATE TABLE IF NOT EXISTS users (id SERIAL PRIMARY KEY, username VARCHAR(50), password VARCHAR(50))")
cur.execute("INSERT INTO users (username, password) VALUES ('admin', 'admin123'), ('john', 'password1'), ('jane', 'letmein')")
conn.commit()
PYEOF

# Start the app
python3 /home/ec2-user/app.py &