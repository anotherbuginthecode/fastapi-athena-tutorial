#!/bin/bash

# CLI ARGS
TUTORIAL_NAME=fastapi-athena-tutorial
S3BUCKET=$TUTORIAL_NAME-$(openssl rand -hex 4)
AWS_REGION=$1
GLUE_DATABASE=$TUTORIAL_NAME-db
GLUE_CRAWLER=$TUTORIAL_NAME-crawler
IAM_ROLE=AWSGLUServiceRole-FastAPIAthenaGlue-Tutorial

echo "📣 Creating S3 bucket \"$S3BUCKET\" in $AWS_REGION"
aws s3api create-bucket --bucket $S3BUCKET \
    --region $AWS_REGION \
    --acl private \
    --create-bucket-configuration LocationConstraint=$AWS_REGION

echo "📣 Creating base folders structure (database, athena)"
aws s3api put-object --bucket $S3BUCKET --key database/ > /dev/null
aws s3api put-object --bucket $S3BUCKET --key athena/ > /dev/null

echo "📣 Uploading movies.csv file into database folder"
aws s3 cp ../data/movies.csv s3://$S3BUCKET/database/movies/movies.csv 

echo "📣 Creating IAM Role \"$IAM_ROLE\" to use Glue Crawler"
aws iam create-role --role-name $IAM_ROLE --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "glue.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}'

aws iam attach-role-policy --role-name $IAM_ROLE --policy-arn arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole

aws iam put-role-policy --role-name $IAM_ROLE --policy-name AWSGLUServiceRole-FastAPIAthena-Tutorial-S3Policy --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::'"$S3BUCKET"'/database/movies/*"
            ]
        }
    ]
}'

echo "📣 Creating database \"$GLUE_DATABASE\" in Glue"
aws glue create-database --database-input Name=$GLUE_DATABASE

echo "📣 Creating the crawler \"$GLUE_CRAWLER\" in Glue"
aws glue create-crawler --name $GLUE_CRAWLER \
  --role $(aws iam get-role --role-name $IAM_ROLE | jq -r '.Role.Arn') \
  --database-name $GLUE_DATABASE \
  --targets '{"S3Targets": [{"Path": "s3://'"$S3BUCKET"'/database/movies/"}]}'

echo "📣 Starting the crawler \"$GLUE_CRAWLER\""
aws glue start-crawler --name $GLUE_CRAWLER

echo "📣 Creating a config.txt file. It will use to clean up the tutorial using the script clean-aws.sh"
if [ -f "./config.txt" ]; then
    rm "./config.txt"
fi

cat <<EOF >>config.txt
S3BUCKET=$S3BUCKET
AWS_REGION=$1
GLUE_DATABASE=$TUTORIAL_NAME-db
GLUE_CRAWLER=$TUTORIAL_NAME-crawler
IAM_ROLE=AWSGLUServiceRole-FastAPIAthenaGlue-Tutorial
IAM_POLICY_NAME=AWSGLUServiceRole-FastAPIAthena-Tutorial-S3Policy
EOF

echo "📣 Creating .env file in root folder. Fill the missing variables before start FastAPI."
if [ -f "../.env" ]; then
    rm "../.env"
fi

cat <<EOF >>../.env
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=
ATHENA_S3_OUTPUT_LOCATION='s3://$S3BUCKET/athena'
EOF