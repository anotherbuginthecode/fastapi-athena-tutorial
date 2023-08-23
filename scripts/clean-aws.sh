#!/bin/bash

file_path="./config.txt"  # Replace with the actual file path

# Check if the file exists
if [ -f "$file_path" ]; then
    # Read each line and extract variables
    while IFS='=' read -r key value; do
        if [ -n "$key" ] && [ -n "$value" ]; then
            export "$key"="$value"
        fi
    done < "$file_path"
else
    echo "File does not exist."
fi



echo "❌ Deleting S3 Bucket \"$S3BUCKET\""
aws s3 rb s3://$S3BUCKET --force > /dev/null


echo "❌ Deleting \"$GLUE_DATABASE\" database and tables in Glue"

# List tables in the database
tables=$(aws glue get-tables --database-name $GLUE_DATABASE --query 'TableList[].Name' --output text)

# Loop through the tables and delete them
for table in $tables; do
    aws glue delete-table --database-name $GLUE_DATABASE --name "$table"
done

aws glue delete-database --name $GLUE_DATABASE

echo "❌ Deleting \"$GLUE_CRAWLER\" in Glue"
aws glue delete-crawler --name $GLUE_CRAWLER

echo "❌ Deleting \"$IAM_ROLE\" IAM Role"
attached_policies=$(aws iam list-attached-role-policies --role-name $IAM_ROLE --query 'AttachedPolicies[].PolicyArn' --output text)

for policy_arn in $attached_policies; do
    aws iam detach-role-policy --role-name $IAM_ROLE --policy-arn $policy_arn
done

aws iam delete-role-policy --role-name $IAM_ROLE --policy-name $AWS_IAM_ROLE_GLUE_POLICY_NAME

aws iam delete-role --role-name $IAM_ROLE
