#!/bin/bash
S3_ENDPOINT="http://localhost:9000"
S3_ACCESS_KEY="testuser"
S3_SECRET_KEY="testpassword"
S3_BUCKET="test-bucket"
POSTGRESQL_SERVICE_HOST="localhost"
POSTGRES_PORT=5432
POSTGRESQL_USER="testuser"
POSTGRESQL_PASSWORD="testpassword"
POSTGRESQL_DATABASE="testdb"
EXPORTED_TABLES="table1 table2"
ENVIRONMENT="test"

# -- AWS configuration to work with Minio
aws configure set aws_access_key_id "$S3_ACCESS_KEY"
aws configure set aws_secret_access_key "$S3_SECRET_KEY"

# --- Functions ---
test_s3() {
  echo "--- Testing S3 (minio) ---"

  # Create bucket (ignore if it already exists)
  aws s3 mb "s3://$S3_BUCKET" --endpoint-url="$S3_ENDPOINT" || true

  # Check if a file exists in S3
  s3_file_exists() {
    local bucket="$1"
    local key="$2"
    aws s3 ls "s3://${bucket}/${key}" --endpoint-url="$S3_ENDPOINT" > /dev/null 2>&1
    return $?
  }
}

test_egress_functionality() {
  echo "--- Testing egress functionality ---"
  # Run the egress image, simulating the cronjob
  echo "Running the egress image..."
  docker run --rm --network="host" \
    -e EXPORTED_TABLES="$EXPORTED_TABLES" \
    -e S3_BUCKET="$S3_BUCKET" \
    -e ENVIRONMENT="$ENVIRONMENT" \
    -e POSTGRESQL_SERVICE_HOST="$POSTGRESQL_SERVICE_HOST" \
    -e POSTGRESQL_USER="$POSTGRESQL_USER" \
    -e POSTGRESQL_DATABASE="$POSTGRESQL_DATABASE" \
    -e POSTGRESQL_PASSWORD="$POSTGRESQL_PASSWORD" \
    -e S3_ACCESS_KEY="$S3_ACCESS_KEY" \
    -e S3_SECRET_KEY="$S3_SECRET_KEY" \
    -e S3_ENDPOINT="$S3_ENDPOINT" \
    "$EGRESS_IMAGE" sh -c '
      pipenv run aws configure set aws_access_key_id "$S3_ACCESS_KEY"
      pipenv run aws configure set aws_secret_access_key "$S3_SECRET_KEY"

      for table in $EXPORTED_TABLES; do
        echo "Table ${table}: Data collection started.";
        PGPASSWORD="'"$POSTGRESQL_PASSWORD"'" psql -h $POSTGRESQL_SERVICE_HOST -U $POSTGRESQL_USER -d $POSTGRESQL_DATABASE -c "COPY $table TO STDOUT CSV HEADER" |
        pipenv run aws s3 cp - s3://${S3_BUCKET}/${ENVIRONMENT}/${table}/historic/$(date -I)-${table}.csv --endpoint-url="$S3_ENDPOINT";
        pipenv run aws s3 cp s3://${S3_BUCKET}/${ENVIRONMENT}/${table}/historic/$(date -I)-${table}.csv s3://${S3_BUCKET}/${ENVIRONMENT}/${table}/latest/full_data.csv --endpoint-url="$S3_ENDPOINT";
        echo "Table ${table}: Dump uploaded to intermediate storage.";
      done;
    '

  # Verify that the files were created in S3
  echo "--- Verifying files in S3 ---"
  TABLES_ARRAY=($(echo "$EXPORTED_TABLES" | tr ' ' '\n'))
  for table in "${TABLES_ARRAY[@]}"; do
    historic_file="s3://${S3_BUCKET}/${ENVIRONMENT}/${table}/historic/$(date -I)-${table}.csv"
    latest_file="s3://${S3_BUCKET}/${ENVIRONMENT}/${table}/latest/full_data.csv"

    echo "Checking for historic file: $historic_file"
    if test_s3_file_exists "${ENVIRONMENT}/${table}/historic/$(date -I)-${table}.csv"; then
      echo "Historic file for table $table found."
    else
      echo "Error: Historic file for table $table not found."
      return 1
    fi

    echo "Checking for latest file: $latest_file"
    if test_s3_file_exists "${ENVIRONMENT}/${table}/latest/full_data.csv"; then
      echo "Latest file for table '$table' found."
    else
      echo "Error: Latest file for table $table not found."
      return 1
    fi
  done

  echo "Egress functionality test passed."
}

# Helper function to check if an S3 file exists
test_s3_file_exists() {
  local key="$1"
  echo aws s3 ls "s3://$S3_BUCKET/${key}" --endpoint-url="$S3_ENDPOINT"
  aws s3 ls "s3://$S3_BUCKET/${key}" --endpoint-url="$S3_ENDPOINT" > /dev/null 2>&1
  return $?
}

# --- Main ---

test_s3
test_egress_functionality