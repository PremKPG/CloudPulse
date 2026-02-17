from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"status": "CloudPulse API is Online"}

@app.get("/health")
def health_check():
    return {"health": "OK", "version": "1.0.0"}