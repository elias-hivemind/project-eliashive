# SAFE EliasNorth Flask AI Website Builder
from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return "Welcome to EliasNorth AI Website — System Online."

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
