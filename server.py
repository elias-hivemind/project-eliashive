from fastapi import FastAPI
from fastapi.responses import HTMLResponse

app = FastAPI()

@app.get("/", response_class=HTMLResponse)
def root():
    return """
    <html>
        <head><title>Nova Core</title></head>
        <body style='font-family:sans-serif; background:#111; color:#0ff; text-align:center; padding-top:40px;'>
            <h1>🛡️ Nova Core is Live</h1>
            <p>Welcome to your FastAPI-powered Guardian system.</p>
        </body>
    </html>
    """
