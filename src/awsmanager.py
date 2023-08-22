import boto3
import time
from typing import TypedDict, Optional, List, Dict, Unpack
import os
from jinjasql import JinjaSql
from dotenv import load_dotenv

load_dotenv()


class AWSAthena:
    def __init__(self, database):
        self.aws_access_key_id = os.environ.get("AWS_ACCESS_KEY_ID")
        self.aws_secret_access_key = os.environ.get("AWS_SECRET_ACCESS_KEY")
        self.aws_region = os.environ.get("AWS_REGION")
        self.database = database

        try:
            # Create an Athena client
            self.client = boto3.client(
                "athena",
                aws_access_key_id=self.aws_access_key_id,
                aws_secret_access_key=self.aws_secret_access_key,
                region_name=self.aws_region,
            )
        except Exception as e:
            raise e

    def query_builder(self, sql_file: str, params: dict):
        j = JinjaSql()
        if os.path.exists(sql_file):
            sql_template = open(sql_file).read()
            query, bind_params = j.prepare_query(sql_template, params)
            return query, bind_params
        else:
            raise FileNotFoundError

    def execute(self, query: str):
        # Start the query execution
        response = self.client.start_query_execution(
            QueryString=query,
            QueryExecutionContext={"Database": self.database},
            ResultConfiguration={
                "OutputLocation": os.environ.get("ATHENA_S3_OUTPUT_LOCATION")
            },
        )

        # Get the query execution ID
        query_execution_id = response["QueryExecutionId"]

        # Poll for query status
        while True:
            query_status = self.client.get_query_execution(
                QueryExecutionId=query_execution_id
            )
            status = query_status["QueryExecution"]["Status"]["State"]

            if status in ["SUCCEEDED", "FAILED", "CANCELLED"]:
                break

            time.sleep(2)

        # Check if the query was successful
        if status == "SUCCEEDED":
            # Get query results
            result_response = self.client.get_query_results(
                QueryExecutionId=query_execution_id
            )

            # Process and print results
            # for row in result_response['ResultSet']['Rows']:
            #     print([field['VarCharValue'] for field in row['Data']])
            return self.parse(result=result_response["ResultSet"]["Rows"])
        else:
            print(f"Query execution {query_execution_id} failed with status: {status}")
            return None

    def parse(self, result: list):
        # the column names are always in position 0
        columns = [field["VarCharValue"] for field in result[0]["Data"]]

        output = []
        for index, row in enumerate(result):
            if index == 0:
                continue  # Skip the first row
            tmp = {}
            for j, data in enumerate(row["Data"]):
                tmp.update({columns[j]: data["VarCharValue"]})
            output.append(tmp)

        # assert to verify that everything works fine
        assert len(result) - 1 == len(output)
        return output
