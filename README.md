rhsm-subscriptions-egress
-------------------------

Dockerfile for RHEL-based build of the service started in https://github.com/tumido/egress

Note that anywhere the `aws` command is is needed, it should be run as `pipenv run aws`.

If you wish to use the environment locally, you can use the included `Pipfile/Pipfile.lock`, as long as the local environment has a Python 3.6 interpreter available (`pipenv sync`)

Deploy to Openshift
-------------------

Prerequisite secrets:

- `swatch-tally-db`: DB connection info, having `db.host`, `db.port`, `db.user`, `db.password`, and `db.name` properties.
- `egress-s3`: secret with having `access_key`, `secret_key`, and `bucket`.

```
oc process -f templates/rhsm-subscriptions-egress.yaml | oc create -f -
```

Test Locally
-------------

0. Be logged to https://access.redhat.com/articles/RegistryAuthentication 
1. Generate image: `./build_deploy.sh`

Example:

```
✔ Successfully created virtual environment! 
Virtualenv location: /var/lib/pgsql/.local/share/virtualenvs/src-dqYAXZ28
Installing dependencies from Pipfile.lock (94bc2a)...
To activate this project's virtualenv, run pipenv shell.
Alternatively, run a command inside the virtualenv with pipenv run.
All dependencies are now up-to-date!
--> b07cf440e62f
STEP 7/8: USER 1001
--> cfce7cb029bd
STEP 8/8: CMD /bin/bash
COMMIT quay.io/cloudservices/rhsm-subscriptions-egress:abffc03
--> c51e6715032d
Successfully tagged quay.io/cloudservices/rhsm-subscriptions-egress:abffc03
```

And export the image to be tested:

```
export EGRESS_IMAGE=quay.io/cloudservices/rhsm-subscriptions-egress:abffc03
```

2. Start Up Postgresql (with some tables and data) and Minio to mock S3: `docker compose -f tests/docker-compose.yml up -d`
3. Run tests: `./run-test.sh`

Expected output:

```
--- Verifying files in S3 ---
Checking for historic file: s3://test-bucket/test/table1/historic/2025-05-20-table1.csv
aws s3 ls s3://test-bucket/test/table1/historic/2025-05-20-table1.csv --endpoint-url=http://localhost:9000
Historic file for table table1 found.
Checking for latest file: s3://test-bucket/test/table1/latest/full_data.csv
aws s3 ls s3://test-bucket/test/table1/latest/full_data.csv --endpoint-url=http://localhost:9000
Latest file for table 'table1' found:
Checking for historic file: s3://test-bucket/test/table2/historic/2025-05-20-table2.csv
aws s3 ls s3://test-bucket/test/table2/historic/2025-05-20-table2.csv --endpoint-url=http://localhost:9000
Historic file for table table2 found.
Checking for latest file: s3://test-bucket/test/table2/latest/full_data.csv
aws s3 ls s3://test-bucket/test/table2/latest/full_data.csv --endpoint-url=http://localhost:9000
Latest file for table 'table2' found:
Egress functionality test passed.
```