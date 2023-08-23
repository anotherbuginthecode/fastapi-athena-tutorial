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


@router.get("/metrics/top-10-movies-rotten")
async def get_top_10_movies_rotten(filters: str | None = Query(None)):
    params_dict: dict = {"filters": filters.split(",")}
    sql_file = os.path.join(ROOT_FOLDER, "src/sql/movies/get_top_10_movies_rotten.sql")
    query, _ = athena.query_builder(sql_file, params_dict)
    result = athena.execute(query=query)
    return result


@router.get("/metrics/avg-profitability-by-genres")
async def avg_profitability_by_genres():
    sql_file = os.path.join(
        ROOT_FOLDER, "src/sql/movies/avg_profitability_by_genres.sql"
    )
    query, _ = athena.query_builder(sql_file)
    result = athena.execute(query=query)
    return result


@router.get("/metrics/studios-with-highest-profit")
async def studios_with_highest_profit():
    sql_file = os.path.join(
        ROOT_FOLDER, "src/sql/movies/studios_with_highest_profits.sql"
    )
    query, _ = athena.query_builder(sql_file)
    result = athena.execute(query=query)
    return result
