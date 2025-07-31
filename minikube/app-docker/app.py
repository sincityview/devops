import socket
from flask import Flask

app = Flask(__name__)

@app.route('/')
def get_hostname():
    hostname = socket.gethostname()
    return f"Pod name is {hostname}"

if __name__ == '__main__':
    app.run()