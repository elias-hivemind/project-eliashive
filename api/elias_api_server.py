from flask import Flask, jsonify, send_file
import os
import glob

app = Flask(__name__)
BASE_DIR = os.path.expanduser("~/eliashive_repo")
LOG_DIR = os.path.join(BASE_DIR, "logs")
INSIGHTS_DIR = os.path.join(BASE_DIR, "memory_core/insights")

@app.route('/api/brainfeed')
def brainfeed():
    files = sorted(glob.glob(os.path.join(INSIGHTS_DIR, "top_ai_repos_*.txt")), reverse=True)
    if files:
        with open(files[0], "r") as f:
            return jsonify({"brainfeed": f.read()})
    return jsonify({"error": "No brainfeed data yet."})

@app.route('/api/logs')
def logs():
    files = sorted(glob.glob(os.path.join(LOG_DIR, "sentinel_*.log")), reverse=True)
    if files:
        with open(files[0], "r") as f:
            return jsonify({"logs": f.read()})
    return jsonify({"error": "No logs available."})

@app.route('/api/memory')
def memory():
    files = sorted(glob.glob(os.path.join(INSIGHTS_DIR, "*.txt")), reverse=True)
    data = {}
    for file in files:
        with open(file, "r") as f:
            data[os.path.basename(file)] = f.read()
    return jsonify({"memory_core": data})

@app.route('/api/status')
def status():
    try:
        processes = os.popen("ps aux | grep -E 'nova_guardian|intel_harvester|github_sync|drive_sync|brainfeed' | grep -v grep").read()
        return jsonify({"status": processes})
    except Exception as e:
        return jsonify({"error": str(e)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
