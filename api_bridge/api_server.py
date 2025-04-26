from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/nova_to_elias', methods=['POST'])
def nova_to_elias():
    data = request.json
    print(f"[Nova->Elias API] Received: {data}")
    return jsonify({"status": "received", "echo": data})

@app.route('/elias_to_nova', methods=['POST'])
def elias_to_nova():
    data = request.json
    print(f"[Elias->Nova API] Received: {data}")
    return jsonify({"status": "received", "echo": data})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5050)
