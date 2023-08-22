from fastapi import APIRouter, Query
import os
from ...awsmanager import AWSAthena


athena = AWSAthena(database="fastapi-athena-tutorial-db")
ROOT_FOLDER = os.getcwd()

router = APIRouter(
    prefix="/api/v1/movies",
    tags=["movies"],
    responses={
        404: {"description": "Not found"},
        500: {"description": "Internal Error"},
    },
)


@router.get("")
def get_movie_info(movie: str = None, filters: list[str] = Query(None)):
    params: dict = {"table": "movies", "movie": movie, "filters": filters}
    sql_file = os.path.join(ROOT_FOLDER, "src/sql/get_movie.sql")
    query, params = athena.query_builder(sql_file, params)
    result = athena.execute(query=query)
    return result


@router.get("/genre/{genre}")
def get_movies_by_genre(genre: str, filters: list[str] | None = None):
    params: dict = {"table": "movies", "genre": genre, "filters": filters}
    sql_file = os.path.join(ROOT_FOLDER, "src/sql/get_movies_by_genre.sql")
    query, params = athena.query_builder(sql_file, params)
    result = athena.execute(query=query)
    return result


@router.get("/metrics/top-10-movies-rotten")
async def get_top_10_movies_rotten(filters: list[str] | None = None):
    params: dict = {"table": "movies", "filters": filters}
    sql_file = os.path.join(ROOT_FOLDER, "src/sql/get_top_10_movies_rotten.sql")
    query, params = athena.query_builder(sql_file, params)
    result = athena.execute(query=query)
    return result
