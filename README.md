rhsm-subscriptions-egress
-------------------------

Dockerfile for RHEL-based build of the service started in https://github.com/tumido/egress

The image ships `aws` on `PATH` (awscli from a pinned `requirements.txt`). CronJob
templates invoke `aws` directly.

Build
----------------------

Refresh the pip lockfile after changing `requirements.in`:

```bash
./scripts/refresh-requirements.sh
```

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

0. Be logged in to https://access.redhat.com/articles/RegistryAuthentication
   (`podman login registry.redhat.io`) — the runtime base is
   `registry.redhat.io/rhel9/postgresql-13`.
1. Generate image: `./scripts/build-local.sh` (or `./build_deploy.sh`)

Example:

```
==> Building rhsm-subscriptions-egress:local with podman (Dockerfile)
...
Successfully tagged localhost/rhsm-subscriptions-egress:local
```

And export the image to be tested:

```
export EGRESS_IMAGE=localhost/rhsm-subscriptions-egress:local
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
