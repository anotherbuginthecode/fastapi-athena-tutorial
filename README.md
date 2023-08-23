# FastAPI + Athena

This experimental repository aims to leverage the power of FastAPI and AWS Athena to analyze data stored in CSV files within an S3 bucket.

The CSV data used for this experiment is taken from [here](https://gist.github.com/tiangechen/b68782efa49a16edaf07dc2cdaa855ea).

(I have to be honest, I didn't spend too much time deciding on which data to use for this experiment. As a movie lover, I simply Googled "movies CSV file download" and found this dataset. 😅)

For more information about the project, I invite you to read the article I published on medium [_Level Up Your Data Game with FastAPI and Athena_](https://medium.com/@anotherbuginthecode/level-up-your-data-game-with-fastapi-and-athena-cd7f3ccf7bff)

**Prerequisites**

having a basic grasp of FastAPI will make your ride smoother. Also, ensure that you have an AWS Account with the appropriate permissions for AWS S3, AWS Athena, AWS Glue, and AWS CLI installed on your computer.

**Additional Notes**: The Python part was built using Poetry as a dependencies manager, and Poe as a task runner. I leave here the link to install and explore them!

## How to use this repository

### Setup the AWS Environment

To completely setup your AWS enviroment, go inside the `scripts` folder and run the script `start-aws.sh` followed by the AWS region where you want to deploy the all necessary resources.

```bash
cd scripts
bash start-aws.sh eu-west-1
```

**Prerequisites**: to execute the script correctly be sure to have the aws-cli installed and configured, and jq installed.

The script will perform the following actions in your AWS Account:

1. Create an S3 bucket with the name like `fastapi-athena-tutorial-7346d3ba`.
2. Create a basic folder structure inside the bucket:
   - **athena**: this is where the query results returned by Athena will be stored as CSV\
   - **database**: this is where the "movies" table will be created. IMHO, when working with Glue, it is recommended to keep the folder structure in a database-like style database-name/table-name/data.csv.
3. Upload the CSV file inside data/movies.csv into **database/movies/**.
4. Create an IAM ROLE named `AWSGLUEServiceRole-FastAPIAthenaGlue-Tutorial` to attach to the crawler in order to generate the data catalog.
5. Create a Glue Data Catalog database called `fastapi-athena-tutorial-db`.
6. Create a Glue Crawler called `fastapi-athena-tutorial-crawler`.
7. Run the crawler.
8. Create a `config.txt` file to keep track of the resources created, which will be used by the clean script to remove them all.
9. Create a `.env` file in the root folder with all the necessary environment variables to run the FastAPI backend (NB: Before moving into FastAPI, make sure to fill in the missing variables).

### Install the necessary dependencies

Once the AWS Environment is ready, you need to start the FastAPI backend. First things first, you need to install all the necessary dependecies. Here, poetry comes in our help.\
In the root of the project run the command: `poetry install`

### Start FastAPI

To start FastAPI execute the commnad: `poe start`. It will start the FastAPI application under `localhost:8000`.

Then you can start to perform some curl like:

```bash
curl 'localhost:8000/api/v1/movies/metrics/studios-with-highest-profit'
curl 'localhost:8000/api/v1/movies/metrics/avg-profitability-by-genres'
curl 'localhost:8000/api/v1/movies/metrics/top-10-movies-rotten?filters=film,lead%20studio'
```

To stop the application just type `ctrl+c` in the current terminal window.

### Clean the AWS Enviroment

Once finished with the experiment, you can delete all related AWS resources created by executing the bash script under the `scripts/clean-aws.sh`. The script will take all the cleaning operations for you.

```bash
cd scripts
bash clean-aws.sh
```
