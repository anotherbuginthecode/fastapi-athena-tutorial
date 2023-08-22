from fastapi import FastAPI
from .routes.movies import movies

app = FastAPI()


@app.get("/ping")
def ping():
    return {"message": "pong"}


app.include_router(movies.router)
