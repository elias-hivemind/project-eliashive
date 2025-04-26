from flask import Flask, render_template_string, request
import requests

app = Flask(__name__)

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Elias Hive Intelligence</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #0a0a0a; color: white; margin: 0; padding: 0; }
        header { background: linear-gradient(90deg, #00c3ff, #0077ff); padding: 20px; text-align: center; font-size: 24px; }
        section { padding: 20px; }
        .btn { background: #0077ff; padding: 10px 20px; color: white; border: none; margin-top: 20px; cursor: pointer; }
        .card { background: #1a1a1a; margin: 20px 0; padding: 20px; border-radius: 10px; }
    </style>
</head>
<body>
    <header>Elias Hive Intelligence Dashboard</header>
    <section>
        <h2>Live Insights</h2>
        {% if insights %}
            {% for insight in insights %}
                <div class="card">
                    <pre>{{ insight | tojson(indent=2) }}</pre>
                </div>
            {% endfor %}
        {% else %}
            <p>No insights found.</p>
        {% endif %}
        
        <h2>Urgent Tasks</h2>
        {% if tasks %}
            {% for task in tasks %}
                <div class="card">
                    <strong>{{ task.get('task', 'No task') }}</strong> (Priority {{ task.get('priority', '?') }})
                </div>
            {% endfor %}
        {% else %}
            <p>No urgent tasks found.</p>
        {% endif %}
        
        <form action="/start" method="post">
            <button type="submit" class="btn">GET STARTED</button>
        </form>
    </section>
</body>
</html>
"""

@app.route('/', methods=['GET'])
def dashboard():
    insights = []
    tasks = []
    try:
        insights_resp = requests.get('http://localhost:5050/insights', timeout=5)
        if insights_resp.status_code == 200:
            insights = insights_resp.json().get('insights', [])
    except Exception:
        pass
    try:
        tasks_resp = requests.get('http://localhost:5050/tasks', timeout=5)
        if tasks_resp.status_code == 200:
            tasks = tasks_resp.json().get('urgent_tasks', [])
    except Exception:
        pass
    return render_template_string(HTML_TEMPLATE, insights=insights, tasks=tasks)

@app.route('/start', methods=['POST'])
def start_now():
    return "<h1>✅ You pressed Get Started! [Expansion Mode Coming Soon]</h1>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
